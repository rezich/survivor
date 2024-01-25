PLAYER_CHARACTER :: Character.{
    health = 100,
    speed  = 30
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
    gold       = 1
};

PICKUP_COIN_PILE :: Pickup.{
    sprite     = .COIN_PILE,
    gold       = 10
};

PICKUP_EXPERIENCE_ORB :: Pickup.{
    sprite     = .EXPERIENCE_ORB,
    experience = 1
};
