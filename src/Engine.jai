Dt :: struct { scaled, actual: float; }

#placeholder Full_Screen_Render_Target;
#insert -> string {
    builder: String_Builder;
    append(*builder, "Full_Screen_Render_Target :: enum {\n");
    append(*builder, "    OUTPUT;\n");
    append(*builder, "    UI;\n");
    for type_info(Full_Screen_Effect).names print(*builder, "    %;\n" , it);
    append(*builder, "}\n");
    return builder_to_string(*builder);
}

window: struct {
    handle:               Window_Type;
    width:                int = 1280;
    height:               int = 720;
    half_size:            Vector2;
    pythagorean_distance: float; // this is a dumb name for this
    saved_info:           Saved_Window_Info;
    is_fullscreen:        bool;
    scale_from_720:       float;

    full_screen_render_targets: [#run type_info(Full_Screen_Render_Target).values.count] *Simp.Texture;
    full_screen_render_targets_initted := false;
}
engine_time: Apollo_Time;

init_engine :: inline (window_title: string) {
    #if OS == .WINDOWS {
        Windows :: #import "Windows";
        Windows.SetProcessDPIAware();
        Windows.timeBeginPeriod(1);
    }

    window.handle = create_window(window.width, window.height, "survivor");
    window.width, window.height = Simp.get_render_dimensions(window.handle);
    
    Simp.set_render_target(window.handle);

    init_full_screen_effects();

    engine_time = current_time_monotonic();
}
advance_time :: inline () -> float {
    using state;
    prev_time := engine_time;
    engine_time = current_time_monotonic();
    return cast(float) to_float64_seconds(engine_time - prev_time);
}
begin_rendering_world :: inline () {
    if !window.full_screen_render_targets_initted then init_full_screen_render_targets();
    Simp.set_render_target(window.full_screen_render_targets[Full_Screen_Render_Target.OUTPUT]);
    Simp.set_shader_for_color(enable_blend = true);
    Simp.immediate_begin();
}
end_rendering_world :: inline () {
    Simp.immediate_flush();
}
begin_rendering_ui :: inline () {
    Simp.set_render_target(window.full_screen_render_targets[Full_Screen_Render_Target.UI]);
    clear_render_target();
    Simp.set_shader_for_color(enable_blend = true);
}
end_rendering_ui :: inline () {
    Simp.immediate_flush();
}
display :: inline () {
    render_full_screen_effects();

    Simp.set_render_target(window.handle);
    Simp.set_shader_for_images(window.full_screen_render_targets[Full_Screen_Render_Target.OUTPUT]);
    render_immediate_full_screen_quad();

    render_full_screen_effects_to_render_target();

    Simp.set_shader_for_images(window.full_screen_render_targets[#run type_info(Full_Screen_Render_Target).values.count-1]);
    render_immediate_full_screen_quad();

    Simp.set_shader_for_images(window.full_screen_render_targets[Full_Screen_Render_Target.UI]);
    render_immediate_full_screen_quad();

    Simp.immediate_flush();
    Simp.swap_buffers(window.handle);
}
render_immediate_full_screen_quad :: inline (color: Vector4 = .{1,1,1,1}) {
    Simp.immediate_quad(0, 0, xx window.width, xx window.height, color);
}
clear_render_target :: () { Simp.clear_render_target(0,0,0,0); }
recalculate_window :: () {
    using window;

    old_width, old_height := width, height;
    width, height = Simp.get_render_dimensions(window.handle);
    half_size = .{ xx width, xx height } * .5;
    pythagorean_distance = sqrt(half_size.x*half_size.x + half_size.y*half_size.y);

    if width != old_width || height != old_height {
        init_full_screen_render_targets();
        load_fonts();
    }

    scale_from_720 = cast(float) height / 720.0;
}
init_full_screen_render_targets :: () {
    using window;
    for * full_screen_render_targets {
        if it.* {
            Simp.deinit(it.*);
            free(it.*);
        }
        it.* = Simp.texture_create_render_target(xx window.width, xx window.height, .RGBA8);
    }
    full_screen_render_targets_initted = true;
}
set_fullscreen_render_target :: (index: Full_Screen_Render_Target) {
    Simp.set_render_target(window.full_screen_render_targets[index]);
}
reset_render_target :: () {
    set_fullscreen_render_target(Full_Screen_Render_Target.OUTPUT);
}
handle_input :: inline () {
    is_held     :: inline (key: Input.Key_Code) -> bool         { return xx (Input.input_button_states[key] & .DOWN);       }
    is_pressed  :: inline (key: Input.Key_Code) -> bool #expand { return `received[key] &&  `pressed[key] && !`repeat[key]; }
    is_released :: inline (key: Input.Key_Code) -> bool #expand { return `received[key] && !`pressed[key] && !`repeat[key]; }

    Input.update_window_events();
    for Input.get_window_resizes() {
        Simp.update_window(it.window);
        if it.window == window.handle then recalculate_window();
    }

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

    is_suspended = settings.suspend_when_out_of_focus && !Input.input_application_has_focus;

    #insert,scope() INPUT_HANDLING_CODE;
}
toggle_fullscreen :: () {
    using window;

    success := toggle_fullscreen(handle, !is_fullscreen, *saved_info);
    if success then is_fullscreen = !is_fullscreen;
    else log("FAILED TO SET FULLSCREEN FROM % TO %", is_fullscreen, !is_fullscreen);
}




// hide console in release builds
#if BUILD != .DEBUG && OS == .WINDOWS then #run {
    WR :: #import "Windows_Resources";
    WR.disable_runtime_console();
}


DEBUG_MEMORY :: BUILD == .DEBUG;




#import "Basic"()(MEMORY_DEBUGGER=DEBUG_MEMORY);
#import "Math";
#import "Sloppy_Math";
#import "Random";
#import "Hash_Table";
#import "Window_Creation";
#import "System";  // For get_path_of_running_executable. @Cleanup.
#import "String";  // For path_strip_filename. @Cleanup.

Simp    :: #import "Simp";
Input   :: #import "Input";
//GetRect :: #import "GetRect";
//Rect    :: GetRect.Rect;
