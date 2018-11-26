require_relative 'actor.rb'
require_relative 'collision.rb'
require_relative 'utils.rb'

module Gosling
  ##
  # A Polygon is an Actor with a shape defined by three or more vertices. Can be used to make triangles, hexagons, or
  # any other unusual geometry not covered by the other Actors. For circles, you should use Circle. For squares or
  # rectangles, see Rect.
  #
  class Polygon < Actor
    ##
    # Creates a new, square Polygon with a width and height of 1.
    #
    def initialize(window)
      type_check(window, Gosu::Window)
      super(window)
      @vertices = [
        Snow::Vec3[0, 0, 0],
        Snow::Vec3[1, 0, 0],
        Snow::Vec3[1, 1, 0],
        Snow::Vec3[0, 1, 0]
      ]
    end

    ##
    # Returns a copy of this Polygon's vertices (@vertices is read-only).
    #
    def get_vertices
      @vertices.dup
    end

    ##
    # Sets this polygon's vertices. Requires three or more Snow::Vec3.
    #
    # Usage:
    # - polygon.set_vertices([Snow::Vec3[-1, 0, 0], Snow::Vec3[0, -1, 0], Snow::Vec3[1, 1, 0]])
    #
    def set_vertices(vertices)
      type_check(vertices, Array)
      raise ArgumentError.new("set_vertices() expects an array of at least three 3D Vectors") unless vertices.length >= 3
      vertices.each { |v| type_check(v, Snow::Vec3) }
      @vertices.replace(vertices)
    end

    ##
    # Returns an array containing all of our local vertices transformed to global-space. (See Actor#get_global_transform.)
    #
    def get_global_vertices
      tf = get_global_transform
      @vertices.map { |v| Transform.transform_point(tf, v) }
    end

    ##
    # Returns true if the point is inside of this Polygon, false otherwise.
    #
    def is_point_in_bounds(point)
      Collision.is_point_in_shape?(point, self)
    end

    private

    def render(matrix)
      type_check(matrix, Snow::Mat3)
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
