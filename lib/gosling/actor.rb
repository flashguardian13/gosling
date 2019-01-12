require_relative 'transformable.rb'

require 'gosu'

module Gosling
  ##
  # Actors are fundamental elements of a rendering and worldspace hierarchy. They represent the things that exist
  # inside of the game world or parts of our application's user interface.
  #
  # A key difference between an Actor and any of its subclasses - Circle, Polygon, Sprite, and the like - is that an
  # Actor is inherently intangible. By itself, it has no shape or appearance and takes up no space. If it's something you
  # can see or interact with, it should probably be an instance of one of Actor's subclasses.
  #
  # The inheritance model is what makes an Actor by itself useful. Actors can have one or more children, which can be
  # any type of Actor. Those Actors can in turn have any number of child Actors, and so on, creating a sort of tree
  # structure. A parent Actor's transform is inherited by its children, so moving or rotating a parent Actor moves or
  # rotates all of its children relative to its parent. And when a parent is drawn, all of its children are drawn as well
  # (see #draw for exceptions).
  #
  # One common application of this is to use a plain Actor as a root object to which all other elements visible in the
  # game world are added. As the player moves through the game world, rather than move the position of each game
  # element across the screen to simulate travel, you need only move the root Actor and all other Actors will be moved
  # similarly. This root actor then acts like a "stage" or "camera". For this reason, one could think of a plain Actor as
  # sort of a "container" for other Actors, a way to keep them all organized and related.
  #
  # The behavior of inheritance can modified by setting various properties. Read on for more details.
  #
  class Actor
    include Transformable

    attr_reader :parent, :children, :window

    ##
    # If set to true, this Actor will be drawn to screen. If false, it will be skipped. The default is true.
    #
    attr_accessor :is_visible

    ##
    # If set to true, this Actor will respond to "point-in-shape" tests. If false, such tests will skip this Actor. The default
    # is true.
    #
    attr_accessor :is_tangible

    ##
    # If set to true, all of this Actor's children will be drawn to screen. If false, they and their descendants will be
    # skipped. The default is true.
    #
    attr_accessor :are_children_visible

    ##
    # If set to true, this Actor's children will respond to "point-in-shape" tests. If false, such tests will skip them and
    # their descendants. The default is true.
    #
    attr_accessor :are_children_tangible

    ##
    # If set to true, this Actor will be treated as a "mask" for its parent regarding "point-in-shape" tests. If the point is
    # in this Actor's bounds, it will act as though the point is in its parent's bounds instead of its own. The default is
    # false.
    #
    attr_accessor :is_mask

    ##
    # The Gosu::Color to use when rendering this Actor.
    #
    attr_accessor :color

    ##
    # Creates a new Actor, setting all inheritance properties to their defaults and assigning a random color. Requires
    # a Gosu::Window to be used when rendering.
    #
    def initialize(window)
      super()
      @window = window
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

    ##
    # Establishes a parent/child relationship between this actor and the one passed, respectively. The child Actor will
    # appear relative to its parent, move as the parent moves, and draw when the parent draws.
    #
    # An Actor cannot be made a child of itself. Similarly, a child cannot be added to a parent if doing so would create
    # a circular reference (e.g. a.add_child(b) followed by b.add_child(a)).
    #
    # If the child Actor already had a parent, the Actor is disassociated from its former parent before becoming
    # associated with this one. An Actor can have only one parent at a time.
    #
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

    ##
    # If the given Actor is a child of this Actor, it is disassociated from this Actor. In any case, the child Actor is
    # immediately orphaned.
    #
    def remove_child(child)
      return unless @children.include?(child)

      @children.delete(child)
      child.parent = nil
    end

    ##
    # Returns true if this Actor has the given Actor as a child.
    #
    def has_child?(child)
      @children.include?(child)
    end

    ##
    # Calls #render on this Actor, drawing it to the screen if #is_visible is set to true (the default).
    #
    # The Actor's transforms, if any, will be applied prior to rendering. If an optional Snow::Mat3 matrix transform is
    # given, the Actor will be transformed by a combination of that matrix transform and its own.
    #
    # If the #are_children_visible flag is set to true (the default), then this method will recursively call draw on each
    # of the Actor's children, passing them the combined matrix used to render the parent. Otherwise, children will
    # be skipped and not drawn.
    #
    def draw(matrix = nil)
      transform = MatrixCache.instance.get
      if matrix
        to_matrix.multiply(matrix, transform)
      else
        transform.set(to_matrix)
      end

      render(transform) if @is_visible
      if @are_children_visible
        @children.each { |child| child.draw(transform) }
      end
    ensure
      MatrixCache.instance.recycle(transform)
    end

    ##
    # Returns false. Actors have no shape, and so no point is in their bounds. Subclasses override this method with
    # shape-specific behavior.
    #
    def is_point_in_bounds(point)
      false
    end

    ##
    # Given a point in global space, tests this Actor and each of its children, returning the first Actor for whom this
    # point is inside its shape. Respects each Actor's transforms as well as any it may inherit from its ancestors.
    # Useful for determining which Actor the user may have clicked on.
    #
    # If the #is_tangible flag is set to false, this Actor will not be tested. The default is true.
    #
    # If the #are_children_tangible flag is set to false, this Actor's children will not be tested. The default is true.
    #
    # If the #is_mask flag is set to true, a positive test from this Actor instead returns its parent Actor, if any. The
    # default is false.
    #
    # If the point is not inside this Actor or any of its children (excluding any skipped Actors), nil is returned.
    #
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

    ##
    # Functions similarly to #get_actor_at, but returns a list of +all+ Actors for whom the point is inside their shape.
    #
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

    ##
    # Returns a Snow::Mat3 transformation matrix combining this Actor's transforms as well as all of its ancestors.
    # This matrix can be used to transform a point in this Actor's local space to its global equivalent (the geometric
    # space of its root ancestor).
    #
    def get_global_transform(out = nil)
      if parent
        out ||= Snow::Mat3.new
        to_matrix.multiply(parent.get_global_transform, out)
        out
      else
        to_matrix
      end
    end

    ##
    # Returns the global x/y position of this actor (where it is relative to its root ancestor). This value is calculated
    # using the Actor's center (see Transformable#center).
    #
    def get_global_position
      tf = get_global_transform
      Transformable.transform_point(tf, center, Snow::Vec3.new)
    end

    ##
    # Wrapper method. Returns this Actor's alpha value (0-255).
    #
    def alpha
      @color.alpha
    end

    ##
    # Wrapper method. Sets this Actor's alpha value (0-255).
    #
    def alpha=(val)
      @color.alpha = val
    end

    ##
    # Wrapper method. Returns this Actor's red value (0-255).
    #
    def red
      @color.red
    end

    ##
    # Wrapper method. Sets this Actor's red value (0-255).
    #
    def red=(val)
      @color.red = val
    end

    ##
    # Wrapper method. Returns this Actor's green value (0-255).
    #
    def green
      @color.green
    end

    ##
    # Wrapper method. Sets this Actor's green value (0-255).
    #
    def green=(val)
      @color.green = val
    end

    ##
    # Wrapper method. Returns this Actor's blue value (0-255).
    #
    def blue
      @color.blue
    end

    ##
    # Wrapper method. Sets this Actor's blue value (0-255).
    #
    def blue=(val)
      @color.blue = val
    end

    protected

    def render(matrix)
    end

    ##
    # Internal use only. See #add_child and #remove_child.
    #
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
