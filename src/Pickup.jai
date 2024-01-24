Pickup :: struct {
    using #as base: Entity;

    experience: int;
    gold:       int;

    MAXIMUM :: 10_000;
}

spawn :: (pickup: Pickup, position: Vector2) {
    using state;

    new_pickup := spawn(*pickups, pickup);
    new_pickup.position = position;
}

pick_up :: (using pickup: *Pickup) {
    using state;

    log("ding");

    player.gold       += gold;
    player.experience += experience;

    despawn(pickup);
}
