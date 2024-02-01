Enemy :: struct {
    using #as entity:    Entity;
    using #as character: Character;
    sprite: Sprite;

    damage: int;
    flags:  enum_flags { IMMUNE_TO_FIRE; }

    SPAWN_OFFSET_RANGE :: ENEMY_SPAWN_OFFSET_RANGE;

    MAXIMUM :: 10_000;
}

spawn :: (enemy: Enemy, position: Vector2) -> *Enemy {
    using state;

    new_enemy := spawn(*enemies, enemy);
    assert(!!new_enemy);
    //if !new_enemy then return null;

    new_enemy.position   = position;
    new_enemy.health_max = new_enemy.health;

    return new_enemy;
}

spawn_somewhere_off_screen :: (enemy: Enemy) {
    theta       := random_get_within_range(0, TAU);
    offset      := random_get_within_range(0, Enemy.SPAWN_OFFSET_RANGE);
    distance    := window.pythagorean_distance + enemy.radius * (2.0 + offset*2);
    from_camera := Vector2.{cos(theta), sin(theta)} * distance;
    spawn(enemy, state.camera.position + from_camera);
}

spawn_around_player :: (enemy: Enemy, count: int, distance: float) {
    for 0..count-1 {
        theta := TAU / count * it;
        spawn(enemy, state.player.position + .{ cos(theta), sin(theta) } * distance);
    }
}

kill :: (using enemy: *Enemy) {
    spawn(ifx random_get() % 100 then PICKUP_COIN else PICKUP_COIN_PILE, position);
    despawn(enemy);
}

simulate_enemy_behavior :: inline () {
    using state;

    for * enemies {
        toward_player := player.position - it.position;
        normalize(*toward_player);
        it.velocity = toward_player * it.speed;
    }
}

simulate_collisions_between_enemies_and_player :: inline () {
    using state;

    for enemies if will_collide(it, player) then hurt_player(it.damage);
}
