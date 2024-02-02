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
