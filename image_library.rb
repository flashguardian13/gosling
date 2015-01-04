require 'singleton'

class ImageLibrary
  @@window = nil
  @@cache = {}
  
  include Singleton
  
  def self.window=(window)
    @@window = window
  end
  
  def self.get(filename)
    raise RuntimeError.new("ImageLibrary requires a window to load images") unless @@window
    raise ArgumentError.new("File not found: '#{filename}' in '#{Dir.pwd}'") unless File.exists?(filename)
    unless @@cache.has_key?(filename)
      @@cache[filename] = Gosu::Image.new(@@window, filename, true)
    end
    @@cache[filename]
  end
end
