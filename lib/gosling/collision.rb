require 'singleton'

require_relative 'utils.rb'

module Gosling
  class Collision
    include Singleton

    def self.test(shapeA, shapeB)
      return false if shapeA.instance_of?(Actor) || shapeB.instance_of?(Actor)

      return false if shapeA === shapeB

      separation_axes = get_separation_axes(shapeA, shapeB)

      separation_axes.each do |axis|
        projectionA = project_onto_axis(shapeA, axis)
        projectionB = project_onto_axis(shapeB, axis)
        return false unless projections_overlap?(projectionA, projectionB)
      end

      return true
    end

    def self.is_point_in_shape?(point, shape)
      type_check(point, Snow::Vec3)
      type_check(shape, Actor)

      return false if shape.instance_of?(Actor)

      separation_axes = []
      if shape.instance_of?(Circle)
        centers_axis = point - shape.get_global_position
        separation_axes.push(centers_axis) if centers_axis && centers_axis.magnitude > 0
      else
        separation_axes.concat(get_polygon_separation_axes(shape.get_global_vertices))
      end

      separation_axes.each do |axis|
        shape_projection = project_onto_axis(shape, axis)
        point_projection = point.dot_product(axis)
        return false unless shape_projection.min <= point_projection && point_projection <= shape_projection.max
      end

      return true
    end

    private

    def self.get_normal(vector)
      type_check(vector, Snow::Vec3)
      raise ArgumentError.new("Cannot determine normal of zero-length vector") if vector.magnitude_squared == 0
      Snow::Vec3[-vector[1], vector[0], 0]
    end

    def self.get_polygon_separation_axes(vertices)
      type_check(vertices, Array)
      vertices.each { |v| type_check(v, Snow::Vec3) }

      axes = (0...vertices.length).map do |i|
        axis = vertices[(i + 1) % vertices.length] - vertices[i]
        (axis.magnitude > 0) ? get_normal(axis).normalize : nil
      end
      axes.compact
    end

    def self.get_circle_separation_axis(circleA, circleB)
      type_check(circleA, Actor)
      type_check(circleB, Actor)
      axis = circleB.get_global_position - circleA.get_global_position
      (axis.magnitude > 0) ? axis.normalize : nil
    end

    def self.get_separation_axes(shapeA, shapeB)
      unless shapeA.is_a?(Actor) && !shapeA.instance_of?(Actor)
        raise ArgumentError.new("Expected a child of the Actor class, but received #{shapeA.inspect}!")
      end

      unless shapeB.is_a?(Actor) && !shapeB.instance_of?(Actor)
        raise ArgumentError.new("Expected a child of the Actor class, but received #{shapeB.inspect}!")
      end

      separation_axes = []

      unless shapeA.instance_of?(Circle)
        separation_axes.concat(get_polygon_separation_axes(shapeA.get_global_vertices))
      end

      unless shapeB.instance_of?(Circle)
        separation_axes.concat(get_polygon_separation_axes(shapeB.get_global_vertices))
      end

      if shapeA.instance_of?(Circle) || shapeB.instance_of?(Circle)
        axis = get_circle_separation_axis(shapeA, shapeB)
        separation_axes.push(axis) if axis
      end

      separation_axes.map! { |v| v[0] < 0 ? v * -1 : v }
      separation_axes.uniq
    end

    def self.project_onto_axis(shape, axis)
      type_check(shape, Actor)
      type_check(axis, Snow::Vec3)

      global_vertices = if shape.instance_of?(Circle)
        global_tf = shape.get_global_transform
        local_axis = global_tf.inverse * Snow::Vec3[axis[0], axis[1], 0]
        v = shape.get_point_at_angle(Math.atan2(local_axis[1], local_axis[0]))
        [v, v * -1].map { |vertex| Transform.transform_point(global_tf, vertex) }
      else
        shape.get_global_vertices
      end

      projections = global_vertices.map { |vertex| vertex.dot_product(axis) }.sort
      [projections.first, projections.last]
    end

    def self.projections_overlap?(a, b)
      type_check(a, Array)
      type_check(b, Array)
      a.each { |x| type_check(x, Numeric) }
      b.each { |x| type_check(x, Numeric) }
      raise ArgumentError.new("Expected two arrays of length 2, but received #{a.inspect} and #{b.inspect}!") unless a.length == 2 && b.length == 2

      a.sort! if a[0] > a[1]
      b.sort! if b[0] > b[1]
      (a[0] <= b[1] && (b[1] <= a[1] || b[0] <= a[0])) || (b[0] <= a[1] && (a[0] <= b[0] || a[1] <= b[1]))
    end
  end
end
