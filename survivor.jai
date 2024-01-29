#load "src/Assets.jai";
#load "src/Animation.jai";
#load "src/Enemy.jai";
#load "src/Entity.jai";
#load "src/Pickup.jai";
#load "src/Projectile.jai";
#load "src/Util.jai";
#load "src/Weapon.jai";

#load "design.jai";



BUILD : enum { DEBUG; RELEASE; } : .DEBUG;



/*

TODO:
  - weapon acquisition/upgrade system
  - some kind of invulnerability window thing
  - add wave system
  - add HUD
  - put any thought at all into the framerate controller

*/




window: struct {
    handle:    Window_Type;
    width   := 1280;
    height  := 720;
    half_size: Vector2;
}




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
        is_player_intentionally_moving: bool;
    }

    camera: struct {
        position: Vector2;
        left:     float;
        right:    float;
        top:      float;
        bottom:   float;
    }

    time: struct {
        real: Apollo_Time;
        game: float;
    }

    is_paused:  bool;
    is_exiting: bool;
}




init :: () {
    using state;

    time.real = current_time_monotonic();

    player.health_max = player.health;
    for PLAYER_INITIAL_WEAPONS array_add(*player.weapons, it);

    spawn_around_player(ENEMY_VAMPIRE, 10, 200.0);
    spawn_around_player(ENEMY_GOBLIN,  20, 300.0);
}


INPUT_HANDLING_CODE :: #code {
    is_player_intentionally_moving = is_held(.MOUSE_BUTTON_LEFT);
};


simulate :: (dt: float) {
    using state;

    // skip rest of simulation if paused, otherwise update game time
    if is_paused then return;
    time.game += dt;


    // move camera
    window.half_size = .{ xx window.width, xx window.height } * .5;
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
    if input.is_player_intentionally_moving {
        toward_cursor := input.cursor_position.world - player.position;
        normalize(*toward_cursor);
        player.velocity = toward_cursor * player.speed;
    } else player.velocity = .{};


    // simulate weapons
    simulate_player_weapon_behavior();


    // simulate entities
    simulate_enemy\    _behavior();
    simulate_pickup\   _behavior();
    simulate_projectile_behavior(dt);


    // move entities
    for * enemies     move(it,      dt);
    for * projectiles move(it,      dt);
    for * pickups     move(it,      dt);
                      move(*player, dt);


    // handle collisions
    simulate_collisions_between_player\    _and_pickups();
    simulate_collisions_between_projectiles_and_enemies();
    simulate_collisions_between_enemies\   _and_player ();


    // end the game if the player dies
    if player.health <= 0 then is_exiting = true;


    cleanup(*enemies);
    cleanup(*projectiles);
    cleanup(*pickups);
}


render :: () {
    using state;

    Simp.clear_render_target(BACKGROUND_COLOR.x, BACKGROUND_COLOR.y, BACKGROUND_COLOR.z, BACKGROUND_COLOR.w);
    Simp.set_shader_for_color(enable_blend = true);
    Simp.immediate_begin();

    for pickups     render(it);
    for enemies     render(it);
                    render(player);
    for projectiles render(it);

    Simp.immediate_flush();
    Simp.swap_buffers(window.handle);
}




handle_input :: () {
    is_held     :: inline (key: Input.Key_Code) -> bool         { return xx (Input.input_button_states[key] & .DOWN);       }
    is_pressed  :: inline (key: Input.Key_Code) -> bool #expand { return `received[key] &&  `pressed[key] && !`repeat[key]; }
    is_released :: inline (key: Input.Key_Code) -> bool #expand { return `received[key] && !`pressed[key] && !`repeat[key]; }

    Input.update_window_events();
    using state;
    input = .{};

    using state.input;

    cursor_x, cursor_y, cursor_success := get_mouse_pointer_position(window.handle, true);
    if cursor_success then cursor_position = .{
        raw    = .{ cursor_x, cursor_y },
        screen = .{ xx cursor_x, xx cursor_y },
        world  = to_world_space(Vector2.{ xx cursor_x, xx cursor_y })
    };

    received, pressed, repeat: [Input.NUM_BUTTON_STATES] bool;
    for Input.events_this_frame {
        if it.type == {
        case .QUIT; is_exiting = true;
        case .KEYBOARD;
            received[it.key_code] = true;
            pressed [it.key_code] = xx it.key_pressed;
            repeat  [it.key_code] = it.repeat;
        }
    }

    #insert,scope() INPUT_HANDLING_CODE;
}




main :: () {
    #if OS == .WINDOWS {
        Windows :: #import "Windows";
        Windows.SetProcessDPIAware();
        Windows.timeBeginPeriod(1);
    }

    window.handle = create_window(window.width, window.height, "survivor");
    window.width, window.height = Simp.get_render_dimensions(window.handle);
    Simp.set_render_target(window.handle);

    load_assets();

    init();

    using state;

    while (!is_exiting) {
        prev_time := time.real;
        time.real = current_time_monotonic();
        dt := cast(float) to_float64_seconds(time.real - prev_time);

        handle_input();
        simulate(dt);
        render();

        //sleep_milliseconds(10); //TODO: an actual frame controller
        reset_temporary_storage();
    }
}




#import "Basic";
#import "Math";
#import "Sloppy_Math";
#import "Random";
#import "Window_Creation";
//#import "System";  // For get_path_of_running_executable. @Cleanup.
//#import "String";  // For path_strip_filename. @Cleanup.

Simp    :: #import "Simp";
Input   :: #import "Input";
//GetRect :: #import "GetRect";
//Rect    :: GetRect.Rect;




// hide console in release builds
#if BUILD != .DEBUG then #run #if OS == .WINDOWS {
    WR :: #import "Windows_Resources";
    WR.disable_runtime_console();
}
