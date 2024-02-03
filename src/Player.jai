PLAYER_PICKUP_RADIUS        :: 40;

PLAYER_INITIAL_WEAPONS      :: Held_Weapon.[
    .{ weapon = WEAPON_SPREADSHOT },
    .{ weapon = WEAPON_PULSE },
    .{ weapon = WEAPON_STAFF },
];


PLAYER_CHARACTER :: Character.{
    health = 100,
    speed  = 100
};

PLAYER_ENTITY :: Entity.{
    radius = 16
};




Player :: struct {
    using #as entity:    Entity    = PLAYER_ENTITY;
    using #as character: Character = PLAYER_CHARACTER;
    sprite:              Sprite    = .PLAYER;

    weapons:       [..] Held_Weapon;

    pickup_radius: float = PLAYER_PICKUP_RADIUS;

    gold:          int;
    kills:         int;
    experience:    int;
    level:         int;

    experience_to_level_up: int = 5;

    invulnerability_to_enemies: Table(Enemy.ID, float);
}

hurt_player :: (enemy_id: Enemy.ID, damage: int, invulnerability: float) {
    using state;

    if table_contains(*player.invulnerability_to_enemies, enemy_id) then return;
    if invulnerability then table_add(*player.invulnerability_to_enemies, enemy_id, invulnerability);

    player.health -= damage;

    hud.most_recent_health_change = .HURT;
    hud.health_shake_amount += 5.0 * damage;
    Clamp(*hud.health_shake_amount, 10.0, 50.0);

    spawn(FLOATER_PLAYER_DAMAGE, player.position, damage);
}
heal_player :: (health: int) {
    using state;

    previous_health := player.health;
    player.health = min(player.health + health, player.health_max);

    hud.most_recent_health_change = .HEAL;
    hud.health_shake_amount += 5.0 * health;
    Clamp(*hud.health_shake_amount, 10.0, 50.0);

    spawn(FLOATER_PLAYER_HEAL, player.position, player.health - previous_health);
}
simulate_player :: (dt: float) {
    using state;

    if player.experience >= player.experience_to_level_up then level_up_player();

    if input.is_player_moving_toward_cursor {
        toward_cursor := input.cursor_position.world - player.position;
        normalize(*toward_cursor);
        player.velocity = toward_cursor * player.speed;
    } else player.velocity = .{};

    for * player.invulnerability_to_enemies {
        it.* -= dt;
        if it.* <= 0 then remove it;
    }

    if input.is_hurting_player    then hurt_player(U64_MAX, xx (random_get() % 30), 0);
    if input.is_spawning_chicken  then spawn(PICKUP_CHICKEN, player.position + .{100,0});
}
get_experience_required_to_level_up_player :: () -> int {
    get_experience_required_for_level_after :: (level: int) -> int {
        experience := 5;

        experience += min(level,    20) * 10;
        if level <= 20 then return experience;

        experience += min(level-20, 40) * 13;
        if level <= 40 then return experience;

        experience +=    (level-40    ) * 16;
        return experience;
    }

    using state.player;

    experience_needed := 0;
    for 0..level experience_needed += get_experience_required_for_level_after(it);
    return experience_needed;
}
level_up_player :: () {
    using state.player;
    level += 1;
    experience_to_level_up = get_experience_required_to_level_up_player();
}
