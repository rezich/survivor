Enemy :: struct {
    using #as entity:    Entity;
    using #as character: Character;
    sprite: Sprite;

    damage: int;
    flags:  enum_flags { IMMUNE_TO_FIRE; }

    invulnerability_to_projectiles: Table(u64, float);
    invulnerability: float = 0.5; // bad name; invulnerability that's conferred to player on hit

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
    init(*new_enemy.invulnerability_to_projectiles);

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

hurt :: (using,except(damage, invulnerability) enemy: *Enemy, damage: int, projectile_id: u64, invulnerability: float) {
    if table_contains(*enemy.invulnerability_to_projectiles, projectile_id) then return;
    if invulnerability then table_add(*enemy.invulnerability_to_projectiles, projectile_id, invulnerability);

    health = max(health - damage, 0);
    if health == 0 then kill(enemy);
    spawn(FLOATER_ENEMY_DAMAGE, position, damage);
}

kill :: (using enemy: *Enemy) {
    //spawn(ifx random_get() % 100 then PICKUP_COIN else PICKUP_COIN_PILE, position);
    if random_get() % 100 == 0 then spawn(PICKUP_COIN_PILE, position);
    spawn(PICKUP_EXPERIENCE_ORB, position);
    deinit(*enemy.invulnerability_to_projectiles);
    despawn(enemy);
    state.player.kills += 1;
}

reset_enemies :: () { for * state.enemies deinit(*it.invulnerability_to_projectiles); }

simulate_enemy_behavior :: inline (dt: float) {
    using state;

    for * enemies {
        for * it.invulnerability_to_projectiles {
            it.* -= dt;
            if it.* <= 0 then remove it;
        }
        toward_player := player.position - it.position;
        normalize(*toward_player);
        it.velocity = toward_player * it.speed;
    }
}

simulate_collisions_between_enemies_and_player :: inline () {
    using state;

    for enemies if will_collide(it, player) then hurt_player(it.id, it.damage, it.invulnerability);
}
