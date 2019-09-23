require 'gosling'

require_relative 'game_piece.rb'
require_relative 'particle_effect.rb'

class GameWindow < Gosu::Window
  # Constants

  DEFAULT_MILLISECONDS_PER_FRAME = 1000.0 / 60

  PLAYER_VELOCITY = 200
  PLAYER_PROJECTILE_VELOCITY = 300
  ENEMY_VELOCITY = 100
  ENEMY_PROJECTILE_VELOCITY = 200
  ASTEROID_VELOCITY = 50

  ENEMY_SPAWN_TIME = 7
  ASTEROID_SPAWN_TIME = 20
  ENEMY_SHOOT_TIME = 3
  RESPAWN_TIME = 5
  SPAWN_IMMUNITY_DURATION = 3

  COLLISION_CHART = {
    :asteroids => {
      :asteroids =>      true,
      :enemy_shots =>    true,
      :enemy_ships =>    true,
      :friendly_shots => true,
      :friendly_ships => true,
    },
    :enemy_shots => {
      :enemy_shots =>    false,
      :enemy_ships =>    false,
      :friendly_shots => true,
      :friendly_ships => true,
    },
    :enemy_ships => {
      :enemy_ships =>    false,
      :friendly_shots => true,
      :friendly_ships => true,
    },
    :friendly_shots => {
      :friendly_shots => false,
      :friendly_ships => false,
    },
    :friendly_ships => {
      :friendly_ships => false,
    },
  }

  # Initialization

  def initialize(width, height, fullscreen, caption = "Shooter Demo", update_interval = DEFAULT_MILLISECONDS_PER_FRAME)
    super(width, height, fullscreen, update_interval)
    self.caption = caption

    @cursor = Gosling::ImageLibrary.get(File.expand_path('../images/cursor.png', File.dirname(__FILE__)))
    @cursor_x = width / 2
    @cursor_y = height / 2

    calculate_asteroid_spawn_points(width, height)

    @stage = Gosling::Actor.new(self)

    @game_pieces = []
    @player_projectiles = []
    @enemy_ships = []
    @enemy_projectiles = []
    @asteroids = []
    @particle_effects = []

    spawn_player

    reset_enemy_spawn_timer
    reset_enemy_shoot_timer
    reset_asteroid_timer
    @respawn_timer = 0.0

    update_player_velocity
  end

  def calculate_asteroid_spawn_points(width, height)
    @asteroid_spawn_points = [
      Snow::Vec3[-64, height / 4, 0],
      Snow::Vec3[-64, height / 8, 0],
      Snow::Vec3[-64, 0, 0],
      Snow::Vec3[-64, -64, 0],
      Snow::Vec3[width * 0, -64, 0],
      Snow::Vec3[width / 9, -64, 0],
      Snow::Vec3[width * 2 / 9, -64, 0],
      Snow::Vec3[width * 3 / 9, -64, 0],
      Snow::Vec3[width * 4 / 9, -64, 0],
      Snow::Vec3[width * 5 / 9, -64, 0],
      Snow::Vec3[width * 6 / 9, -64, 0],
      Snow::Vec3[width * 7 / 9, -64, 0],
      Snow::Vec3[width, -64, 0],
      Snow::Vec3[width + 64, -64, 0],
      Snow::Vec3[width + 64, 0, 0],
      Snow::Vec3[width + 64, height / 8, 0],
      Snow::Vec3[width + 64, height / 4, 0],
    ]
  end

  # Gosu::Window event-driven methods

  def update
		@cursor_x = mouse_x
		@cursor_y = mouse_y

    cur_time = Time.now
    elapsed = @prev_time ? cur_time - @prev_time : DEFAULT_MILLISECONDS_PER_FRAME / 1000.0
    @prev_time = cur_time

    move_game_pieces(elapsed)

    remove_offscreen_actors

    update_particle_effects(elapsed)

    update_timers(elapsed)

    do_collision_tests
  end

  def draw
    @stage.draw
  end

  def button_down(id)
    case id
    when Gosu::KbSpace
      fire_player_projectile unless @respawn_timer > 0 || @spawn_immunity > 0
    when Gosu::KbLeft
      @is_left_down = true
      update_player_velocity
    when Gosu::KbRight
      @is_right_down = true
      update_player_velocity
    when Gosu::KbEscape
      close
    end
  end

  def button_up(id)
    case id
    when Gosu::KbLeft
      @is_left_down = false
      update_player_velocity
    when Gosu::KbRight
      @is_right_down = false
      update_player_velocity
    end
  end

  private

  # Game timers

  def reset_enemy_spawn_timer
    @enemy_spawn_timer = ENEMY_SPAWN_TIME * 0.5 + rand() * ENEMY_SPAWN_TIME
  end

  def reset_enemy_shoot_timer
    @enemy_shoot_timer = ENEMY_SHOOT_TIME * 0.5 + rand() * ENEMY_SHOOT_TIME
  end

  def reset_asteroid_timer
    @asteroid_timer = ASTEROID_SPAWN_TIME * 0.5 + rand() * ASTEROID_SPAWN_TIME
  end

  def update_timers(elapsed)
    if @respawn_timer > 0
      @respawn_timer -= elapsed
      if @respawn_timer <= 0
        spawn_player
      end
    end

    if @enemy_spawn_timer > 0
      @enemy_spawn_timer -= elapsed
      if @enemy_spawn_timer <= 0
        reset_enemy_spawn_timer
        spawn_enemy
      end
    end

    if @enemy_shoot_timer > 0
      @enemy_shoot_timer -= elapsed
      if @enemy_shoot_timer <= 0
        reset_enemy_shoot_timer
        @enemy_ships.each { |ship| spawn_enemy_shot(ship) }
      end
    end

    if @asteroid_timer > 0
      @asteroid_timer -= elapsed
      if @asteroid_timer <= 0
        reset_asteroid_timer
        spawn_asteroid
      end
    end

    if @spawn_immunity > 0
      @spawn_immunity -= elapsed
      if @spawn_immunity <= 0
        @player.actor.alpha = 255
      else
        @player.actor.alpha = (Math.sin(@spawn_immunity * Math::PI * 2) + 1) * 128
      end
    end
  end

  # Game object creation and destruction

  def spawn_player
    @player = create_game_piece(:player, Snow::Vec3[width / 2, height * 4 / 5, 0])
    @spawn_immunity = SPAWN_IMMUNITY_DURATION
    update_player_velocity
  end

  def fire_player_projectile
    projectile = create_game_piece(:player_projectile, @player.actor.pos, Snow::Vec3[0, -PLAYER_PROJECTILE_VELOCITY, 0])
    @player_projectiles.push(projectile)
  end

  def spawn_enemy
    spawn_height = 64 + rand(128)
    if rand(2) == 0
      enemy = create_game_piece(:enemy, Snow::Vec3[0 - 32, spawn_height, 0], Snow::Vec3[ENEMY_VELOCITY, 0, 0])
    else
      enemy = create_game_piece(:enemy, Snow::Vec3[width + 32, spawn_height, 0], Snow::Vec3[-ENEMY_VELOCITY, 0, 0])
    end
    @enemy_ships.push(enemy)
  end

  def spawn_enemy_shot(ship)
    projectile = create_game_piece(:enemy_projectile, ship.actor.pos, Snow::Vec3[0, ENEMY_PROJECTILE_VELOCITY, 0])
    @enemy_projectiles.push(projectile)
  end

  def spawn_asteroid
    spawn_pos = @asteroid_spawn_points.sample
    heading = Snow::Vec3[width * 0.5, height * 0.5, 0] - spawn_pos
    theta = Math.atan2(heading[1], heading[0]) - Math::PI / 8 + rand() * Math::PI / 4
    heading = Snow::Vec3[Math.cos(theta), Math.sin(theta), 0] * ASTEROID_VELOCITY
    asteroid = create_game_piece(:asteroid, spawn_pos, heading)
    @asteroids.push(asteroid)
  end

  def create_game_piece(object_type, position = Snow::Vec3[0, 0, 0], velocity = Snow::Vec3[0, 0, 0])
    piece = GamePiece.new
    piece.velocity = velocity
    piece.actor = case object_type
    when :player
      piece.layer = :friendly_ships
      actor = Gosling::Polygon.new(self)
      actor.set_vertices([
        Snow::Vec3[0, -32, 0],
        Snow::Vec3[32, 32, 0],
        Snow::Vec3[-32, 32, 0]
      ])
      actor.color = Gosu::Color.rgba(0, 128, 0, 255)
      actor
    when :enemy
      piece.layer = :enemy_ships
      actor = Gosling::Rect.new(self)
      actor.width = 64
      actor.height = 64
      actor.center_x = 32
      actor.center_y = 32
      actor.color = Gosu::Color.rgba(128, 0, 0, 255)
      actor
    when :player_projectile
      piece.layer = :friendly_shots
      actor = Gosling::Circle.new(self)
      actor.radius = 8
      actor.color = Gosu::Color.rgba(0, 255, 0, 255)
      actor
    when :enemy_projectile
      piece.layer = :enemy_shots
      actor = Gosling::Circle.new(self)
      actor.radius = 8
      actor.color = Gosu::Color.rgba(255, 0, 0, 255)
      actor
    when :asteroid
      piece.layer = :asteroids
      actor = Gosling::Circle.new(self)
      actor.radius = 64
      actor.color = Gosu::Color.rgba(128, 128, 128, 255)
      actor
    else
      puts "Unrecognized game object type: '#{object_type}'"
    end
    piece.actor.pos = position
    @stage.add_child(piece.actor)
    @game_pieces.push(piece)
    piece
  end

  def remove_offscreen_actors
    @enemy_ships.dup.each do |ship|
      if ship.actor.x > width + ship.actor.width || ship.actor.x < 0 - ship.actor.width
        remove_game_piece(ship)
      end
    end

    @player_projectiles.dup.each do |projectile|
      if projectile.actor.y < 0 - projectile.actor.radius
        remove_game_piece(projectile)
      end
    end

    @enemy_projectiles.dup.each do |projectile|
      if projectile.actor.y > height + projectile.actor.radius
        remove_game_piece(projectile)
      end
    end

    @asteroids.dup.each do |asteroid|
      ax = asteroid.actor.x
      ay = asteroid.actor.y
      ar = asteroid.actor.radius
      if ax < 0 - ar || ax > width + ar || ay < 0 - ar || ay > height + ar
        remove_game_piece(asteroid)
      end
    end
  end

  def remove_game_piece(game_piece, show_particles = false)
    @stage.remove_child(game_piece.actor)
    @game_pieces.delete(game_piece)

    @enemy_ships.delete(game_piece)
    @player_projectiles.delete(game_piece)
    @enemy_projectiles.delete(game_piece)
    @asteroids.delete(game_piece)

    @respawn_timer = RESPAWN_TIME if game_piece == @player

    return unless show_particles

    severity = if game_piece.layer == :enemy_ships
                  5
                elsif game_piece == @player
                  7
                else
                  3
                end
    @particle_effects.push(ParticleEffect.new(self, @stage, game_piece.actor.pos, severity))
  end

  # Movement methods

  def update_player_velocity
    x_vel = @is_left_down ? -PLAYER_VELOCITY : (@is_right_down ? PLAYER_VELOCITY : 0)
    @player.velocity.x = x_vel
  end

  def move_game_pieces(elapsed)
    @game_pieces.each do |piece|
      piece.actor.pos += piece.velocity * elapsed
    end

    @player.actor.x = 0 + 32 if @player.actor.x < 0 + 32
    @player.actor.x = width - 32 if @player.actor.x > width - 32
  end

  def update_particle_effects(elapsed)
    @particle_effects.dup.each do |particles|
      particles.update(elapsed)
      @particle_effects.delete(particles) if particles.is_done?
    end
  end

  # Collision detection

  def do_collision_tests
    @game_pieces.each_index do |i|
      pieceA = @game_pieces[i]
      @game_pieces[(i + 1)..-1].each do |pieceB|
        layers = [pieceA.layer, pieceB.layer].sort
        next unless COLLISION_CHART[layers[0]][layers[1]]

        next if (pieceA == @player || pieceB == @player) && @spawn_immunity > 0

        if Gosling::Collision.test(pieceA.actor, pieceB.actor)
          if pieceA.layer == :asteroids && pieceB.layer == :asteroids
            pieceA.velocity, pieceB.velocity = pieceB.velocity, pieceA.velocity
          else
            remove_game_piece(pieceA, true) unless pieceA.layer == :asteroids
            remove_game_piece(pieceB, true) unless pieceB.layer == :asteroids
          end
        end
      end
    end
  end

end
