require 'snow-math'

require_relative 'patches.rb'
require_relative 'utils.rb'

module Gosling
  class Transform
    def self.rational_sin(r)
      type_check(r, Numeric)

      r = r % (2 * Math::PI)
      case r
      when 0.0
        0.to_r
      when Math::PI / 2
        1.to_r
      when Math::PI
        0.to_r
      when Math::PI * 3 / 2
        -1.to_r
      else
        Math.sin(r).to_r
      end
    end

    def self.rational_cos(r)
      type_check(r, Numeric)

      r = r % (2 * Math::PI)
      case r
      when 0.0
        1.to_r
      when Math::PI / 2
        0.to_r
      when Math::PI
        -1.to_r
      when Math::PI * 3 / 2
        0.to_r
      else
        Math.cos(r).to_r
      end
    end

    attr_reader :rotation

    def initialize
      @center = Snow::Vec3[0.to_r, 0.to_r, 1.to_r]
      @scale = Snow::Vec2[1.to_r, 1.to_r]
      @translation = Snow::Vec3[0.to_r, 0.to_r, 1.to_r]
      reset
    end

    def reset
      self.center = 0.to_r, 0.to_r
      self.scale = 1.to_r, 1.to_r
      self.rotation = 0.to_r
      self.translation = 0.to_r, 0.to_r
    end

    def center
      @center.dup
    end

    def scale
      @scale.dup
    end

    def translation
      @translation.dup
    end

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

    def scale=(args)
      case args[0]
      when Array
        self.scale = args[0][0], args[0][1]
      when Snow::Vec2, Snow::Vec3, Snow::Vec4
        @scale.x = args[0].x
        @scale.y = args[0].y
      when Numeric
        raise ArgumentError.new("Cannot set scale from #{args.inspect}: numeric array requires at least two arguments!") unless args.length >= 2
        args.each { |arg| type_check(arg, Numeric) }
        @scale.x = args[0]
        @scale.y = args[1]
      else
        raise ArgumentError.new("Cannot set scale from #{args.inspect}: bad type!")
      end
      @scale_is_dirty = @is_dirty = true
    end
    alias :set_scale :scale=

    def rotation=(radians)
      type_check(radians, Numeric)
      @rotation = radians
      @rotate_is_dirty = @is_dirty = true
    end
    alias :set_rotation :rotation=

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

    def self.transform_point(mat, v)
      type_check(mat, Snow::Mat3)
      type_check(v, Snow::Vec3)
      result = mat * Snow::Vec3[v[0], v[1], 1.to_r]
      result[2] = 0.to_r
      result
    end

    def transform_point(v)
      Transform.transform_point(to_matrix, v)
    end

    def self.untransform_point(mat, v)
      type_check(mat, Snow::Mat3)
      type_check(v, Snow::Vec3)
      inverse_mat = mat.inverse
      unless inverse_mat
        raise "Unable to invert matrix: #{mat}!"
      end
      result = mat.inverse * Snow::Vec3[v[0], v[1], 1.to_r]
      result[2] = 0.to_r
      result
    end

    def untransform_point(v)
      Transform.untransform_point(to_matrix, v)
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
      @scale_mat[0] = @scale[0].to_r
      @scale_mat[4] = @scale[1].to_r
      @scale_is_dirty = false
    end

    def update_rotate_matrix
      return unless @rotate_is_dirty || @rotate_mat.nil?
      @rotate_mat ||= Snow::Mat3.new
      @rotate_mat[0] = Transform.rational_cos(@rotation)
      @rotate_mat[1] = Transform.rational_sin(@rotation)
      @rotate_mat[3] = -Transform.rational_sin(@rotation)
      @rotate_mat[4] = Transform.rational_cos(@rotation)
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
