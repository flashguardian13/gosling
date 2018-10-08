describe Gosling::TextRenderer do
  context "before being given a Gosu::Window reference" do
    before do
      Gosling::TextRenderer.window = nil
    end

    it "does nothing" do
      expect { Gosling::TextRenderer.render("This shouldn't work yet.") }.to raise_error(Gosling::InitializationError)
    end
  end

  context "after being given a Gosu::Window reference" do
    before(:all) do
      Gosling::TextRenderer.window = Gosu::Window.new(640, 480, false)
    end

    it "returns a rendered text image when given some text" do
      image = Gosling::TextRenderer.render("Some Example Text!")
      expect(image).to be_instance_of(Gosu::Image)
    end

    context '.render' do
      it 'can receive a font argument' do
        expect { Gosling::TextRenderer.render("stuff", :font => 'Geneva') }.not_to raise_error
      end

      it 'can receive a font size argument' do
        expect { Gosling::TextRenderer.render("stuff", :font_size => 4) }.not_to raise_error
      end

      it 'throws an error if it receives an unexpected argument' do
        expect { Gosling::TextRenderer.render("stuff", :foo => 'bar') }.to raise_error(ArgumentError)
      end
    end

    after(:all) do
      Gosling::TextRenderer.window = nil
    end
  end
end