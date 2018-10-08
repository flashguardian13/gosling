require 'singleton'

module Gosling
  class TextRenderer
    @@window = nil

    include Singleton

    def self.window=(window)
      @@window = window
    end

    def self.render(text, options = {})
      raise InitializationError.new('TextRenderer has not been made aware of a window yet!') unless @@window

      unexpected_options = options.keys - [:font, :font_size]
      raise ArgumentError.new("Unexpected options: #{unexpected_options.join(', ')}") unless unexpected_options.empty?

      font = options[:font] || 'Geneva'
      font_size = options[:font_size] || 16

      image = Gosu::Image.from_text(@@window, text, font, font_size)
      image
    end
  end
end
