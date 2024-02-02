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
