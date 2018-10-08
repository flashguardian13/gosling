require 'singleton'

module Gosling
  class ImageLibrary
    @@cache = {}

    include Singleton

    def self.get(filename)
      raise ArgumentError.new("File not found: '#{filename}' in '#{Dir.pwd}'") unless File.exists?(filename)
      unless @@cache.has_key?(filename)
        @@cache[filename] = Gosu::Image.new(filename, tileable: true)
      end
      @@cache[filename]
    end
  end
end
