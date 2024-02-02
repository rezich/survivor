WEAPON_SPREADSHOT :: Weapon.{
    name                 = "Spreadshot",
    projectile           = PROJECTILE_BULLET,
    projectiles_per_shot = 8,
    shot_pattern         = .RADIAL,
    shot_cooldown        = 0.66,
    upgrades             = .[.{

        projectiles_per_shot = 1

    }, .{

        projectiles_per_shot = 2

    }, .{

        projectiles_per_shot = 1

    }, .{

        projectiles_per_shot = 1

    }]
};

WEAPON_PULSE :: Weapon.{
    name                 = "Pulser",
    projectile           = PROJECTILE_PULSE,
    projectiles_per_shot = 1,
    shot_pattern         = .RADIAL,
    shot_cooldown        = 1.0
};

WEAPON_STAFF :: Weapon.{
    name                 = "Magic Staff",
    projectile           = PROJECTILE_BULLET,
    projectiles_per_shot = 1,
    shot_pattern         = .AIM_AT_NEAREST_ENEMY,
    shot_cooldown        = 2
};
