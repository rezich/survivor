PLAYER_CHARACTER :: Character.{
    health = 100,
    speed  = 50
};

PLAYER_ENTITY :: Entity.{
    radius = 16
};




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




PROJECTILE_BULLET :: Projectile.{
    sprite = .BULLET,
    radius = 4,
    damage = 10
};




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
