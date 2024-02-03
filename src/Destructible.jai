DESTRUCTIBLE_TIME_BETWEEN_SPAWNS :: 1.0;


DESTRUCTIBLE_LAMP :: Destructible.{
    sprite = .LAMP,
    radius = 10
};




Destructible :: struct {
    using #as entity: Entity;
    sprite:           Sprite;

    MAXIMUM :: 100;

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

destroy :: (using destructible: *Destructible) {
    pickup := PICKUP_COIN;
    roll   := random_get_zero_to_one();
         if roll <= 0.1  then pickup = PICKUP_COIN_PILE;
    else if roll <= 0.5  then pickup = PICKUP_CHICKEN;
    spawn(pickup, destructible.position);
    despawn(destructible);
}