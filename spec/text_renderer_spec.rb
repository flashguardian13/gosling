#~ require_relative '../../spec_helper.rb'

require 'gosu'

require_relative '../text_renderer.rb'

describe TextRenderer do
  context "before being given a Gosu::Window reference" do
    before do
      TextRenderer.window = nil
    end
    
    it "does nothing" do
      expect { TextRenderer.render("This shouldn't work yet.") }.to raise_error
    end
  end
  
  context "after being given a Gosu::Window reference" do
    before(:all) do
      TextRenderer.window = Gosu::Window.new(640, 480, false)
    end
  
    it "returns a rendered text image when given some text" do
      image = TextRenderer.render("Some Example Text!")
      expect(image).to be_instance_of(Gosu::Image)
    end
  
    context '.render' do
      it 'can receive a font argument' do
        expect { TextRenderer.render("stuff", :font => 'Geneva') }.not_to raise_error
      end
      
      it 'can receive a font size argument' do
        expect { TextRenderer.render("stuff", :font_size => 4) }.not_to raise_error
      end
      
      it 'throws an error if it receives an unexpected argument' do
        expect { TextRenderer.render("stuff", :foo => 'bar') }.to raise_error
      end
    end
    
    after(:all) do
      TextRenderer.window = nil
    end
  end
end