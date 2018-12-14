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
