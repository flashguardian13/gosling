require_relative 'actor.rb'
require_relative 'collision.rb'

module Gosling
  ##
  # Represents an Actor with a circular shape, defined by a mutable radius. The circle is rendered relative to the
  # Circle's center (see Transformable#center).
  #
  class Circle < Actor
    ##
    # How many vertices to use when rendering circles. More vertices means more accurate rendering at the cost of
    # performance.
    #
    RENDER_VERTEX_COUNT = 16

    attr_reader :radius

    ##
    # Creates a new Circle with initial radius of zero.
    #
    def initialize(window)
      super(window)
      @radius = 0
    end

    ##
    # Sets this circle's radius. Radius must be a positive integer.
    #
    def radius=(val)
      raise ArgumentError.new("Circle.radius cannot be negative") if val < 0
      @radius = val
    end

    ##
    # Returns the angle's corresponding unit vector times this circle's radius.
    #
    def get_point_at_angle(radians, out = nil)
      raise ArgumentError.new("Expected Numeric, but received #{radians.inspect}!") unless radians.is_a?(Numeric)
      out ||= Snow::Vec3.new
      out.set(Math.cos(radians) * @radius, Math.sin(radians) * @radius, 0)
    end

    ##
    # Returns true if the point is inside the Circle, false otherwise.
    #
    def is_point_in_bounds(point)
      Collision.is_point_in_shape?(point, self)
    end

    private

    # TODO: keep a cached, class-level list of local vertices that can be re-used during rendering

    def render(matrix)
      # TODO: store these vertices in a cached, class-level array (see above)
      local_vertices = (0...RENDER_VERTEX_COUNT).map do |i|
        get_point_at_angle(Math::PI * 2 * i / RENDER_VERTEX_COUNT)
      end
      # TODO: retain an array of vertices in memory; write transformed vertices to this array
      global_vertices = local_vertices.map { |v| Transformable.transform_point(matrix, v) }

      fill_polygon(global_vertices)
    end
  end
end
