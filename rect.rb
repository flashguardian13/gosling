require_relative 'polygon.rb'

class Rect < Polygon
  attr_reader :width, :height
  
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
  
  def rebuild_vertices
    vertices = [
      Vector[     0,       0, 0],
      Vector[@width,       0, 0],
      Vector[@width, @height, 0],
      Vector[     0, @height, 0],
    ]
    set_vertices(vertices)
  end
  
  private :set_vertices
end