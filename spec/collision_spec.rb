require 'set'

def clean_shape(shape)
  shape.x = 0
  shape.y = 0
  shape.center_x = 0
  shape.center_y = 0
  shape.scale_x = 1
  shape.scale_y = 1
  shape.rotation = 0
end

def clean_rect(rect)
  rect.x = 0
  rect.y = 0
  rect.center_x = 5
  rect.center_y = 5
  rect.scale_x = 1
  rect.scale_y = 1
  rect.rotation = 0
end

def clean_sprite(sprite)
  sprite.x = 0
  sprite.y = 0
  sprite.center_x = 8
  sprite.center_y = 8
  sprite.scale_x = 1
  sprite.scale_y = 1
  sprite.rotation = 0
end

def create_inheritance_chain(ancestry)
  (1...ancestry.length).each do |i|
    ancestry[i-1].add_child(ancestry[i])
  end
end

def break_inheritance_chain(ancestry)
  ancestry.each do |actor|
    actor.parent.remove_child(actor) if actor.parent
  end
end

describe Gosling::Collision do
  before(:all) do
    @window = Gosu::Window.new(640, 480, false)
    @local_path = File.dirname(__FILE__)
    @image = Gosling::ImageLibrary.get(File.join(@local_path, 'images/nil.png'))

    @actor1 = Gosling::Actor.new(@window)

    @actor2 = Gosling::Actor.new(@window)

    @circle1 = Gosling::Circle.new(@window)
    @circle1.radius = 5

    @circle2 = Gosling::Circle.new(@window)
    @circle2.radius = 5

    @polygon1 = Gosling::Polygon.new(@window)
    @polygon1.set_vertices([
      Snow::Vec3[ 0,  5, 0],
      Snow::Vec3[ 5, -5, 0],
      Snow::Vec3[-5, -5, 0]
    ])

    @polygon2 = Gosling::Polygon.new(@window)
    @polygon2.set_vertices([
      Snow::Vec3[ 0, -5, 0],
      Snow::Vec3[ 5, 5, 0],
      Snow::Vec3[-5, 5, 0]
    ])

    @rect1 = Gosling::Rect.new(@window)
    @rect1.width = 10
    @rect1.height = 10
    @rect1.center_x = 5
    @rect1.center_y = 5

    @rect2 = Gosling::Rect.new(@window)
    @rect2.width = 10
    @rect2.height = 10
    @rect2.center_x = 5
    @rect2.center_y = 5
    @rect2.rotation = Math::PI / 4

    @sprite1 = Gosling::Sprite.new(@window)
    @sprite1.set_image(@image)
    @sprite1.center_x = 8
    @sprite1.center_y = 8

    @sprite2 = Gosling::Sprite.new(@window)
    @sprite2.set_image(@image)
    @sprite2.center_x = 8
    @sprite2.center_y = 8

    @center_actor = Gosling::Actor.new(@window)
    @center_actor.center_x = 5
    @center_actor.center_y = 5

    @scale_actor = Gosling::Actor.new(@window)
    @scale_actor.scale_x = 3.5
    @scale_actor.scale_y = 2.5

    @rotate_actor = Gosling::Actor.new(@window)
    @rotate_actor.rotation = Math::PI * -0.5

    @translate_actor = Gosling::Actor.new(@window)
    @translate_actor.x = 128
    @translate_actor.y = 256
  end

  describe '#test' do
    context 'any actor vs. itself' do
      it 'never collides' do
        [@actor1, @circle1, @polygon1, @rect1, @sprite1].each do |actor|
          expect(Gosling::Collision.test(actor, actor)).to be false
        end
      end
    end

    context 'actor vs. actor' do
      it 'never collides' do
        expect(Gosling::Collision.test(@actor1, @actor2)).to be false
      end
    end

    context 'actor vs. circle' do
      it 'never collides' do
        expect(Gosling::Collision.test(@actor1, @circle1)).to be false
      end
    end

    context 'actor vs. polygon' do
      it 'never collides' do
        expect(Gosling::Collision.test(@actor1, @polygon1)).to be false
      end
    end

    context 'actor vs. rect' do
      it 'never collides' do
        expect(Gosling::Collision.test(@actor1, @rect1)).to be false
      end
    end

    context 'actor vs. sprite' do
      it 'never collides' do
        expect(Gosling::Collision.test(@actor1, @sprite1)).to be false
      end
    end

    context 'circle vs. circle' do
      it 'collides if the shapes are close enough' do
        clean_shape(@circle1)
        @circle1.x = 0
        @circle1.y = 0

        clean_shape(@circle2)
        @circle2.x = 5
        @circle2.y = 5

        expect(Gosling::Collision.test(@circle1, @circle2)).to be true
      end

      it 'does not collide if the shapes are far apart' do
        clean_shape(@circle1)
        @circle1.x = 0
        @circle1.y = 0

        clean_shape(@circle2)
        @circle2.x = 10
        @circle2.y = 5

        expect(Gosling::Collision.test(@circle1, @circle2)).to be false
      end
    end

    context 'circle vs. polygon' do
      it 'collides if the shapes are close enough' do
        clean_shape(@circle1)
        @circle1.x = 0
        @circle1.y = 0

        clean_shape(@polygon1)
        @polygon1.x = 5
        @polygon1.y = 5

        expect(Gosling::Collision.test(@circle1, @polygon1)).to be true
      end

      it 'does not collide if the shapes are far apart' do
        clean_shape(@circle1)
        @circle1.x = 0
        @circle1.y = 0

        clean_shape(@polygon1)
        @polygon1.x = 10
        @polygon1.y = 10

        expect(Gosling::Collision.test(@circle1, @polygon1)).to be false
      end
    end

    context 'circle vs. rect' do
      it 'collides if the shapes are close enough' do
        clean_shape(@circle1)
        @circle1.x = 0
        @circle1.y = 0

        clean_rect(@rect1)
        @rect1.x = 5
        @rect1.y = 5

        expect(Gosling::Collision.test(@circle1, @rect1)).to be true
      end

      it 'does not collide if the shapes are far apart' do
        clean_shape(@circle1)
        @circle1.x = 0
        @circle1.y = 0

        clean_rect(@rect1)
        @rect1.x = 10
        @rect1.y = 10

        expect(Gosling::Collision.test(@circle1, @rect1)).to be false
      end
    end

    context 'circle vs. sprite' do
      it 'collides if the shapes are close enough' do
        clean_shape(@circle1)
        @circle1.x = 0
        @circle1.y = 0

        clean_sprite(@sprite1)
        @sprite1.x = 8
        @sprite1.y = 8

        expect(Gosling::Collision.test(@circle1, @sprite1)).to be true
      end

      it 'does not collide if the shapes are far apart' do
        clean_shape(@circle1)
        @circle1.x = 0
        @circle1.y = 0

        clean_sprite(@sprite1)
        @sprite1.x = 16
        @sprite1.y = 16

        expect(Gosling::Collision.test(@circle1, @sprite1)).to be false
      end
    end

    context 'polygon vs. polygon' do
      it 'collides if the shapes are close enough' do
        clean_shape(@polygon1)
        @polygon1.x = 0
        @polygon1.y = 0

        clean_shape(@polygon2)
        @polygon2.x = 0
        @polygon2.y = 5

        expect(Gosling::Collision.test(@polygon1, @polygon2)).to be true
      end

      it 'does not collide if the shapes are far apart' do
        clean_shape(@polygon1)
        @polygon1.x = 0
        @polygon1.y = 0

        clean_shape(@polygon2)
        @polygon2.x = 5
        @polygon2.y = 5

        expect(Gosling::Collision.test(@polygon1, @polygon2)).to be false
      end
    end

    context 'polygon vs. rect' do
      it 'collides if the shapes are close enough' do
        clean_shape(@polygon1)
        @polygon1.x = 0
        @polygon1.y = 0

        clean_rect(@rect1)
        @rect1.x = 5
        @rect1.y = 5

        expect(Gosling::Collision.test(@polygon1, @rect1)).to be true
      end

      it 'does not collide if the shapes are far apart' do
        clean_shape(@polygon1)
        @polygon1.x = 0
        @polygon1.y = 0

        clean_rect(@rect1)
        @rect1.x = 10
        @rect1.y = 5

        expect(Gosling::Collision.test(@polygon1, @rect1)).to be false
      end
    end

    context 'polygon vs. sprite' do
      it 'collides if the shapes are close enough' do
        clean_shape(@polygon1)
        @polygon1.x = 0
        @polygon1.y = 0

        clean_sprite(@sprite1)
        @sprite1.x = 8
        @sprite1.y = 8

        expect(Gosling::Collision.test(@polygon1, @sprite1)).to be true
      end

      it 'does not collide if the shapes are far apart' do
        clean_shape(@polygon1)
        @polygon1.x = 0
        @polygon1.y = 0

        clean_sprite(@sprite1)
        @sprite1.x = 13
        @sprite1.y = 8

        expect(Gosling::Collision.test(@polygon1, @sprite1)).to be false
      end
    end

    context 'rect vs. rect' do
      it 'collides if the shapes are close enough' do
        clean_rect(@rect1)
        @rect1.x = 0
        @rect1.y = 0

        clean_rect(@rect2)
        @rect2.x = 5
        @rect2.y = 5

        expect(Gosling::Collision.test(@rect1, @rect2)).to be true
      end

      it 'does not collide if the shapes are far apart' do
        clean_rect(@rect1)
        @rect1.x = 0
        @rect1.y = 0

        clean_shape(@rect2)
        @rect2.x = 11
        @rect2.y = 5

        expect(Gosling::Collision.test(@rect1, @rect2)).to be false
      end
    end

    context 'rect vs. sprite' do
      it 'collides if the shapes are close enough' do
        clean_rect(@rect1)
        @rect1.x = 0
        @rect1.y = 0

        clean_sprite(@sprite1)
        @sprite1.x = 8
        @sprite1.y = 8

        expect(Gosling::Collision.test(@rect1, @sprite1)).to be true
      end

      it 'does not collide if the shapes are far apart' do
        clean_rect(@rect1)
        @rect1.x = 0
        @rect1.y = 0

        clean_sprite(@sprite1)
        @sprite1.x = 16
        @sprite1.y = 8

        expect(Gosling::Collision.test(@rect1, @sprite1)).to be false
      end
    end

    context 'sprite vs. sprite' do
      it 'collides if the shapes are close enough' do
        clean_sprite(@sprite1)
        @sprite1.x = 0
        @sprite1.y = 0

        clean_sprite(@sprite2)
        @sprite2.x = 8
        @sprite2.y = 8

        expect(Gosling::Collision.test(@sprite1, @sprite2)).to be true
      end

      it 'does not collide if the shapes are far apart' do
        clean_sprite(@sprite1)
        @sprite1.x = 0
        @sprite1.y = 0

        clean_sprite(@sprite2)
        @sprite2.x = 17
        @sprite2.y = 8

        expect(Gosling::Collision.test(@sprite1, @sprite2)).to be false
      end
    end
  end

  describe '#is_point_in_shape?' do
    it 'expects a point and an actor' do
      expect { Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, 0, 0], @actor1) }.not_to raise_error

      expect { Gosling::Collision.is_point_in_shape?(@actor1, Snow::Vec3[0, 0, 0]) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.is_point_in_shape?(@actor1, :foo) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.is_point_in_shape?(:bar, Snow::Vec3[0, 0, 0]) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.is_point_in_shape?() }.to raise_error(ArgumentError)
    end

    context 'point vs. actor' do
      it 'never collides' do
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, 0, 0], @actor1)).to be false
      end
    end

    context 'point vs. circle' do
      it 'returns true if point is in shape' do
        clean_shape(@circle1)
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, 0, 0], @circle1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[4, 0, 0], @circle1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-4, 0, 0], @circle1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, 4, 0], @circle1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, -4, 0], @circle1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[5, 0, 0], @circle1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-5, 0, 0], @circle1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, 5, 0], @circle1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, -5, 0], @circle1)).to be true
      end

      it 'returns false if point is not in shape' do
        clean_shape(@circle1)
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[6, 0, 0], @circle1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-6, 0, 0], @circle1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, 6, 0], @circle1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, -6, 0], @circle1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[4, 4, 0], @circle1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-4, 4, 0], @circle1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-4, -4, 0], @circle1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[4, -4, 0], @circle1)).to be false
      end
    end

    context 'point vs. polygon' do
      it 'returns true if point is in shape' do
        clean_shape(@polygon1)
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, 0, 0], @polygon1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, 4, 0], @polygon1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, -4, 0], @polygon1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[4, -4, 0], @polygon1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-4, -4, 0], @polygon1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, 5, 0], @polygon1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, -5, 0], @polygon1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[5, -5, 0], @polygon1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-5, -5, 0], @polygon1)).to be true
      end

      it 'returns false if point is not in shape' do
        clean_shape(@polygon1)
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, 6, 0], @polygon1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, -6, 0], @polygon1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[6, -6, 0], @polygon1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-6, -6, 0], @polygon1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[4, 4, 0], @polygon1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-4, 4, 0], @polygon1)).to be false
      end
    end

    context 'point vs. rect' do
      it 'returns true if point is in shape' do
        clean_rect(@rect1)
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, 0, 0], @rect1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-4, -4, 0], @rect1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, -4, 0], @rect1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[4, -4, 0], @rect1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[4, 0, 0], @rect1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[4, 4, 0], @rect1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, 4, 0], @rect1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-4, 4, 0], @rect1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-4, 0, 0], @rect1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-5, -5, 0], @rect1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, -5, 0], @rect1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[5, -5, 0], @rect1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[5, 0, 0], @rect1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[5, 5, 0], @rect1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, 5, 0], @rect1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-5, 5, 0], @rect1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-5, 0, 0], @rect1)).to be true
      end

      it 'returns false if point is not in shape' do
        clean_rect(@rect1)
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-6, -6, 0], @rect1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, -6, 0], @rect1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[6, -6, 0], @rect1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[6, 0, 0], @rect1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[6, 6, 0], @rect1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, 6, 0], @rect1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-6, 6, 0], @rect1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-6, 0, 0], @rect1)).to be false
      end
    end

    context 'point vs. sprite' do
      it 'returns true if point is in shape' do
        clean_sprite(@sprite1)
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, 0, 0], @sprite1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-7, -7, 0], @sprite1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, -7, 0], @sprite1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[7, -7, 0], @sprite1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[7, 0, 0], @sprite1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[7, 7, 0], @sprite1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, 7, 0], @sprite1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-7, 7, 0], @sprite1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-7, 0, 0], @sprite1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-8, -8, 0], @sprite1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, -8, 0], @sprite1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[8, -8, 0], @sprite1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[8, 0, 0], @sprite1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[8, 8, 0], @sprite1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, 8, 0], @sprite1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-8, 8, 0], @sprite1)).to be true
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-8, 0, 0], @sprite1)).to be true
      end

      it 'returns false if point is not in shape' do
        clean_sprite(@sprite1)
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-9, -9, 0], @sprite1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, -9, 0], @sprite1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[9, -9, 0], @sprite1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[9, 0, 0], @sprite1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[9, 9, 0], @sprite1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[0, 9, 0], @sprite1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-9, 9, 0], @sprite1)).to be false
        expect(Gosling::Collision.is_point_in_shape?(Snow::Vec3[-9, 0, 0], @sprite1)).to be false
      end
    end
  end

  describe '#get_normal' do
    it 'expects a 3d vector' do
      expect { Gosling::Collision.get_normal(Snow::Vec3[1, 0, 0]) }.not_to raise_error
      expect { Gosling::Collision.get_normal(Snow::Vec3[1, 0, 1, 0]) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.get_normal(Snow::Vec3[1, 0]) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.get_normal(:foo) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.get_normal(nil) }.to raise_error(ArgumentError)
    end

    it 'returns a 3d vector' do
      result = Gosling::Collision.get_normal(Snow::Vec3[1, 0, 0])
      expect(result).to be_instance_of(Snow::Vec3)
    end

    it 'z value of returned vector is always 0' do
      [
        Snow::Vec3[1, 1, 0],
        Snow::Vec3[-1, -1, -1],
        Snow::Vec3[-22, -22, 0],
        Snow::Vec3[-11, 13, 34],
        Snow::Vec3[37, -4, -15],
        Snow::Vec3[34, 39, -16],
        Snow::Vec3[-48, 23, -32],
        Snow::Vec3[24, -39, 42],
        Snow::Vec3[49, 44, -15],
        Snow::Vec3[27, 23, 42],
        Snow::Vec3[33, -25, -20],
        Snow::Vec3[-46, -18, 48],
      ].each do |v|
        expect(Gosling::Collision.get_normal(v)[2]).to be == 0
      end
    end

    it 'raises an error when given a zero length vector' do
      expect { Gosling::Collision.get_normal(Snow::Vec3[0, 0, 0]) }.to raise_error(ArgumentError)
    end

    it 'returns a vector that is +/- 90 degrees from the original' do
      [
        Snow::Vec3[1, 1, 0],
        Snow::Vec3[-1, -1, -1],
        Snow::Vec3[-22, -22, 0],
        Snow::Vec3[-11, 13, 34],
        Snow::Vec3[37, -4, -15],
        Snow::Vec3[34, 39, -16],
        Snow::Vec3[-48, 23, -32],
        Snow::Vec3[24, -39, 42],
        Snow::Vec3[49, 44, -15],
        Snow::Vec3[27, 23, 42],
        Snow::Vec3[33, -25, -20],
        Snow::Vec3[-46, -18, 48],
      ].each do |v|
        norm_v = Gosling::Collision.get_normal(v)
        radians = Math.acos(v.dot_product(norm_v) / (v.magnitude * norm_v.magnitude))
        expect(radians.abs).to be == Math::PI / 2
      end
    end
  end

  describe '#get_polygon_separation_axes' do
    it 'expects an array of length 3 vectors' do
      good_vector_array = [
        Snow::Vec3[3, 1, 0],
        Snow::Vec3[4, 2, 0],
        Snow::Vec3[5, 3, 0],
        Snow::Vec3[1, 4, 0],
        Snow::Vec3[2, 5, 0]
      ]
      bad_vector_array = [
        Snow::Vec2[9, 11],
        Snow::Vec3[7, 12, 0],
        Snow::Vec4[5, 13, 1, 0],
        Snow::Vec2[3, 14],
        Snow::Vec2[1, 15]
      ]
      p = Gosling::Polygon.new(@window)
      expect { Gosling::Collision.get_polygon_separation_axes(good_vector_array) }.not_to raise_error
      expect { Gosling::Collision.get_polygon_separation_axes(bad_vector_array) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.get_polygon_separation_axes(p.get_vertices) }.not_to raise_error
      expect { Gosling::Collision.get_polygon_separation_axes(p) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.get_polygon_separation_axes(:foo) }.to raise_error(ArgumentError)
    end

    it 'returns an array of 3d vectors' do
      vertices = [
        Snow::Vec3[3, 1, 0],
        Snow::Vec3[4, 2, 0],
        Snow::Vec3[5, 3, 0],
        Snow::Vec3[1, 4, 0],
        Snow::Vec3[2, 5, 0]
      ]
      result = Gosling::Collision.get_polygon_separation_axes(vertices)
      expect(result).to be_instance_of(Array)
      expect(result.reject { |v| v.is_a?(Snow::Vec3) }).to be_empty
    end

    it 'skips length zero sides' do
      vertices = [
        Snow::Vec3[1, 1, 0],
        Snow::Vec3[1, 1, 0],
        Snow::Vec3[1, 2, 0],
        Snow::Vec3[2, 2, 0],
        Snow::Vec3[2, 2, 0]
      ]
      result = Gosling::Collision.get_polygon_separation_axes(vertices)
      expect(result.length).to be == 3
    end

    it 'returns correct values' do
      vertices = [
        Snow::Vec3[ 2,  1, 0],
        Snow::Vec3[ 1, -1, 0],
        Snow::Vec3[ 0, -2, 0],
        Snow::Vec3[-1, -1, 0],
        Snow::Vec3[-1,  2, 0]
      ]
      result = Gosling::Collision.get_polygon_separation_axes(vertices)
      expect(result.length).to be == 5
      expect(result[0]).to be == Snow::Vec3[ 2, -1, 0].normalize
      expect(result[1]).to be == Snow::Vec3[ 1, -1, 0].normalize
      expect(result[2]).to be == Snow::Vec3[-1, -1, 0].normalize
      expect(result[3]).to be == Snow::Vec3[-3,  0, 0].normalize
      expect(result[4]).to be == Snow::Vec3[ 1,  3, 0].normalize
    end
  end

  describe '#get_circle_separation_axis' do
    it 'expects two shape arguments' do
      expect { Gosling::Collision.get_circle_separation_axis(@circle1, @circle2) }.not_to raise_error
      expect { Gosling::Collision.get_circle_separation_axis(@circle1, @polygon1) }.not_to raise_error
      expect { Gosling::Collision.get_circle_separation_axis(@rect1, @circle2) }.not_to raise_error

      expect { Gosling::Collision.get_circle_separation_axis(:foo, @circle2) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.get_circle_separation_axis(@circle1, @circle2, @circle1) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.get_circle_separation_axis(@circle1) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.get_circle_separation_axis() }.to raise_error(ArgumentError)
      expect { Gosling::Collision.get_circle_separation_axis(:foo) }.to raise_error(ArgumentError)
    end

    it 'returns a 3d vector' do
      clean_shape(@circle1)
      @circle1.x = 0
      @circle1.y = 0

      clean_shape(@circle2)
      @circle2.x = 10
      @circle2.y = -5

      result = Gosling::Collision.get_circle_separation_axis(@circle1, @circle2)
      expect(result).to be_instance_of(Snow::Vec3)
    end

    it "returns nil if distance beween shape centers is 0" do
      clean_shape(@circle1)
      @circle1.x = 0
      @circle1.y = 0

      clean_shape(@circle2)
      @circle2.x = 0
      @circle2.y = 0

      result = Gosling::Collision.get_circle_separation_axis(@circle1, @circle2)
      expect(result).to be nil
    end

    it 'returns a correct unit vector' do
      clean_shape(@circle1)
      @circle1.x = 5
      @circle1.y = -10

      clean_shape(@circle2)
      @circle2.x = 10
      @circle2.y = -5

      result = Gosling::Collision.get_circle_separation_axis(@circle1, @circle2)
      expect(result).to be == Snow::Vec3[1, 1, 0].normalize
    end
  end

  describe '#get_separation_axes' do
    it 'expects two shapes' do
      expect { Gosling::Collision.get_separation_axes(@circle1, @circle2) }.not_to raise_error
      expect { Gosling::Collision.get_separation_axes(@circle1, @polygon2) }.not_to raise_error
      expect { Gosling::Collision.get_separation_axes(@polygon1, @polygon2) }.not_to raise_error
      expect { Gosling::Collision.get_separation_axes(@polygon1, @rect2) }.not_to raise_error
      expect { Gosling::Collision.get_separation_axes(@sprite1, @polygon2) }.not_to raise_error

      expect { Gosling::Collision.get_separation_axes(@actor1, @circle2) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.get_separation_axes(@circle1, @circle2, @polygon2) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.get_separation_axes(@circle1, 1) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.get_separation_axes(@polygon1, :foo) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.get_separation_axes(:foo) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.get_separation_axes() }.to raise_error(ArgumentError)
    end

    it 'returns an array of 3d vectors' do
      result = Gosling::Collision.get_separation_axes(@polygon1, @polygon2)
      expect(result).to be_instance_of(Array)
      expect(result.reject { |v| v.is_a?(Snow::Vec3) }).to be_empty
    end

    it 'returns only unit vectors' do
      result = Gosling::Collision.get_separation_axes(@polygon1, @circle1)
      expect(result).to be_instance_of(Array)
      result.each do |v|
        expect(v).to be_instance_of(Snow::Vec3)
        expect(v.magnitude).to be_between(0.99999999, 1.00000001)
      end
    end

    it 'returns only right-facing (positive x direction) vectors' do
      result = Gosling::Collision.get_separation_axes(@rect2, @polygon1)
      expect(result).to be_instance_of(Array)
      expect(result.reject { |v| v.is_a?(Snow::Vec3) && v[0] >= 0 }).to be_empty
    end

    it 'returns only unique vectors' do
      result = Gosling::Collision.get_separation_axes(@rect2, @polygon2)
      expect(result).to be_instance_of(Array)
      expect(result.uniq.length).to be == result.length
    end

    it 'is commutative' do
      result1 = Gosling::Collision.get_separation_axes(@rect2, @polygon2)
      result2 = Gosling::Collision.get_separation_axes(@polygon2, @rect2)
      expect(result1.map { |x| x.to_s }.sort).to be == result2.map { |x| x.to_s }.sort
    end

    it 'respects centering' do
      clean_shape(@polygon1)
      @polygon1.center_x = 10
      @polygon1.center_y = 2

      clean_shape(@circle1)

      result = Gosling::Collision.get_separation_axes(@polygon1, @circle1)
      expect(result).to be == [
        Snow::Vec3[10, 5, 0].normalize,
        Snow::Vec3[0, -10, 0].normalize,
        Snow::Vec3[10, -5, 0].normalize
      ]
    end

    it 'respects scaling' do
      clean_shape(@polygon1)
      @polygon1.scale_x = 3
      @polygon1.scale_y = 2

      clean_shape(@circle1)

      result = Gosling::Collision.get_separation_axes(@polygon1, @circle1)
      expect(result).to be == [
        Snow::Vec3[20, 15, 0].normalize,
        Snow::Vec3[0, -30, 0].normalize,
        Snow::Vec3[20, -15, 0].normalize
      ]
    end

    it 'respects rotation' do
      clean_shape(@polygon1)
      @polygon1.rotation = Math::PI / 2
      result = Gosling::Collision.get_separation_axes(@polygon1, @circle1)

      clean_shape(@circle1)

      expect(result).to be == [
        Snow::Vec3[5, -10, 0].normalize,
        Snow::Vec3[10, 0, 0].normalize,
        Snow::Vec3[5, 10, 0].normalize
      ]
    end

    it 'respects translation' do
      clean_shape(@polygon1)
      @polygon1.x = -50
      @polygon1.y = 10

      clean_shape(@circle1)

      result = Gosling::Collision.get_separation_axes(@polygon1, @circle1)
      expect(result).to be == [
        Snow::Vec3[10, 5, 0].normalize,
        Snow::Vec3[0, -10, 0].normalize,
        Snow::Vec3[10, -5, 0].normalize,
        Snow::Vec3[50, -10, 0].normalize
      ]
    end

    context 'with two polygons' do
      it 'returns an array with no more axes than total vertices, and no less than two' do
        [
          [@polygon1, @polygon2],
          [@polygon1, @rect1],
          [@polygon1, @rect2],
          [@polygon1, @sprite1],
          [@polygon1, @sprite2],
          [@polygon2, @rect1],
          [@polygon2, @rect2],
          [@polygon2, @sprite1],
          [@polygon2, @sprite2],
          [@rect1, @rect2],
          [@rect1, @sprite1],
          [@rect1, @sprite2],
          [@rect2, @sprite1],
          [@rect2, @sprite2],
          [@sprite1, @sprite2]
        ].each do |shapes|
          result = Gosling::Collision.get_separation_axes(*shapes)
          vertex_count = 0
          shapes.each { |s| vertex_count += s.get_vertices.length }
          expect(result.length).to be_between(2, vertex_count).inclusive
        end
      end
    end

    context 'with two circles' do
      context 'when both circles have the same center' do
        it 'returns an empty array' do
          @circle1.x = 0
          @circle1.y = 0
          @circle2.x = 0
          @circle2.y = 0
          result = Gosling::Collision.get_separation_axes(@circle1, @circle2)
          expect(result).to be_instance_of(Array)
          expect(result).to be_empty
        end
      end

      it 'returns an array with one axis' do
        @circle1.x = 1
        @circle1.y = 0
        @circle2.x = 17
        @circle2.y = -5
        result = Gosling::Collision.get_separation_axes(@circle1, @circle2)
        expect(result).to be_instance_of(Array)
        expect(result.length).to be == 1
      end
    end

    context 'with a polygon and a circle' do
      it 'returns an array with no more axes than total vertices plus one, and no less than two' do
        [
          [@circle1, @polygon1],
          [@circle2, @polygon2],
          [@circle1, @rect1],
          [@circle2, @rect2],
          [@circle1, @sprite1],
          [@circle2, @sprite2]
        ].each do |shapes|
          result = Gosling::Collision.get_separation_axes(*shapes)
          vertex_count = shapes[1].get_vertices.length
          expect(result.length).to be_between(2, vertex_count + 1).inclusive
        end
      end
    end
  end

  describe '#project_onto_axis' do
    it 'expects a shape and a 3d unit vector' do
      axis = Snow::Vec3[1, 1, 0]

      expect { Gosling::Collision.project_onto_axis(@sprite1, axis) }.not_to raise_error
      expect { Gosling::Collision.project_onto_axis(@rect1, axis) }.not_to raise_error
      expect { Gosling::Collision.project_onto_axis(@circle1, axis) }.not_to raise_error
      expect { Gosling::Collision.project_onto_axis(@polygon1, axis) }.not_to raise_error

      expect { Gosling::Collision.project_onto_axis(:foo, axis) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.project_onto_axis(@sprite1, Snow::Vec4[1, 1, 0, 2]) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.project_onto_axis(@rect1, Snow::Vec2[1, 1]) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.project_onto_axis(@polygon1, :foo) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.project_onto_axis(@circle1, @circle1, axis) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.project_onto_axis() }.to raise_error(ArgumentError)
    end

    it 'returns an array of two numbers' do
      axis = Snow::Vec3[1, 1, 0]
      result = Gosling::Collision.project_onto_axis(@polygon1, axis)
      expect(result).to be_instance_of(Array)
      expect(result.length).to be == 2
      expect(result.reject { |x| x.is_a?(Numeric) }).to be_empty
    end

    context 'with a circle' do
      it 'returns expected values' do
        clean_shape(@circle1)
        @circle1.x = 0
        @circle1.y = 0
        @circle1.radius = 5

        axis = Snow::Vec3[-1, 1, 0].normalize
        result = Gosling::Collision.project_onto_axis(@circle1, axis)
        expect(result).to be == [-5, 5]

        clean_shape(@circle1)
        @circle1.x = 5
        @circle1.y = 0
        @circle1.radius = 5

        axis = Snow::Vec3[1, 0, 0].normalize
        result = Gosling::Collision.project_onto_axis(@circle1, axis)
        expect(result).to be == [0, 10]
      end

      it 'respects centering' do
        clean_shape(@circle1)
        @circle1.center_x = 3
        @circle1.center_y = 6

        axis = Snow::Vec3[1, 0, 0].normalize
        result = Gosling::Collision.project_onto_axis(@circle1, axis)
        expect(result).to be == [-8, 2]

        axis = Snow::Vec3[0, 1, 0].normalize
        result = Gosling::Collision.project_onto_axis(@circle1, axis)
        expect(result).to be == [-11, -1]
      end

      it 'respects scaling' do
        clean_shape(@circle1)
        @circle1.scale_x = 2
        @circle1.scale_y = 0.5

        axis = Snow::Vec3[1, 0, 0].normalize
        result = Gosling::Collision.project_onto_axis(@circle1, axis)
        expect(result).to be == [-10, 10]

        axis = Snow::Vec3[0, 1, 0].normalize
        result = Gosling::Collision.project_onto_axis(@circle1, axis)
        expect(result).to be == [-2.5, 2.5]
      end

      it 'respects rotation' do
        clean_shape(@circle1)
        @circle1.rotation = Math::PI

        axis = Snow::Vec3[1, 0, 0].normalize
        result = Gosling::Collision.project_onto_axis(@circle1, axis)
        expect(result).to be == [-5, 5]
      end

      it 'respects translation' do
        clean_shape(@circle1)
        @circle1.x = -12
        @circle1.y = 23

        axis = Snow::Vec3[1, 0, 0].normalize
        result = Gosling::Collision.project_onto_axis(@circle1, axis)
        expect(result).to be == [-17, -7]

        axis = Snow::Vec3[0, 1, 0].normalize
        result = Gosling::Collision.project_onto_axis(@circle1, axis)
        expect(result).to be == [18, 28]
      end

      it 'respects its entire ancestry of transforms' do
        circle = Gosling::Circle.new(@window)
        clean_shape(circle)
        circle.radius = 10

        create_inheritance_chain([@center_actor, @scale_actor, @rotate_actor, @translate_actor, circle])

        axis = Snow::Vec3[1, 0, 0].normalize
        result = Gosling::Collision.project_onto_axis(circle, axis)
        expect(result).to be == [-936.0, -866.0]

        axis = Snow::Vec3[0, 1, 0].normalize
        result = Gosling::Collision.project_onto_axis(circle, axis)
        expect(result).to be == [290.0, 340.0]

        axis = Snow::Vec3[1, 1, 0].normalize
        result = Gosling::Collision.project_onto_axis(circle, axis)
        expect(result).to be == [-443.1343965537543, -385.5947509968793]

        break_inheritance_chain([@center_actor, @scale_actor, @rotate_actor, @translate_actor, circle])
      end
    end

    context 'with a polygon' do
      it 'returns expected values' do
        axis = Snow::Vec3[1, 0, 0].normalize
        clean_shape(@polygon2)
        @polygon2.x = 0
        @polygon2.y = 0
        result = Gosling::Collision.project_onto_axis(@polygon2, axis)
        expect(result).to be == [-5, 5]

        axis = Snow::Vec3[0, 1, 0].normalize
        clean_shape(@polygon1)
        @polygon1.x = 0
        @polygon1.y = 5
        result = Gosling::Collision.project_onto_axis(@polygon1, axis)
        expect(result).to be == [0, 10]

        axis = Snow::Vec3[1, -1, 0].normalize
        clean_shape(@polygon1)
        @polygon1.x = 0
        @polygon1.y = 0
        result = Gosling::Collision.project_onto_axis(@polygon1, axis)
        expect(result[0]).to be_within(0.00000001).of(-Math.sqrt(25 * 0.5))
        expect(result[1]).to be_within(0.00000001).of(Math.sqrt(50))
      end

      it 'respects centering' do
        clean_shape(@polygon1)
        @polygon1.center_x = 5
        @polygon1.center_y = -1

        axis = Snow::Vec3[1, 0, 0].normalize
        result = Gosling::Collision.project_onto_axis(@polygon1, axis)
        expect(result).to be == [-10, 0]

        axis = Snow::Vec3[0, 1, 0].normalize
        result = Gosling::Collision.project_onto_axis(@polygon1, axis)
        expect(result).to be == [-4, 6]
      end

      it 'respects scaling' do
        clean_shape(@polygon1)
        @polygon1.scale_x = 3
        @polygon1.scale_y = 2

        axis = Snow::Vec3[1, 0, 0].normalize
        result = Gosling::Collision.project_onto_axis(@polygon1, axis)
        expect(result).to be == [-15, 15]

        axis = Snow::Vec3[0, 1, 0].normalize
        result = Gosling::Collision.project_onto_axis(@polygon1, axis)
        expect(result).to be == [-10, 10]
      end

      it 'respects rotation' do
        clean_shape(@polygon1)
        @polygon1.rotation = Math::PI / 4

        axis = Snow::Vec3[1, 0, 0].normalize
        result = Gosling::Collision.project_onto_axis(@polygon1, axis)
        expect(result).to be == [-7.0710678118654755, 3.5355339059327373]

        axis = Snow::Vec3[0, 1, 0].normalize
        result = Gosling::Collision.project_onto_axis(@polygon1, axis)
        expect(result).to be == [-7.0710678118654755, 3.5355339059327378]
      end

      it 'respects translation' do
        clean_shape(@polygon1)
        @polygon1.x = -7
        @polygon1.y = 13

        axis = Snow::Vec3[1, 0, 0].normalize
        result = Gosling::Collision.project_onto_axis(@polygon1, axis)
        expect(result).to be == [-12, -2]

        axis = Snow::Vec3[0, 1, 0].normalize
        result = Gosling::Collision.project_onto_axis(@polygon1, axis)
        expect(result).to be == [8, 18]
      end

      it 'respects its entire ancestry of transforms' do
        polygon = Gosling::Polygon.new(@window)
        clean_shape(polygon)
        polygon.set_vertices(@polygon1.get_vertices)

        create_inheritance_chain([@center_actor, @scale_actor, @rotate_actor, @translate_actor, polygon])

        axis = Snow::Vec3[1, 0, 0].normalize
        result = Gosling::Collision.project_onto_axis(polygon, axis)
        expect(result).to be == [-918.5, -883.5]

        axis = Snow::Vec3[0, 1, 0].normalize
        result = Gosling::Collision.project_onto_axis(polygon, axis)
        expect(result).to be == [302.5, 327.5]

        axis = Snow::Vec3[1, 1, 0].normalize
        result = Gosling::Collision.project_onto_axis(polygon, axis)
        expect(result).to be == [-426.7389424460814, -393.1513703397204]

        break_inheritance_chain([@center_actor, @scale_actor, @rotate_actor, @translate_actor, polygon])
      end
    end
  end

  describe '#projections_overlap?' do
    it 'accepts two length 2 arrays with numbers' do
      expect { Gosling::Collision.projections_overlap?([0, 0], [0, 0]) }.not_to raise_error
      expect { Gosling::Collision.projections_overlap?([1, 2], [3, -4]) }.not_to raise_error

      expect { Gosling::Collision.projections_overlap?([1, 2, 3], [4, 5, 6]) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.projections_overlap?([1], [4]) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.projections_overlap?([1, 2], [3, -4], [5, 6]) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.projections_overlap?([1, 2]) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.projections_overlap?([1, 2], :foo) }.to raise_error(ArgumentError)
      expect { Gosling::Collision.projections_overlap?(nil, [1, 2]) }.to raise_error(ArgumentError)
    end

    context 'when a and b do not overlap' do
      it 'returns false' do
        expect(Gosling::Collision.projections_overlap?([0, 10], [20, 30])).to be false
        expect(Gosling::Collision.projections_overlap?([-20, -30], [0, 10])).to be false
      end
    end

    context 'when a contains b' do
      it 'returns true' do
        expect(Gosling::Collision.projections_overlap?([0, 40], [20, 30])).to be true
        expect(Gosling::Collision.projections_overlap?([-40, 0], [-25, -15])).to be true
        expect(Gosling::Collision.projections_overlap?([-2, 0], [-1, 0])).to be true
      end
    end

    context 'when b contains a' do
      it 'returns true' do
        expect(Gosling::Collision.projections_overlap?([5, 10], [0, 50])).to be true
        expect(Gosling::Collision.projections_overlap?([-10, 10], [-25, 25])).to be true
        expect(Gosling::Collision.projections_overlap?([5, 6], [5, 10])).to be true
      end
    end

    context 'when a overlaps b' do
      it 'returns true' do
        expect(Gosling::Collision.projections_overlap?([-10, 10], [0, 20])).to be true
        expect(Gosling::Collision.projections_overlap?([-1000, 0], [-1, 314159])).to be true
      end
    end

    context 'when a touches b' do
      it 'returns true' do
        expect(Gosling::Collision.projections_overlap?([-10, 0], [0, 10])).to be true
        expect(Gosling::Collision.projections_overlap?([-5, 30], [-17, -5])).to be true
      end
    end
  end
end
