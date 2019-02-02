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

      get_separation_axes(shapeA, shapeB)

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
    def self.get_collision_info(shapeA, shapeB, info = nil)
      if info
        info.clear
      else
        info = {}
      end
      info.merge!(actors: [shapeA, shapeB], colliding: false, overlap: nil, penetration: nil)

      return info if shapeA.instance_of?(Actor) || shapeB.instance_of?(Actor)

      return info if shapeA === shapeB

      get_separation_axes(shapeA, shapeB)
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
          smallest_axis = axis
          smallest_axis.negate! if flip
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

      global_pos = nil
      centers_axis = nil
      global_vertices = nil
      if shape.instance_of?(Circle)
        unless @@global_position_cache.key?(shape)
          global_pos = VectorCache.instance.get
          shape.get_global_position(global_pos)
        end
        centers_axis = VectorCache.instance.get
        point.subtract(@@global_position_cache.fetch(shape, global_pos), centers_axis)
        next_separation_axis.set(centers_axis) if centers_axis && (centers_axis[0] != 0 || centers_axis[1] != 0)
      else
        unless @@global_vertices_cache.key?(shape)
          global_vertices = Array.new(shape.get_vertices.length) { VectorCache.instance.get }
          shape.get_global_vertices(global_vertices)
        end
        get_polygon_separation_axes(@@global_vertices_cache.fetch(shape, global_vertices))
      end

      separation_axes.each do |axis|
        shape_projection = project_onto_axis(shape, axis)
        point_projection = point.dot_product(axis)
        return false unless shape_projection.first <= point_projection && point_projection <= shape_projection.last
      end

      return true
    ensure
      VectorCache.instance.recycle(global_pos) if global_pos
      VectorCache.instance.recycle(centers_axis) if centers_axis
      global_vertices.each { |v| VectorCache.instance.recycle(v) } if global_vertices
    end

    @@collision_buffer = []
    @@global_position_cache = {}
    @@global_vertices_cache = {}
    @@global_transform_cache = {}
    @@buffer_iterator_a = nil
    @@buffer_iterator_b = nil

    ##
    # Adds one or more descendents of Actor to the collision testing buffer. The buffer's iterators will be reset to the
    # first potential collision in the buffer.
    #
    # When added to the buffer, important and expensive global-space collision values for each Actor - transform,
    # position, and any vertices - are calculated and cached for re-use. This ensures that expensive transform
    # calculations are only performed once per actor during each collision resolution step.
    #
    # If you modify a buffered actor's transforms in any way, you will need to update its cached values by calling
    # buffer_shapes again. Otherwise, it will continue to use stale and inaccurate transform information.
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
    # Removes one or more descendents of Actor from the collision testing buffer. Any cached values for the actors
    # are discarded. The buffer's iterators will be reset to the first potential collision in the buffer.
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
    # Removes all actors from the collision testing buffer. See Collision.unbuffer_shapes.
    #
    def self.clear_buffer
      unbuffer_shapes(@@collision_buffer)
    end

    ##
    # Returns collision information for the next pair of actors in the collision buffer, or returns nil if all pairs in the
    # buffer have been tested. Advances the buffer's iterators to the next pair. See Collision.get_collision_info.
    #
    def self.next_collision_info
      reset_buffer_iterators if @@buffer_iterator_a.nil? || @@buffer_iterator_b.nil?
      return if iteration_complete?

      info = get_collision_info(@@collision_buffer[@@buffer_iterator_a], @@collision_buffer[@@buffer_iterator_b])
      skip_next_collision
      info
    end

    ##
    # Returns the pair of actors in the collision buffer that would be tested during the next call to
    # Collision.next_collision_info, or returns nil if all pairs in the buffer have been tested. Does not perform
    # collision testing or advance the buffer's iterators.
    #
    # One use of this method is to look at the two actors about to be tested and, using some custom and likely more
    # efficient logic, determine if it's worth bothering to collision test these actors at all. If not, the pair's collision test
    # can be skipped by calling Collision.skip_next_collision.
    #
    def self.peek_at_next_collision
      reset_buffer_iterators if @@buffer_iterator_a.nil? || @@buffer_iterator_b.nil?
      return if iteration_complete?

      [@@collision_buffer[@@buffer_iterator_a], @@collision_buffer[@@buffer_iterator_b]]
    end

    ##
    # Advances the collision buffer's iterators to the next pair of actors in the buffer without performing any collision
    # testing. By using this method in conjunction with Collision.peek_at_next_collision, it is possible to selectively
    # skip collision testing for pairs of actors that meet certain criteria.
    #
    def self.skip_next_collision
      reset_buffer_iterators if @@buffer_iterator_a.nil? || @@buffer_iterator_b.nil?
      return if iteration_complete?

      @@buffer_iterator_b += 1
      if @@buffer_iterator_b >= @@buffer_iterator_a
        @@buffer_iterator_b = 0
        @@buffer_iterator_a += 1
      end
    end

    private

    def self.iteration_complete?
      @@buffer_iterator_a >= @@collision_buffer.length
    end

    def self.reset_buffer_iterators
      @@buffer_iterator_a = 1
      @@buffer_iterator_b = 0
    end

    def self.get_normal(vector, out = nil)
      raise ArgumentError.new("Cannot determine normal of zero-length vector") if vector[0] == 0 && vector[1] == 0
      out ||= Snow::Vec3.new
      out.set(-vector[1], vector[0], 0)
    end

    @@separation_axes = []
    @@separation_axis_count = 0

    def self.reset_separation_axes
      @@separation_axis_count = 0
    end

    def self.next_separation_axis
      axis = @@separation_axes[@@separation_axis_count] ||= Snow::Vec3.new
      @@separation_axis_count += 1
      axis
    end

    def self.separation_axes
      @@separation_axes[0...@@separation_axis_count]
    end

    @@gpsa_axis = Snow::Vec3.new
    def self.get_polygon_separation_axes(vertices)
      vertices.each_index do |i|
        vertices[i].subtract(vertices[i - 1], @@gpsa_axis)
        if @@gpsa_axis[0] != 0 || @@gpsa_axis[1] != 0
          get_normal(@@gpsa_axis, @@gpsa_axis).normalize(next_separation_axis)
        end
      end
      nil
    end

    @@global_pos_a = nil
    @@global_pos_b = nil
    @@gcsa_axis = nil
    def self.get_circle_separation_axis(circleA, circleB)
      unless @@global_position_cache.key?(circleA)
        @@global_pos_a ||= Snow::Vec3.new
        circleA.get_global_position(@@global_pos_a)
      end

      unless @@global_position_cache.key?(circleB)
        @@global_pos_b ||= Snow::Vec3.new
        circleB.get_global_position(@@global_pos_b)
      end

      @@gcsa_axis ||= Snow::Vec3.new
      @@global_pos_a = @@global_position_cache.fetch(circleA, @@global_pos_a)
      @@global_pos_b = @@global_position_cache.fetch(circleB, @@global_pos_b)
      @@global_pos_b.subtract(@@global_pos_a, @@gcsa_axis)
      if @@gcsa_axis[0] != 0 || @@gcsa_axis[1] != 0
        @@gcsa_axis.normalize(next_separation_axis)
      end
      nil
    end

    def self.remove_duplicate_axes
      (0...@@separation_axis_count).each do |i|
        v = @@separation_axes[i]
        v.negate! if v[0] < 0
      end

      i = 0
      unique_hash = {}
      while i < @@separation_axis_count
        v = @@separation_axes[i]
        key = v.to_s
        if unique_hash.key?(key)
          @@separation_axes.push(@@separation_axes.slice!(i))
          @@separation_axis_count -= 1
        else
          unique_hash[key] = nil
          i += 1
        end
      end
    end

    def self.get_separation_axes(shapeA, shapeB)
      unless shapeA.is_a?(Actor) && !shapeA.instance_of?(Actor)
        raise ArgumentError.new("Expected a child of the Actor class, but received #{shapeA.inspect}!")
      end

      unless shapeB.is_a?(Actor) && !shapeB.instance_of?(Actor)
        raise ArgumentError.new("Expected a child of the Actor class, but received #{shapeB.inspect}!")
      end

      reset_separation_axes
      global_vertices = nil

      unless shapeA.instance_of?(Circle)
        unless @@global_vertices_cache.key?(shapeA)
          global_vertices = Array.new(shapeA.get_vertices.length) { VectorCache.instance.get }
          shapeA.get_global_vertices(global_vertices)
        end
        get_polygon_separation_axes(@@global_vertices_cache.fetch(shapeA, global_vertices))
      end

      unless shapeB.instance_of?(Circle)
        unless @@global_vertices_cache.key?(shapeB)
          global_vertices ||= []
          (shapeB.get_vertices.length - global_vertices.length).times do
            global_vertices.push(VectorCache.instance.get)
          end
          (global_vertices.length - shapeB.get_vertices.length).times do
            VectorCache.instance.recycle(global_vertices.pop)
          end
          shapeB.get_global_vertices(global_vertices)
        end
        get_polygon_separation_axes(@@global_vertices_cache.fetch(shapeB, global_vertices))
      end

      if shapeA.instance_of?(Circle) || shapeB.instance_of?(Circle)
        get_circle_separation_axis(shapeA, shapeB)
      end

      remove_duplicate_axes

      nil
    ensure
      global_vertices.each { |v| VectorCache.instance.recycle(v) } if global_vertices
    end

    @@poa_zero_z_axis = nil
    @@poa_local_axis = nil
    @@poa_intersection = nil
    @@poa_global_tf = nil
    @@poa_global_tf_inverse = nil
    def self.get_circle_vertices_by_axis(shape, axis)
      unless @@global_transform_cache.key?(shape)
        @@poa_global_tf ||= Snow::Mat3.new
        shape.get_global_transform(@@poa_global_tf)
      end

      @@poa_zero_z_axis ||= Snow::Vec3.new
      @@poa_zero_z_axis.set(axis[0], axis[1], 0)

      @@poa_global_tf_inverse ||= Snow::Mat3.new
      @@global_transform_cache.fetch(shape, @@poa_global_tf).inverse(@@poa_global_tf_inverse)

      @@poa_local_axis ||= Snow::Vec3.new
      @@poa_global_tf_inverse.multiply(@@poa_zero_z_axis, @@poa_local_axis)

      @@poa_intersection ||= Snow::Vec3.new
      shape.get_point_at_angle(Math.atan2(@@poa_local_axis[1], @@poa_local_axis[0]), @@poa_intersection)

      # TODO: Are we transforming points more than once?
      Transformable.transform_point(@@global_transform_cache.fetch(shape, @@poa_global_tf), @@poa_intersection, next_global_vertex)

      @@poa_intersection.negate!
      Transformable.transform_point(@@global_transform_cache.fetch(shape, @@poa_global_tf), @@poa_intersection, next_global_vertex)
    end

    @@global_vertices = nil
    @@global_vertices_count = 0

    def self.reset_global_vertices
      @@global_vertices ||= []
      @@global_vertices_count = 0
    end

    def self.next_global_vertex
      vertex = @@global_vertices[@@global_vertices_count] ||= Snow::Vec3.new
      @@global_vertices_count += 1
      vertex
    end

    def self.project_onto_axis(shape, axis, out = nil)
      unless @@global_vertices_cache.key?(shape)
        reset_global_vertices
        if shape.instance_of?(Circle)
          get_circle_vertices_by_axis(shape, axis)
        else
          shape.get_global_vertices(@@global_vertices)
          @@global_vertices_count = shape.get_vertices.length
        end
      end

      min = nil
      max = nil
      @@global_vertices_cache.fetch(shape, @@global_vertices[0...@@global_vertices_count]).each do |vertex|
        projection = vertex.dot_product(axis)
        if min.nil?
          min = projection
          max = projection
        else
          min = projection if projection < min
          max = projection if projection > max
        end
      end
      out ||= []
      out[1] = max
      out[0] = min
      out
    end

    def self.projections_overlap?(a, b)
      overlap = get_overlap(a, b)
      overlap != nil && overlap > COLLISION_TOLERANCE
    end

    def self.get_overlap(a, b)
      raise ArgumentError.new("Projection array must be length 2, not #{a.inspect}!") unless a.length == 2
      raise ArgumentError.new("Projection array must be length 2, not #{b.inspect}!") unless b.length == 2
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
