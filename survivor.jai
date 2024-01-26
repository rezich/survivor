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
  - add weapon system
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

        //TODO: multiple weapons
        weapon: Held_Weapon = .{ weapon = PLAYER_INITIAL_WEAPON };

        pickup_radius: float = PLAYER_PICKUP_RADIUS;

        gold:          int;
        experience:    int;
    }

    input: struct {
        cursor_world_position:          Vector2;
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

    frames:     int;
    is_paused:  bool;
    is_exiting: bool;
}




init :: () {
    using state;

    time.real = current_time_monotonic();

    player.health_max = player.health;

    spawn_in_circle_around_player(ENEMY_VAMPIRE, 10, 200.0);
    spawn_in_circle_around_player(ENEMY_GOBLIN,  20, 300.0);
}

handle_input :: () {
    using state;

    Input.update_window_events();

    cursor_x, cursor_y, cursor_success := get_mouse_pointer_position(window.handle, true);

    if cursor_success {
        cursor_position := Vector2.{ xx cursor_x, xx cursor_y };
        input.cursor_world_position = to_world_space(cursor_position);
    }

    for Input.events_this_frame {
        if it.type == .QUIT then is_exiting = true;

        if it.type == {
            case .KEYBOARD;
                if it.key_pressed && it.key_code == .ESCAPE then is_paused = !is_paused;
                if it.key_code == .MOUSE_BUTTON_LEFT then input.is_player_intentionally_moving = xx it.key_pressed;
                if it.key_pressed && it.key_code == .SPACEBAR then player.position.y += 10;
        }
    }
}

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
        toward_cursor := input.cursor_world_position - player.position;
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
