Pickup :: struct {
    using #as entity: Entity;
    sprite:           Sprite;

    status:           enum       { PLOPPING; IDLE; SWOOPING; FOLLOWING_PLAYER; };
    flags:            enum_flags { PICK_UP_ALL_GOLD_AND_EXPERIENCE_IN_STAGE; }

    radius_intended:  float;
    swoop_target:     Vector2;

    experience:       int;
    gold:             int;
    health:           int;

    MAXIMUM :: 10_000;
    SPEED   :: PICKUP_SPEED;

    PLOP_SPEED :: PICKUP_PLOP_SPEED;

    VIBRATION_RANGE     :: PICKUP_VIBRATION_RANGE;
    VIBRATION_INTENSITY :: PICKUP_VIBRATION_INTENSITY;

    SWOOP_DISTANCE :: PICKUP_SWOOP_DISTANCE;
    SWOOP_SPEED    :: PICKUP_SWOOP_SPEED;
}

spawn :: (pickup: Pickup, position: Vector2) -> *Pickup {
    using state;

    new_pickup := spawn(*pickups, pickup);
    assert(!!new_pickup);
    //if !new_pickup then return null;

    new_pickup.position        = position;
    new_pickup.radius_intended = new_pickup.radius;
    new_pickup.radius          = 0;

    return new_pickup;
}

pick_up :: (using pickup: *Pickup) {
    using state;

    player.gold       += gold;
    player.experience += experience;
    if health then heal_player(health);

    if flags & .PICK_UP_ALL_GOLD_AND_EXPERIENCE_IN_STAGE then for * pickups if (it.status == .PLOPPING || it.status == .IDLE) && (it.gold > 0 || it.experience > 0) then begin_magnetizing(it);

    despawn(pickup);
}

begin_magnetizing :: (using pickup: *Pickup) {
    pickup.radius = pickup.radius_intended; // kinda a hack
    pickup.status = .SWOOPING;
    away_from_player := pickup.position - state.player.position;
    normalize(*away_from_player);
    pickup.swoop_target = pickup.position + away_from_player * Pickup.SWOOP_DISTANCE;
}

simulate_pickup_behavior :: inline (dt: float) {
    using state;

    for * pickups {
        it.vibration = 0;

        if #complete it.status == {
        case .PLOPPING;
            it.radius = ease(it.radius, it.radius_intended, Pickup.PLOP_SPEED * dt);
            if values_are_close(it.radius_intended, it.radius, 0.1) {
                it.radius = it.radius_intended;
                it.status = .IDLE;
            }
            #through;
        case .IDLE;
            distance_to_player := distance(it.position, player.position);
            vibration_begin_distance := player.pickup_radius + Pickup.VIBRATION_RANGE;
            if distance_to_player < vibration_begin_distance {
                it.vibration = (Pickup.VIBRATION_RANGE - (distance_to_player - player.pickup_radius)) * Pickup.VIBRATION_INTENSITY;
            }
        case .SWOOPING;
            distance_to_swoop_target := distance(it.position, it.swoop_target);
            if is_approximately_zero(distance_to_swoop_target, 1) then it.status = .FOLLOWING_PLAYER;
            else {
                toward_swoop_target := it.swoop_target - it.position;
                normalize(*toward_swoop_target);
                it.velocity = toward_swoop_target * (distance_to_swoop_target * Pickup.SWOOP_SPEED);
            }
        case .FOLLOWING_PLAYER;
            toward_player := player.position - it.position;
            normalize(*toward_player);
            it.velocity = toward_player * Pickup.SPEED;
        }
    }
}

simulate_collisions_between_player_and_pickups :: inline () {
    using state;

    for * pickup: pickups {
        if pickup.status == .IDLE {
            will_be_magnetized := will_collide(player, pickup, player.pickup_radius);
            if will_be_magnetized then begin_magnetizing(pickup);
        }

        will_be_picked_up := will_collide(player, pickup);
        if will_be_picked_up  then pick_up(pickup);
    }
}
