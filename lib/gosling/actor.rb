require_relative 'transform.rb'

require 'gosu'

module Gosling
  class Actor
    attr_reader :transform, :parent, :children, :window
    attr_accessor :is_visible, :is_tangible, :are_children_visible, :are_children_tangible, :is_mask, :color

    def initialize(window)
      @window = window
      @transform = Transform.new
      @parent = nil
      @children = []
      @is_visible = true
      @is_tangible = true
      @are_children_visible = true
      @are_children_tangible = true
      @is_mask = false
      @color = Gosu::Color.from_hsv(rand(360), rand(), rand())
    end

    def inspect
      "#<#{self.class}:#{self.object_id}>"
    end

    def add_child(child)
      return if @children.include?(child)
      raise Gosling::InheritanceError.new("An Actor cannot be made a child of itself.") if child == self
      ancestor = parent
      until ancestor.nil?
        raise Gosling::InheritanceError.new("Adding a child's ancestor as a child would create a circular reference.") if child == ancestor
        ancestor = ancestor.parent
      end

      child.parent.remove_child(child) if child.parent
      @children.push(child)
      child.parent = self
    end

    def remove_child(child)
      return unless @children.include?(child)

      @children.delete(child)
      child.parent = nil
    end

    def has_child?(child)
      @children.include?(child)
    end

    def x
      @transform.translation.x
    end

    def x=(val)
      @transform.translation = val, @transform.translation.y
    end

    def y
      @transform.translation.y
    end

    def y=(val)
      @transform.translation = @transform.translation.x, val
    end

    def pos
      @transform.translation
    end

    def pos=(val)
      @transform.translation = val
    end

    def center_x
      @transform.center.x
    end

    def center_x=(val)
      @transform.center = val, @transform.center.y
    end

    def center_y
      @transform.center.y
    end

    def center_y=(val)
      @transform.center = @transform.center.x, val
    end

    def scale_x
      @transform.scale.x
    end

    def scale_x=(val)
      @transform.scale = val, @transform.scale.y
    end

    def scale_y
      @transform.scale.y
    end

    def scale_y=(val)
      @transform.scale = @transform.scale.x, val
    end

    def rotation
      @transform.rotation
    end

    def rotation=(val)
      @transform.rotation = val
    end

    def draw(matrix = nil)
      matrix ||= Snow::Mat3.new
      transform = matrix * @transform.to_matrix
      render(transform) if @is_visible
      if @are_children_visible
        @children.each { |child| child.draw(transform) }
      end
    end

    def is_point_in_bounds(point)
      false
    end

    def get_actor_at(point)
      hit = nil
      if @are_children_tangible
        @children.reverse_each do |child|
          hit = child.get_actor_at(point)
          if hit
            break if @is_mask
            return hit
          end
        end
      end
      hit = self if hit == nil && @is_tangible && is_point_in_bounds(point)
      hit = @parent if @is_mask && hit == self
      hit
    end

    def get_actors_at(point)
      actors = []
      if @are_children_tangible
        @children.reverse_each do |child|
          actors |= child.get_actors_at(point)
        end
      end
      actors.push(self) if @is_tangible && is_point_in_bounds(point)
      actors.uniq!
      if @is_mask
        actors.map! { |actor| (actor == self) ? @parent : actor }
      end
      actors
    end

    def get_global_transform(out = nil)
      if parent
        out ||= Snow::Mat3.new
        @transform.to_matrix.multiply(parent.get_global_transform, out)
        out
      else
        @transform.to_matrix
      end
    end

    def get_global_position
      tf = get_global_transform
      Transform.transform_point(tf, @transform.center)
    end

    def alpha
      @color.alpha
    end

    def alpha=(val)
      @color.alpha = val
    end

    def red
      @color.red
    end

    def red=(val)
      @color.red = val
    end

    def green
      @color.green
    end

    def green=(val)
      @color.green = val
    end

    def blue
      @color.blue
    end

    def blue=(val)
      @color.blue = val
    end

    protected

    def render(matrix)
    end

    def parent=(parent)
      return if parent == @parent
      unless parent
        raise Gosling::InheritanceError.new("You should use Actor.remove_child() instead of setting the parent directly.") if @parent.has_child?(self)
      end
      @parent = parent
      if @parent
        raise Gosling::InheritanceError.new("You should use Actor.add_child() instead of setting the parent directly.") unless @parent.has_child?(self)
      end
    end
  end
end
