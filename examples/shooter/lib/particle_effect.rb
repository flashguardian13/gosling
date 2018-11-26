class Particle
  attr_reader :actor

  def initialize(window, start_pos, severity)
    @actor = Gosling::Circle.new(window)
    @actor.radius = @start_radius = severity * 5
    @actor.color = Gosu::Color.rgba(255, 255, 255, 255)
    @actor.pos = start_pos

    angle = Math::PI * 2 * rand()
    @velocity = Snow::Vec3[Math.cos(angle) * 100, Math.sin(angle) * 100, 0]

    @age = 0.0
    @lifespan = severity * 0.2
  end

  def update(elapsed)
    return if is_done?

    @age += elapsed
    if is_done?
      @actor.is_visible = false
      return
    end

    @actor.pos += @velocity * elapsed

    scalar = @age / @lifespan
    @actor.radius = @start_radius * (1.0 - scalar)
    @actor.alpha = 255 * (1.0 - scalar)
  end

  def is_done?
    @age >= @lifespan
  end
end

class ParticleEffect
  def initialize(window, stage, start_pos, severity = 3)
    @stage = stage
    @particles = []
    severity.times do
      particle = Particle.new(window, start_pos, severity)
      @particles.push(particle)
      @stage.add_child(particle.actor)
    end
  end

  def update(elapsed)
    @particles.dup.each do |particle|
      particle.update(elapsed)
      if particle.is_done?
        @particles.delete(particle)
        @stage.remove_child(particle.actor)
      end
    end
  end

  def is_done?
    @particles.empty?
  end
end