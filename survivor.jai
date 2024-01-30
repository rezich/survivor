BUILD : enum { DEBUG; RELEASE; } : .DEBUG;



/*

TODO:
  - weapon acquisition/upgrade system
  - some kind of invulnerability window thing
  - add wave system
  - add HUD
  - add a decent, reasonably competent framerate controller

*/




Character :: struct {
    health:     int;
    health_max: int;
    speed:      float;
}




state: struct {
    enemies:     Entities(Enemy);
    projectiles: Entities(Projectile);
    pickups:     Entities(Pickup);

    player: struct {
        using #as base:      Entity    = PLAYER_ENTITY;
        using #as character: Character = PLAYER_CHARACTER;

        weapons:       [..] Held_Weapon;

        pickup_radius: float = PLAYER_PICKUP_RADIUS;

        gold:          int;
        experience:    int;
    }

    input: struct {
        cursor_position: struct {
            raw:    struct { x, y: int; };
            screen: Vector2;
            world:  Vector2;
        }

        // player actions
        is_player_moving_toward_cursor: bool;

        // system actions
        is_toggling_pause:              bool;
        is_toggling_fullscreen:         bool;
    }

    camera: struct {
        position: Vector2;
        left:     float;
        right:    float;
        top:      float;
        bottom:   float;
    }

    time: float;

    is_paused:  bool;
    is_exiting: bool;
}




init :: () {
    using state;

    player.health_max = player.health;
    for PLAYER_INITIAL_WEAPONS array_add(*player.weapons, it);

    spawn_around_player(ENEMY_VAMPIRE, 10, 200.0);
    spawn_around_player(ENEMY_GOBLIN,  20, 300.0);
}

reinit :: () { state = .{}; init(); }




INPUT_HANDLING_CODE :: #code {
    is_player_moving_toward_cursor = is_held   (.MOUSE_BUTTON_LEFT);
    is_toggling_pause              = is_pressed(.ESCAPE);
    is_toggling_fullscreen         = is_pressed(.F4);
};




simulate :: (dt: float) {
    using state;

    // toggle fullscreen
    if input.is_toggling_fullscreen then toggle_fullscreen();

    // skip rest of simulation if paused, otherwise update game time
    if input.is_toggling_pause then is_paused = !is_paused;
    if is_paused then return;
    time += dt;


    // move camera
    {
        using camera;
        left   = position.x - window.half_size.x;
        right  = position.x + window.half_size.x;
        bottom = position.y - window.half_size.y;
        top    = position.y + window.half_size.y;
    }


    // spawn waves if needed
    //TODO


    // simulate player
    if input.is_player_moving_toward_cursor {
        toward_cursor := input.cursor_position.world - player.position;
        normalize(*toward_cursor);
        player.velocity = toward_cursor * player.speed;
    } else player.velocity = .{};


    // simulate weapons
    simulate_player_weapon_behavior();


    // simulate entities
    simulate_enemy\       _behavior();
    simulate_pickup\      _behavior();
    simulate_projectile\  _behavior(dt);


    // move entities
    for * enemies     move(it,      dt);
    for * projectiles move(it,      dt);
    for * pickups     move(it,      dt);
                      move(*player, dt);


    // handle collisions
    simulate_collisions_between_player\    _and_pickups();
    simulate_collisions_between_projectiles_and_enemies();
    simulate_collisions_between_enemies\   _and_player ();


    // restart the game if the player dies
    if player.health <= 0 then reinit();


    // remove dead entities
    cleanup(*enemies);
    cleanup(*projectiles);
    cleanup(*pickups);
}




render :: () {
    begin_rendering();

    using state;

    for pickups     render(it);
    for enemies     render(it);
                    render(player);
    for projectiles render(it);

    end_rendering();
}




main :: () {
    init_engine("survivor");
    load_assets();
    init();

    using state;

    while (!is_exiting) {
        dt := advance_time();

        handle_input();
        simulate(dt);
        render();

        reset_temporary_storage();
    }

    #if DEBUG_MEMORY then report_memory_leaks();
}




#load "src/Assets.jai";
#load "src/Animation.jai";
#load "src/Enemy.jai";
#load "src/Engine.jai";
#load "src/Entity.jai";
#load "src/Pickup.jai";
#load "src/Projectile.jai";
#load "src/Util.jai";
#load "src/Weapon.jai";

#load "design.jai";
