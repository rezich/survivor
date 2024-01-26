Pickup :: struct {
    using #as base: Entity;

    status: enum { IDLE; SWOOPING; FOLLOWING_PLAYER; };

    swoop_target: Vector2;

    experience: int;
    gold:       int;

    MAXIMUM :: 10_000;
    SPEED   :: PICKUP_SPEED;

    VIBRATION_RANGE     :: PICKUP_VIBRATION_RANGE;
    VIBRATION_INTENSITY :: PICKUP_VIBRATION_INTENSITY;

    SWOOP_DISTANCE :: PICKUP_SWOOP_DISTANCE;
    SWOOP_SPEED    :: PICKUP_SWOOP_SPEED;
}

spawn :: (pickup: Pickup, position: Vector2) -> *Pickup {
    using state;

    new_pickup := spawn(*pickups, pickup);
    new_pickup.position = position;

    return new_pickup;
}

pick_up :: (using pickup: *Pickup) {
    using state;

    player.gold       += gold;
    player.experience += experience;

    despawn(pickup);
}

simulate_pickup_behavior :: inline () {
    using state;

    for * pickups {
        it.vibration = 0;

        if #complete it.status == {
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
            will_be_magnetized, _ := will_collide(player, pickup, player.pickup_radius);
            if will_be_magnetized {
                pickup.status = .SWOOPING;
                away_from_player := pickup.position - player.position;
                normalize(*away_from_player);
                pickup.swoop_target = pickup.position + away_from_player * Pickup.SWOOP_DISTANCE;
            }
        }

        will_be_picked_up, _ := will_collide(player, pickup);
        if will_be_picked_up  then pick_up(pickup);
    }
}
