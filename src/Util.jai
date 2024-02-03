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
    return abs(distance_squared(a, b)) <= radii_sum * radii_sum, .{}; //TODO: get point of overlap
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

//to_screen_space :: (position) => position - state.camera.position + window.half_size;
//to_world_space  :: (position) => position + state.camera.position - window.half_size;

to_screen_space :: (position: Vector2) -> Vector2 {
    return transform(state.camera.matrix, position) + window.half_size;
}
to_world_space :: (position: Vector2) -> Vector2 {
    return transform(state.camera.inverse_matrix, position - window.half_size);
}

lerp_theta :: (a: float, b: float, t: float) -> float {
    t2 := b-a;
    dt := clamp(t2-floor(t2/TAU) * TAU, 0, TAU);
    return lerp(a, a + (ifx dt > PI then dt-TAU else dt), t);
}

atan2_between :: (a, b) => atan2(a.y-b.y, a.x-b.x);

ease :: (x, target, speed) => x + (target - x) * speed;
ease_color :: (x: Vector4, target: Vector4, speed: float) -> Vector4 { return .{
    ease(x.x, target.x, speed),
    ease(x.y, target.y, speed),
    ease(x.z, target.z, speed),
    ease(x.w, target.w, speed)
};}

draw_prepared_text_outlined :: (font: *Simp.Dynamic_Font, x: int, y: int, fg: Vector4 = .{1,1,1,1}, bg: Vector4 = .{0,0,0,1}) {
    OUTLINE_OFFSETS : [8] struct { x, y: int; } : .[
        .{1,0}, .{1,1}, .{0,1}, .{-1,1}, .{-1,0}, .{-1,-1}, .{0,-1}, .{1,-1}
    ];
    for OUTLINE_OFFSETS Simp.draw_prepared_text(font, x + it.x, y + it.y, bg);
    Simp.draw_prepared_text(font, x, y, fg);
}

format_time :: (time: float) -> string {
    total_seconds := cast(int) time;
    seconds := total_seconds % 60;
    minutes := total_seconds / 60;
    deciseconds := cast(int) ((time - xx total_seconds) * 100.00);
    return tprint("%:%.%", formatInt(minutes, minimum_digits=2), formatInt(seconds, minimum_digits=2), formatInt(deciseconds, minimum_digits=2));
}

make_transform_matrix :: (translation: Vector2, scale: Vector2, rotation: float) -> Matrix3 {
    m: Matrix3 = ---;
    identity(*m);

    cos_rotation := cos(rotation);
    sin_rotation := sin(rotation);

    m._11 =  scale.x * cos_rotation;
    m._12 = -scale.y * sin_rotation;
    m._13 =  translation.x * scale.x;
    m._21 =  scale.x * sin_rotation;
    m._22 =  scale.y * cos_rotation;
    m._23 =  translation.y * scale.y;

    return m;
}

transform :: (m: Matrix3, v: Vector2) -> Vector2 { return .{
    m._11 * v.x + m._12 * v.y + m._13,
    m._21 * v.x + m._22 * v.y + m._23
}; }
