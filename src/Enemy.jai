Enemy :: struct {
    using #as base:      Entity;
    using #as character: Character;
    //using #as animator:  Animator;

    damage: int;

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

spawn_around_player :: (enemy: Enemy, count: int, distance: float) {
    for 0..count-1 {
        theta := TAU / count * it;
        spawn(enemy, state.player.position + .{ cos(theta), sin(theta) } * distance);
    }
}

kill :: (using enemy: *Enemy) {
    spawn(PICKUP_COIN, position);
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

    for enemy: enemies {
        will_collide_with_player := will_collide(enemy, player);
        if will_collide_with_player {
            player.health -= enemy.damage;
        }
    }
}
