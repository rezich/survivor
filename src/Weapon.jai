Weapon :: struct {
    Stats :: struct {
        projectiles_per_shot: int;
        shot_cooldown:        float;
    }

    name:         string;
    projectile:   Projectile;
    using stats:  Stats;
    shot_pattern: enum { RADIAL; AIM_AT_NEAREST_ENEMY; };
    
    upgrades:     [] Stats;

    level:         int;
}

Held_Weapon :: struct {
    using weapon: Weapon;
    next_shot:    float;
}

upgrade :: (using weapon: *Weapon) {
    assert(level < upgrades.count-1);
    upgrade := upgrades[level+1];

    projectiles_per_shot += upgrade.projectiles_per_shot;
    shot_cooldown        += upgrade.shot_cooldown;

    level += 1;
}

upgrade_random_weapon_if_possible :: () {
    using state;
}

simulate_player_weapon_behavior :: inline () {
    using state;

    nearest_enemy_distance := FLOAT32_INFINITY;
    nearest_enemy_position := Vector2.{};
    for enemies {
        distance_to_enemy := distance_squared(player.position, it.position);
        if distance_to_enemy >= nearest_enemy_distance || !is_on_screen(it) then continue;
        nearest_enemy_distance = distance_to_enemy;
        nearest_enemy_position = it.position;
    }

    for * player.weapons {
        if time >= it.next_shot {
            if #complete it.shot_pattern == {

            case .RADIAL;
                if it.projectiles_per_shot > 1 {
                    for i: 0..it.projectiles_per_shot-1 {
                        theta := TAU / it.projectiles_per_shot * i;
                        direction := Vector2.{ cos(theta), sin(theta) };
                        spawn(it.projectile, player.position + direction * player.radius, direction);
                    }
                } else spawn(it.projectile, player.position, .{});

            case .AIM_AT_NEAREST_ENEMY;
                assert(it.projectiles_per_shot == 1); //TODO: remove this, obviously
                if nearest_enemy_distance != FLOAT32_INFINITY {
                    theta := atan2_between(nearest_enemy_position, player.position);
                    direction := Vector2.{ cos(theta), sin(theta) };
                    spawn(it.projectile, player.position + direction * player.radius, direction);
                }

            }
            it.next_shot = time + it.shot_cooldown;
        }
    }
}
