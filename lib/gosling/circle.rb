require_relative 'actor.rb'
require_relative 'collision.rb'

module Gosling
  class Circle < Actor
    RENDER_VERTEX_COUNT = 16

    attr_reader :radius

    def initialize(window)
      super(window)
      @radius = 0
    end

    def radius=(val)
      raise ArgumentError.new("Circle.radius cannot be negative") if val < 0
      @radius = val
    end

    def get_point_at_angle(radians)
      raise ArgumentError.new("Expected Numeric, but received #{radians.inspect}!") unless radians.is_a?(Numeric)
      Vector[Math.cos(radians) * @radius, Math.sin(radians) * @radius, 0]
    end

    def is_point_in_bounds(point)
      Collision.is_point_in_shape?(point, self)
    end

    private

    def render(matrix)
      local_vertices = (0...RENDER_VERTEX_COUNT).map do |i|
        get_point_at_angle(Math::PI * 2 * i / RENDER_VERTEX_COUNT)
      end
      global_vertices = local_vertices.map { |v| Transform.transform_point(matrix, v) }
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
