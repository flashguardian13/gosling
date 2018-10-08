# Gosling

Provides some common 2d application functionality using Gosu gem and Ruby's Vector/Matrix classes.

## Installation

```
gem install gosling
```

## Example Usage

First, you'll want to be familiar with Gosu, because this gem relies on Gosu pretty heavily. Start [here](https://github.com/gosu/gosu) if you're unfamiliar.

In order to create a basic 2D app, you'll first need to instantiate a `Gosu::Window`. All of the magic happens in the window. `Gosu::Window` is a module, so we'll need to make our own class which inherits from it.

```
class GameWindow < Gosu::Window
  attr_accessor :actors

  def initialize(width, height, options)
    super(width, height, options)
    self.caption = 'Gosling Demo'
  end

  def update
  end

  def draw
    @actors.each { |actor| actor.draw }
  end
end
```

That's a very basic window. Let's instantiate one now.

```
window = GameWindow.new(1024, 768, fullscreen: false, update_interval: 1000.0 / 60)
```

We can then verify that our window is working:

```
window.show
```

A blank screen isn't much, but it's a start. Let's set the stage with some actors.

### Actors

At its most basic, an Actor is a shape in two-dimensional space. Actors can be rendered to a window. Collision detection can determine if a point intersects an Actor, or if two Actors are overlapping.

There are multiple types of Actors you can use, depending on what sort of shape you need:
- **Actor**: An invisible, insubstantial actor. Never renders itself. Never collides with anything. Defined by a point in space.
- **Circle**: Inherits from Actor. Defined by a radius.
- **Polygon**: Inherits from Actor. Defined by a set of three or more vertices.
- **Rect**: Inherits from Polygon. Its four vertices are defined by its width and height.
- **Sprite**: Inherits from Rect. Its width and height are automatically set to the width and height of the `Gosu::Image` it is assigned.

```
circle = Gosling::Circle.new(window)
circle.radius = 25
circle.x = 100
circle.y = 100
circle.color = Gosu::Color.rgba(0, 255, 0, 255)

rectangle = Gosling::Rect.new(window)
rectangle.width = 200
rectangle.height = 50
rectangle.pos = [150, 300]
rectangle.color = Gosu::Color.rgba(255, 0, 0, 255)

triangle = Gosling::Polygon.new(window)
triangle.set_vertices([
  Vector[-40, -30, 1],
  Vector[  0,  30, 1],
  Vector[ 40, -30, 1]
])
triangle.pos = [400, 200]
triangle.color = Gosu::Color.rgba(64, 64, 128, 255)
```

Text is handled by Gosu. See either `Font.draw` or `Image.from_text`.

To make these actors show up on screen, all we need to do is call `actor.draw` on them as part of the window's `draw` method.

```
window.actors = [circle, rectangle, triangle]
window.show
```

To create a Sprite, which is an image-based Actor, we first need to load the image from file. Gosling::ImageLibrary maintains an image cache based on filename so that image files are never loaded more than once.

```
sprite = Gosling::Sprite.new(window)
image = Gosling::ImageLibrary.get('./images/red-meeple.png')
sprite.set_image(image)
```

### Actor Properties

There are a lot you can do with Actors. They can be freely transformed:
- **translated**: `actor.x`, `actor.y`, `actor.pos`
- **scaled**: `scale_x`, `scale_y`
- **rotated**: `rotation`

Their centerpoint - the point in space around which the Actor is rotated and scaled - can likewise be altered via `center_x` and `center_y`.

An Actor's color can either be set directly via the Actor's `color` attribute, or individual color components can be modified via `red`, `green`, `blue`, and `alpha`.

### Actor Inheritance

Parent/child relationships can be establed between Actors such that one belongs to the other. Those familiar with ActionScript and similar models should already be familiar with how this works. What makes this model so useful is that a parent's transform is automatically applied to all of its children. Scale or rotate the parent actor, and all of its children are similarly scaled. Child Actors can be nested as deeply as desired, allowing for complex family trees. This allows us to build conglomerate actors that render, hit, and move as one. We can also have all of our game's Actor's be the children of one root Actor, which would then behave like a sort of camera into the 2D world we've created. Move the camera Actor, and all Actors in the world move. We can also use this approach for easy hit-testing and detection of which Actors the mouse is currently over, if any (read on for details).

With this approach, our GameWindow would look more like this:

```
class GameWindow < Gosu::Window
  attr_accessor :camera

  def initialize(width, height, options)
    super(width, height, options)
    self.caption = 'Gosling Demo'
    @camera = Gosling::Actor.new(self)
  end

  def update
  end

  def draw
    @camera.draw
  end
end
```

Now to render our actors, we just make them children of the stage actor.

```
window.camera.add_child(circle)
window.camera.add_child(rectangle)
window.camera.add_child(triangle)
window.show
```

### Actor Inheritance Modifiers

Actors can be made invisible, which prevents them from being rendered. Separately, they can be made intangible, which prevents them from colliding or responding to hit tests. Separate from these, an Actor's children can collectively be made invisible or intangible. And if a child Actor is designated as a mask, whenever it would hit or collide, it defers the hit/collision to its parent.

The corresponding attributes are:
- `is_visible`
- `is_tangible`
- `are_children_visible`
- `are_children_tangible`
- `is_mask`

### Animation

Animation can be called by harnessing our GameWindow's update event, which Gosu will call periodically for us based on the `update_interval` value we specified.

```
class GameWindow < Gosu::Window
  ...

  def update
    cur_time = Time.now
    elapsed = @prev_time ? cur_time - @prev_time : 60
    @prev_time = cur_time

    @camera.x += 10 * elapsed
    @camera.x -= 500 if @camera.x > 500
  end

  ...
end
```

Note: Gosling currently uses Ruby's `matrix` class when calculating its transforms. This class is incredibly slow due to the way it handles memory. Animations will become choppy if there is too much action happening on screen. I may explore other, faster alternatives in the future.

### Hit Testing

To do point-based hit testing on actors, you can use the `get_actor_at` or `get_actors_at` methods of `Gosling::Actor`, which will return either the first tangible actor or all tangible actors at that point. If all of your actors are the children of a camera Actor, you need only call this method once on the camera. This is very useful for detecting which Actors the mouse is currently over.

To test whether two Actors have collided or are overlapping, pass those two Actors as arguments to `Gosling::Collision.test`. The method returns true if the Actors touch or overlap, false otherwise.

## What Gosling Isn't

It is not fast. It is not 3D. It is not a physics engine. But there's no reason you couldn't use it to develop some simple games, or a calendar, or to-do list app.

## Testing

Tests are written in RSpec. To run them:

```
rspec spec
```
