// sprite

Sprite :: enum {
    PLAYER;

    SPIDER;
    BAT;
    ZOMBIE;
    VAMPIRE;
    GOBLIN;
    SKELETON;

    BULLET;
    PULSE_WAVE;

    EXPERIENCE_ORB;
    COIN;
    COIN_PILE;
    CHICKEN;

    LAMP;
}

SPRITE_COLOR_CODE :: #code {
    if #complete sprite == {
        case .PLAYER;         color = .{ 0, 1, 0, 1};

        case .SPIDER;         color = .{.7,.7,.7, 1};
        case .ZOMBIE;         color = .{.3,.9,.6, 1};
        case .BAT;            color = .{.5,.5,.5, 1};
        case .VAMPIRE;        color = .{ 1, 0, 0, 1};
        case .GOBLIN;         color = .{.5, 0, 0, 1};
        case .SKELETON;       color = .{ 1, 1, 1, 1};

        case .BULLET;         color = .{ 1, 0, 1, 1};
        case .PULSE_WAVE;     color = .{.5, 0,.5,.5};

        case .EXPERIENCE_ORB; color = .{ 0, 1, 1, 1};
        case .COIN;           color = .{ 1, 1, 0, 1};
        case .COIN_PILE;      color = .{.5,.5, 0, 1};
        case .CHICKEN;        color = .{ 0,.5, 0, 1};

        case .LAMP;           color = .{ 1,.5, 0, 1};
    }
}




// font

FONTS :: struct { name: string; size_denominator: int; }.[
    .{ "FLOATER"   , 48 },
    .{ "HUD_LARGE" , 16 },
    .{ "HUD_SMALL" , 24 },
];

#insert -> string {
    builder: String_Builder;
    append(*builder, "Font :: enum {\n");
    for FONTS print_to_builder(*builder, "    %;\n", it.name);
    append(*builder, "}\n");

    append(*builder, "FONT_SIZE_DENOMINATORS :: int.[\n");
    for FONTS print_to_builder(*builder, "    %,\n", it.size_denominator);
    append(*builder, "];\n");

    return builder_to_string(*builder);
}




// player

PLAYER_PICKUP_RADIUS        :: 40;

PLAYER_INITIAL_WEAPONS      :: Held_Weapon.[
    .{ weapon = WEAPON_SPREADSHOT },
    .{ weapon = WEAPON_PULSE },
    .{ weapon = WEAPON_STAFF },
];


PLAYER_CHARACTER :: Character.{
    health = 100,
    speed  = 100
};

PLAYER_ENTITY :: Entity.{
    radius = 16
};




// enemy

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




// stage

STAGE_ENEMY_SPAWN_MAXIMUM   :: 300;
STAGE_SECONDS_BETWEEN_WAVES :: 10;

STAGE_FIRST :: Stage.{
    background = .{ .30, .33, .37, 1 },
    destructibles = .{
        chance        = 0.2,
        maximum       = 10,
        destructibles = .[
            DESTRUCTIBLE_LAMP
        ]
    },
    waves      = .[.{

        minimum  = 15,
        interval = 1.0,
        enemies  = .[
            ENEMY_SPIDER
        ]

    }, .{

        minimum  = 30,
        interval = 1.0,
        enemies  = .[
            ENEMY_ZOMBIE,
            ENEMY_BAT
        ]

    }, .{

        minimum  = 50,
        interval = 0.5,
        enemies  = .[
            ENEMY_SPIDER
        ]

    }, .{

        minimum  = 40,
        interval = 0.25,
        enemies  = .[
            ENEMY_SKELETON
        ]

    }, .{

        minimum  = 30,
        interval = 1.0,
        enemies  = .[
            ENEMY_SKELETON,
            ENEMY_GOBLIN
        ]

    }, .{

        minimum  = 300,
        interval = 0.1,
        enemies  = .[
            ENEMY_SKELETON
        ]

    }, .{

        minimum  = 50,
        interval = 0.5,
        enemies  = .[
            ENEMY_VAMPIRE,
            ENEMY_GOBLIN
        ]

    }]
};




// weapon

WEAPON_SPREADSHOT :: Weapon.{
    projectile           = PROJECTILE_BULLET,
    projectiles_per_shot = 8,
    shot_pattern         = .RADIAL,
    shot_cooldown        = 0.66
};

WEAPON_PULSE :: Weapon.{
    projectile           = PROJECTILE_PULSE,
    projectiles_per_shot = 1,
    shot_pattern         = .RADIAL,
    shot_cooldown        = 1.0
};

WEAPON_STAFF :: Weapon.{
    projectile           = PROJECTILE_BULLET,
    projectiles_per_shot = 1,
    shot_pattern         = .AIM_AT_NEAREST_ENEMY,
    shot_cooldown        = 2
};




// projectile

PROJECTILE_BULLET :: Projectile.{
    sprite = .BULLET,
    radius = 4,
    damage = 10,
    speed  = 200,
    growth = 2,
    flags  = .IS_FIRE
};

PROJECTILE_PULSE :: Projectile.{
    sprite = .PULSE_WAVE,
    radius = 32,
    damage = 1,
    speed  = 0,
    growth = 64,
    life   = 0.5,
    flags  = .FOLLOWS_PLAYER | .NOT_DESTROYED_UPON_COLLISION
};




// pickup

PICKUP_SPEED               :: 140;

PICKUP_PLOP_SPEED          :: 20.0;

PICKUP_VIBRATION_RANGE     :: 19;
PICKUP_VIBRATION_INTENSITY :: 0.07;

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
    gold       = 0, // not much of a coin pile...
    flags      = .PICK_UP_ALL_GOLD_AND_EXPERIENCE_IN_STAGE
};

PICKUP_EXPERIENCE_ORB :: Pickup.{
    sprite     = .EXPERIENCE_ORB,
    radius     = 3,
    experience = 1
};

PICKUP_CHICKEN :: Pickup.{
    sprite     = .CHICKEN,
    radius     = 10,
    health     = 25
};




// destructible

DESTRUCTIBLE_SPAWN_OFFSET_RANGE  :: 0;
DESTRUCTIBLE_TIME_BETWEEN_SPAWNS :: 1.0;

DESTRUCTIBLE_LAMP :: Destructible.{
    sprite = .LAMP,
    radius = 10
};




// floater

FLOATER_FADE_SPEED     :: 1.5;

FLOATER_SCALE_INITIAL                     :: Vector2.{ 0.5, 2.0 };
FLOATER_SCALE_SPEED_INITIAL_TO_STRETCHED  :: 30.0;
FLOATER_SCALE_STRETCHED                   :: Vector2.{ 1.8, 0.5 };
FLOATER_SCALE_SPEED_STRETCHED_TO_SQUISHED :: 20.0;
FLOATER_SCALE_SQUISHED                    :: Vector2.{ 1.0, 1.0 };


FLOATER_ENEMY_DAMAGE :: Floater.{
    color          = .{ 1, 1, 1, 1},
    outline        = .{ 0, 0, 0, 1},
    float_style    = .LINEAR,
    float_speed    = 52,
    float_distance = 20
};

FLOATER_ENEMY_IMMUNE :: Floater.{
    color          = .{.7,.7,.7, 1},
    outline        = .{.1,.1,.1, 1},
    float_style    = .EASED,
    float_speed    = 20,
    float_distance = 16
};

FLOATER_PLAYER_DAMAGE :: Floater.{
    color          = .{ 1, 0, 0, 1},
    outline        = .{ 1,.8,.8, 1},
    float_style    = .LINEAR,
    float_speed    = 52,
    float_distance = 20
};

FLOATER_PLAYER_HEAL :: Floater.{
    color          = .{ 0, 1, 0, 1},
    outline        = .{.8, 1,.8, 1},
    float_style    = .LINEAR,
    float_speed    = 52,
    float_distance = 20
};
