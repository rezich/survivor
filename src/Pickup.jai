Pickup :: struct {
    using #as base: Entity;

    status: enum { IDLE; SWOOPING; FOLLOWING_PLAYER; };

    swoop_target: Vector2;

    experience: int;
    gold:       int;

    MAXIMUM :: 10_000;
    SPEED   :: PICKUP_SPEED;

    VIBRATION_RANGE     :: PICKUP_VIBRATION_RANGE;
    VIBRATION_INTENSITY :: PICKUP_VIBRATION_INTENSITY;

    SWOOP_DISTANCE :: PICKUP_SWOOP_DISTANCE;
    SWOOP_SPEED    :: PICKUP_SWOOP_SPEED;
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
