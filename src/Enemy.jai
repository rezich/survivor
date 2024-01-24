Enemy :: struct {
    using #as base:      Entity;
    using #as character: Character;
    //using #as animator:  Animator;

    damage: int;

    MAXIMUM :: 10_000;
}

spawn :: (enemy: Enemy, position: Vector2) {
    using state;

    new_enemy := spawn(*enemies, enemy);
    new_enemy.position   = position;
    new_enemy.health_max = new_enemy.health;
}

spawn_in_circle_around_player :: (enemy: Enemy, count: int, distance: float) {
    for 0..count-1 {
        theta := TAU / count * it;
        spawn(enemy, state.player.position + .{ -cos(theta), sin(theta) } * distance);
    }
}

kill :: (using enemy: *Enemy) {
    spawn(PICKUP_COIN, position);
    despawn(enemy);
}
