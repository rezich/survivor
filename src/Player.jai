PLAYER_PICKUP_RADIUS        :: 40;

PLAYER_INITIAL_WEAPONS      :: Weapon.[
    WEAPON_SPREADSHOT,
    WEAPON_PULSE,
    WEAPON_STAFF,
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

    weapons:       [..] Weapon;

    pickup_radius: float = PLAYER_PICKUP_RADIUS;

    gold:          int;
    kills:         int;
    experience:    int;
    level:         int;

    experience_to_level_up: int = 5;

    invulnerability_to_enemies: Table(Enemy.ID, float);

    hit_effect: float;
    //HIT_EFFECT_INVULNERABILITY_SCALE :: 4.0;
    HIT_EFFECT_TIME_SCALE            :: 0.25;
    HIT_EFFECT_TIME_SCALE_DOWN_SPEED :: 30.0;
    HIT_EFFECT_TIME_SCALE_UP\ _SPEED :: 30.0;
    HIT_EFFECT_ZOOM                  :: 1.75;
    HIT_EFFECT_ZOOM_IN\_SPEED        :: 6.0;
    HIT_EFFECT_ZOOM_OUT_SPEED        :: 7.0;
    HIT_EFFECT_VIGNETTE_SCALE        :: 0.5;
}

hurt_player :: (enemy_id: Enemy.ID, damage: int, invulnerability: float) {
    using state;

    if enemy_id != U64_MAX {
        if table_contains(*player.invulnerability_to_enemies, enemy_id) then return;
        if invulnerability then table_add(*player.invulnerability_to_enemies, enemy_id, invulnerability);
    }

    player.health -= damage;

    hud.most_recent_health_change = .HURT;
    hud.health_shake_amount += 5.0 * damage;
    Clamp(*hud.health_shake_amount, 10.0, 50.0);

    spawn(FLOATER_PLAYER_DAMAGE, player.position, damage);

    //player.hit_effect = invulnerability * Player.HIT_EFFECT_INVULNERABILITY_SCALE;
    player.hit_effect = 2.0;
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
simulate_player :: (dt: Dt) {
    using state;

    if player.hit_effect > 0 {
        time_scale = ease(time_scale, Player.HIT_EFFECT_TIME_SCALE, Player.HIT_EFFECT_TIME_SCALE_DOWN_SPEED * dt.actual);
        player.hit_effect = max(player.hit_effect - dt.actual, 0);
        camera.scale = ease(camera.scale, Player.HIT_EFFECT_ZOOM, Player.HIT_EFFECT_ZOOM_IN_SPEED * dt.actual);
    } else {
        time_scale = ease(time_scale, 1.0, Player.HIT_EFFECT_TIME_SCALE_UP_SPEED * dt.actual);
        camera.scale = ease(camera.scale, 1.0, Player.HIT_EFFECT_ZOOM_OUT_SPEED * dt.actual);
    }

    if player.experience >= player.experience_to_level_up then level_up_player();

    if input.is_player_moving_toward_cursor {
        toward_cursor := input.cursor_position.world - player.position;
        normalize(*toward_cursor);
        player.velocity = toward_cursor * player.speed;
    } else player.velocity = .{};

    for * player.invulnerability_to_enemies {
        it.* -= dt.scaled;
        if it.* <= 0 then remove it;
    }

    if input.is_hurting_player    then hurt_player(U64_MAX, xx (random_get() % 5) + 5, 0.25);
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
    upgrade_random_weapon_if_possible();
    experience_to_level_up = get_experience_required_to_level_up_player();
}
