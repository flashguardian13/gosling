require 'singleton'

module Gosling
  ##
  # A cached Gosu::Image repository.
  #
  class ImageLibrary
    @@cache = {}

    include Singleton

    ##
    # When passed the path to an image, it first checks to see if that image is in the cache. If so, it returns the cached
    # Gosu::Image. Otherwise, it loads the image, stores it in the cache, and returns it.
    #
    def self.get(filename)
      unless @@cache.has_key?(filename)
        raise ArgumentError.new("File not found: '#{filename}' in '#{Dir.pwd}'") unless File.exists?(filename)
        @@cache[filename] = Gosu::Image.new(filename, tileable: true)
      end
      @@cache[filename]
    end
  end
end
