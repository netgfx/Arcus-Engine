# Arcus Engine

### A game engine made with Dart and Flutter, based mainly on Canvas/Custom-Painter

<br/>
<hr/>
<br/>

## Todo

✔️ (done)
❗ (important)
❌ (problem)
🚩 (revisit)
🚀 (launch)
🔨 (fix)
👾 (bug)
🏭(in progress)

### Release v0.1

- Custom events on canvas elements 🏭 (click is working, need to support drag also and hover)
- keyboard events (https://api.flutter.dev/flutter/widgets/KeyboardListener-class.html)
- Depth sorting ✔️
  - Event honoring depth, so only first is supported ✔️
  - Make drag event
- Tweens 🏭
  - Add enumerable properties e.g (x, y) or make it read dot notation
  - Tween working with item Id now (so all items should have an id)
- Sprite rotation
- Pooling 🚩
- port Arcade physics ❗
  - Simple physics 🏭
  - generalize the collision
  - fix collide with bounds ✔️
- create master Sprite class for all game objects to inherit basic properties via mixin ✔️
- cache ✔️
- loader class for all assets ✔️
- audio (https://pub.dev/packages/audioplayers)
- Shapes ✔️
- Group component 🏭
- Plugin template 🏭
- Proper tilemap and culling
- Autoscroll tile-sprite
- Camera 🏭
  - need to test with scrolling sprite (WIP)
  - need to test moving sprite
- Get name for library... ❗
  - Arcus ✔️

### Sample games for v0.1

- whack a mole
- auto-runner
- Bullet-hell
