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
