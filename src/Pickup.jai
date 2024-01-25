Pickup :: struct {
    using #as base: Entity;

    is_following_player: bool;

    experience: int;
    gold:       int;

    MAXIMUM :: 10_000;
    SPEED   :: 100;
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

    log("ding");

    despawn(pickup);
}
