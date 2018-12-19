describe Gosling::Polygon do
  before(:all) do
    @window = Gosu::Window.new(640, 480, false)
    @polygon = Gosling::Polygon.new(@window)
  end

  describe '#get_vertices' do
    it 'returns a list of three or more vertices' do
      expect(@polygon.get_vertices).to be_instance_of(Array)
      expect(@polygon.get_vertices[0]).to be_instance_of(Snow::Vec3)
      expect(@polygon.get_vertices.length).to be >= 3
    end
  end

  describe '#set_vertices' do
    it 'accepts an array of Vectors' do
      vertices = [
        Snow::Vec3[ 1,  0, 1],
        Snow::Vec3[ 0,  1, 1],
        Snow::Vec3[-1,  0, 1],
        Snow::Vec3[ 0, -1, 1]
      ]

      polygon = Gosling::Polygon.new(@window)
      expect { polygon.set_vertices(vertices) }.not_to raise_error
      expect(polygon.get_vertices.length).to eq(vertices.length)
      vertices.each_index do |i|
        expect(polygon.get_vertices[i].x).to eq(vertices[i].x)
        expect(polygon.get_vertices[i].y).to eq(vertices[i].y)
      end

      vertices = [
        Snow::Vec2[ 1,  0],
        Snow::Vec2[ 0,  1],
        Snow::Vec2[-1,  0]
      ]

      expect { polygon.set_vertices(vertices) }.not_to raise_error
      expect(polygon.get_vertices.length).to eq(vertices.length)
      vertices.each_index do |i|
        expect(polygon.get_vertices[i].x).to eq(vertices[i].x)
        expect(polygon.get_vertices[i].y).to eq(vertices[i].y)
      end
    end

    it 'accepts an array of arrays of numbers' do
      vertices = [
        [ 1,  0, 1],
        [ 0,  1, 1],
        [-1,  0, 1]
      ]

      polygon = Gosling::Polygon.new(@window)
      expect { polygon.set_vertices(vertices) }.not_to raise_error
      expect(polygon.get_vertices.length).to eq(vertices.length)
      vertices.each_index do |i|
        expect(polygon.get_vertices[i].x).to eq(vertices[i][0])
        expect(polygon.get_vertices[i].y).to eq(vertices[i][1])
      end

      vertices = [
        [ 1,  0],
        [ 0,  1],
        [-1,  0],
        [ 0, -1]
      ]

      expect { polygon.set_vertices(vertices) }.not_to raise_error
      expect(polygon.get_vertices.length).to eq(vertices.length)
      vertices.each_index do |i|
        expect(polygon.get_vertices[i].x).to eq(vertices[i][0])
        expect(polygon.get_vertices[i].y).to eq(vertices[i][1])
      end
    end

    it 'raises an error if the parameter is not an array' do
      polygon = Gosling::Polygon.new(@window)
      expect { polygon.set_vertices("foo") }.to raise_error(ArgumentError)
    end

    it 'raises an error if the parameter array does not contains vectors or equivalents' do
      vertices = [
        ['21', '3'],
        ['7', '-3'],
        ['4.212', '0.0']
      ]
      polygon = Gosling::Polygon.new(@window)
      expect { polygon.set_vertices(vertices) }.to raise_error(ArgumentError)
    end

    it 'raises an error if the parameter array is too short' do
      vertices = [
        Snow::Vec3[ 1,  0, 1],
        Snow::Vec3[ 0,  1, 1]
      ]

      polygon = Gosling::Polygon.new(@window)
      expect { polygon.set_vertices(vertices) }.to raise_error(ArgumentError)
    end

    it 'raises an error if any vertices in the parameter array are not at least length 2' do
      vertices = [
        Snow::Vec3[ 1,  0, 1],
        Snow::Vec3[ 0,  1, 0],
        Snow::Vec2[-1,  0],
        [0],
      ]

      polygon = Gosling::Polygon.new(@window)
      expect { polygon.set_vertices(vertices) }.to raise_error(ArgumentError)
    end
  end

  describe '#get_global_vertices' do
    before(:all) do
      @global_polygon = Gosling::Polygon.new(@window)
      @global_polygon.set_vertices([
        Snow::Vec3[1, 1, 0],
        Snow::Vec3[0, -1, 0],
        Snow::Vec3[-1, -1, 0],
        Snow::Vec3[-1, 2, 0]
      ])
    end

    it 'returns a list of three or more vertices' do
      result = @global_polygon.get_global_vertices
      expect(result).to be_instance_of(Array)
      expect(result[0]).to be_instance_of(Snow::Vec3)
      expect(result.length).to be >= 3
    end

    it 'respects centering' do
      @global_polygon.x = 0
      @global_polygon.y = 0
      @global_polygon.center_x = 10
      @global_polygon.center_y = 2
      @global_polygon.scale_x = 1
      @global_polygon.scale_y = 1
      @global_polygon.rotation = 0

      vertices = @global_polygon.get_global_vertices
      expect(vertices).to be == [
        Snow::Vec3[-9, -1, 0],
        Snow::Vec3[-10, -3, 0],
        Snow::Vec3[-11, -3, 0],
        Snow::Vec3[-11, 0, 0]
      ]
    end

    it 'respects scaling' do
      @global_polygon.x = 0
      @global_polygon.y = 0
      @global_polygon.center_x = 0
      @global_polygon.center_y = 0
      @global_polygon.scale_x = 3
      @global_polygon.scale_y = 2
      @global_polygon.rotation = 0

      vertices = @global_polygon.get_global_vertices
      expect(vertices).to be == [
        Snow::Vec3[3, 2, 0],
        Snow::Vec3[0, -2, 0],
        Snow::Vec3[-3, -2, 0],
        Snow::Vec3[-3, 4, 0]
      ]
    end

    it 'respects rotation' do
      @global_polygon.x = 0
      @global_polygon.y = 0
      @global_polygon.center_x = 0
      @global_polygon.center_y = 0
      @global_polygon.scale_x = 1
      @global_polygon.scale_y = 1
      @global_polygon.rotation = Math::PI / 2

      vertices = @global_polygon.get_global_vertices
      expect(vertices).to be == [
        Snow::Vec3[1, -1, 0],
        Snow::Vec3[-1, 0, 0],
        Snow::Vec3[-1, 1, 0],
        Snow::Vec3[2, 1, 0]
      ]
    end

    it 'respects translation' do
      @global_polygon.x = -50
      @global_polygon.y = 10
      @global_polygon.center_x = 0
      @global_polygon.center_y = 0
      @global_polygon.scale_x = 1
      @global_polygon.scale_y = 1
      @global_polygon.rotation = 0

      vertices = @global_polygon.get_global_vertices
      expect(vertices).to be == [
        Snow::Vec3[-49, 11, 0],
        Snow::Vec3[-50, 9, 0],
        Snow::Vec3[-51, 9, 0],
        Snow::Vec3[-51, 12, 0]
      ]
    end

    context 'with a long ancestry' do
      before do
        @global_polygon.x = 0
        @global_polygon.y = 0
        @global_polygon.center_x = 0
        @global_polygon.center_y = 0
        @global_polygon.scale_x = 1
        @global_polygon.scale_y = 1
        @global_polygon.rotation = 0

        centered_view = Gosling::Actor.new(@window)
        centered_view.center_x = 10
        centered_view.center_y = 2

        scaled_view = Gosling::Actor.new(@window)
        scaled_view.scale_x = 3
        scaled_view.scale_y = 2

        rotated_view = Gosling::Actor.new(@window)
        rotated_view.rotation = Math::PI / 2

        translated_view = Gosling::Actor.new(@window)
        translated_view.x = -50
        translated_view.y = 10

        centered_view.add_child(scaled_view)
        scaled_view.add_child(rotated_view)
        rotated_view.add_child(translated_view)
        translated_view.add_child(@global_polygon)

        @ancestry = [
          centered_view,
          scaled_view,
          rotated_view,
          translated_view,
          @global_polygon
        ]
      end

      it 'respects all ancestors' do
        vertices = @global_polygon.get_global_vertices
        expect(vertices).to be == [
          Snow::Vec3[(1 + 10) * 3 - 10, (1 - 50) * -2 - 2, 0],
          Snow::Vec3[(-1 + 10) * 3 - 10, (0 - 50) * -2 - 2, 0],
          Snow::Vec3[(-1 + 10) * 3 - 10, (-1 - 50) * -2 - 2, 0],
          Snow::Vec3[(2 + 10) * 3 - 10, (-1 - 50) * -2 - 2, 0]
        ]
      end

      after do
        @ancestry.each { |actor| actor.parent.remove_child(actor) if actor.parent }
      end
    end
  end
end