require_relative 'actor.rb'
require_relative 'collision.rb'
require_relative 'utils.rb'

module Gosling
  class Polygon < Actor
    def initialize(window)
      type_check(window, Gosu::Window)
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
      type_check(vertices, Array)
      raise ArgumentError.new("set_vertices() expects an array of at least three 3D Vectors") unless vertices.length >= 3
      vertices.each { |v| type_check(v, Vector) }
      @vertices.replace(vertices)
    end

    def get_global_vertices
      tf = get_global_transform
      @vertices.map { |v| Transform.transform_point(tf, v) }
    end

    def is_point_in_bounds(point)
      Collision.is_point_in_shape?(point, self)
    end

    private

    def render(matrix)
      type_check(matrix, Matrix)
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
  end
end
