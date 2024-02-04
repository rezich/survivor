WEAPON_SPREADSHOT :: Weapon.{
    name                 = "Spreadshot",
    projectile           = .{
        sprite = .BULLET,
        radius = 4,
        speed  = 200,
        growth = 2,
        flags  = .IS_FIRE
    },
    projectiles_per_shot = 3,
    shot_pattern         = .RADIAL,
    shot_cooldown        = 0.66,
    shot_damage          = 1,
    upgrades             = .[.{

        projectiles_per_shot = 1,
        shot_radius          = 1

    }, .{

        projectiles_per_shot = 1,
        shot_damage          = 1,
        shot_radius          = 3

    }, .{

        projectiles_per_shot = 1,
        shot_damage          = 1

    }, .{

        projectiles_per_shot = 3

    }]
};

WEAPON_PULSE :: Weapon.{
    name                 = "Pulser",
    projectile           = .{
        sprite = .PULSE_WAVE,
        radius = 32,
        speed  = 0,
        growth = 64,
        life   = 0.5,
        flags  = .FOLLOWS_PLAYER | .NOT_DESTROYED_UPON_COLLISION
    },
    projectiles_per_shot = 1,
    shot_pattern         = .RADIAL,
    shot_cooldown        = 1.0,
    shot_damage          = 1,
    upgrades             = .[.{

        shot_damage = 1

    }, .{

        shot_growth = 64

    }, .{

        shot_damage = 1,
        shot_radius = 64

    }, .{

        shot_damage = 4,
        shot_radius = 64

    }]
};

WEAPON_STAFF :: Weapon.{
    name                 = "Magic Staff",
    projectile           = .{
        sprite = .BULLET,
        radius = 4,
        speed  = 200,
        flags  = .IS_FIRE
    },
    projectiles_per_shot = 1,
    shot_pattern         = .AIM_AT_NEAREST_ENEMY,
    shot_cooldown        = 2,
    shot_damage          = 2,
    upgrades             = .[.{

        shot_cooldown    = -0.2

    }, .{

        shot_damage      = 1,
        shot_cooldown    = -0.3

    }, .{

        shot_damage      = 1,
        shot_cooldown    = -0.3

    }, .{

        shot_cooldown    = -0.4

    }]
};

/*WEAPON_GARLIC :: Weapon.{
    name                 = "Legally-Distinct Garlic",
    projectile           = .{
        sprite = .PULSE,
        radius = 48,
        flags  = .FOLLOWS_PLAYER | .NOT_DESTROYED_UPON_COLLISION | .ONLY_ONE_PROJECTILE
    },
    projectiles_per_shot = 1,
    shot_pattern         = .RADIAL,
    
}*/




Weapon :: struct {
    Stats :: struct {
        projectiles_per_shot: int;
        shot_cooldown:        float;
        shot_damage:          int;
        shot_radius:          float;
        shot_growth:          float;
    }

    name:         string;
    projectile:   Projectile;
    using stats:  Stats;
    shot_pattern: enum { RADIAL; AIM_AT_NEAREST_ENEMY; };
    
    upgrades:     [] Stats;

    level:         int;
    next_shot:    float;
}

fire :: (using weapon: *Weapon) {
    using state;

    if #complete shot_pattern == {

    case .RADIAL;
        if projectiles_per_shot > 1 {
            for i: 0..projectiles_per_shot-1 {
                theta := TAU / projectiles_per_shot * i;
                direction := Vector2.{ cos(theta), sin(theta) };
                spawn(projectile, weapon, player.position + direction * player.radius, direction);
            }
        } else spawn(projectile, weapon, player.position, .{});

    case .AIM_AT_NEAREST_ENEMY;
        assert(projectiles_per_shot == 1); //TODO: remove this, obviously
        nearest_enemy_distance := FLOAT32_INFINITY;
        nearest_enemy_position := Vector2.{};
        for enemies {
            distance_to_enemy := distance_squared(player.position, it.position);
            if distance_to_enemy >= nearest_enemy_distance || !is_on_screen(it) then continue;
            nearest_enemy_distance = distance_to_enemy;
            nearest_enemy_position = it.position;
        }
        if nearest_enemy_distance != FLOAT32_INFINITY {
            theta := atan2_between(nearest_enemy_position, player.position);
            direction := Vector2.{ cos(theta), sin(theta) };
            spawn(projectile, weapon, player.position + direction * player.radius, direction);
        }

    }
    next_shot = time + shot_cooldown;
}

upgrade :: (using weapon: *Weapon) {
    assert(level <= upgrades.count-1);
    upgrade := upgrades[level];
    level += 1;

    projectiles_per_shot += upgrade.projectiles_per_shot;
    shot_cooldown        += upgrade.shot_cooldown;
    shot_damage          += upgrade.shot_damage;
    shot_radius          += upgrade.shot_radius;
    shot_growth          += upgrade.shot_growth;

    if projectile.flags & .ONLY_ONE_PROJECTILE {
        for * state.projectiles if it.flags & .ONLY_ONE_PROJECTILE then despawn(it);
        for * state.player.weapons if it.projectile.flags & .ONLY_ONE_PROJECTILE then fire(it);
    }
}

upgrade_random_weapon_if_possible :: () {
    using state;
    eligible_weapons: [..] *Weapon;
    for * player.weapons if it.level < it.upgrades.count then array_add(*eligible_weapons, it,, temp);
    if eligible_weapons.count > 0 then upgrade(eligible_weapons[random_get() % xx eligible_weapons.count]); 
}

simulate_player_weapon_behavior :: inline () {
    for * state.player.weapons if state.time >= it.next_shot then fire(it);
}
