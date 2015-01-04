require_relative '../../spec_helper'

require_relative '../../../gosu/common2/polygon.rb'

describe Polygon do
  before(:all) do
    @window = Gosu::Window.new(640, 480, false)
    @polygon = Polygon.new(@window)
  end
  
  describe '#get_vertices' do
    it 'returns a list of three or more vertices' do
      expect(@polygon.get_vertices).to be_instance_of(Array)
      expect(@polygon.get_vertices[0]).to be_instance_of(Vector)
      expect(@polygon.get_vertices.length).to be >= 3
    end
  end
  
  describe '#set_vertices' do
    it 'assigns new vertices' do
      vertices = [
        Vector[ 1,  0, 1],
        Vector[ 0,  1, 1],
        Vector[-1,  0, 1],
        Vector[ 0, -1, 1],
      ]
      
      polygon = Polygon.new(@window)
      polygon.set_vertices(vertices)
      expect(polygon.get_vertices).to be == vertices
    end
    
    it 'raises an error if the parameter is not an array' do
      polygon = Polygon.new(@window)
      expect { polygon.set_vertices("foo") }.to raise_error
    end
    
    it 'raises an error if the parameter array contains non-vectors' do
      vertices = [
        [ 1,  0, 1],
        [ 0,  1, 1],
        [-1,  0, 1],
        [ 0, -1, 1],
      ]
      
      polygon = Polygon.new(@window)
      expect { polygon.set_vertices(vertices) }.to raise_error
    end
    
    it 'raises an error if the parameter array is too short' do
      vertices = [
        Vector[ 1,  0, 1],
        Vector[ 0,  1, 1]
      ]
      
      polygon = Polygon.new(@window)
      expect { polygon.set_vertices(vertices) }.to raise_error
    end
    
    it 'raises an error if any vertices in the parameter array are not length 3' do
      vertices = [
        Vector[ 1,  0],
        Vector[ 0,  1],
        Vector[-1,  0],
        Vector[ 0, -1],
      ]
      
      polygon = Polygon.new(@window)
      expect { polygon.set_vertices(vertices) }.to raise_error
    end
  end
  
  describe '#get_global_vertices' do
    before(:all) do
      @global_polygon = Polygon.new(@window)
      @global_polygon.set_vertices([
        Vector[1, 1, 0],
        Vector[0, -1, 0],
        Vector[-1, -1, 0],
        Vector[-1, 2, 0]
      ])
    end
    
    it 'returns a list of three or more vertices' do
      result = @global_polygon.get_global_vertices
      expect(result).to be_instance_of(Array)
      expect(result[0]).to be_instance_of(Vector)
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
        Vector[-9, -1, 0],
        Vector[-10, -3, 0],
        Vector[-11, -3, 0],
        Vector[-11, 0, 0]
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
        Vector[3, 2, 0],
        Vector[0, -2, 0],
        Vector[-3, -2, 0],
        Vector[-3, 4, 0]
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
        Vector[1, -1, 0],
        Vector[-1, 0, 0],
        Vector[-1, 1, 0],
        Vector[2, 1, 0]
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
        Vector[-49, 11, 0],
        Vector[-50, 9, 0],
        Vector[-51, 9, 0],
        Vector[-51, 12, 0]
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
        
        centered_view = Actor.new(@window)
        centered_view.center_x = 10
        centered_view.center_y = 2
        
        scaled_view = Actor.new(@window)
        scaled_view.scale_x = 3
        scaled_view.scale_y = 2
        
        rotated_view = Actor.new(@window)
        rotated_view.rotation = Math::PI / 2
        
        translated_view = Actor.new(@window)
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
          Vector[(1 + 10) * 3 - 10, (1 - 50) * -2 - 2, 0],
          Vector[(-1 + 10) * 3 - 10, (0 - 50) * -2 - 2, 0],
          Vector[(-1 + 10) * 3 - 10, (-1 - 50) * -2 - 2, 0],
          Vector[(2 + 10) * 3 - 10, (-1 - 50) * -2 - 2, 0]
        ]
      end
      
      after do
        @ancestry.each { |actor| actor.parent.remove_child(actor) if actor.parent }
      end
    end
  end
end