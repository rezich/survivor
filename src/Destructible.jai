Destructible :: struct {
    using #as entity: Entity;
    sprite:           Sprite;

    MAXIMUM :: 100;

    SPAWN_OFFSET_RANGE  :: DESTRUCTIBLE_SPAWN_OFFSET_RANGE;
    TIME_BETWEEN_SPAWNS :: DESTRUCTIBLE_TIME_BETWEEN_SPAWNS;
}

spawn :: (destructible: Destructible, position: Vector2) -> *Destructible {
    using state;

    new_destructible := spawn(*destructibles, destructible);
    assert(!!new_destructible);
    //if !new_destructible then return null;

    new_destructible.position = position;

    return new_destructible;
}

spawn_somewhere_off_screen :: (destructible: Destructible) {
    theta       := random_get_within_range(0, TAU);
    offset      := random_get_within_range(0, Destructible.SPAWN_OFFSET_RANGE);
    distance    := window.pythagorean_distance + destructible.radius * (2.0 + offset*2);
    from_camera := Vector2.{cos(theta), sin(theta)} * distance;
    spawn(destructible, state.camera.position + from_camera);
}

destroy :: (using destructible: *Destructible) {
    pickup := PICKUP_COIN;
    roll   := random_get_zero_to_one();
         if roll <= 0.1  then pickup = PICKUP_COIN_PILE;
    else if roll <= 0.5  then pickup = PICKUP_CHICKEN;
    spawn(pickup, destructible.position);
    despawn(destructible);
}