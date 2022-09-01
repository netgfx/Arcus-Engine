import 'dart:math';
import 'dart:ui';

import 'package:arcus_engine/game_classes/EntitySystem/world.dart';
import 'package:arcus_engine/game_classes/EntitySystem/vector_little.dart';
import 'package:arcus_engine/helpers/constants.dart';
import 'package:arcus_engine/helpers/utils.dart';

class PhysicsBodyProperties {
  /// @property {Number} [mass=objectDefaultMass]                 - How heavy the object is, static if 0 */
  double mass = 1;

  /// @property {Number} [damping=objectDefaultDamping]           - How much to slow down velocity each frame (0-1) */
  double damping = 0.99;

  /// @property {Number} [angleDamping=objectDefaultAngleDamping] - How much to slow down rotation each frame (0-1) */
  double angleDamping = 0.99;

  /// @property {Number} [elasticity=objectDefaultElasticity]     - How bouncy the object is when colliding (0-1) */
  double elasticity = 0.15;

  /// @property {Number} [friction=objectDefaultFriction]         - How much friction to apply when sliding (0-1) */
  double friction = 0.25;

  /// @property {Number} [gravityScale=1]                         - How much to scale gravity by for this object */
  double gravityScale = 1;

  /// @property {Number} [renderOrder=0]                          - Objects are sorted by render order */
  int renderOrder = 0;

  /// @property {Vector2} [velocity=new Vector2()]                - Velocity of the object */
  Vector2 velocity = Vector2(x: 0, y: 0);

  /// @property {Number} [angleVelocity=0]                        - Angular velocity of the object */
  double angleVelocity = 0;
  bool immovable = false;
  bool collideSolidObjects = true;
  dynamic object;
  bool collideTiles = true;
  double angle = 0.0;
  bool collideWorldBounds = true;
  double restitution = 0.99;

  PhysicsBodyProperties({
    mass,
    damping,
    angleDamping,
    elasticity,
    friction,
    gravityScale,
    renderOrder,
    velocity,
    restitution,
    angleVelocity,
    collideSolidObjects,
    immovable,
    collideOnWorldBounds,
  }) {
    this.mass = mass ?? 1;
    this.damping = damping ?? 0.99;
    this.angleDamping = angleDamping ?? 0.99;
    this.elasticity = elasticity ?? 0.15;
    this.friction = friction ?? 0.95;
    this.gravityScale = gravityScale ?? 1;
    this.renderOrder = renderOrder ?? 0;
    this.angleVelocity = angleVelocity ?? 0;
    this.restitution = restitution ?? 0.99;
    this.collideSolidObjects = collideSolidObjects ?? true;
    this.velocity = velocity ?? Vector2(x: 0, y: 0);
    this.immovable = immovable ?? false;
    collideWorldBounds = collideOnWorldBounds ?? true;
  }
}

class PhysicsBodySimple {
  Vector2 pos = Vector2(x: 0, y: 0);

  Vector2 size = Vector2(x: 0, y: 0);

  /// @property {Number} [mass=objectDefaultMass]                 - How heavy the object is, static if 0 */
  double mass = 1;

  /// @property {Number} [damping=objectDefaultDamping]           - How much to slow down velocity each frame (0-1) */
  double damping = 0.99;

  /// @property {Number} [angleDamping=objectDefaultAngleDamping] - How much to slow down rotation each frame (0-1) */
  double angleDamping = 0.99;

  /// @property {Number} [elasticity=objectDefaultElasticity]     - How bouncy the object is when colliding (0-1) */
  double elasticity = 0.15;

  /// @property {Number} [friction=objectDefaultFriction]         - How much friction to apply when sliding (0-1) */
  double friction = 0.25;

  /// @property {Number} [gravityScale=1]                         - How much to scale gravity by for this object */
  double gravityScale = 1;

  /// @property {Number} [renderOrder=0]                          - Objects are sorted by render order */
  int renderOrder = 0;

  /// @property {Vector2} [velocity=new Vector2()]                - Velocity of the object */
  Vector2 _velocity = Vector2(x: 0, y: 0);

  double _angleVelocity = 0;
  bool collideSolidObjects = true;
  dynamic object;
  bool collideTiles = true;
  double _angle = 0.0;
  double objectMaxSpeed = 10.0;
  dynamic groundObject;
  bool enablePhysicsSolver = true;
  TDWorld world;
  Function? onCollision = null;
  bool collideWorldBounds = true;
  double restitution = 0.99;
  String isCollidingAt = "none";
  bool immovable = false;
  PhysicsBodyProperties physicsProperties;
  PhysicsBodySimple({
    required this.object,
    required this.pos,
    required this.world,
    required this.size,
    required this.physicsProperties,
    this.onCollision,
  }) {
    mass = physicsProperties.mass;
    damping = physicsProperties.damping;
    angleDamping = physicsProperties.angleDamping;
    elasticity = physicsProperties.elasticity;
    friction = physicsProperties.friction;
    gravityScale = physicsProperties.gravityScale;
    renderOrder = physicsProperties.renderOrder;
    velocity = physicsProperties.velocity;
    angleVelocity = physicsProperties.angleVelocity;
    restitution = physicsProperties.restitution;
    immovable = physicsProperties.immovable;
    collideSolidObjects = physicsProperties.collideSolidObjects;
    //this.size = size ?? Vector2(x: 0, y: 0);
    //this.onCollision = onCollision;
    collideWorldBounds = physicsProperties.collideWorldBounds;
  }

  double get angle {
    return _angle;
  }

  set angle(double value) {
    _angle = value;
  }

  Vector2 get velocity {
    return _velocity;
  }

  set velocity(Vector2 value) {
    _velocity = value;
  }

  double get angleVelocity {
    return _angleVelocity;
  }

  set angleVelocity(double value) {
    _angleVelocity = value;
  }

  dynamic getObject() {
    return object;
  }

  setCollision({collideSolidObjects = false, isSolid = false, collideTiles = true}) {
    //ASSERT(collideSolidObjects || !isSolid); // solid objects must be set to collide

    this.collideSolidObjects = collideSolidObjects;
    immovable = isSolid;
    this.collideTiles = collideTiles;
  }

  multiply(Vector2 v) {
    return Vector2(x: pos.x * v.x, y: pos.y * v.y);
  }

  collideWithObject(o) {
    if (onCollision != null) {
      onCollision!(o);
    }
    return 1;
  }

  double getRestitution() {
    return restitution;
  }

  /// NOTE: this assumes world bounds starting from 0,0
  String detectEdgeCollisions(PhysicsBodySimple obj) {
    Size worldBounds = world.worldBounds;
    String isColliding = 'none';
    // Check for left and right
    if (obj.pos.x < 0) {
      obj.velocity.x = (obj.velocity.x).abs() * obj.getRestitution();
      obj.pos.x = 0.0;
      isColliding = 'left';
    } else if (obj.pos.x > worldBounds.width - obj.size.x.toDouble()) {
      obj.velocity.x = -(obj.velocity.x).abs() * obj.getRestitution();
      obj.pos.x = worldBounds.width - obj.size.x;
      isColliding = 'right';
    }

    // Check for bottom and top
    if (obj.pos.y > worldBounds.height - obj.size.y) {
      obj.velocity.y = -(obj.velocity.y).abs() * obj.getRestitution();
      obj.pos.y = worldBounds.height - (obj.size.y);
      isColliding = "bottom";
    } else if (obj.pos.y < 0) {
      obj.velocity.y = (obj.velocity.y).abs() * obj.getRestitution();
      obj.pos.y = obj.size.y;
      isColliding = "top";
    }

    return isColliding;
  }

  /// TODO: needs rework
  void calculatePhysicsCollision(PhysicsBodySimple obj1, PhysicsBodySimple obj2) {
    String result = Utils.shared.getCollideSide(obj1, obj2);
    String result2 = Utils.shared.getCollideSide(obj2, obj1);

    if (result != "none" && result2 != "none") {
      if (Utils.shared.isOverlapping(obj1.pos, obj1.size, obj2.pos, obj2.size)) {
        // perhaps needed elsewhere?
      }

      Vector2 sizeBoth = obj1.size.add(obj2.size);
      if (checkIfBlocked(obj1, obj2) && obj1.immovable == false) {
        // push outside object collision
        obj1.pos.y = obj2.pos.y + (sizeBoth.y / 2 + epsilon) * Utils.shared.sign(obj1.pos.y - obj2.pos.y);
      }

      /// TODO: Detect specific collide point
      obj1.isCollidingAt = result2;
      obj2.isCollidingAt = result;

      Map<String, double> vCollision = {"x": obj2.pos.x - obj1.pos.x, "y": obj2.pos.y - obj1.pos.y};
      double distance = sqrt((obj2.pos.x - obj1.pos.x) * (obj2.pos.x - obj1.pos.x) + (obj2.pos.y - obj1.pos.y) * (obj2.pos.y - obj1.pos.y));
      Map<String, double> vCollisionNorm = {"x": vCollision["x"]! / distance, "y": vCollision["y"]! / distance};
      var vRelativeVelocity = {"x": obj1.velocity.x - obj2.velocity.x, "y": obj1.velocity.y - obj2.velocity.y};
      var speed = vRelativeVelocity["x"]! * vCollisionNorm["x"]! + vRelativeVelocity["y"]! * vCollisionNorm["y"]!;

      // Apply restitution to the speed
      speed *= min(obj1.restitution, obj2.restitution);
      //delayedPrint(speed.toString());
      if (speed < 0.1) {
        return;
      }

      var impulse = 2 * speed / (obj1.mass + obj2.mass);
      obj1.velocity.x -= (impulse * obj2.mass * vCollisionNorm["x"]!);
      obj1.velocity.y -= (impulse * obj2.mass * vCollisionNorm["y"]!);
      obj2.velocity.x += (impulse * obj1.mass * vCollisionNorm["x"]!);
      obj2.velocity.y += (impulse * obj1.mass * vCollisionNorm["y"]!);

      obj1.collideWithObject(obj2);
      obj2.collideWithObject(obj1);

      //print("${obj1.pos.y}, ${obj1.velocity.y}, $speed, $impulse");

      /// check any one of them is static
      if (obj2.immovable == true) {
        obj2.velocity.y = 0;
      } else if (obj1.immovable == true) {
        obj1.velocity.y = 0;
      }

      // if (obj1.immovable == false) {
      //   print(obj1.velocity);
      // }
    }
  }

  bool checkIfBlocked(PhysicsBodySimple obj1, PhysicsBodySimple obj2) {
    Vector2 sizeBoth = obj1.size.add(obj2.size);
    var smallStepUp = (obj1.pos.y - obj2.pos.y) * 2 > sizeBoth.y + gravity; // prefer to push up if small delta
    var isBlockedY = (obj1.pos.y - obj2.pos.y).abs() * 2 < sizeBoth.y;

    return (smallStepUp || isBlockedY);
  }

  update(Canvas canvas, {double elapsedTime = 0.0, double timestamp = 0.0, bool shouldUpdate = true}) {
    // var parent = this.object;
    // if (parent) {
    //   // copy parent pos/angle
    //   this.pos = multiply(Vector2(x: parent.getMirrorSign(), y: 1))
    //       .rotate(-parent.angle)
    //       .add(parent.pos);
    //   //this.angle = parent.getMirrorSign()*this.localAngle + parent.angle;
    //   return;
    // }

    // limit max speed to prevent missing collisions
    // this.velocity.x =
    //     Utils.shared.clamp(this.velocity.x, -objectMaxSpeed, objectMaxSpeed);
    // this.velocity.y =
    //     Utils.shared.clamp(this.velocity.y, -objectMaxSpeed, objectMaxSpeed);

    // // apply physics
    var oldPos = Vector2(x: pos.x.toDouble(), y: pos.y.toDouble());

    // if (isCollidingAt == "none") {
    velocity.y += gravity * timestamp;
    //damping *
    // }

    /// immovable objects don't move but do collide
    if (immovable == true) {
      velocity.x = 0;
      velocity.y = 0;
    } else {
      pos = Vector2(x: oldPos.x + velocity.x * timestamp, y: oldPos.y + velocity.y * timestamp);

      /// push outside of collision
      if (isCollidingAt == "bottom" && velocity.y > 0) {
        pos = oldPos;
      }

      angle += angleVelocity *= angleDamping;
    }

    /// RESET
    isCollidingAt = "none";

    ///

    // if (!this.enablePhysicsSolver ||
    //     this.mass == 0) // do not update collision for fixed objects
    //   return;

    var wasMovingDown = velocity.y < 0;

    /// add world collision
    Size worldBounds = world.worldBounds;
    if (collideWorldBounds) {
      Map<String, Map<String, dynamic>> bounds = {
        /// top
        "top": {
          "pos": Point(0, 0),
          "size": Vector2(
            x: worldBounds.width,
            y: 10,
          ),
          "velocity": Vector2(x: 0, y: 0),
          "mass": 5,
          "restitution": 0.99
        },

        /// bottom
        "bottom": {
          "pos": Point(0, worldBounds.height),
          "size": Vector2(
            x: worldBounds.width,
            y: 10,
          ),
          "velocity": Vector2(x: 0, y: 0),
          "mass": 5,
          "restitution": 0.99
        },

        /// left
        "left": {
          "pos": Point(0, 0),
          "size": Vector2(
            x: 10,
            y: worldBounds.height,
          ),
          "velocity": Vector2(x: 0, y: 0),
          "mass": 5,
          "restitution": 0.99
        },

        /// right
        "right": {
          "pos": Point(worldBounds.width, 0),
          "size": Vector2(
            x: 10,
            y: worldBounds.height,
          ),
          "velocity": Vector2(x: 0, y: 0),
          "mass": 5,
          "restitution": 0.99
        },
      };

      String wallCollision = detectEdgeCollisions(this);
      if (wallCollision != "none") {
        isCollidingAt = wallCollision;

        if (isCollidingAt == "bottom") {
          velocity.x = (velocity.x) * friction;
        }
        return;
      }
    }

    if (collideSolidObjects) {
      List<dynamic> items = world.getEngineObjectsCollide();
      for (var item in items) {
        PhysicsBodySimple o = item.physicsBody;
        //print("${o.immovable}, ${o.object.alive}, ${o.object.id}, ${this.object.id}");
        // non solid objects don't collide with eachother
        if (!o.object.alive || o.object.id == object.id) continue;

        if (o.immovable == true) {
          o.velocity.y = 0;
          continue;
        }

        calculatePhysicsCollision(this, o);
      }

      return;
    }

    ////////////////////////////////////////////////////////////////////////////
  }
}
