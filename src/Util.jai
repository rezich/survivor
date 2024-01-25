get_closest_point_on_line :: (point: Vector2, line_begin: Vector2, line_end: Vector2) -> Vector2 {
    a1 := line_end.y - line_begin.y;
    b1 := line_end.x - line_begin.x;

    c1 := (line_end.y - line_begin.y) * line_begin.x + (line_begin.x - line_end.x) * line_begin.y;
    c2 := -b1 * point.x + a1 * point.y;
    det := a1 * a1 - -b1 * b1;
    if det then return .{ (a1*c1 - b1*c2) / det, (a1*c2 - -b1*c1) / det };
    return point;
}

do_circles_overlap :: (a: Vector2, a_radius: float, b: Vector2, b_radius: float) -> bool, Vector2 {
    radii_sum := a_radius + b_radius;
    return abs(distance_squared(a, b)) <= radii_sum * radii_sum, .{};
}

do_line_segments_intersect :: (a_begin: Vector2, a_end: Vector2, b_begin: Vector2, b_end: Vector2) -> bool, Vector2 {
    s1 := Vector2.{ a_end.x - a_begin.x, a_end.y - a_begin.y };
    s2 := Vector2.{ b_end.x - b_begin.x, b_end.y - b_begin.y };

    denom := s1.x * s2.y - s2.x * s1.y;
    if !denom then return false, .{};
    denom_is_positive := denom > 0;

    s3 := Vector2.{ a_begin.x - b_begin.x, a_begin.y - b_begin.y };

    s_numer := s1.x * s3.y - s1.y * s3.x;
    if s_numer < 0 == denom_is_positive then return false, .{};

    t_numer := s2.x * s3.y - s2.y * s3.x;
    if t_numer < 0 == denom_is_positive then return false, .{};

    if s_numer > denom == denom_is_positive || t_numer > denom == denom_is_positive then return false, .{};

    t := t_numer / denom;
    return true, .{ a_begin.x + (t * s1.x), a_begin.y + (t * s1.y) };
}

do_moving_circles_collide :: (a_begin: Vector2, a_end: Vector2, a_radius: float, b_begin: Vector2, b_end: Vector2, b_radius: float) -> bool, Vector2 {
    detected: bool;
    point: Vector2;

    detected, point = do_circles_overlap(a_end, a_radius, b_end, b_radius);
    if detected then return true, point;

    detected, point = do_line_segments_intersect(a_begin, a_end, b_begin, b_end);
    if detected then return true, point;

    //TODO: check for sweep collision properly

    return false, .{};
}

to_screen_space :: (position) => position + state.camera.position + Vector2.{xx window.width, xx window.height} / 2;
to_world_space  :: (position) => position - state.camera.position - Vector2.{xx window.width, xx window.height} / 2;

lerp_theta :: (a: float, b: float, t: float) -> float {
    t2 := b-a;
    dt := clamp(t2-floor(t2/TAU) * TAU, 0, TAU);
    return lerp(a, a + (ifx dt > PI then dt-TAU else dt), t);
}

atan2_between :: (a, b) => atan2(a.y-b.y, a.x-b.x);

easy_ease :: (x, target, speed) => x + (target - x) * speed;
