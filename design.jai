// game

BACKGROUND_COLOR            :: Vector4.{ .30, .33, .37, 1 };




// player

PLAYER_PICKUP_RADIUS        :: 40;

PLAYER_TIME_BETWEEN_SHOTS   :: 1.0;
PLAYER_PROJECTILES_PER_SHOT :: 8;
PLAYER_PROJECTILE_SPEED     :: 400;


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
    damage = 10
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
