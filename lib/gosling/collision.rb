require 'singleton'

require_relative 'utils.rb'

module Gosling
  ##
  # Very basic 2D collision detection. It is naive to where actors were during the last physics step or how fast they are
  # moving. But it does a fine job of detecting collisions between actors in their present state.
  #
  # Keep in mind that Actors and their subclasses each have their own unique shapes. Actors, by themselves, have no
  # shape and will never collide with anything. To see collisions in action, you'll need to use Circle, Polygon, or
  # something else that has an actual shape.
  #

  class Collision
    include Singleton

    COLLISION_TOLERANCE = 0.000001

    ##
    # Tests two Actors or child classes to see whether they overlap. Actors, having no shape, never overlap. Child
    # classes use appropriate algorithms based on their shape.
    #
    # Arguments:
    # - shapeA: an Actor
    # - shapeB: another Actor
    #
    # Returns:
    # - true if the actors' shapes overlap, false otherwise
    #
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

    ##
    # Tests two Actors or child classes to see whether they overlap. This is similar to #test, but returns additional
    # information.
    #
    # Arguments:
    # - shapeA: an Actor
    # - shapeB: another Actor
    #
    # Returns a hash with the following key/value pairs:
    # - colliding: true if the Actors overlap; false otherwise
    # - overlap: if colliding, the smallest overlapping distance; nil otherwise
    # - penetration: if colliding, a vector representing how far shape B must move to be separated from (or merely
    #     touching) shape A; nil otherwise
    #
    def self.get_collision_info(shapeA, shapeB)
      info = { actors: [shapeA, shapeB], colliding: false, overlap: nil, penetration: nil }

      return info if shapeA.instance_of?(Actor) || shapeB.instance_of?(Actor)

      return info if shapeA === shapeB

      separation_axes = get_separation_axes(shapeA, shapeB)
      return info if separation_axes.empty?

      smallest_overlap = nil
      smallest_axis = nil
      separation_axes.each do |axis|
        projectionA = project_onto_axis(shapeA, axis)
        projectionB = project_onto_axis(shapeB, axis)
        overlap = get_overlap(projectionA, projectionB)
        return info unless overlap && overlap > COLLISION_TOLERANCE
        if smallest_overlap.nil? || smallest_overlap > overlap
          smallest_overlap = overlap
          flip = (projectionA[0] + projectionA[1]) * 0.5 > (projectionB[0] + projectionB[1]) * 0.5
          smallest_axis = flip ? -axis : axis
        end
      end

      info[:colliding] = true
      info[:overlap] = smallest_overlap
      info[:penetration] = smallest_axis.normalize * smallest_overlap

      info
    end

    ##
    # Tests a point in space to see whether it is inside the actor's shape or not.
    #
    # Arguments:
    # - point: a Snow::Vec3
    # - shape: an Actor
    #
    # Returns:
    # - true if the point is inside of the actor's shape, false otherwise
    #
    def self.is_point_in_shape?(point, shape)
      type_check(point, Snow::Vec3)
      type_check(shape, Actor)

      return false if shape.instance_of?(Actor)

      separation_axes = []
      if shape.instance_of?(Circle)
        centers_axis = point - (@@global_position_cache.key?(shape) ? @@global_position_cache[shape] : shape.get_global_position)
        separation_axes.push(centers_axis) if centers_axis && centers_axis.magnitude > 0
      else
        vertices =  if @@global_vertices_cache.key?(shape)
                      @@global_vertices_cache[shape]
                    else
                      shape.get_global_vertices
                    end
        separation_axes.concat(get_polygon_separation_axes(vertices))
      end

      separation_axes.each do |axis|
        shape_projection = project_onto_axis(shape, axis)
        point_projection = point.dot_product(axis)
        return false unless shape_projection.min <= point_projection && point_projection <= shape_projection.max
      end

      return true
    end

    @@collision_buffer = []
    @@global_position_cache = {}
    @@global_vertices_cache = {}
    @@global_transform_cache = {}
    @@buffer_iterator_a = nil
    @@buffer_iterator_b = nil

    ##
    #
    #
    def self.buffer_shapes(actors)
      type_check(actors, Array)
      actors.each { |a| type_check(a, Actor) }

      reset_buffer_iterators

      shapes = actors.reject { |a| a.instance_of?(Actor) }

      @@collision_buffer = @@collision_buffer | shapes
      shapes.each do |shape|
        unless @@global_transform_cache.key?(shape)
          @@global_transform_cache[shape] = MatrixCache.instance.get
        end
        shape.get_global_transform(@@global_transform_cache[shape])

        unless @@global_position_cache.key?(shape)
          @@global_position_cache[shape] = VectorCache.instance.get
        end
        # TODO: can we calculate this position using the global transform we already have?
        @@global_position_cache[shape].set(shape.get_global_position)

        if shape.is_a?(Polygon)
          unless @@global_vertices_cache.key?(shape)
            @@global_vertices_cache[shape] = Array.new(shape.get_vertices.length) { VectorCache.instance.get }
          end
          # TODO: can we calculate these vertices using the global transform we already have?
          shape.get_global_vertices(@@global_vertices_cache[shape])
        end
      end
    end

    ##
    #
    #
    def self.unbuffer_shapes(actors)
      type_check(actors, Array)
      actors.each { |a| type_check(a, Actor) }

      reset_buffer_iterators

      @@collision_buffer = @@collision_buffer - actors
      actors.each do |actor|
        if @@global_transform_cache.key?(actor)
          MatrixCache.instance.recycle(@@global_transform_cache[actor])
          @@global_transform_cache.delete(actor)
        end

        if @@global_position_cache.key?(actor)
          VectorCache.instance.recycle(@@global_position_cache[actor])
          @@global_position_cache.delete(actor)
        end

        if @@global_vertices_cache.key?(actor)
          @@global_vertices_cache[actor].each do |vertex|
            VectorCache.instance.recycle(vertex)
          end
          @@global_vertices_cache.delete(actor)
        end
      end
    end

    ##
    #
    #
    def self.clear_buffer
      unbuffer_shapes(@@collision_buffer)
    end

    ##
    #
    #
    def self.next_collision_info
      reset_buffer_iterators if @@buffer_iterator_a.nil? || @@buffer_iterator_b.nil?
      return if interation_complete?

      info = get_collision_info(@@collision_buffer[@@buffer_iterator_a], @@collision_buffer[@@buffer_iterator_b])
      skip_next_collision
      info
    end

    ##
    #
    #
    def self.peek_at_next_collision
      reset_buffer_iterators if @@buffer_iterator_a.nil? || @@buffer_iterator_b.nil?
      return if interation_complete?

      [@@collision_buffer[@@buffer_iterator_a], @@collision_buffer[@@buffer_iterator_b]]
    end

    ##
    #
    #
    def self.skip_next_collision
      reset_buffer_iterators if @@buffer_iterator_a.nil? || @@buffer_iterator_b.nil?
      return if interation_complete?

      @@buffer_iterator_b += 1
      if @@buffer_iterator_b >= @@buffer_iterator_a
        @@buffer_iterator_b = 0
        @@buffer_iterator_a += 1
      end
    end

    private

    def self.interation_complete?
      @@buffer_iterator_a >= @@collision_buffer.length
    end

    def self.reset_buffer_iterators
      @@buffer_iterator_a = 1
      @@buffer_iterator_b = 0
    end

    def self.get_normal(vector, out = nil)
      type_check(vector, Snow::Vec3)
      raise ArgumentError.new("Cannot determine normal of zero-length vector") if vector.magnitude_squared == 0
      out ||= Snow::Vec3.new
      out.set(-vector.y, vector.x, 0)
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
      global_pos_a = (@@global_position_cache.key?(circleA) ? @@global_position_cache[circleA] : circleA.get_global_position)
      global_pos_b = (@@global_position_cache.key?(circleB) ? @@global_position_cache[circleB] : circleB.get_global_position)
      axis = global_pos_b - global_pos_a
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
        vertices =  if @@global_vertices_cache.key?(shapeA)
                      @@global_vertices_cache[shapeA]
                    else
                      shapeA.get_global_vertices
                    end
        separation_axes.concat(get_polygon_separation_axes(vertices))
      end

      unless shapeB.instance_of?(Circle)
        vertices = if @@global_vertices_cache.key?(shapeB)
                      @@global_vertices_cache[shapeB]
                    else
                      shapeB.get_global_vertices
                    end
        separation_axes.concat(get_polygon_separation_axes(vertices))
      end

      if shapeA.instance_of?(Circle) || shapeB.instance_of?(Circle)
        axis = get_circle_separation_axis(shapeA, shapeB)
        separation_axes.push(axis) if axis
      end

      separation_axes.map! { |v| v[0] < 0 ? v * -1 : v }
      separation_axes.uniq
    end

    def self.project_onto_axis(shape, axis, out = nil)
      type_check(shape, Actor)
      type_check(axis, Snow::Vec3)
      type_check(out, Array) unless out.nil?

      global_vertices = nil

      global_tf = nil
      global_tf_inverse = nil

      zero_z_axis = nil
      local_axis = nil
      intersection = nil

      unless @@global_vertices_cache.key?(shape)
        if shape.instance_of?(Circle)
          global_vertices = []

          unless @@global_transform_cache.key?(shape)
            global_tf = MatrixCache.instance.get
            shape.get_global_transform(global_tf)
          end

          zero_z_axis = VectorCache.instance.get
          zero_z_axis.set(axis.x, axis.y, 0)

          global_tf_inverse = MatrixCache.instance.get
          @@global_transform_cache.fetch(shape, global_tf).inverse(global_tf_inverse)

          local_axis = VectorCache.instance.get
          global_tf_inverse.multiply(zero_z_axis, local_axis)

          intersection = VectorCache.instance.get
          # TODO: is this a wasted effort? a roundabout way of normalizing?
          shape.get_point_at_angle(Math.atan2(local_axis.y, local_axis.x), intersection)

          vertex = VectorCache.instance.get
          # TODO: Are we transforming points more than once?
          Transformable.transform_point(@@global_transform_cache.fetch(shape, global_tf), intersection, vertex)
          global_vertices.push(vertex)

          vertex = VectorCache.instance.get
          intersection.negate!
          Transformable.transform_point(@@global_transform_cache.fetch(shape, global_tf), intersection, vertex)
          global_vertices.push(vertex)
        else
          global_vertices = Array.new(shape.get_vertices.length) { VectorCache.instance.get }
          shape.get_global_vertices(global_vertices)
        end
      end

      min = nil
      max = nil
      @@global_vertices_cache.fetch(shape, global_vertices).each do |vertex|
        projection = vertex.dot_product(axis)
        min = projection if min.nil? || projection < min
        max = projection if max.nil? || projection > max
      end
      out ||= []
      out[1] = max
      out[0] = min
      out
    ensure
      MatrixCache.instance.recycle(global_tf) if global_tf
      MatrixCache.instance.recycle(global_tf_inverse) if global_tf_inverse

      VectorCache.instance.recycle(zero_z_axis) if zero_z_axis
      VectorCache.instance.recycle(local_axis) if local_axis
      VectorCache.instance.recycle(intersection) if intersection

      global_vertices.each { |v| VectorCache.instance.recycle(v) } if global_vertices
    end

    def self.projections_overlap?(a, b)
      overlap = get_overlap(a, b)
      overlap != nil && overlap > COLLISION_TOLERANCE
    end

    def self.get_overlap(a, b)
      type_check(a, Array)
      type_check(b, Array)
      a.each { |x| type_check(x, Numeric) }
      b.each { |x| type_check(x, Numeric) }
      raise ArgumentError.new("Expected two arrays of length 2, but received #{a.inspect} and #{b.inspect}!") unless a.length == 2 && b.length == 2

      a.sort! if a[0] > a[1]
      b.sort! if b[0] > b[1]
      return b[1] - b[0] if a[0] <= b[0] && b[1] <= a[1]
      return a[1] - a[0] if b[0] <= a[0] && a[1] <= b[1]
      return a[1] - b[0] if a[0] <= b[0] && b[0] <= a[1]
      return b[1] - a[0] if b[0] <= a[0] && a[0] <= b[1]
      nil
    end
  end
end
