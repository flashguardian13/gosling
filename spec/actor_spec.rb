module Gosling
  class Actor
    public :render
  end
end

describe Gosling::Actor do
  before(:all) do
    @window = Gosu::Window.new(640, 480, false)
    @read_only_actor = Gosling::Actor.new(@window)
    @parent = Gosling::Actor.new(@window)
    @child = Gosling::Actor.new(@window)
  end

  describe '#new' do
    it 'requires a Gosu::Window' do
      expect { Gosling::Actor.new(@window) }.not_to raise_error
      expect { Gosling::Actor.new() }.to raise_error(ArgumentError)
    end
  end

  it 'has a transform' do
    expect(@read_only_actor).to be_kind_of(Gosling::Transformable)
  end

  it 'can have a parent' do
    expect { @read_only_actor.parent }.not_to raise_error
  end

  it "does not initialize with a parent" do
    expect(@read_only_actor.parent).to be == nil
  end

  describe '#add_child' do
    it "creates a two-way parent/child link" do
      @parent.add_child(@child)
      expect(@parent.has_child?(@child)).to be true
      expect(@child.parent).to be == @parent
    end
  end

  describe '#remove_child' do
    it "severs the two-way parent/child link" do
      @parent.add_child(@child)
      @parent.remove_child(@child)
      expect(@parent.has_child?(@child)).to be false
      expect(@child.parent).to be == nil
    end
  end

  it 'has a list of children' do
    expect(@read_only_actor.children).to be_instance_of(Array)
  end

  it "starts with no children" do
    expect(@read_only_actor.children.empty?).to be true
  end

  it "knows if it has a particular child or not" do
    expect(@read_only_actor.has_child?(Gosling::Actor.new(@window))).to be false
  end

  it "will never add any of its ancestors as children" do
    @parent.add_child(@child)
    expect { @child.add_child(@parent) }.to raise_error(Gosling::InheritanceError)
  end

  it "will not add itself as its own child" do
    expect { @child.add_child(@child) }.to raise_error(Gosling::InheritanceError)
  end

  context "when given a child" do
    before do
      @parent.add_child(@child)
    end

    it "it forms a two-way link with that child" do
      expect(@parent.has_child?(@child)).to be true
      expect(@child.parent).to be == @parent
    end

    it "cannot be given the same child more than once" do
      @parent.add_child(@child)
      expect(@parent.children.length).to be == 1
    end

    context "and then the child is removed" do
      before do
        @parent.remove_child(@child)
      end

      it "the parent/child link is broken" do
        expect(@parent.has_child?(@child)).to be false
        expect(@child.parent).to be == nil
      end
    end

    context 'and then adopted by another actor' do
      it 'automatically breaks the old child/parent link' do
        parent2 = Gosling::Actor.new(@window)
        parent2.add_child(@child)
        expect(@parent.has_child?(@child)).to be false
        expect(@child.parent).to be == parent2
      end
    end
  end

  it 'has a visibility flag' do
    actor = Gosling::Actor.new(@window)
    actor.is_visible = true
    expect(actor.is_visible).to be true
    actor.is_visible = false
    expect(actor.is_visible).to be false
  end

  it 'has a children visibility flag' do
    actor = Gosling::Actor.new(@window)
    actor.are_children_visible = true
    expect(actor.are_children_visible).to be true
    actor.are_children_visible = false
    expect(actor.are_children_visible).to be false
  end

  it 'has a tangible flag' do
    actor = Gosling::Actor.new(@window)
    actor.is_tangible = true
    expect(actor.is_tangible).to be true
    actor.is_tangible = false
    expect(actor.is_tangible).to be false
  end

  it 'has a children tangibile flag' do
    actor = Gosling::Actor.new(@window)
    actor.are_children_tangible = true
    expect(actor.are_children_tangible).to be true
    actor.are_children_tangible = false
    expect(actor.are_children_tangible).to be false
  end

  it 'has a mask flag' do
    actor = Gosling::Actor.new(@window)
    actor.is_mask = true
    expect(actor.is_mask).to be true
    actor.is_mask = false
    expect(actor.is_mask).to be false
  end

  describe '#render' do
    it 'the method exists' do
      expect { @read_only_actor.render(Snow::Mat3.new) }.not_to raise_error
    end
  end

  describe '#draw' do
    before(:all) do
      @draw_actor = Gosling::Actor.new(@window)
      @mat = Snow::Mat3.new
    end

    context 'when visible' do
      it 'calls render on itself' do
        @draw_actor.is_visible = true
        expect(@draw_actor).to receive(:render).with(@mat).once
        @draw_actor.draw(@mat)
      end
    end

    context 'when not visible' do
      it 'does not call render on itself' do
        @draw_actor.is_visible = false
        expect(@draw_actor).not_to receive(:render)
        @draw_actor.draw(@mat)
      end
    end

    context 'with children' do
      before(:all) do
        @child1 = Gosling::Actor.new(@window)
        @child2 = Gosling::Actor.new(@window)
        @draw_actor.add_child(@child1)
        @draw_actor.add_child(@child2)
      end

      context 'when are_children_visible is false' do
        it 'draws itself, but not its children' do
          @draw_actor.are_children_visible = false
          expect(@child1).not_to receive(:draw)
          expect(@child2).not_to receive(:draw)
          @draw_actor.draw(@mat)
          @draw_actor.are_children_visible = true
        end
      end

      it 'calls draw on each of its children' do
        expect(@child1).to receive(:draw).with(@mat).once
        expect(@child2).to receive(:draw).with(@mat).once
        @draw_actor.draw(@mat)
      end

      it 'passes its children a comprehensive transformation matrix' do
        parameter_mat = Snow::Mat3[
          1, 0, 10,
          0, 1, 20,
          0, 0,  1
        ]
        self_mat = Snow::Mat3[
          2, 0, 0,
          0, 3, 0,
          0, 0, 1
        ]
        result_mat = self_mat * parameter_mat

        allow(@draw_actor).to receive(:to_matrix).and_return(self_mat)

        expect(@child1).to receive(:draw).with(result_mat).once
        expect(@child2).to receive(:draw).with(result_mat).once
        @draw_actor.draw(parameter_mat)
      end

      after(:all) do
        @draw_actor.children.each { |child| @draw_actor.remove_child(@child) }
      end
    end
  end

  describe '#is_point_in_bounds' do
    it 'returns false' do
      expect(@read_only_actor.is_point_in_bounds(Snow::Vec3[0,0,1])).to be false
    end
  end

  describe '#get_actor_at' do
    before(:all) do
      @parent = Gosling::Actor.new(@window)
    end

    context 'when tangible is false' do
      it 'returns nil even if hit' do
        @parent.is_tangible = false
        allow(@parent).to receive(:is_point_in_bounds).and_return(true)
        expect(@parent.get_actor_at(Snow::Vec3[0,0,1])).to be == nil
        @parent.is_tangible = true
      end
    end

    context 'with no children' do
      it 'returns itself if the point is within its bounds' do
        allow(@parent).to receive(:is_point_in_bounds).and_return(true)
        expect(@parent.get_actor_at(Snow::Vec3[0,0,1])).to be == @parent
      end

      it 'returns nil if point is not within its bounds' do
        allow(@parent).to receive(:is_point_in_bounds).and_return(false)
        expect(@parent.get_actor_at(Snow::Vec3[0,0,1])).to be == nil
      end
    end

    context 'with two children' do
      before(:all) do
        @child1 = Gosling::Actor.new(@window)
        @child2 = Gosling::Actor.new(@window)
        @parent.add_child(@child1)
        @parent.add_child(@child2)
      end

      context 'when the children are not tangible' do
        it 'does not hit test any children' do
          @parent.are_children_tangible = false
          allow(@parent).to receive(:is_point_in_bounds).and_return(false, true)
          allow(@child1).to receive(:is_point_in_bounds).and_return(true)
          allow(@child2).to receive(:is_point_in_bounds).and_return(true)

          expect(@parent.get_actor_at(Snow::Vec3[0,0,1])).to be == nil
          expect(@parent.get_actor_at(Snow::Vec3[0,0,1])).to be == @parent
          @parent.are_children_tangible = true
        end
      end

      it "returns the second child if such is hit" do
        allow(@parent).to receive(:is_point_in_bounds).and_return(false, true,  false, true)
        allow(@child1).to receive(:is_point_in_bounds).and_return(false, false, true,  true)
        allow(@child2).to receive(:is_point_in_bounds).and_return(true)

        4.times { expect(@parent.get_actor_at(Snow::Vec3[0,0,1])).to be == @child2 }
      end

      it "returns the first child if the second was not hit" do
        allow(@parent).to receive(:is_point_in_bounds).and_return(false, true)
        allow(@child1).to receive(:is_point_in_bounds).and_return(true)
        allow(@child2).to receive(:is_point_in_bounds).and_return(false)

        2.times { expect(@parent.get_actor_at(Snow::Vec3[0,0,1])).to be == @child1 }
      end

      it "returns itself if neither child was hit" do
        allow(@parent).to receive(:is_point_in_bounds).and_return(true)
        allow(@child1).to receive(:is_point_in_bounds).and_return(false)
        allow(@child2).to receive(:is_point_in_bounds).and_return(false)

        expect(@parent.get_actor_at(Snow::Vec3[0,0,1])).to be == @parent
      end

      it 'returns nil if point is not within it or its children' do
        allow(@parent).to receive(:is_point_in_bounds).and_return(false)
        allow(@child1).to receive(:is_point_in_bounds).and_return(false)
        allow(@child2).to receive(:is_point_in_bounds).and_return(false)

        expect(@parent.get_actor_at(Snow::Vec3[0,0,1])).to be == nil
      end

      context 'with a mask child' do
        it 'returns the parent if the child is hit' do
          @child1.is_mask = true
          allow(@parent).to receive(:is_point_in_bounds).and_return(false)
          allow(@child1).to receive(:is_point_in_bounds).and_return(true)
          allow(@child2).to receive(:is_point_in_bounds).and_return(false)

          expect(@parent.get_actor_at(Snow::Vec3[0,0,1])).to be == @parent
          @child1.is_mask = false
        end
      end

      after(:all) do
        @parent.children.each { |child| @parent.remove_child(child) }
      end
    end
  end

  describe '#get_actors_at' do
    before(:all) do
      @parent = Gosling::Actor.new(@window)
    end

    context 'when tangible is false' do
      it 'returns an empty array even if hit' do
        @parent.is_tangible = false
        allow(@parent).to receive(:is_point_in_bounds).and_return(true)
        expect(@parent.get_actors_at(Snow::Vec3[0,0,1])).to be_empty
        @parent.is_tangible = true
      end
    end

    context 'with no children' do
      it 'returns an array containing itself if the point is within its bounds' do
        allow(@parent).to receive(:is_point_in_bounds).and_return(true)
        expect(@parent.get_actors_at(Snow::Vec3[0,0,1])).to be == [@parent]
      end

      it 'returns an empty array if point is not within its bounds' do
        allow(@parent).to receive(:is_point_in_bounds).and_return(false)
        expect(@parent.get_actors_at(Snow::Vec3[0,0,1])).to be_empty
      end
    end

    context 'with two children' do
      before(:all) do
        @child1 = Gosling::Actor.new(@window)
        @child2 = Gosling::Actor.new(@window)
        @parent.add_child(@child1)
        @parent.add_child(@child2)
      end

      context 'when the children are not tangible' do
        it 'ignores the children' do
          @parent.are_children_tangible = false
          allow(@parent).to receive(:is_point_in_bounds).and_return(false, true)
          allow(@child1).to receive(:is_point_in_bounds).and_return(true)
          allow(@child2).to receive(:is_point_in_bounds).and_return(true, false)

          expect(@parent.get_actors_at(Snow::Vec3[0,0,1])).to be == []
          expect(@parent.get_actors_at(Snow::Vec3[0,0,1])).to be == [@parent]
          @parent.are_children_tangible = true
        end
      end

      it "returns an array containing all actors hit" do
        allow(@parent).to receive(:is_point_in_bounds).and_return(false, true,  false, true, false, true,  false, true)
        allow(@child1).to receive(:is_point_in_bounds).and_return(false, false, true,  true, false, false, true,  true)
        allow(@child2).to receive(:is_point_in_bounds).and_return(false, false, false, false, true,  true, true,  true)

        expect(@parent.get_actors_at(Snow::Vec3[0,0,1])).to be == []
        expect(@parent.get_actors_at(Snow::Vec3[0,0,1])).to be == [@parent]
        expect(@parent.get_actors_at(Snow::Vec3[0,0,1])).to be == [@child1]
        expect(@parent.get_actors_at(Snow::Vec3[0,0,1])).to be == [@child1, @parent]
        expect(@parent.get_actors_at(Snow::Vec3[0,0,1])).to be == [@child2]
        expect(@parent.get_actors_at(Snow::Vec3[0,0,1])).to be == [@child2, @parent]
        expect(@parent.get_actors_at(Snow::Vec3[0,0,1])).to be == [@child2, @child1]
        expect(@parent.get_actors_at(Snow::Vec3[0,0,1])).to be == [@child2, @child1, @parent]
      end

      context 'with a mask child' do
        before(:all) do
          @child1.is_mask = true
        end

        it 'returns the parent if the child is hit' do
          allow(@parent).to receive(:is_point_in_bounds).and_return(false)
          allow(@child1).to receive(:is_point_in_bounds).and_return(true)
          allow(@child2).to receive(:is_point_in_bounds).and_return(false)

          expect(@parent.get_actors_at(Snow::Vec3[0,0,1])).to be == [@parent]
        end

        it 'returns the parent only once if both children are masks and are hit' do
          @child2.is_mask = true
          allow(@parent).to receive(:is_point_in_bounds).and_return(false)
          allow(@child1).to receive(:is_point_in_bounds).and_return(true)
          allow(@child2).to receive(:is_point_in_bounds).and_return(true)

          expect(@parent.get_actors_at(Snow::Vec3[0,0,1])).to be == [@parent]
          @child2.is_mask = false
        end

        it 'returns the parent only once if both parent and child are hit' do
          allow(@parent).to receive(:is_point_in_bounds).and_return(true)
          allow(@child1).to receive(:is_point_in_bounds).and_return(true)
          allow(@child2).to receive(:is_point_in_bounds).and_return(false)

          expect(@parent.get_actors_at(Snow::Vec3[0,0,1])).to be == [@parent]
        end

        after(:all) do
          @child1.is_mask = false
        end
      end

      after(:all) do
        @parent.children.each { |child| @parent.remove_child(child) }
      end
    end
  end

  describe '#get_global_transform' do
    it 'returns a 3x3 matrix' do
      result = @parent.get_global_transform
      expect(result).to be_instance_of(Snow::Mat3)
    end

    it 'is a composite of its own transform plus all of its ancestors' do
      centered_view = Gosling::Actor.new(@window)
      centered_view.center_x = 10
      centered_view.center_y = 2

      scaled_view = Gosling::Actor.new(@window)
      scaled_view.scale_x = 3
      scaled_view.scale_y = 2

      rotated_view = Gosling::Actor.new(@window)
      rotated_view.rotation = Math::PI / 4

      translated_view = Gosling::Actor.new(@window)
      translated_view.x = -50
      translated_view.y = 10

      centered_view.add_child(scaled_view)
      scaled_view.add_child(rotated_view)
      rotated_view.add_child(translated_view)
      translated_view.add_child(@parent)

      expected = @parent.to_matrix * translated_view.to_matrix * rotated_view.to_matrix * scaled_view.to_matrix * centered_view.to_matrix

      result = @parent.get_global_transform
      expect(result).to be == expected

      translated_view.remove_child(@parent)
    end
  end

  describe '#get_global_position' do
    it 'returns a 3d vector' do
      result = @parent.get_global_position
      expect(result).to be_instance_of(Snow::Vec3)
    end

    context 'with a long ancestry' do
      before do
        @parent.x = 0
        @parent.y = 0
        @parent.center_x = 0
        @parent.center_y = 0
        @parent.scale_x = 1
        @parent.scale_y = 1
        @parent.rotation = 0

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
        translated_view.add_child(@parent)

        @ancestry = [
          centered_view,
          scaled_view,
          rotated_view,
          translated_view,
          @parent
        ]
      end

      it 'respects all ancestors' do
        result = @parent.get_global_position
        expect(result).to be == Snow::Vec3[(0 + 10) * 3 - 10, (0 - 50) * -2 - 2, 0]
      end

      after do
        @ancestry.each { |actor| actor.parent.remove_child(actor) if actor.parent }
      end
    end
  end

  describe '#alpha' do
    it 'returns the alpha (transparency) value' do
      expect(@parent.alpha).to be_kind_of(Numeric)
    end

    it 'sets the alpha (transparency) value' do
      actor = Gosling::Actor.new(@window)

      actor.alpha = 128
      expect(actor.alpha).to be == 128
    end

    it 'forces numeric values to be between 0 and 255' do
      actor = Gosling::Actor.new(@window)

      actor.alpha = -128
      expect(actor.alpha).to be == 0
      actor.alpha = -1
      expect(actor.alpha).to be == 0
      actor.alpha = 256
      expect(actor.alpha).to be == 255
      actor.alpha = 1024
      expect(actor.alpha).to be == 255
    end
  end

  describe '#red' do
    it 'returns the red value' do
      expect(@parent.red).to be_kind_of(Numeric)
    end

    it 'sets the red value' do
      actor = Gosling::Actor.new(@window)

      actor.red = 128
      expect(actor.red).to be == 128
    end

    it 'forces numeric values to be between 0 and 255' do
      actor = Gosling::Actor.new(@window)

      actor.red = -128
      expect(actor.red).to be == 0
      actor.red = -1
      expect(actor.red).to be == 0
      actor.red = 256
      expect(actor.red).to be == 255
      actor.red = 1024
      expect(actor.red).to be == 255
    end
  end

  describe '#green' do
    it 'returns the green value' do
      expect(@parent.green).to be_kind_of(Numeric)
    end

    it 'sets the green value' do
      actor = Gosling::Actor.new(@window)

      actor.green = 128
      expect(actor.green).to be == 128
    end

    it 'forces numeric values to be between 0 and 255' do
      actor = Gosling::Actor.new(@window)

      actor.green = -128
      expect(actor.green).to be == 0
      actor.green = -1
      expect(actor.green).to be == 0
      actor.green = 256
      expect(actor.green).to be == 255
      actor.green = 1024
      expect(actor.green).to be == 255
    end
  end

  describe '#blue' do
    it 'returns the blue value' do
      expect(@parent.blue).to be_kind_of(Numeric)
    end

    it 'sets the blue value' do
      actor = Gosling::Actor.new(@window)

      actor.blue = 128
      expect(actor.blue).to be == 128
    end

    it 'forces numeric values to be between 0 and 255' do
      actor = Gosling::Actor.new(@window)

      actor.blue = -128
      expect(actor.blue).to be == 0
      actor.blue = -1
      expect(actor.blue).to be == 0
      actor.blue = 256
      expect(actor.blue).to be == 255
      actor.blue = 1024
      expect(actor.blue).to be == 255
    end
  end
end