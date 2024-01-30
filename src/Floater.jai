Floater :: struct {
    using #as base: Entity;

    text:             string;
    text_is_constant: bool;
    status:           enum { FLOATING; FADING; }
    color:            Vector4;
    opacity:          float = 1.0;
    initial_position: Vector2;

    MAXIMUM :: 10_000;

    FLOAT_DISTANCE :: FLOATER_FLOAT_DISTANCE;
    FLOAT_SPEED    :: FLOATER_FLOAT_SPEED;

    //FADE_THRESHOLD :: FLOATER_FADE_THRESHOLD;
    FADE_SPEED     :: FLOATER_FADE_SPEED;
}

//TODO: rename spawn_floater to spawn, once the compiler bug is fixed
spawn_floater :: (floater: Floater, position: Vector2, $$text: string) -> *Floater {
    using state;

    new_floater := spawn(*floaters, floater);
    assert(!!new_floater);
    //if !new_floater then return null;

    new_floater.position         = position;
    new_floater.initial_position = position;
    new_floater.text             = text;
    new_floater.text_is_constant = #run is_constant(text);

    return new_floater;
}

spawn_floater :: (floater: Floater, position: Vector2, number: int) -> *Floater {
    return spawn_floater(floater, position, sprint("%", number));
}

simulate_floater_behavior :: inline (dt: float) {
    using state;

    for * floaters {
        if #complete it.status == {
        case .FLOATING;
            it.position.y += Floater.FLOAT_SPEED * dt;
            if it.position.y - it.initial_position.y >= Floater.FLOAT_DISTANCE then it.status = .FADING;
        case .FADING;
            it.opacity -= Floater.FADE_SPEED * dt;
            if it.opacity <= 0 {
                reset  (it);
                despawn(it);
            }
        }
    }
}

reset :: inline (using floater: *Floater) { if !text_is_constant then free(text); }

reset_floaters :: () { for * state.floaters reset(it); }

render :: (using floater: Floater) {
    font := assets.fonts[Font.FLOATER];
    text_width := Simp.prepare_text(font, text);
    text_pos := to_screen_space(position) - Vector2.{xx text_width/2.0, xx font.character_height/2.0};
    color_with_opacity := color;
    color_with_opacity.w = opacity;

    Simp.draw_prepared_text(font, xx text_pos.x, xx text_pos.y, color_with_opacity);
}

/*

Something to think about is how floaters manage their memory. Right now we're just using sprint()
to dynamically allocate a string (unless a constant string is used), and then we free() it at when
the floater dies. This is fine for now but maybe later we can have like a Bucket_Array of strings
or something. If we improve the floater system by rendering each floater to its own texture and then
rendering that texture, then we can use the same stopgap measure for now, but later it would almost
certainly be better to put these textures into a Bucket_Array or something else, as well.

*/
