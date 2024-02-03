Entity :: struct {
    ID :: #type,distinct u64;
    id:        ID;
    is_dead:   bool;
    position:  Vector2;
    velocity:  Vector2;
    radius:    float;
    vibration: float;
    //position_intended: Vector2;
}

// if the two Entities collide, returns true and position of collision
will_collide :: (a: Entity, b: Entity, a_radius_override := 0.0) -> bool, Vector2 {
    //circles_collide, collision_point := do_moving_circles_collide(a.position, a.position_intended, ifx a_radius_override else a.radius, b.position, b.position_intended, b.radius);
    circles_collide, collision_point := do_circles_overlap(a.position, ifx a_radius_override else a.radius, b.position, b.radius);
    return circles_collide, collision_point;
}
/*determine_intended_movement :: inline (using entity: *Entity, dt: float) {
    position_intended = position + velocity * dt;
}*/
move :: inline(using entity: *Entity, dt: float) {
    position += velocity * dt;
}




Entity_With_Sprite :: struct {
    entity: Entity;
    sprite: Sprite;
}

render :: (using,except(entity) entity: $T/interface Entity_With_Sprite) {
    if !is_on_screen(entity) then return;

    using state;

    vibration_vector: Vector2;
    if vibration {
        theta  := random_get_within_range(0, TAU);
        amount := random_get_within_range(0, vibration);
        vibration_vector = .{ cos(theta) * amount, sin(theta) * amount };
    }

    p0 := to_screen_space(position + vibration_vector - Vector2.{radius, radius});
    p1 := to_screen_space(position + vibration_vector + Vector2.{radius, radius});

    color := SPRITE_COLORS[sprite];

    Simp.set_shader_for_images(*assets.textures[sprite]);
    Simp.immediate_quad(p0.x, p0.y, p1.x, p1.y, color);
}
is_on_screen :: (using entity: Entity) -> bool {
    using state;
    return
        position.x + radius >= camera.left   &&
        position.x - radius <= camera.right  &&
        position.y + radius >= camera.bottom &&
        position.y - radius <= camera.top;
}

despawn :: inline (using entity: *Entity) { is_dead = true; }




Entities :: struct(T: Type) #modify {
    return (#import "Compiler").is_subclass_of(cast(*Type_Info) T, "Entity");
} {
    entities: [T.MAXIMUM] T;
    count:    int;
    next_id:  T.ID;
}

operator [] :: (using holder: $T/Entities, i: int) -> *T.T {
    assert(i < count);
    return *entities[i];
}
// TODO: operator []= ...?

for_expansion :: (holder: *$T/Entities, body: Code, flags: For_Flags) #expand {
    for <=cast(bool)(flags & .REVERSE) index: 0..holder.count-1 {
        `it_index := index;
        #if flags & .POINTER {
            `it := *holder.entities[it_index];
        } else {
            `it := holder.entities[it_index];
        }
        if it.is_dead then continue;
        #insert(remove=#assert(false)) body;
    }
}

spawn :: (using holder: *$T/Entities, entity: T.T) -> *T.T {
    if count == T.MAXIMUM then return null;

    new_entity := *entities[count];
    new_entity.* = entity;
    new_entity.id = next_id;
    next_id += 1;
    count += 1;

    return new_entity;
}
cleanup :: inline (using holder: *$T/Entities) {
    for it_index: 0..count-1 {
        it := entities[it_index];
        if it.is_dead {
            last_index := count - 1;
            if it_index != last_index then entities[it_index] = entities[last_index];
            count -= 1;
        }
    }
}
