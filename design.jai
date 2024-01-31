// game

BACKGROUND_COLOR            :: Vector4.{ .30, .33, .37, 1 };




// sprite

Sprite :: enum {
    PLAYER;
    VAMPIRE;
    GOBLIN;
    BULLET;
    PULSE_WAVE;
    EXPERIENCE_ORB;
    COIN;
    COIN_PILE;
}

SPRITE_COLOR_CODE :: #code {
    if #complete sprite == {
        case .PLAYER;         color = .{ 0, 1, 0,  1};
        case .VAMPIRE;        color = .{ 1, 0, 0,  1};
        case .GOBLIN;         color = .{.5, 0, 0,  1};
        case .BULLET;         color = .{ 1, 0, 1,  1};
        case .PULSE_WAVE;     color = .{.5, 0,.5, .5};
        case .EXPERIENCE_ORB; color = .{ 0, 1, 1,  1};
        case .COIN;           color = .{ 1, 1, 0,  1};
        case .COIN_PILE;      color = .{.5,.5, 0,  1};
    }
}




// font

Font :: enum {
    FLOATER;
}

FONT_SIZE_PROCS : [#run type_info(Font).values.count] Font_Size_Proc : .[
    // FLOATER
    () -> int {
        return window.height / 48;
    },
];




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
    damage = 1,
    flags  = .IMMUNE_TO_FIRE
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
    damage = 10,
    speed  = 0,
    growth = 64,
    life   = 0.5,
    flags  = .FOLLOWS_PLAYER | .NOT_DESTROYED_UPON_COLLISION
};




// pickup

PICKUP_SPEED               :: 140;

PICKUP_PLOP_SPEED          :: 6.0;

PICKUP_VIBRATION_RANGE     :: 21;
PICKUP_VIBRATION_INTENSITY :: 0.17;

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
    float_speed    = 50,
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
    outline        = .{ 0, 0, 0, 1},
    float_style    = .LINEAR,
    float_speed    = 50,
    float_distance = 20
};
