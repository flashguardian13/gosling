class VectorCache
  def cache
    @cache
  end
end

describe VectorCache do
  describe '.get' do
    context 'when there are no Vec3 objects available' do
      before do
        VectorCache.instance.clear
      end

      it 'creates a new Vec3 and returns it' do
        new_vector = Snow::Vec3.new
        expect(Snow::Vec3).to receive(:new).and_return(new_vector)
        v = VectorCache.instance.get
        expect(v).to equal(new_vector)
      end
    end

    context 'when there are Vec3 objects available' do
      before do
        VectorCache.instance.clear
        @recycled_vector = Snow::Vec3.new
        VectorCache.instance.recycle(@recycled_vector)
      end

      it 'does not create a new Vec3' do
        expect(Snow::Vec3).not_to receive(:new)
        VectorCache.instance.get
      end

      it 'returns one of the cached Vec3' do
        expect(VectorCache.instance.get).to eq(@recycled_vector)
      end
    end
  end

  describe '.recycle' do
    it 'expects a Vec3' do
      expect{ VectorCache.instance.recycle(Snow::Vec3.new) }.not_to raise_error
      expect{ VectorCache.instance.recycle(:foo) }.to raise_error(ArgumentError)
    end

    it 'adds the Vec3 to the cache' do
      v = Snow::Vec3.new
      VectorCache.instance.recycle(v)
      expect(VectorCache.instance.cache.values).to include(v)
    end

    it 'zeros out the Vec3' do
      v = Snow::Vec3[1, 2, 3]
      VectorCache.instance.recycle(v)
      expect(v.x).to eq(0)
      expect(v.y).to eq(0)
      expect(v.z).to eq(0)
    end
  end

  describe '.clear' do
    it 'removes all Vec3 from the cache' do
      VectorCache.instance.recycle(Snow::Vec3.new)
      VectorCache.instance.recycle(Snow::Vec3.new)
      VectorCache.instance.recycle(Snow::Vec3.new)
      VectorCache.instance.clear
      expect(VectorCache.instance.size).to eq(0)
    end
  end

  describe '.size' do
    it 'returns the number of Vec3 in the cache' do
      VectorCache.instance.clear
      VectorCache.instance.recycle(Snow::Vec3.new)
      VectorCache.instance.recycle(Snow::Vec3.new)
      VectorCache.instance.recycle(Snow::Vec3.new)
      expect(VectorCache.instance.size).to eq(3)
    end
  end
end
