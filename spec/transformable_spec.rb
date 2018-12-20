class TransformableThing
  include Gosling::Transformable
end

describe Gosling::Transformable do
  before(:all) do
    @read_only_tf = TransformableThing.new
  end

  it 'has a center' do
    expect(@read_only_tf.center).to be_instance_of(Snow::Vec3)
  end

  it 'has a scale' do
    expect(@read_only_tf.scale).to be_instance_of(Snow::Vec2)
  end

  it 'has a rotation' do
    expect(@read_only_tf.rotation).to be_kind_of(Numeric)
  end

  it 'has a translation' do
    expect(@read_only_tf.translation).to be_instance_of(Snow::Vec3)
  end

  it 'has methods for getting its x/y position' do
    expect(@read_only_tf.x).to be_kind_of(Numeric)
    expect(@read_only_tf.y).to be_kind_of(Numeric)
  end

  it 'has methods for setting its x/y position' do
    @read_only_tf.x = 13
    @read_only_tf.y = -7
    expect(@read_only_tf.x).to be == 13
    expect(@read_only_tf.y).to be == -7
  end

  it 'has methods for getting its x/y centerpoint' do
    expect(@read_only_tf.center_x).to be_kind_of(Numeric)
    expect(@read_only_tf.center_y).to be_kind_of(Numeric)
  end

  it 'has methods for setting its x/y centerpoint' do
    @read_only_tf.center_x = 5
    @read_only_tf.center_y = 15
    expect(@read_only_tf.center_x).to be == 5
    expect(@read_only_tf.center_y).to be == 15
  end

  it 'has methods for getting its x/y scaling' do
    expect(@read_only_tf.scale_x).to be_kind_of(Numeric)
    expect(@read_only_tf.scale_y).to be_kind_of(Numeric)
  end

  it 'has methods for setting its x/y scaling' do
    @read_only_tf.scale_x = 2
    @read_only_tf.scale_y = 3
    expect(@read_only_tf.scale_x).to be == 2
    expect(@read_only_tf.scale_y).to be == 3
  end

  it 'has a method for getting its rotation' do
    expect(@read_only_tf.rotation).to be_kind_of(Numeric)
  end

  it 'has a method for setting its rotation' do
    @read_only_tf.rotation = Math::PI
    expect(@read_only_tf.rotation).to be == Math::PI
  end

  describe '#center=' do
    it 'accepts a size 3 vector' do
      tf = TransformableThing.new
      expect { tf.center = Snow::Vec3[0, 0, 0] }.not_to raise_error
      expect { tf.center = [0, 0, 0] }.not_to raise_error
      expect { tf.center = :foo }.to raise_error(ArgumentError)
    end

    it 'sets the center transform' do
      v = Snow::Vec3[10.to_r, 20.to_r, 1.to_r]
      tf = TransformableThing.new
      tf.center = v
      expect(tf.center).to be == v
    end

    it 'does not alter the z value, which should always be 1' do
      tf = TransformableThing.new
      [
        Snow::Vec3[1, 1, 1],
        Snow::Vec3[1, 1, 13],
        Snow::Vec3[1, 1, 7],
        Snow::Vec3[1, 1, 29373],
        Snow::Vec3[1, 1, -1],
        Snow::Vec3[1, 1, 0],
        Snow::Vec3[1, 1, -328.7],
      ].each do |v|
        tf.center = v
        expect(tf.center[2]).to be == 1
      end
    end
  end

  describe '#set_scale' do
    it 'accepts a size 2 vector, an equivalent, or a single numeric value' do
      tf = TransformableThing.new
      expect { tf.scale = Snow::Vec2[1, 1] }.not_to raise_error
      expect { tf.scale = [1, 1] }.not_to raise_error
      expect { tf.scale = 1 }.not_to raise_error
      expect { tf.set_scale([1, 1]) }.not_to raise_error
      expect { tf.set_scale(1, 1) }.not_to raise_error
      expect { tf.set_scale(1) }.not_to raise_error
      expect { tf.scale = :foo }.to raise_error(ArgumentError)
    end

    it 'sets the scale transform' do
      v = Snow::Vec2[2.to_r, 0.5.to_r]
      tf = TransformableThing.new
      tf.scale = v
      expect(tf.scale).to be == v
    end

    context 'when given a single value' do
      it 'sets the x and y scaling' do
        tf = TransformableThing.new
        tf.scale = 2.7
        expect(tf.scale.x).to eq(2.7)
        expect(tf.scale.y).to eq(2.7)
      end
    end
  end

  describe '#set_rotation' do
    it 'sets the rotation transform' do
      r = Math::PI / 2
      tf = TransformableThing.new
      tf.rotation = r
      expect(tf.rotation).to be == r
    end

    it 'does not allow non-finite floats' do
      tf = TransformableThing.new
      expect { tf.rotation = Float::NAN }.to raise_error(ArgumentError)
      expect { tf.rotation = Float::INFINITY }.to raise_error(ArgumentError)
    end
  end

  describe '#set_translation' do
    it 'accepts a size 3 vector' do
      tf = TransformableThing.new
      expect { tf.translation = Snow::Vec3[0, 0, 0] }.not_to raise_error
      expect { tf.translation = :foo }.to raise_error(ArgumentError)
    end

    it 'sets the translation transform' do
      v = Snow::Vec3[1024.to_r, 768.to_r, 1.to_r]
      tf = TransformableThing.new
      tf.translation = v
      expect(tf.translation).to be == v
    end

    it 'does not alter the z value, which should always be 1' do
      tf = TransformableThing.new
      [
        Snow::Vec3[1, 1, 1],
        Snow::Vec3[1, 1, 13],
        Snow::Vec3[1, 1, 7],
        Snow::Vec3[1, 1, 29373],
        Snow::Vec3[1, 1, -1],
        Snow::Vec3[1, 1, 0],
        Snow::Vec3[1, 1, -328.7],
      ].each do |v|
        tf.translation = v
        expect(tf.translation[2]).to be == 1
      end
    end
  end

  describe '#to_matrix' do
    it 'returns a matrix' do
      expect(@read_only_tf.to_matrix).to be_instance_of(Snow::Mat3)
    end
  end

  it 'centers correctly' do
    tf = TransformableThing.new
    tf.center = Snow::Vec3[10.to_r, 20.to_r, 0.to_r]
    expected_matrix = Snow::Mat3[
                        1, 0, -10,
                        0, 1, -20,
                        0, 0,   1
                      ]
    expect(tf.to_matrix).to be == expected_matrix
  end

  it 'scales correctly' do
    tf = TransformableThing.new
    tf.scale = Snow::Vec2[2.to_r, 0.5.to_r]
    expected_matrix = Snow::Mat3[
                        2,   0, 0,
                        0, 0.5, 0,
                        0,   0, 1
                      ]
    expect(tf.to_matrix).to be == expected_matrix
  end

  it 'rotates correctly' do
    tf = TransformableThing.new
    tf.rotation = Math::PI / 2
    expected_matrix = Snow::Mat3[
                         0, 1, 0,
                        -1, 0, 0,
                         0, 0, 1
                      ]
    expect(tf.to_matrix).to be == expected_matrix
  end

  it 'translates correctly' do
    tf = TransformableThing.new
    tf.translation = Snow::Vec3[1024.to_r, 768.to_r, 0.to_r]
    expected_matrix = Snow::Mat3[
                        1, 0, 1024,
                        0, 1,  768,
                        0, 0,    1
                      ]
    expect(tf.to_matrix).to be == expected_matrix
  end

  it 'applies all transforms in the correct order' do
    tf = TransformableThing.new
    tf.center = Snow::Vec3[10.to_r, 20.to_r, 0.to_r]
    tf.scale = Snow::Vec2[2.to_r, 0.5.to_r]
    tf.rotation = Math::PI / 2
    tf.translation = Snow::Vec3[1024.to_r, 768.to_r, 0.to_r]

    expected_matrix = Snow::Mat3[
                        0.0, 0.5, 1014.0,
                        -2.0, 0.0, 788.0,
                        0.0, 0.0, 1.0
                      ]
    expect(tf.to_matrix).to be == expected_matrix

    v = Snow::Vec3[0.to_r, -50.to_r, 1.to_r]
    v_transformed = Snow::Vec3[989.to_r, 788.to_r, 1.to_r]
    expect(tf.to_matrix * v).to be == v_transformed

    v = Snow::Vec3[100.to_r, -50.to_r, 1.to_r]
    v_transformed = Snow::Vec3[989.to_r, 588.to_r, 1.to_r]
    expect(tf.to_matrix * v).to be == v_transformed

    v = Snow::Vec3[100.to_r, 50.to_r, 1.to_r]
    v_transformed = Snow::Vec3[1039.to_r, 588.to_r, 1.to_r]
    expect(tf.to_matrix * v).to be == v_transformed

    v = Snow::Vec3[0.to_r, 50.to_r, 1.to_r]
    v_transformed = Snow::Vec3[1039.to_r, 788.to_r, 1.to_r]
    expect(tf.to_matrix * v).to be == v_transformed
  end

  describe '#transform_point' do
    it 'expects a length 3 vector' do
      expect { @read_only_tf.transform_point(Snow::Vec3[1, 0, 1]) }.not_to raise_error
      expect { @read_only_tf.transform_point(:foo) }.to raise_error(ArgumentError)
      expect { @read_only_tf.transform_point(nil) }.to raise_error(ArgumentError)
    end

    it 'returns a length 3 vector' do
      result = @read_only_tf.transform_point(Snow::Vec3[1, 0, 1])
      expect(result).to be_instance_of(Snow::Vec3)
    end

    it 'always returns a z value of 0' do
      [
        Snow::Vec3[1, 1, 1],
        Snow::Vec3[-1, -1, -1],
        Snow::Vec3[-22, -22, 0],
        Snow::Vec3[-11, 13, 34],
        Snow::Vec3[37, -4, -15],
        Snow::Vec3[34, 39, -16],
        Snow::Vec3[-48, 23, -32],
        Snow::Vec3[24, -39, 42],
        Snow::Vec3[49, 44, -15],
        Snow::Vec3[27, 23, 42],
        Snow::Vec3[33, -25, -20],
        Snow::Vec3[-46, -18, 48],
      ].each do |v|
        expect(@read_only_tf.transform_point(v)[2]).to be == 0
      end
    end

    it 'transforms the point correctly' do
      tf = TransformableThing.new
      tf.center = Snow::Vec3[5.to_r, 20.to_r, 0.to_r]
      tf.scale = Snow::Vec2[2.to_r, 0.5.to_r]
      tf.rotation = Math::PI / 2
      tf.translation = Snow::Vec3[1024.to_r, 768.to_r, 0.to_r]

      [
        [0, 0],
        [10, -20],
        [-1024, -768],
        [-5, 999],
        [5, 20]
      ].each do |pt|
        x, y = pt
        expect(tf.transform_point(Snow::Vec3[x, y, 0])).to be == Snow::Vec3[(y - 20) * 0.5 + 1024, (x - 5) * -2 + 768, 0]
      end
    end
  end

  describe '#untransform_point' do
    it 'expects a length 3 vector' do
      expect { @read_only_tf.untransform_point(Snow::Vec3[1, 0, 1]) }.not_to raise_error
      expect { @read_only_tf.untransform_point(:foo) }.to raise_error(ArgumentError)
      expect { @read_only_tf.untransform_point(nil) }.to raise_error(ArgumentError)
    end

    it 'returns a length 3 vector' do
      result = @read_only_tf.untransform_point(Snow::Vec3[1, 0, 1])
      expect(result).to be_instance_of(Snow::Vec3)
    end

    it 'always returns a z value of 0' do
      [
        Snow::Vec3[1, 1, 1],
        Snow::Vec3[-1, -1, -1],
        Snow::Vec3[-22, -22, 0],
        Snow::Vec3[-11, 13, 34],
        Snow::Vec3[37, -4, -15],
        Snow::Vec3[34, 39, -16],
        Snow::Vec3[-48, 23, -32],
        Snow::Vec3[24, -39, 42],
        Snow::Vec3[49, 44, -15],
        Snow::Vec3[27, 23, 42],
        Snow::Vec3[33, -25, -20],
        Snow::Vec3[-46, -18, 48],
      ].each do |v|
        expect(@read_only_tf.untransform_point(v)[2]).to be == 0
      end
    end

    it 'untransforms the point correctly' do
      tf = TransformableThing.new
      tf.center = Snow::Vec3[5.to_r, 20.to_r, 0.to_r]
      tf.scale = Snow::Vec2[2.to_r, 0.5.to_r]
      tf.rotation = Math::PI / 2
      tf.translation = Snow::Vec3[1024.to_r, 768.to_r, 0.to_r]

      [
        [1014, 778],
        [1004, 758],
        [630, 2826],
        [788, 3027],
        [768, 1024]
      ].each do |pt|
        x, y = pt
        expect(tf.untransform_point(Snow::Vec3[x, y, 0])).to be == Snow::Vec3[(y - 768) * -0.5 + 5, (x - 1024) * 2 + 20, 0]
      end
    end

    it 'undoes the results of transform_point' do
      tf = TransformableThing.new
      tf.center = Snow::Vec3[5.to_r, 20.to_r, 0.to_r]
      tf.scale = Snow::Vec2[2.to_r, 0.5.to_r]
      tf.rotation = Math::PI / 2
      tf.translation = Snow::Vec3[1024.to_r, 768.to_r, 0.to_r]

      [
        Snow::Vec3[1, 1, 0],
        Snow::Vec3[-1, -1, 0],
        Snow::Vec3[-22, -22, 0],
        Snow::Vec3[-11, 13, 0],
        Snow::Vec3[37, -4, 0],
        Snow::Vec3[34, 39, 0],
        Snow::Vec3[-48, 23, 0],
        Snow::Vec3[24, -39, 0],
        Snow::Vec3[49, 44, 0],
        Snow::Vec3[27, 23, 0],
        Snow::Vec3[33, -25, 0],
        Snow::Vec3[-46, -18, 0],
      ].each do |v|
        expect(tf.untransform_point(tf.transform_point(v))).to be == v
        expect(tf.transform_point(tf.untransform_point(v))).to be == v
      end
    end
  end
end
