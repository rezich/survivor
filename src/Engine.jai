window: struct {
    handle:        Window_Type;
    width       := 1280;
    height      := 720;
    half_size:     Vector2;
    saved_info:    Saved_Window_Info;
    is_fullscreen: bool;
}

init_engine :: inline (window_title: string) {
    #if OS == .WINDOWS {
        Windows :: #import "Windows";
        Windows.SetProcessDPIAware();
        Windows.timeBeginPeriod(1);
    }

    window.handle = create_window(window.width, window.height, "survivor");
    window.width, window.height = Simp.get_render_dimensions(window.handle);
    Simp.set_render_target(window.handle);

    engine_time = current_time_monotonic();
}

engine_time: Apollo_Time;

advance_time :: inline () -> float {
    using state;
    prev_time := engine_time;
    engine_time = current_time_monotonic();
    return cast(float) to_float64_seconds(engine_time - prev_time);
}

begin_rendering :: inline () {
    Simp.clear_render_target(BACKGROUND_COLOR.x, BACKGROUND_COLOR.y, BACKGROUND_COLOR.z, BACKGROUND_COLOR.w);
    Simp.set_shader_for_color(enable_blend = true);
    Simp.immediate_begin();
}

end_rendering :: inline () {
    Simp.immediate_flush();
    Simp.swap_buffers(window.handle);
}

handle_input :: inline () {
    is_held     :: inline (key: Input.Key_Code) -> bool         { return xx (Input.input_button_states[key] & .DOWN);       }
    is_pressed  :: inline (key: Input.Key_Code) -> bool #expand { return `received[key] &&  `pressed[key] && !`repeat[key]; }
    is_released :: inline (key: Input.Key_Code) -> bool #expand { return `received[key] && !`pressed[key] && !`repeat[key]; }

    Input.update_window_events();
    for Input.get_window_resizes() {
        Simp.update_window(it.window);
        //if it.window == window.handle {}
    }
    window.half_size = .{ xx window.width, xx window.height } * .5;

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

toggle_fullscreen :: () {
    using window;
    success := toggle_fullscreen(handle, !is_fullscreen, *saved_info);
    if success {
        is_fullscreen = !is_fullscreen;
        width, height = Simp.get_render_dimensions(window.handle);
    }
}




// hide console in release builds
#if BUILD != .DEBUG then #run #if OS == .WINDOWS {
    WR :: #import "Windows_Resources";
    WR.disable_runtime_console();
}




DEBUG_MEMORY :: BUILD == .DEBUG;




#import "Basic"()(MEMORY_DEBUGGER=DEBUG_MEMORY);
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