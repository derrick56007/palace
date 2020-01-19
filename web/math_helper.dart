import 'dart:math';

num _lerp(num n1, num n2, num by) => n1 * (1 - by) + n2 * by;

class Vector2 {
  final num x, y;

  const Vector2(this.x, this.y);
}

Vector2 lerp(Vector2 v1, Vector2 v2, num by) =>
    Vector2(_lerp(v1.x, v2.x, by), _lerp(v1.y, v2.y, by));

num toRadians(num n) => n * pi / 180;
