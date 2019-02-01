describe Object do
  before(:all) do
    @test_object = []
  end

  describe '.unfreeze' do
    it 'allows the object to be edited after being frozen' do
      @test_object.freeze
      expect { @test_object << 'a' }.to raise_error(RuntimeError)
      @test_object.unfreeze
      expect { @test_object << 'a' }.not_to raise_error
    end

    it 'works even after multiple freeze/unfreeze cycles' do
      3.times do
        @test_object.freeze
        @test_object.unfreeze
      end
      expect { @test_object << 'a' }.not_to raise_error
    end
  end
end
