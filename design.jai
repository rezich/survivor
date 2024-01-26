// game

BACKGROUND_COLOR            :: Vector4.{ .30, .33, .37, 1 };




// player

PLAYER_PICKUP_RADIUS        :: 40;

PLAYER_INITIAL_WEAPONS      :: Held_Weapon.[
    .{ weapon = WEAPON_SPREADSHOT },
    .{ weapon = WEAPON_PULSE }
];


PLAYER_CHARACTER :: Character.{
    health = 100,
    speed  = 50
};

PLAYER_ENTITY :: Entity.{
    radius = 16
};




// enemy

ENEMY_VAMPIRE :: Enemy.{
    sprite = .VAMPIRE,
    radius = 16,
    speed  = 3,
    health = 10,
    damage = 2
};

ENEMY_GOBLIN :: Enemy.{
    sprite = .GOBLIN,
    radius = 8,
    speed  = 5,
    health = 4,
    damage = 1
};




// projectile

PROJECTILE_BULLET :: Projectile.{
    sprite = .BULLET,
    radius = 4,
    damage = 10,
    speed  = 200,
    growth = 2
};

PROJECTILE_PULSE :: Projectile.{
    sprite = .PULSE_WAVE,
    radius = 32,
    damage = 10,
    speed  = 0,
    growth = 64,
    life   = 0.5,
    flags  = .FOLLOWS_PLAYER | .NOT_DESTROYED_UPON_COLLISION
};




// pickup

PICKUP_SPEED               :: 120;

PICKUP_VIBRATION_RANGE     :: 32;
PICKUP_VIBRATION_INTENSITY :: 0.18;

PICKUP_SWOOP_DISTANCE      :: 32;
PICKUP_SWOOP_SPEED         :: 12;


PICKUP_COIN :: Pickup.{
    sprite     = .COIN,
    radius     = 4,
    gold       = 1
};

PICKUP_COIN_PILE :: Pickup.{
    sprite     = .COIN_PILE,
    radius     = 8,
    gold       = 10
};

PICKUP_EXPERIENCE_ORB :: Pickup.{
    sprite     = .EXPERIENCE_ORB,
    radius     = 6,
    experience = 1
};




// weapon

WEAPON_SPREADSHOT :: Weapon.{
    projectile           = PROJECTILE_BULLET,
    projectiles_per_shot = 8,
    shot_cooldown        = 0.66
};

WEAPON_PULSE :: Weapon.{
    projectile           = PROJECTILE_PULSE,
    projectiles_per_shot = 1,
    shot_cooldown        = 1.0
};
