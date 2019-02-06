# Gosling

Provides some common 2d application functionality using Gosu gem and nilium's [snow-math](https://github.com/nilium/ruby-snowmath) gem, including stage-setting, actor transforms with inheritance, and basic collision and hit detection.

If you discover a bug, please take a look at the dev branch to see if there's a fix before creating a new issue.

## Installation

```
gem install gosling
```

## Getting Started

Check out the example game that ships with the gem. You'll find it in `examples/shooter`. That should give you a pretty good idea of where to start and how to do things. You can even use it as a skeleton from which to create your own game or app.

All of the code is pretty well documented, so check out the RDocs if you need more information about anything. If you're looking for a more detailed walkthrough, check out this [tutorial](https://github.com/flashguardian13/gosling/wiki/Tutorial) on the wiki.

## Testing

Tests are written in RSpec. To run them:

```
rspec spec
```

## What Gosling Isn't

It is not 3D. It is not a physics engine. And it's not meant to be blazingly fast, but I want to ensure that it's at least reasonably performant for most 2D game applications and animations. Thanks to user nilium's [snow-math](https://github.com/nilium/ruby-snowmath) gem, the vast majority of the mathematical heavy-lifting is done on the C-side rather than the Ruby side, so at present it's pretty smooth.

## Changelog

Version 2.3.0 - released February 5, 2019
- Did I forget to release 2.2? Oops. Oh well. This version is _waaay_ better anyway.
- Speeeed! Transform and collision code has been optimized and is now at least ten times faster. Frame rates are noticably better at scale or when there's just a lot of action happening in the game universe.
- Creating new Vectors and Matrices all the time is slow. What's faster? Maintaining a pool of temporary, throw-away Vectors and Matrices! Just #get one from the VectorCache or MatrixCache as needed, then #recycle it when done! Recycled Vectors and Matrices are cleaned and put on ice, making them fresh and ready to re-use the next time you need them.
- ImageLibrary no longer pointlessly checks for the existence of files it has previously loaded. Let go of the disk, ImageLibrary.
- Many expensive transform/collision functions now accept an optional object reference where the answer should be stored. Because if you already have a slice of memory carved out for the result, why waste time carving out a new one?
- Collision has new methods for bulk collision detections! At the start of your physics step, you can pre-load any number of actors into the Collision buffers, and all the math is done once ahead of time. No repeat calculations. Just remember to re-buffer any actors you transform and clear the buffers when you're done.
- Strict type-checking isn't just un-Ruby-like. Turns out it's also really slow. Type-checking has been disabled in all speed-critical methods.
- Polygon has a new method, #set_vertices_rect. When you just want four sides at right angles without all that corner-calculation, this method makes it easy. And yeah, Rect and Sprite now use this method internally.
- Transformable's center, scale, and translation vectors can now be directly manipulated by passing a block to #set_center, #set_scale, and #set_translation. The vectors get passed to the block so you can have your way with them, and when you're done the relevant matrices are automatically marked as dirty. This is the fastest way to perform SnowMath-based transforms, perfect for animations.
- Lots of other little tweaks, refactors, and test fixes.

Version 2.1.0 - released December 19, 2018
- New Collision.get_collision_info provides additional information about collisions between two actors.
- Touching and colliding aren't the same thing. The two shapes being tested must now overlap or it doesn't count.
- Out with slow Rational numbers. Accurate, but hella slow.
- Polygon.set_vertices is now more flexible with the arguments it accepts.
- Test refactoring for easier reading and maintaining.
- Other minor tweaks.

Version 2.0.1 - released December 14, 2018
- Transformable is now a module included by the Actor class.
- The #center, #scale, and #translation methods now return frozen duplicates. Modifying these vectors directly wouldn't update the related transform matrices. Nothing says frustration like changing an actor's x position only to watch it sit there unmoving.
- Fixed a rendering transform bug.

Version 2.0.0 - released November 25, 2018
- Switched from Ruby's standard Matrix/Vector classes to nilium's [snow-math](https://github.com/nilium/ruby-snowmath)! Frame rates are now +much+ better when lots of Actors are on-screen! The downside is that any apps which used previous versions will need to change all their uses of Matrix to Snow::Mat3 and Vector to Snow::Vec3. Personally, I found the conversion pretty straightforward, but if anyone complains about the lack of backwards-compatibility, there's a small possibility that I could go back and fix it. No promises. I'd really like to encourage everyone to switch out for the faster, more memory-efficient snow-math classes.
- Added RDoc documentation via comments.
- Added a really basic example game to demonstrate a typical game build.
- More robust argument type-checking. (Sorry to all you ducks, but you're gonna need to show some ID.)
- Various optimizations and bugfixes.

## TODO

- Update everything to take advantage of latest version of Gosu wherever possible
- Update everything to take advantage of full snow-math functionality
- A shinier example game, maybe?
