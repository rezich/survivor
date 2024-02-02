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
