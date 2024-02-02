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
