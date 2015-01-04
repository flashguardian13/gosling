require 'matrix'

class FastMatrix
  @@multiply_buffer = []
  @@cache = []
  
  attr_reader :array
  attr_accessor :row_count, :column_count
  
  private
  
  def initialize
    @array = nil
    reset
  end
  
  public
  
  def self.create
    if @@cache.empty?
      FastMatrix.new
    else
      @@cache.pop.reset
    end
  end
  
  def destroy
    reset
    @@cache.push(self)
    nil
  end
  
  def reset
    if @array
      @array.clear
    else
      @array = []
    end
    @row_count = 0
    @column_count = 0
    self
  end
  
  def copy_from(matrix)
    if matrix.is_a?(Matrix)
      @array = matrix.to_a.flatten
      @row_count = matrix.row_size
      @column_count = matrix.column_size
    elsif matrix.is_a?(FastMatrix)
      @array = matrix.array
      @row_count = matrix.row_count
      @column_count = matrix.column_count
    else
      raise ArgumentError.new("Cannot copy from #{matrix.inspect}!")
    end
    self
  end
  
  def to_matrix
    rows = (0...@row_count).map do |i|
      @array[(@column_count * i)...(@column_count * (i + 1))]
    end
    Matrix.rows(rows)
  end
  
  def fast_multiply(mat2, result = nil)
    raise ArgumentError.new() unless mat2.is_a?(FastMatrix) && result.is_a?(FastMatrix)
    Matrix.Raise ErrDimensionMismatch if @column_count != mat2.row_count
    
    i = 0
    while i < @row_count do
      j = 0
      while j < mat2.column_count do
        k = 0
        sum = 0
        while k < @column_count do
          sum += @array[i * @column_count + k] * mat2.array[k * mat2.column_count + j]
          k += 1
        end
        @@multiply_buffer[i * @column_count + j] = sum
        j += 1
      end
      i += 1
    end
    
    result ||= FastMatrix.create
    result.array.replace(@@multiply_buffer)
    result.row_count = @row_count
    result.column_count = mat2.column_count
    result
  end
  
  def self.combine_matrices(*matrices)
    raise ArgumentError.new("Transform.combine_matrices expects one or more matrices") unless matrices.reject { |m| m.is_a?(Matrix) }.empty?
    
    fast_matrices = matrices.map { |mat| FastMatrix.create.copy_from(mat) }
    result = nil
    fast_matrices.each do |fast_matrix|
      if result
        result.fast_multiply(fast_matrix, result)
      else
        result = fast_matrix
      end
    end
    result
  end
end

class Transform
  def self.rational_sin(r)
    r = r % (2 * Math::PI)
    return case r
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
    r = r % (2 * Math::PI)
    return case r
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
  
  attr_reader :center, :scale, :rotation, :translation
  
  def initialize
    set_center(Vector[0.to_r, 0.to_r, 0.to_r])
    set_scale(Vector[1.to_r, 1.to_r])
    set_rotation(0)
    set_translation(Vector[0.to_r, 0.to_r, 0.to_r])
  end
  
  def set_center(v)
    raise ArgumentError.new("Transform.set_center() requires a length 3 vector") unless v.is_a?(Vector) && v.size == 3
    @center = Vector[v[0], v[1], 0.to_r]
    @center_mat = Matrix[
      [1.to_r, 0.to_r, -@center[0].to_r],
      [0.to_r, 1.to_r, -@center[1].to_r],
      [0.to_r, 0.to_r, 1.to_r]
    ]
    @is_dirty = true
  end
  
  def set_scale(v)
    raise ArgumentError.new("Transform.set_scale() requires a length 2 vector") unless v.is_a?(Vector) && v.size == 2
    @scale = v
    @scale_mat = Matrix[
      [@scale[0].to_r, 0.to_r, 0.to_r],
      [0.to_r, @scale[1].to_r, 0.to_r],
      [0.to_r, 0.to_r, 1.to_r]
    ]
    @is_dirty = true
  end
  
  def set_rotation(radians)
    @rotation = radians
    @rotate_mat = Matrix[
      [Transform.rational_cos(@rotation), Transform.rational_sin(@rotation), 0.to_r],
      [-Transform.rational_sin(@rotation), Transform.rational_cos(@rotation), 0.to_r],
      [0.to_r, 0.to_r, 1.to_r]
    ]
    @is_dirty = true
  end
  
  def set_translation(v)
    raise ArgumentError.new("Transform.set_translation() requires a length 3 vector") unless v.is_a?(Vector) && v.size == 3
    @translation = Vector[v[0], v[1], 0.to_r]
    @translate_mat = Matrix[
      [1.to_r, 0.to_r, @translation[0].to_r],
      [0.to_r, 1.to_r, @translation[1].to_r],
      [0.to_r, 0.to_r, 1.to_r]
    ]
    @is_dirty = true
  end
  
  def to_matrix
    return @matrix unless @is_dirty
    #~ @matrix = @translate_mat * @rotate_mat * @scale_mat * @center_mat
    @matrix = FastMatrix.combine_matrices(@translate_mat, @rotate_mat, @scale_mat, @center_mat).to_matrix
    @is_dirty = false
    @matrix
  end
  
  def self.transform_point(mat, v)
    raise ArgumentError.new("Transform.transform_point() requires a length 3 vector") unless v.is_a?(Vector) && v.size == 3
    result = mat * Vector[v[0], v[1], 1.to_r]
    Vector[result[0], result[1], 0.to_r]
  end
  
  def transform_point(v)
    Transform.transform_point(to_matrix, v)
  end
  
  def self.untransform_point(mat, v)
    raise ArgumentError.new("Transform.transform_point() requires a length 3 vector") unless v.is_a?(Vector) && v.size == 3
    result = mat.inverse * Vector[v[0], v[1], 1.to_r]
    Vector[result[0], result[1], 0.to_r]
  end
  
  def untransform_point(v)
    Transform.untransform_point(to_matrix, v)
  end
end