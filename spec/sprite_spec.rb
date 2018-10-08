describe Gosling::Sprite do
  before(:all) do
    @window = Gosu::Window.new(640, 480, false)
    @local_path = File.dirname(__FILE__)
    @image = Gosling::ImageLibrary.get(File.join(@local_path, 'images/key.png'))

    @sprite = Gosling::Sprite.new(@window)
  end

  describe '#get_image' do
    it 'returns our image' do
      get_sprite = Gosling::Sprite.new(@window)
      expect(get_sprite.get_image).to be == nil
      get_sprite.set_image(@image)
      expect(get_sprite.get_image).to be_instance_of(Gosu::Image)
    end
  end

  describe '#set_image' do
    before(:each) do
      @image_sprite = Gosling::Sprite.new(@window)
      @image_sprite.set_image(@image)
    end

    it 'complains if given something other than an image' do
      expect { Gosling::Sprite.new(@window).set_image(:foo) }.to raise_error(ArgumentError)
    end

    it 'sets our image' do
      expect(@image_sprite.get_image).to be == @image
    end

    it 'automatically updates our width and height' do
      expect(@image_sprite.width).to be == @image.width
      expect(@image_sprite.height).to be == @image.height
    end
  end

  it 'does not allow set_width or set_height to be called directly' do
    expect { @sprite.set_width(10) }.to raise_error(NoMethodError)
    expect { @sprite.set_height(20) }.to raise_error(NoMethodError)
  end
end
