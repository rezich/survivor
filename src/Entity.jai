Entity :: struct {
    is_dead:  bool;
    position: Vector2;
    velocity: Vector2;
    radius:   float;
    sprite:   Sprite;
    position_intended: Vector2;
}

// if the two Entities collide, returns true and position of collision
will_collide :: (a: Entity, b: Entity, a_radius_override := 0.0) -> bool, Vector2 {
    circles_collide, collision_point := do_moving_circles_collide(a.position, a.position_intended, ifx a_radius_override else a.radius, b.position, b.position_intended, b.radius);
    return circles_collide, collision_point;
}

determine_intended_movement :: inline (using entity: *Entity, dt: float) {
    position_intended = position + velocity * dt;
}

move :: inline(using entity: *Entity) {
    position = position_intended;
}

render :: (using entity: Entity) {
    using state;
    pos := to_screen_space(position);
    p0 := pos - Vector2.{radius, radius};
    p1 := pos + Vector2.{radius, radius};

    color: Vector4;
    if #complete sprite == {
        case .PLAYER;         color = .{ 0, 1, 0,1};
        case .VAMPIRE;        color = .{ 1, 0, 0,1};
        case .GOBLIN;         color = .{.5, 0, 0,1};
        case .BULLET;         color = .{ 1, 0, 1,1};
        case .EXPERIENCE_ORB; color = .{ 0, 1, 1,1};
        case .COIN;           color = .{ 1, 1, 0,1};
        case .COIN_PILE;      color = .{.5,.5, 0,1};
    }

    Simp.immediate_quad(p0.x, p0.y, p1.x, p1.y, color);
}

despawn :: inline (entity: *Entity) {
    entity.is_dead = true;
}




Entities :: struct(T: Type, CAPACITY: int) #modify {
    return (#import "Compiler").is_subclass_of(cast(*Type_Info) T, "Entity");
} {
    entities: [CAPACITY] T;
    count:    int;
}

spawn :: inline (using holder: *$T/Entities, entity: T.T) -> *T.T {
    assert(count < CAPACITY);
    new_entity := *entities[count];
    new_entity.* = entity;
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

operator [] :: (using holder: $T/Entities, i: int) -> *T.T {
    assert(i < count);
    return *entities[i];
}

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
