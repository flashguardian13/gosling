describe Gosling::Rect do
  before(:all) do
    @window = Gosu::Window.new(640, 480, false)
    @rect = Gosling::Rect.new(@window)
  end

  it 'starts with width and height 1' do
    expect(@rect.width).to be == 1
    expect(@rect.height).to be == 1
  end

  describe '#width' do
    it 'returns our width' do
      expect(@rect.width).to be_kind_of(Numeric)
    end
  end

  describe '#set_width' do
    it 'alters our width, updating our vertices' do
      rect = Gosling::Rect.new(@window)
      rect.width = 10
      expect(rect.width).to be == 10
    end

    it 'cannot be less than one' do
      rect = Gosling::Rect.new(@window)
      expect { rect.width = 0 }.to raise_error(ArgumentError)
      expect { rect.width = -100 }.to raise_error(ArgumentError)
    end

    it 'updates our vertices' do
      expected_vertices = [
        Snow::Vec3[ 0, 0, 0],
        Snow::Vec3[11, 0, 0],
        Snow::Vec3[11, 1, 0],
        Snow::Vec3[ 0, 1, 0]
      ]

      rect = Gosling::Rect.new(@window)
      rect.width = 11
      expect(rect.get_vertices).to be == expected_vertices
    end
  end

  describe '#height' do
    it 'returns our height' do
      expect(@rect.height).to be_kind_of(Numeric)
    end
  end

  describe '#set_height' do
    it 'alters our height, updating our vertices' do
      rect = Gosling::Rect.new(@window)
      rect.height = 15
      expect(rect.height).to be == 15
    end

    it 'cannot be less than one' do
      rect = Gosling::Rect.new(@window)
      expect { rect.height = 0 }.to raise_error(ArgumentError)
      expect { rect.height = -200 }.to raise_error(ArgumentError)
    end

    it 'updates our vertices' do
      expected_vertices = [
        Snow::Vec3[0,  0, 0],
        Snow::Vec3[1,  0, 0],
        Snow::Vec3[1, 40, 0],
        Snow::Vec3[0, 40, 0]
      ]

      rect = Gosling::Rect.new(@window)
      rect.height = 40
      expect(rect.get_vertices).to be == expected_vertices
    end
  end

  it 'does not allow set_vertices to be called directly' do
    vertices = [
      Snow::Vec3[0,  0, 0],
      Snow::Vec3[1, 10, 0],
      Snow::Vec3[2, 20, 0],
      Snow::Vec3[3, 40, 0]
    ]
    expect { @rect.set_vertices(vertices) }.to raise_error(NoMethodError)
  end
end