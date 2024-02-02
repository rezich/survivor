ENEMY_SPAWN_OFFSET_RANGE :: 4;

ENEMY_SPIDER :: Enemy.{
    sprite = .SPIDER,
    radius = 10,
    speed  = 25,
    health = 1,
    damage = 1
};

ENEMY_ZOMBIE :: Enemy.{
    sprite = .ZOMBIE,
    radius = 12,
    speed  = 20,
    health = 2,
    damage = 1
};

ENEMY_BAT :: Enemy.{
    sprite = .BAT,
    radius = 6,
    speed  = 25,
    health = 1,
    damage = 1
};

ENEMY_VAMPIRE :: Enemy.{
    sprite = .VAMPIRE,
    radius = 16,
    speed  = 30,
    health = 10,
    damage = 2
};

ENEMY_GOBLIN :: Enemy.{
    sprite = .GOBLIN,
    radius = 8,
    speed  = 40,
    health = 4,
    damage = 1,
    flags  = .IMMUNE_TO_FIRE
};

ENEMY_SKELETON :: Enemy.{
    sprite = .SKELETON,
    radius = 12,
    speed  = 30,
    health = 10,
    damage = 5
};
