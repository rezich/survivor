Camera :: struct {
    position: Vector2;
    scale:    float = 1.0;
    rotation: float;

    left, right, top, bottom: float;
    matrix_to_screen_space: Matrix3;
    matrix_to_world\_space: Matrix3;

    half_size: Vector2;

    OFF_CAMERA_DISTANCE_BASE      :: #run length(.{1280, 720} * .5);
    OFF_CAMERA_DISTANCE_DIAMETERS :: 1.0;
}

move_camera :: () {
    make_camera_matrix :: (translation: Vector2, scale: Vector2, rotation: float) -> Matrix3 {
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

    using state; using camera;

    position = player.position;

    final_scale = scale * window.scale_from_720;

    matrix_to_screen_space = make_camera_matrix(-position, .{final_scale, final_scale}, rotation);
    matrix_to_world\_space = inverse(matrix_to_screen_space);

    half_size = window.half_size / window.scale_from_720;

    left   = position.x - half_size.x;
    right  = position.x + half_size.x;
    bottom = position.y - half_size.y;
    top    = position.y + half_size.y;
}

spawn_somewhere_off_screen :: (entity: $T/Entity) {
    theta       := random_get_within_range(0, TAU);
    offset      := random_get_within_range(0, Camera.OFF_CAMERA_DISTANCE_DIAMETERS);
    distance    := Camera.OFF_CAMERA_DISTANCE_BASE + length(state.player.velocity) + entity.radius * offset * 2;
    from_camera := Vector2.{cos(theta), sin(theta)} * distance;
    spawn(entity, state.camera.position + from_camera);
}

transform :: inline (m: Matrix3, v: Vector2) -> Vector2 { return .{
    m._11 * v.x + m._12 * v.y + m._13,
    m._21 * v.x + m._22 * v.y + m._23
}; }

to_screen_space :: inline (position: Vector2) -> Vector2 {
    return transform(state.camera.matrix_to_screen_space, position) + window.half_size;
}
to_world_space :: inline (position: Vector2) -> Vector2 {
    return transform(state.camera.matrix_to_world\_space, position - window.half_size);
}