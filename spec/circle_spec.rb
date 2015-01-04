#~ require_relative '../../spec_helper'

require_relative '../circle.rb'

describe Circle do
  before(:all) do
    @window = Gosu::Window.new(640, 480, false)
    @circle = Circle.new(@window)
  end
  
  it 'has a radius' do
    expect(@circle.radius).to be_kind_of(Numeric)
    @circle.radius = 13
    expect(@circle.radius).to be == 13
  end
  
  it 'radius must be 0 or more' do
    expect { @circle.radius = 0 }.not_to raise_error
    expect { @circle.radius = -13 }.to raise_error
  end
  
  describe '#get_point_at_angle' do
    it 'accepts an angle in radians' do
      expect { @circle.get_point_at_angle(Math::PI) }.not_to raise_error
      expect { @circle.get_point_at_angle(-1) }.not_to raise_error
      expect { @circle.get_point_at_angle(0) }.not_to raise_error
      expect { @circle.get_point_at_angle(1) }.not_to raise_error
      
      expect { @circle.get_point_at_angle('PI') }.to raise_error
      expect { @circle.get_point_at_angle(:foo) }.to raise_error
    end
    
    it 'returns a size three vector' do
      result = @circle.get_point_at_angle(Math::PI)
      expect(result).to be_instance_of(Vector)
      expect(result.size).to be == 3
    end
    
    it 'returns a point on this circle in local-space' do
      @circle.radius = 7
      
      angles = (0...16).map { |x| Math::PI * x / 8 }
      unit_vectors = angles.map { |a| Vector[Math.cos(a), Math.sin(a), 0] }
      
      angles.each_index do |i|
        angle = angles[i]
        unit_vector = unit_vectors[i]
        expect(@circle.get_point_at_angle(angle)).to be == unit_vector * @circle.radius
      end
    end
  end
end