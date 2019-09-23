require_relative 'lib/game_window.rb'

# A simple game to showcase and test Gosling. Shoot enemy ships! Dodge bullets and indestructible asteroids!
#
# Controls:
#     left and right arrows: move your ship
#     space: shoot bullets
#     escape: quit the game

$debug_show_collision_masks = false
$enable_type_checking = false

if __FILE__ == $PROGRAM_NAME
  window = GameWindow.new(1024, 768, false)
  window.show
end
