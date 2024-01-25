Pickup :: struct {
    using #as base: Entity;

    status: enum { IDLE; SWOOPING; FOLLOWING_PLAYER; };

    swoop_target: Vector2;

    experience: int;
    gold:       int;

    MAXIMUM :: 10_000;
    SPEED   :: 100;

    VIBRATION_RANGE     :: 32;
    VIBRATION_INTENSITY :: 0.18;

    SWOOP_DISTANCE :: 32;
    SWOOP_SPEED    :: 10;
}

spawn :: (pickup: Pickup, position: Vector2) -> *Pickup {
    using state;

    new_pickup := spawn(*pickups, pickup);
    new_pickup.position = position;

    return new_pickup;
}

pick_up :: (using pickup: *Pickup) {
    using state;

    player.gold       += gold;
    player.experience += experience;

    despawn(pickup);
}
