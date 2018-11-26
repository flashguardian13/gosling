require_relative 'polygon.rb'

module Gosling
  ##
  # A Rect is a Polygon with exactly four vertices, defined by a width and height, with sides at right angles to one
  # another. The width and height can be modified at runtime; all vertices will be updated automatically.
  #
  class Rect < Polygon
    attr_reader :width, :height

    ##
    # Creates a new Rect with a width and height of 1.
    #
    def initialize(window)
      super(window)
      @width = 1
      @height = 1
      rebuild_vertices
    end

    def width=(val)
      raise ArgumentError.new("set_width() expects a positive, non-zero number") if val <= 0
      @width = val
      rebuild_vertices
    end

    def height=(val)
      raise ArgumentError.new("set_height() expects a positive, non-zero number") if val <= 0
      @height = val
      rebuild_vertices
    end

    private

    def rebuild_vertices
      vertices = [
        Snow::Vec3[     0,       0, 0],
        Snow::Vec3[@width,       0, 0],
        Snow::Vec3[@width, @height, 0],
        Snow::Vec3[     0, @height, 0],
      ]
      set_vertices(vertices)
    end

    private :set_vertices
  end
end
