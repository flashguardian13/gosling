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

      vertices.each_index { |i| @vertices[i].set(vertices[i][0], vertices[i][1], 0) }
    end

    ##
    # Sets this polygon to a rectangular shape with the given width and height, with its upper left at local [0, 0].
    #
    def set_vertices_rect(width, height)
      raise ArgumentError.new("Expected positive non-zero integer, but received #{width.inspect}!") unless width > 0
      raise ArgumentError.new("Expected positive non-zero integer, but received #{height.inspect}!") unless height > 0

      if @vertices.length < 4
        @vertices.concat(Array.new(4 - @vertices.length) { Snow::Vec3.new })
      elsif @vertices.length > 4
        @vertices.pop(@vertices.length - 4)
      end

      @vertices[0].set(    0,      0, 0)
      @vertices[1].set(width,      0, 0)
      @vertices[2].set(width, height, 0)
      @vertices[3].set(    0, height, 0)
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
      # TODO: write transformed vertices to a reserved list of vertices retained in memory each time
      type_check(matrix, Snow::Mat3)
      global_vertices = @vertices.map { |v| Transformable.transform_point(matrix, v) }

      fill_polygon(global_vertices)
    end
  end
end
