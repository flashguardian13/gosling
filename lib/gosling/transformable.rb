require 'snow-math'

require_relative 'patches.rb'
require_relative 'utils.rb'

module Gosling
  ##
  # A helper class for performing vector transforms in 2D space. Relies heavily on the Vec3 and Mat3 classes of the
  # SnowMath gem to remain performant.
  #
  module Transformable
    attr_reader :rotation

    ##
    # Initializes this Transformable to have no transformations (identity matrix).
    #
    def initialize
      @center = Snow::Vec3[0, 0, 1]
      @scale = Snow::Vec2[1, 1]
      @translation = Snow::Vec3[0, 0, 1]
      reset
    end

    ##
    # Resets center and translation to [0, 0], scale to [1, 1], and rotation to 0, restoring this transformation to the identity
    # matrix.
    #
    def reset
      self.center = 0, 0
      self.scale = 1, 1
      self.rotation = 0
      self.translation = 0, 0
    end

    ##
    # Returns a duplicate of the center Vec3 (@center is read-only).
    #
    def center
      @center.dup.freeze
    end

    ##
    # Returns the x component of the centerpoint of this Transformable. See Transformable#center.
    #
    def center_x
      @center.x
    end

    ##
    # Returns the y component of the centerpoint of this Transformable. See Transformable#center.
    #
    def center_y
      @center.y
    end

    ##
    # Returns a duplicate of the scale Vec2 (@scale is read-only).
    #
    def scale
      @scale.dup.freeze
    end

    ##
    # Returns the x component of the scaling of this Transformable. See Transformable#scale.
    #
    def scale_x
      @scale.x
    end

    ##
    # Returns the y component of the scaling of this Transformable. See Transformable#scale.
    #
    def scale_y
      @scale.y
    end

    ##
    # Returns a duplicate of the translation Vec3 (@translation is read-only).
    #
    def translation
      @translation.dup.freeze
    end
    alias :pos :translation

    ##
    # Returns this Transformable's x position in relative space. See Transformable#translation.
    #
    def x
      @translation.x
    end

    ##
    # Returns this Transformable's y position in relative space. See Transformable#translation.
    #
    def y
      @translation.y
    end

    ##
    # Sets this transform's centerpoint. All other transforms are performed relative to this central point.
    #
    # The default centerpoint is [0, 0], which is the same as no transform. For a square defined by the vertices
    # [[0, 0], [10, 0], [10, 10], [0, 10]], this would translate to that square's upper left corner. In this case, when scaled
    # larger or smaller, only the square's right and bottom edges would expand or  contract, and when rotated it
    # would spin around its upper left corner. For most applications, this is probably not what we want.
    #
    # By setting the centerpoint to something other than the origin, we can change the scaling and rotation to
    # something that makes more sense. For the square defined above, we could set center to be the actual center of
    # the square: [5, 5]. By doing so, scaling the square would cause it to expand evenly on all sides, and rotating it
    # would cause it to spin about its center like a four-cornered wheel.
    #
    # You can set the centerpoint to be any point in local space, inside or even outside of the shape in question.
    #
    # If passed more than two numeric arguments, only the first two are used.
    #
    # Usage:
    # - transform.center = x, y
    # - transform.center = [x, y]
    # - transform.center = Snow::Vec2[x, y]
    # - transform.center = Snow::Vec3[x, y, z]
    # - transform.center = Snow::Vec4[x, y, z, c]
    #
    def center=(args)
      case args[0]
      when Array
        self.center = args[0][0], args[0][1]
      when Snow::Vec2, Snow::Vec3, Snow::Vec4
        @center.x = args[0].x
        @center.y = args[0].y
      when Numeric
        raise ArgumentError.new("Cannot set center from #{args.inspect}: numeric array requires at least two arguments!") unless args.length >= 2
        args.each { |arg| type_check(arg, Numeric) }
        @center.x = args[0]
        @center.y = args[1]
      else
        raise ArgumentError.new("Cannot set center from #{args.inspect}: bad type!")
      end
      @center_is_dirty = @is_dirty = true
    end
    alias :set_center :center=

    ##
    # Sets the x component of the centerpoint of this Transformable. See Transformable#center.
    #
    def center_x=(val)
      type_check(val, Numeric)
      @center.x = val
      @center_is_dirty = @is_dirty = true
    end

    ##
    # Sets the y component of the centerpoint of this Transformable. See Transformable#center.
    #
    def center_y=(val)
      type_check(val, Numeric)
      @center.y = val
      @center_is_dirty = @is_dirty = true
    end

    ##
    # Sets this transform's x/y scaling. A scale value of [1, 1] results in no scaling. Larger values make a shape bigger,
    # while smaller values will make it smaller. Great for shrinking/growing animations, or to zoom the camera in/out.
    #
    # If passed more than two numeric arguments, only the first two are used.
    #
    # Usage:
    # - transform.scale = scalar
    # - transform.scale = x, y
    # - transform.scale = [x, y]
    # - transform.scale = Snow::Vec2[x, y]
    # - transform.scale = Snow::Vec3[x, y, z]
    # - transform.scale = Snow::Vec4[x, y, z, c]
    #
    def scale=(*args)
      if args.length >= 2
        case args[0]
        when Numeric
          args.each { |arg| type_check(arg, Numeric) }
          @scale.x = args[0]
          @scale.y = args[1]
        else
          raise ArgumentError.new("Bad combination of arguments: #{args.inspect}! Please supply a Snow::Vec2, an Array of Numerics, or a single scalar.")
        end
      elsif args.length == 1
        case args[0]
        when Array
          self.set_scale(*(args[0]))
        when Snow::Vec2
          self.set_scale(args[0].x, args[0].y)
        when Numeric
          self.set_scale(args[0], args[0])
        else
          raise ArgumentError.new("Bad combination of arguments: #{args.inspect}! Please supply a Snow::Vec2, an Array of Numerics, or a single scalar.")
        end
      else
        raise ArgumentError.new("Bad combination of arguments: #{args.inspect}! Please supply a Snow::Vec2, an Array of Numerics, or a single scalar.")
      end
      @scale_is_dirty = @is_dirty = true
    end
    alias :set_scale :scale=

    ##
    # Wrapper method. Sets the x component of the scaling of this Actor. See Transformable#scale.
    #
    def scale_x=(val)
      type_check(val, Numeric)
      @scale.x = val
      @scale_is_dirty = @is_dirty = true
    end

    ##
    # Wrapper method. Sets the y component of the scaling of this Actor. See Transformable#scale.
    #
    def scale_y=(val)
      type_check(val, Numeric)
      @scale.y = val
      @scale_is_dirty = @is_dirty = true
    end

    ##
    # Sets this transform's rotation in radians. A value of 0 results in no rotation. Great for spinning animations, or
    # rotating the player's camera view.
    #
    # Usage:
    # - transform.rotation = radians
    #
    def rotation=(radians)
      type_check(radians, Numeric)
      if radians.is_a?(Float)
        raise ArgumentError.new("Expected a finite number, but received #{radians.inspect}!") unless radians.finite?
      end
      @rotation = radians
      @rotate_is_dirty = @is_dirty = true
    end
    alias :set_rotation :rotation=

    ##
    # Sets this transform's x/y translation in radians. A value of [0, 0] results in no translation. Great for moving
    # actors across the screen or scrolling the camera.
    #
    # If passed more than two numeric arguments, only the first two are used.
    #
    # Usage:
    # - transform.translation = x, y
    # - transform.translation = [x, y]
    # - transform.translation = Snow::Vec2[x, y]
    # - transform.translation = Snow::Vec3[x, y, z]
    # - transform.translation = Snow::Vec4[x, y, z, c]
    #
    def translation=(args)
      case args[0]
      when Array
        self.translation = args[0][0], args[0][1]
      when Snow::Vec2, Snow::Vec3, Snow::Vec4
        @translation.x = args[0].x
        @translation.y = args[0].y
      when Numeric
        raise ArgumentError.new("Cannot set translation from #{args.inspect}: numeric array requires at least two arguments!") unless args.length >= 2
        args.each { |arg| type_check(arg, Numeric) }
        @translation.x = args[0]
        @translation.y = args[1]
      else
        raise ArgumentError.new("Cannot set translation from #{args.inspect}: bad type!")
      end
      @translate_is_dirty = @is_dirty = true
    end
    alias :set_translation :translation=
    alias :pos= :translation=

    ##
    # Sets this Transformable's x position in relative space. See Transformable#translation.
    #
    def x=(val)
      type_check(val, Numeric)
      @translation.x = val
      @translate_is_dirty = @is_dirty = true
    end

    ##
    # Sets this Transformable's y position in relative space. See Transformable#translation.
    #
    def y=(val)
      type_check(val, Numeric)
      @translation.y = val
      @translate_is_dirty = @is_dirty = true
    end

    ##
    # Returns a Snow::Mat3 which combines our current center, scale, rotation, and translation into a single transform
    # matrix. When a point in space is multiplied by this transform, the centering, scaling, rotation, and translation
    # will all be applied to that point.
    #
    # This Snow::Mat3 is cached and will only be recalculated as needed.
    #
    def to_matrix
      return @matrix unless @is_dirty || @matrix.nil?

      update_center_matrix
      update_scale_matrix
      update_rotate_matrix
      update_translate_matrix

      @matrix = Snow::Mat3.new unless @matrix

      @matrix.set(@center_mat)
      @matrix.multiply!(@scale_mat)
      @matrix.multiply!(@rotate_mat)
      @matrix.multiply!(@translate_mat)

      @is_dirty = false
      @matrix
    end

    ##
    # Transforms a Vec3 using the provided Mat3 transform and returns the result as a new Vec3. This is the
    # opposite of Transformable.untransform_point.
    #
    def self.transform_point(mat, point, out = nil)
      type_check(mat, Snow::Mat3)
      type_check(point, Snow::Vec3)
      type_check(out, Snow::Vec3) unless out.nil?
      raise "Output vector is temporarily required!" unless out

      transformable_point = VectorCache.instance.get
      transformable_point.set(point.x, point.y, 1)

      out ||= Snow::Vec3.new
      mat.multiply(transformable_point, out)
      out.z = 0
      out
    ensure
      VectorCache.instance.recycle(transformable_point) if transformable_point
    end

    ##
    # Applies all of our transformations to the point, returning the resulting point as a new Vec3. This is the opposite
    # of Transformable#untransform_point.
    #
    def transform_point(point, out = nil)
      Transformable.transform_point(to_matrix, point, out)
    end

    ##
    # Transforms a Vec3 using the inverse of the provided Mat3 transform and returns the result as a new Vec3. This
    # is the opposite of Transformable.transform_point.
    #
    def self.untransform_point(mat, point, out = nil)
      inverse_mat = MatrixCache.instance.get
      raise "Unable to invert matrix: #{mat}!" unless mat.inverse(inverse_mat)
      transform_point(inverse_mat, point, out)
    ensure
      MatrixCache.instance.recycle(inverse_mat) if inverse_mat
    end

    ##
    # Applies the inverse of all of our transformations to the point, returning the resulting point as a new Vec3. This
    # is the opposite of Transformable#transform_point.
    #
    def untransform_point(point, out = nil)
      Transformable.untransform_point(to_matrix, point, out)
    end

    private

    def update_center_matrix
      return unless @center_is_dirty || @center_mat.nil?
      @center_mat ||= Snow::Mat3.new
      @center_mat[2] = -@center.x
      @center_mat[5] = -@center.y
      @center_is_dirty = false
    end

    def update_scale_matrix
      return unless @scale_is_dirty || @scale_mat.nil?
      @scale_mat ||= Snow::Mat3.new
      @scale_mat[0] = @scale[0]
      @scale_mat[4] = @scale[1]
      @scale_is_dirty = false
    end

    def update_rotate_matrix
      return unless @rotate_is_dirty || @rotate_mat.nil?
      @rotate_mat ||= Snow::Mat3.new
      @rotate_mat[4] = @rotate_mat[0] = Math.cos(@rotation)
      @rotate_mat[1] = Math.sin(@rotation)
      @rotate_mat[3] = -@rotate_mat[1]
      @rotate_is_dirty = false
    end

    def update_translate_matrix
      return unless @translate_is_dirty || @translate_mat.nil?
      @translate_mat ||= Snow::Mat3.new
      @translate_mat[2] = @translation.x
      @translate_mat[5] = @translation.y
      @translate_is_dirty = false
    end
  end
end
