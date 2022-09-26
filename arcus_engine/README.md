# Arcus Engine

### A game engine made with Dart and Flutter, based mainly on Canvas/Custom-Painter

<br/>
<hr/>
<br/>

## Todo

✔️ (done)
❗ (important)
🧪 (needs testing)
❌ (problem)
🚩 (revisit)
🚀 (launch)
🔨 (fix)
👾 (bug)
🏭(in progress)

### Release v0.1

- Custom events on canvas elements 🏭 (click is working, need to support drag also and hover)
  - check effects to use centered pos when clicked (could be a self property like `useCenterPosition=true`)
- keyboard events (https://api.flutter.dev/flutter/widgets/KeyboardListener-class.html)
- Add drag event
- Depth sorting ✔️
  - Event honoring depth, so only first is supported ✔️
- Tweens 🏭
  - Add enumerable properties e.g (x, y) or make it read dot notation
  - Tween working with item Id now (so all items should have an id)
  - Extra easings
    - Slow-mo ✔️
    - Spring bounce ✔️
- Sprite rotation
- Pooling 🚩
- Add text object support ✔️
  - Styles (fonts, color simple, size, etc) ✔️
  - Color gradient 🧪
  - Physics !?
  - Bordered with fill (need to do some hacking in there) 🏭
  - Dynamic ✔️
- Bitmap font support 🏭
  - Cache items ✔️
  - Read .fnt file and texture ✔️
  - Reconstruct text with bitmap images ✔️
  - Multi-line (only works with line breaks \n,\r) ✔️
- port Arcade physics ❗
  - Simple physics 🏭
  - generalize the collision 🏭
  - fix collide with bounds ✔️
- create master Sprite class for all game objects to inherit basic properties via mixin ✔️
- Sprite cache ✔️
- loader class for all assets ✔️
- audio (https://pub.dev/packages/just_audio) 🏭
  - Basic sound playback, working ✔️
  - Need to add repeating background sound 🧪
  - Might need some preloading work or cache
  - Add global mute 🧪
- Shapes ✔️
  - Add gradient support
- Group component 🏭
  - Add alignment options
  - Flex spacing
  - Add a stack component !?
- Plugin template 🏭
- Proper tilemap and culling
- Autoscroll tile-sprite
- Particles 🏭
- Camera 🏭
  - need to test with scrolling sprite (WIP)
  - need to test moving sprite 🧪
  - Add a cursor class to track user movement and feed that to Camera
    - size
    - position
- Get name for library... ✔️❗
  - Arcus ✔️
- Documentation ❗

<br/>
<hr/>
<br/>
### Sample games for v0.1

- whack a mole
- auto-runner
- Bullet-hell
- Arcanoid
