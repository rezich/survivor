Weapon :: struct {
    projectile:           Projectile;
    projectiles_per_shot: int;
    shot_cooldown:        float;
    shot_pattern:         enum { RADIAL; };
}

Held_Weapon :: struct {
    using weapon: Weapon;
    next_shot:    float;
}

simulate_player_weapon_behavior :: inline () {
    using state;

    for * player.weapons {
        if time.game >= it.next_shot {
            if #complete it.shot_pattern == {
            case .RADIAL;
                if it.projectiles_per_shot > 1 {
                    for i: 0..it.projectiles_per_shot-1 {
                        theta := TAU / it.projectiles_per_shot * i;
                        direction := Vector2.{ cos(theta), sin(theta) };
                        spawn(it.projectile, player.position + direction * player.radius, direction);
                    }
                } else spawn(it.projectile, player.position, .{});
            }
            it.next_shot = time.game + it.shot_cooldown;
        }
    }
}
