require_relative 'actor.rb'

require_relative 'collision.rb'

class Polygon < Actor
  def initialize(window)
    super(window)
    @vertices = [
      Vector[0, 0, 0],
      Vector[1, 0, 0],
      Vector[1, 1, 0],
      Vector[0, 1, 0]
    ]
  end
  
  def get_vertices
    @vertices.dup
  end
  
  def set_vertices(vertices)
    unless vertices.is_a?(Array) && vertices.length >= 3 && vertices.reject { |v| v.is_a?(Vector) && v.size == 3 }.empty?
      raise ArgumentError.new("set_vertices() expects an array of at least three 3D Vectors")
    end
    @vertices.replace(vertices)
  end
  
  def get_global_vertices
    tf = get_global_transform
    @vertices.map { |v| Transform.transform_point(tf, v) }
  end
  
  def render(matrix)
    global_vertices = @vertices.map { |v| Transform.transform_point(matrix, v) }
    i = 2
    while i < global_vertices.length
      v0 = global_vertices[0]
      v1 = global_vertices[i-1]
      v2 = global_vertices[i]
      @window.draw_triangle(
        v0[0].to_f, v0[1].to_f, @color,
        v1[0].to_f, v1[1].to_f, @color,
        v2[0].to_f, v2[1].to_f, @color,
      )
      i += 1
    end
  end
  
  def is_point_in_bounds(point)
    Collision.is_point_in_shape?(point, self)
  end
end