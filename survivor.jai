BUILD : enum { DEBUG; RELEASE; } : .DEBUG;
FRAME_CONTROLLER : enum { VERY_NAIVE; LESS_NAIVE; } : .VERY_NAIVE;




/*

TODO:
  - massively clean up HUD text rendering
  - weapon acquisition/upgrade system
  - add the rest of the HUD
  - add a decent, reasonably competent framerate controller
  - figure out how to do collision sweeps for projectiles, player, enemies
  - add terrain
  - add particles

*/




Character :: struct {
    health:          int;
    health_max:      int;
    speed:           float;
}




settings: struct {
    suspend_when_out_of_focus := true;
};




state: struct {
    enemies:       Entities(Enemy);
    projectiles:   Entities(Projectile);
    pickups:       Entities(Pickup);
    destructibles: Entities(Destructible);
    floaters:      Entities(Floater);

    stage: struct {
        using stage:                        Stage = STAGE_FIRST;
        current_wave:                       int;
        time_until_next_enemy_spawn:        float;
        time_until_next_destructible_spawn: float;
    }

    player: Player;

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
        is_restarting:                  bool;

        // debug
        is_hurting_player:              bool;
        is_spawning_chicken:            bool;
    }

    camera: Camera;

    hud:  Hud;

    time: float;
    time_scale: float = 1.0;

    is_paused:    bool;
    is_suspended: bool;
    is_exiting:   bool;
}




initted := false;

init :: () {
    if initted { reset(); state = .{}; } initted = true;

    using state;

    player.health_max = player.health;
    init(*player.invulnerability_to_enemies); //TODO: determine a default capacity
    for PLAYER_INITIAL_WEAPONS array_add(*player.weapons, it);
}

reset :: () {
    deinit(*state.player.invulnerability_to_enemies);
    array_reset(*state.player.weapons); //TODO: remove, or at least move
    reset_floaters();
    reset_enemies();
}




INPUT_HANDLING_CODE :: #code {
    is_player_moving_toward_cursor = is_held   (.MOUSE_BUTTON_LEFT);

    is_toggling_pause              = is_pressed(.ESCAPE);
    is_toggling_fullscreen         = is_pressed(.F4);
    is_restarting                  = is_pressed(.F5);

    is_hurting_player              = is_pressed(.F1);
    is_spawning_chicken            = is_pressed(.F2);
};




simulate :: (dt: Dt) {
    using state;

    // skip rest of simulation if paused or suspended, otherwise update game time
    if input.is_toggling_pause then is_paused = !is_paused;
    if is_suspended then return;

    if !is_paused {
        time += dt.scaled;

        // simulate and move player
        simulate_player(dt);
        move(*player, dt.scaled);
    }

    // move camera
    move_camera();

    if is_paused then return;


    // simulate stage
    simulate_stage(dt.scaled);



    // simulate weapons
    simulate_player_weapon_behavior();


    // simulate entities
    simulate_enemy\      _behavior(dt.scaled);
    simulate_pickup\     _behavior(dt.scaled);
    simulate_floater\    _behavior(dt.scaled);
    simulate_projectile\ _behavior(dt.scaled);


    // move entities
    for * enemies     move(it,      dt.scaled);
    for * projectiles move(it,      dt.scaled);
    for * pickups     move(it,      dt.scaled);


    // handle collisions
    simulate_collisions_between_player\    _and_pickups();
    simulate_collisions_between_projectiles_and_enemies_and_destructibles();
    simulate_collisions_between_enemies\   _and_player ();


    // simulate HUD
    simulate_hud(dt.actual);


    // restart the game if the player dies
    if player.health <= 0 then input.is_restarting = true; //TODO: lmao


    // remove dead entities
    cleanup(*enemies);
    cleanup(*projectiles);
    cleanup(*pickups);
    cleanup(*floaters);
}




render :: () {
    using state;

    //if is_suspended then return;

    begin_rendering();

    { using stage.background; Simp.clear_render_target(x, y, z, w); }

    for pickups       render(it);
    for enemies       render(it);
    for destructibles render(it);
                      render(player);
    for projectiles   render(it);
    for floaters      render(it);

    render_hud();

    end_rendering();
}




on_reload_fonts :: () {
    font := assets.fonts[Font.FLOATER];
    assert(font != null);
    x := Simp.prepare_text(font, "WWWWWWWWWW");
    y := font.character_height;
    floater_texture_size = .{ x, y, .{ x/2.0, y/2.0 } };
}



main :: () {
    init_engine("survivor");
    load_assets();

    is_going_to_reinit := true;
    while is_going_to_reinit {
        init(); is_going_to_reinit = false;

        using state;

        #if FRAME_CONTROLLER != .VERY_NAIVE {
            accumulator: float = 0;
            DT_FIXED       :: 1.0 / 60.0;
            DT_FIXED_LIMIT :: 1.0 / 62.0;
        }

        while !is_exiting && !is_going_to_reinit {
            
            #if FRAME_CONTROLLER == {

            case .VERY_NAIVE;
                dt_actual := advance_time();
                handle_input();
                simulate(.{ scaled=dt_actual*time_scale, actual=dt_actual });
            
            case .LESS_NAIVE;
                accumulator += advance_time();
                while accumulator > DT_FIXED_LIMIT {
                    handle_input();
                    simulate(.{ scaled=DT_FIXED*time_scale, actual=DT_FIXED });
                    accumulator -= DT_FIXED;
                    if accumulator < 0 then accumulator = 0;
                }
    
            }

            render();

            if input.is_toggling_fullscreen then toggle_fullscreen();

            reset_temporary_storage();
            is_going_to_reinit = input.is_restarting;
        }
    }

    #if DEBUG_MEMORY {
        reset();
        report_memory_leaks();
    }
}




#load "src/Animation.jai";
#load "src/Assets.jai";
#load "src/Camera.jai";
#load "src/Destructible.jai";
#load "src/Engine.jai";
#load "src/Enemy.jai";
#load "src/Entity.jai";
#load "src/Floater.jai";
#load "src/HUD.jai";
#load "src/Pickup.jai";
#load "src/Player.jai";
#load "src/Projectile.jai";
#load "src/Stage.jai";
#load "src/Util.jai";
#load "src/Weapon.jai";
