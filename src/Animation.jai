Animation :: struct {
    is_looping:        bool;
    frames: [..]       Sprite;
    frames_per_second: float;
}
Animator :: struct {
    animation:     *Animation;
    frame:         int;
    partial_frame: float;
}
Animated_Entity :: struct {
    using base:     Entity;
    using animator: Animator;
}

animate :: (using entity: *$T/interface Animated_Entity, dt: float) {
    if !animation then return;
    partial_frame += animation.frames_per_second * dt;
    if partial_frame >= 1.0 {
        partial_frame -= 1.0;
        frame += 1;
        if frame == animation.frames.count then frame = ifx animation.is_looping then 0 else frame + 1;
    }
    sprite = animation.frames[frame];
}
begin_animation :: (using entity: *$T/interface Animated_Entity, animation: *Animation) {
    animator = .{ animation = animation };
}
is_done_animating :: (using entity: *$T/interface Animated_Entity) -> bool {
    using animator;
    return !animation || (!animation.is_looping && frame == animation.count-1);
}
move_and_animate :: inline (entity: *$T/interface Animated_Entity, dt: float) {
    if entity.is_dead then return;
    move(entity, dt);
    animate(entity, dt);
}
