#~ require_relative '../../spec_helper'

require_relative '../transform.rb'

describe Transform do
  before(:all) do
    @read_only_tf = Transform.new
  end
  
  it 'has a center' do
    expect(@read_only_tf.center).to be_instance_of(Vector)
  end
  
  it 'has a scale' do
    expect(@read_only_tf.scale).to be_instance_of(Vector)
  end
  
  it 'has a rotation' do
    expect(@read_only_tf.rotation).to be_instance_of(Fixnum)
  end
  
  it 'has a translation' do
    expect(@read_only_tf.translation).to be_instance_of(Vector)
  end
  
  describe '#set_center' do
    it 'accepts a size 3 vector' do
      tf = Transform.new
      expect { tf.set_center(Vector[0,0,0]) }.not_to raise_error
      expect { tf.set_center(Vector[0,0,0,0]) }.to raise_error
      expect { tf.set_center(Vector[0,0]) }.to raise_error
      expect { tf.set_center(:foo) }.to raise_error
    end
    
    it 'sets the center transform' do
      v = Vector[10.to_r, 20.to_r, 0.to_r]
      tf = Transform.new
      tf.set_center(v)
      expect(tf.center).to be == v
    end
    
    it 'does not alter the z value, which should always be 0' do
      tf = Transform.new
      [
        Vector[1, 1, 1],
        Vector[1, 1, 13],
        Vector[1, 1, 7],
        Vector[1, 1, 29373],
        Vector[1, 1, -1],
        Vector[1, 1, 0],
        Vector[1, 1, -328.7],
      ].each do |v|
        tf.set_center(v)
        expect(tf.center[2]).to be == 0
      end
    end
  end
  
  describe '#set_scale' do
    it 'accepts a size 2 vector' do
      tf = Transform.new
      expect { tf.set_scale(Vector[1,1]) }.not_to raise_error
      expect { tf.set_scale(Vector[1,1,1]) }.to raise_error
      expect { tf.set_scale(Vector[1]) }.to raise_error
      expect { tf.set_scale(:foo) }.to raise_error
    end
    
    it 'sets the scale transform' do
      v = Vector[2.to_r, 0.5.to_r]
      tf = Transform.new
      tf.set_scale(v)
      expect(tf.scale).to be == v
    end
  end
  
  describe '#set_rotation' do
    it 'sets the rotation transform' do
      r = Math::PI / 2
      tf = Transform.new
      tf.set_rotation(r)
      expect(tf.rotation).to be == r
    end
  end
  
  describe '#set_translation' do
    it 'accepts a size 3 vector' do
      tf = Transform.new
      expect { tf.set_translation(Vector[0,0,0]) }.not_to raise_error
      expect { tf.set_translation(Vector[0,0,0,0]) }.to raise_error
      expect { tf.set_translation(Vector[0,0]) }.to raise_error
      expect { tf.set_translation(:foo) }.to raise_error
    end
    
    it 'sets the translation transform' do
      v = Vector[1024.to_r, 768.to_r, 0.to_r]
      tf = Transform.new
      tf.set_translation(v)
      expect(tf.translation).to be == v
    end
    
    it 'does not alter the z value, which should always be 0' do
      tf = Transform.new
      [
        Vector[1, 1, 1],
        Vector[1, 1, 13],
        Vector[1, 1, 7],
        Vector[1, 1, 29373],
        Vector[1, 1, -1],
        Vector[1, 1, 0],
        Vector[1, 1, -328.7],
      ].each do |v|
        tf.set_translation(v)
        expect(tf.translation[2]).to be == 0
      end
    end
  end
  
  describe '#to_matrix' do
    it 'returns a matrix' do
      expect(@read_only_tf.to_matrix).to be_instance_of(Matrix)
    end
  end
  
  it 'centers correctly' do
    tf = Transform.new
    tf.set_center(Vector[10.to_r, 20.to_r, 0.to_r])
    expected_matrix = Matrix[
      [1, 0, -10],
      [0, 1, -20],
      [0, 0,   1]
    ]
    expect(tf.to_matrix).to be == expected_matrix
  end
  
  it 'scales correctly' do
    tf = Transform.new
    tf.set_scale(Vector[2.to_r, 0.5.to_r])
    expected_matrix = Matrix[
      [2,   0, 0],
      [0, 0.5, 0],
      [0,   0, 1]
    ]
    expect(tf.to_matrix).to be == expected_matrix
  end
  
  it 'rotates correctly' do
    tf = Transform.new
    tf.set_rotation(Math::PI / 2)
    expected_matrix = Matrix[
      [ 0, 1, 0],
      [-1, 0, 0],
      [ 0, 0, 1]
    ]
    expect(tf.to_matrix).to be == expected_matrix
  end
  
  it 'translates correctly' do
    tf = Transform.new
    tf.set_translation(Vector[1024.to_r, 768.to_r, 0.to_r])
    expected_matrix = Matrix[
      [1, 0, 1024],
      [0, 1,  768],
      [0, 0,    1]
    ]
    expect(tf.to_matrix).to be == expected_matrix
  end
  
  it 'applies all transforms in the correct order' do
    tf = Transform.new
    tf.set_center(Vector[10.to_r, 20.to_r, 0.to_r])
    tf.set_scale(Vector[2.to_r, 0.5.to_r])
    tf.set_rotation(Math::PI / 2)
    tf.set_translation(Vector[1024.to_r, 768.to_r, 0.to_r])
    
    expected_matrix = Matrix[
      [0.0, 0.5, 1014.0],
      [-2.0, 0.0, 788.0],
      [0.0, 0.0, 1.0]
    ]
    expect(tf.to_matrix).to be == expected_matrix
    
    v = Vector[0.to_r, -50.to_r, 1.to_r]
    v_transformed = Vector[989.to_r, 788.to_r, 1.to_r]
    expect(tf.to_matrix * v).to be == v_transformed

    v = Vector[100.to_r, -50.to_r, 1.to_r]
    v_transformed = Vector[989.to_r, 588.to_r, 1.to_r]
    expect(tf.to_matrix * v).to be == v_transformed

    v = Vector[100.to_r, 50.to_r, 1.to_r]
    v_transformed = Vector[1039.to_r, 588.to_r, 1.to_r]
    expect(tf.to_matrix * v).to be == v_transformed

    v = Vector[0.to_r, 50.to_r, 1.to_r]
    v_transformed = Vector[1039.to_r, 788.to_r, 1.to_r]
    expect(tf.to_matrix * v).to be == v_transformed
  end
  
  describe '#transform_point' do
    it 'expects a length 3 vector' do
      expect { @read_only_tf.transform_point(Vector[1, 0, 1]) }.not_to raise_error
      expect { @read_only_tf.transform_point(Vector[1, 0, 1, 1]) }.to raise_error
      expect { @read_only_tf.transform_point(Vector[1, 0]) }.to raise_error
      expect { @read_only_tf.transform_point(:foo) }.to raise_error
      expect { @read_only_tf.transform_point(nil) }.to raise_error
    end
    
    it 'returns a length 3 vector' do
      result = @read_only_tf.transform_point(Vector[1, 0, 1])
      expect(result).to be_instance_of(Vector)
      expect(result.size).to be == 3
    end
    
    it 'always returns a z value of 0' do
      [
        Vector[1, 1, 1],
        Vector[-1, -1, -1],
        Vector[-22, -22, 0],
        Vector[-11, 13, 34],
        Vector[37, -4, -15],
        Vector[34, 39, -16],
        Vector[-48, 23, -32],
        Vector[24, -39, 42],
        Vector[49, 44, -15],
        Vector[27, 23, 42],
        Vector[33, -25, -20],
        Vector[-46, -18, 48],
      ].each do |v|
        expect(@read_only_tf.transform_point(v)[2]).to be == 0
      end
    end
    
    it 'transforms the point correctly' do
      tf = Transform.new
      tf.set_center(Vector[5.to_r, 20.to_r, 0.to_r])
      tf.set_scale(Vector[2.to_r, 0.5.to_r])
      tf.set_rotation(Math::PI / 2)
      tf.set_translation(Vector[1024.to_r, 768.to_r, 0.to_r])

      [
        [0, 0],
        [10, -20],
        [-1024, -768],
        [-5, 999],
        [5, 20]
      ].each do |pt|
        x, y = pt
        expect(tf.transform_point(Vector[x, y, 0])).to be == Vector[(y - 20) * 0.5 + 1024, (x - 5) * -2 + 768, 0]
      end
    end
  end
  
  describe '#untransform_point' do
    it 'expects a length 3 vector' do
      expect { @read_only_tf.untransform_point(Vector[1, 0, 1]) }.not_to raise_error
      expect { @read_only_tf.untransform_point(Vector[1, 0, 1, 1]) }.to raise_error
      expect { @read_only_tf.untransform_point(Vector[1, 0]) }.to raise_error
      expect { @read_only_tf.untransform_point(:foo) }.to raise_error
      expect { @read_only_tf.untransform_point(nil) }.to raise_error
    end
    
    it 'returns a length 3 vector' do
      result = @read_only_tf.untransform_point(Vector[1, 0, 1])
      expect(result).to be_instance_of(Vector)
      expect(result.size).to be == 3
    end
    
    it 'always returns a z value of 0' do
      [
        Vector[1, 1, 1],
        Vector[-1, -1, -1],
        Vector[-22, -22, 0],
        Vector[-11, 13, 34],
        Vector[37, -4, -15],
        Vector[34, 39, -16],
        Vector[-48, 23, -32],
        Vector[24, -39, 42],
        Vector[49, 44, -15],
        Vector[27, 23, 42],
        Vector[33, -25, -20],
        Vector[-46, -18, 48],
      ].each do |v|
        expect(@read_only_tf.untransform_point(v)[2]).to be == 0
      end
    end
    
    it 'untransforms the point correctly' do
      tf = Transform.new
      tf.set_center(Vector[5.to_r, 20.to_r, 0.to_r])
      tf.set_scale(Vector[2.to_r, 0.5.to_r])
      tf.set_rotation(Math::PI / 2)
      tf.set_translation(Vector[1024.to_r, 768.to_r, 0.to_r])

      [
        [1014, 778],
        [1004, 758],
        [630, 2826],
        [788, 3027],
        [768, 1024]
      ].each do |pt|
        x, y = pt
        expect(tf.untransform_point(Vector[x, y, 0])).to be == Vector[(y - 768) * -0.5 + 5, (x - 1024) * 2 + 20, 0]
      end
    end
    
    it 'undoes the results of transform_point' do
      tf = Transform.new
      tf.set_center(Vector[5.to_r, 20.to_r, 0.to_r])
      tf.set_scale(Vector[2.to_r, 0.5.to_r])
      tf.set_rotation(Math::PI / 2)
      tf.set_translation(Vector[1024.to_r, 768.to_r, 0.to_r])
      
      [
        Vector[1, 1, 0],
        Vector[-1, -1, 0],
        Vector[-22, -22, 0],
        Vector[-11, 13, 0],
        Vector[37, -4, 0],
        Vector[34, 39, 0],
        Vector[-48, 23, 0],
        Vector[24, -39, 0],
        Vector[49, 44, 0],
        Vector[27, 23, 0],
        Vector[33, -25, 0],
        Vector[-46, -18, 0],
      ].each do |v|
        expect(tf.untransform_point(tf.transform_point(v))).to be == v
        expect(tf.transform_point(tf.untransform_point(v))).to be == v
      end
    end
  end
  
  #~ describe '#combine_matrices' do
    #~ it 'accepts one or more matrices' do
      #~ expect { Transform.combine_matrices(Matrix.identity(3)) }.not_to raise_error
      #~ expect { Transform.combine_matrices(Matrix.identity(3), Matrix.identity(3)) }.not_to raise_error
      #~ expect { Transform.combine_matrices(Matrix.identity(3), Matrix.identity(3), Matrix.identity(3)) }.not_to raise_error
      #~ expect { Transform.combine_matrices(Matrix.identity(3), Matrix.identity(3), Matrix.identity(3), Matrix.identity(3)) }.not_to raise_error

      #~ expect { Transform.combine_matrices(Matrix.identity(3), :foo) }.to raise_error
      #~ expect { Transform.combine_matrices(:bar, Matrix.identity(3)) }.to raise_error
      #~ expect { Transform.combine_matrices(nil) }.to raise_error
    #~ end
    
    #~ it 'given m0, m1, m2 returns the same result as m0 * m1 * m2' do
      #~ center_tf = Transform.new
      #~ center_tf.set_center(Vector[10.to_r, 20.to_r, 0.to_r])

      #~ scale_tf = Transform.new
      #~ scale_tf.set_scale(Vector[2.to_r, 0.5.to_r])

      #~ rotate_tf = Transform.new
      #~ rotate_tf.set_rotation(Math::PI / 2)

      #~ translate_tf = Transform.new
      #~ translate_tf.set_translation(Vector[1024.to_r, 768.to_r, 0.to_r])
      
      #~ normal_combination = translate_tf.to_matrix * rotate_tf.to_matrix * scale_tf.to_matrix * center_tf.to_matrix
      #~ faster_combination = Transform.combine_matrices(translate_tf.to_matrix, rotate_tf.to_matrix, scale_tf.to_matrix, center_tf.to_matrix)
      #~ expect(faster_combination).to be == normal_combination
    #~ end
  #~ end
end
