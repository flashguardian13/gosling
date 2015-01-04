#~ sprite < rect
#~ - @image
#~ - instead of colored vertices, draws the image between its four vertices

require_relative '../../spec_helper'

require 'gosu'

require_relative '../../../gosu/common2/image_library.rb'
require_relative '../../../gosu/common2/sprite.rb'

describe Sprite do
  before(:all) do
    @window = Gosu::Window.new(640, 480, false)
    ImageLibrary.window = @window
    @local_path = File.dirname(__FILE__)
    @image = ImageLibrary.get(File.join(@local_path, 'images/key.png'))

    @sprite = Sprite.new(@window)
  end
  
  describe '#get_image' do
    it 'returns our image' do
      get_sprite = Sprite.new(@window)
      expect(get_sprite.get_image).to be == nil
      get_sprite.set_image(@image)
      expect(get_sprite.get_image).to be_instance_of(Gosu::Image)
    end
  end
  
  describe '#set_image' do
    before(:each) do
      @image_sprite = Sprite.new(@window)
      @image_sprite.set_image(@image)
    end
    
    it 'complains if given something other than an image' do
      expect { Sprite.new(@window).set_image(:foo) }.to raise_error
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
    expect { @sprite.set_width(10) }.to raise_error
    expect { @sprite.set_height(20) }.to raise_error
  end
end