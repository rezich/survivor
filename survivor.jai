#load "src/Assets.jai";
#load "src/Animation.jai";
#load "src/Entity.jai";
#load "src/Enemy.jai";
#load "src/Projectile.jai";
#load "src/Pickup.jai";
#load "src/Util.jai";

#load "design.jai";




SECONDS_TO_SIMULATE :: 30;




Character :: struct {
    health:     int;
    health_max: int;
    speed:      float;
}




state: struct {
    enemies:     Entities(Enemy,           Enemy.MAXIMUM);
    projectiles: Entities(Projectile, Projectile.MAXIMUM);
    pickups:     Entities(Pickup,         Pickup.MAXIMUM);

    player: struct {
        using #as base:      Entity    = PLAYER_ENTITY;
        using #as character: Character = PLAYER_CHARACTER;

        pickup_radius: float = 24;

        gold:          int;
        experience:    int;
    }

    camera: struct {
        position: Vector2;
    }

    frames:     int;
    time:       float;
    is_paused:  bool;
    is_exiting: bool;
}




init :: () {
    using state;

    player.health_max = player.health;

    //spawn_in_circle_around_player(ENEMY_VAMPIRE, 10, 100.0);
    spawn(ENEMY_VAMPIRE, .{-100, 0});
    spawn(PICKUP_COIN, .{ 10, 0 });
}

simulate :: (dt: float) {
    using state;


    // handle player input
    //TODO


    // return if paused, otherwise increment time
    if is_paused then return;
    time += dt;
    if time >= SECONDS_TO_SIMULATE then is_exiting = true;


    // fire player weapons if needed
    //TODO


    // spawn waves if needed
    //TODO


    // determine enemy behavior
    for * enemies {
        toward_player := player.position - it.position;
        normalize(*toward_player);
        it.velocity = toward_player * it.speed;
    }


    // determine entity movement
    for * enemies     determine_intended_movement(it,      dt);
    for * projectiles determine_intended_movement(it,      dt);
    for * pickups     determine_intended_movement(it,      dt);
                      determine_intended_movement(*player, dt);


    // check for collisions

    // player -> pickups
    for * pickup: pickups {
        will_be_picked_up, _ := will_collide(player, pickup, player.pickup_radius);
        if will_be_picked_up then pick_up(pickup);
    }

    // projectiles -> enemies
    for * projectile: projectiles {
        for * enemy: enemies {
            they_will_collide, _ := will_collide(projectile, enemy);
            if they_will_collide {
                despawn(projectile);
                enemy.health = max(enemy.health - projectile.damage, 0);
                if enemy.health == 0 then kill(enemy);
                //continue projectile;
            }
        }
    }

    // enemies -> player
    for enemy: enemies {
        will_collide_with_player, _ := will_collide(enemy, player);
        if will_collide_with_player {
            log("ow");
            player.health -= enemy.damage;
        }
    }


    // move and animate everything
    for * enemies     move(it);
    for * projectiles move(it);
    for * pickups     move(it);
                      move(*player);


    // end the game if the player dies
    if player.health <= 0 {
        log("player died % seconds in on frame %", time, frames);
        is_exiting = true;
    }


    cleanup(*enemies);
    cleanup(*projectiles);
    cleanup(*pickups);

    if enemies.count > 0 && frames % 10 == 0 then log("frame %: enemy0 is at %", frames, enemies[0].position);

    frames += 1;
}

render :: () {
    using state;

    for pickups     render(it);
    for enemies     render(it);
                    render(player);
    for projectiles render(it);
}




main :: () {
    load_assets();

    init();

    using state;

    while (!is_exiting) { simulate(1.0 / 60.0); render(); }
}




#import "Basic";
#import "Math";