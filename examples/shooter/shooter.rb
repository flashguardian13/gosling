require_relative 'lib/game_window.rb'

require 'ruby-prof'
require 'time'

# A simple game to showcase and test Gosling. Shoot enemy ships! Dodge bullets and indestructible asteroids!
#
# Controls:
#     left and right arrows: move your ship
#     space: shoot bullets
#     escape: quit the game

if __FILE__ == $PROGRAM_NAME
  window = GameWindow.new(1024, 768, false)

  profile = RubyProf::Profile.new
  profile.exclude_common_methods!

  profile.start
  window.show
  result = profile.stop

  printer = RubyProf::GraphHtmlPrinter.new(result)
  commit = ''
  timestamp = Time.now.strftime("%F-%T").gsub(/\D/, '-')
  File.open(File.join(File.dirname(__FILE__), "profile-graphs-#{commit}-#{timestamp}.html"), 'w') do |f|
    printer.print(f, :min_percent => 1)
  end
end
