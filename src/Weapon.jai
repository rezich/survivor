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

    if time.game >= player.weapon.next_shot {
        if #complete player.weapon.shot_pattern == {
        case .RADIAL;
            if player.weapon.projectiles_per_shot > 1 {
                for 0..player.weapon.projectiles_per_shot-1 {
                    theta := TAU / player.weapon.projectiles_per_shot * it;
                    direction := Vector2.{ cos(theta), sin(theta) };
                    spawn(player.weapon.projectile, player.position + direction * player.radius, direction);
                }
            } else spawn(player.weapon.projectile, player.position, .{});
        }
        player.weapon.next_shot = time.game + player.weapon.shot_cooldown;
    }
}
