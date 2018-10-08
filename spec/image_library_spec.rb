describe Gosling::ImageLibrary do
  context "before given a valid Gosu::Window reference" do
    before do
      Gosling::ImageLibrary.window = nil
    end

    it "does nothing" do
      expect { Gosling::ImageLibrary.get("C:/Users/Ben/Pictures/icons/me_64.png") }.to raise_error(Gosling::InitializationError)
    end
  end

  context "after being given a Gosu::Window reference" do
    before do
      Gosling::ImageLibrary.window = Gosu::Window.new(640, 480, false)
    end

    it "returns a Gosu:Image reference when given a filename" do
      expect(Gosling::ImageLibrary.get("C:/Users/Ben/Pictures/icons/me_64.png")).to be_instance_of(Gosu::Image)
    end

    it "raises an argument error if the file does not exist" do
      expect { Gosling::ImageLibrary.get("C:/does/not/exist.png") }.to raise_error(ArgumentError)
    end

    it "does not create a new Gosu:Image if it already has one cached" do
      image_a = Gosling::ImageLibrary.get("C:/Users/Ben/Pictures/icons/me_64.png")
      image_b = Gosling::ImageLibrary.get("C:/Users/Ben/Pictures/icons/me_64.png")
      expect(image_a).to be == image_b
    end
  end
end
