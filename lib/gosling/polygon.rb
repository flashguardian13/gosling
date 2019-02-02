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
    # Sets this polygon's vertices. Requires three or more Snow::Vec2, Vec3, Vec4, or Arrays containing 2 or more
    # numbers.
    #
    # Usage:
    # - polygon.set_vertices([Snow::Vec3[-1, 0, 0], Snow::Vec3[0, -1, 0], Snow::Vec3[1, 1, 0]])
    #
    def set_vertices(vertices)
      type_check(vertices, Array)
      raise ArgumentError.new("set_vertices() expects an array of at least three 2D vectors") unless vertices.length >= 3
      vertices.each do |v|
        types_check(v, Snow::Vec2, Snow::Vec3, Snow::Vec4, Array)
        if v.is_a?(Array)
          raise ArgumentError.new("set_vertices() expects an array of at least three 2D vectors") unless v.length >= 2
          v.each { |n| type_check(n, Numeric) }
        end
      end

      if @vertices.length < vertices.length
        @vertices.concat(Array.new(vertices.length - @vertices.length) { Snow::Vec3.new })
      elsif @vertices.length > vertices.length
        @vertices.pop(@vertices.length - vertices.length)
      end

      vertices.each_index do |i|
        @vertices[i][0] = vertices[i][0]
        @vertices[i][1] = vertices[i][1]
        @vertices[i][2] = 0
      end
    end

    ##
    # Returns an array containing all of our local vertices transformed to global-space. (See Actor#get_global_transform.)
    #
    def get_global_vertices(out = nil)
      type_check(out, Array) unless out.nil?

      tf = MatrixCache.instance.get
      get_global_transform(tf)

      if out.nil?
        return @vertices.map { |v| Transformable.transform_point(tf, v, Snow::Vec3.new) }
      end

      @vertices.each_index do |i|
        v = @vertices[i]
        if out[i]
          Transformable.transform_point(tf, v, out[i])
        else
          out[i] = Transformable.transform_point(tf, v)
        end
      end
      out
    ensure
      MatrixCache.instance.recycle(tf) if tf
    end

    ##
    # Returns true if the point is inside of this Polygon, false otherwise.
    #
    def is_point_in_bounds(point)
      Collision.is_point_in_shape?(point, self)
    end

    private

    def render(matrix)
      # TODO: optimize and refactor
      type_check(matrix, Snow::Mat3)
      global_vertices = @vertices.map { |v| Transformable.transform_point(matrix, v) }
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
