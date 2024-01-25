#load "src/Assets.jai";
#load "src/Animation.jai";
#load "src/Entity.jai";
#load "src/Enemy.jai";
#load "src/Projectile.jai";
#load "src/Pickup.jai";
#load "src/Util.jai";

#load "design.jai";



BUILD : enum { DEBUG; RELEASE; } : .DEBUG;



/*

TODO:
  - despawn projectiles that go off-screen
  - add weapon system
  - add wave system
  - add HUD
  - put any thought at all into the framerate controller

*/




window: struct {
    handle: Window_Type;
    width  := 1280;
    height := 720;
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

        pickup_radius: float = 48;

        next_shot_time: float;
        TIME_BETWEEN_SHOTS   :: 1.0;
        PROJECTILES_PER_SHOT :: 8;
        PROJECTILE_SPEED     :: 400;

        gold:          int;
        experience:    int;
    }

    input: struct {
        cursor_world_position:          Vector2;
        is_player_intentionally_moving: bool;
    }

    camera: struct {
        position: Vector2;
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
                if it.key_pressed && it.key_code == .SPACEBAR then for pickups log("% %", it_index, it.position);
        }
    }
}

simulate :: (dt: float) {
    using state;

    // skip if paused, otherwise update game time
    if is_paused then return;
    time.game += dt;


    // fire player weapons if needed
    //TODO
    if time.game >= player.next_shot_time {
        for 0..player.PROJECTILES_PER_SHOT-1 {
            theta := TAU / player.PROJECTILES_PER_SHOT * it;
            offset := Vector2.{ -cos(theta), sin(theta) };
            spawn(PROJECTILE_BULLET, player.position + offset * player.radius, offset * player.PROJECTILE_SPEED);
        }
        player.next_shot_time = time.game + player.TIME_BETWEEN_SHOTS;
    }


    // spawn waves if needed
    //TODO


    // determine player behavior
    if input.is_player_intentionally_moving {
        toward_cursor := input.cursor_world_position - player.position;
        normalize(*toward_cursor);
        player.velocity = toward_cursor * player.speed;
    } else player.velocity = .{};


    // determine enemy behavior
    for * enemies {
        toward_player := player.position - it.position;
        normalize(*toward_player);
        it.velocity = toward_player * it.speed;
    }


    // determine pickup behavior
    for * pickups {
        if !it.is_following_player then continue;

        toward_player := player.position - it.position;
        normalize(*toward_player);
        it.velocity = toward_player * Pickup.SPEED;
    }


    // move entities
    for * enemies     move(it,      dt);
    for * projectiles move(it,      dt);
    for * pickups     move(it,      dt);
                      move(*player, dt);


    // check for collisions

    // player -> pickups
    for * pickup: pickups {
        will_be_magnetized, _ := will_collide(player, pickup, player.pickup_radius);
        if will_be_magnetized then pickup.is_following_player = true;

        will_be_picked_up, _ := will_collide(player, pickup);
        if will_be_picked_up  then pick_up(pickup);
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
            player.health -= enemy.damage;
        }
    }


    // end the game if the player dies
    if player.health <= 0 then is_exiting = true;


    cleanup(*enemies);
    cleanup(*projectiles);
    cleanup(*pickups);
}

render :: () {
    using state;

    Simp.clear_render_target(.30, .33, .37, 1);
    Simp.set_shader_for_color();
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
        // Windows is very bad at thread-switching by default unless you do this. Sad.
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

        sleep_milliseconds(10); //TODO: an actual frame controller
        reset_temporary_storage();
    }
}




#import "Basic";
#import "Math";
#import "Window_Creation";
#import "System";  // For get_path_of_running_executable. @Cleanup.
#import "String";  // For path_strip_filename. @Cleanup.

Simp  :: #import "Simp";
Input :: #import "Input";




// hide console in release builds
#if BUILD != .DEBUG then #run #if OS == .WINDOWS {
    WR :: #import "Windows_Resources";
    WR.disable_runtime_console();
}
