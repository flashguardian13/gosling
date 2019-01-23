describe MatrixCache do
  describe '.get' do
    context 'when there are no Mat3 objects available' do
      before do
        MatrixCache.instance.clear
      end

      it 'creates a new Mat3 and returns it' do
        new_matrix = Snow::Vec3.new
        expect(Snow::Mat3).to receive(:new).and_return(new_matrix)
        m = MatrixCache.instance.get
        expect(m).to equal(new_matrix)
      end
    end
  end

  describe '.recycle' do
    it 'resets the Mat3' do
      m = Snow::Mat3[1, 2, 3, 4, 5, 6, 7, 8, 9]
      MatrixCache.instance.recycle(m)
      [0, 4, 8].each { |i| expect(m[i]).to eq(1) }
      [1, 2, 3, 5, 6, 7].each { |i| expect(m[i]).to eq(0) }
    end
  end
end
