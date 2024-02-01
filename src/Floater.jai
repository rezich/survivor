Floater :: struct {
    using #as entity: Entity;

    status:           enum { FLOATING; FADING; }
    scale:            Vector2 = SCALE_INITIAL;
    scale_status:     enum { STRETCHING; SQUISHING; }
    float_style:      enum { LINEAR; EASED; }
    float_speed:      float;
    float_distance:   float;
    color:            Vector4;
    outline:          Vector4;
    opacity:          float = 1.0;
    initial_position: Vector2;
    texture:          *Simp.Texture;

    MAXIMUM :: 10_000;

    FADE_SPEED     :: FLOATER_FADE_SPEED;

    SCALE_INITIAL                     :: FLOATER_SCALE_INITIAL;
    SCALE_SPEED_INITIAL_TO_STRETCHED  :: FLOATER_SCALE_SPEED_INITIAL_TO_STRETCHED;
    SCALE_STRETCHED                   :: FLOATER_SCALE_STRETCHED;
    SCALE_SPEED_STRETCHED_TO_SQUISHED :: FLOATER_SCALE_SPEED_STRETCHED_TO_SQUISHED;
    SCALE_SQUISHED                    :: FLOATER_SCALE_SQUISHED;

    TEXTURE_WIDTH     :: 128;
    TEXTURE_HEIGHT    :: 128;
    TEXTURE_HALF_SIZE :: Vector2.{ TEXTURE_WIDTH/2.0, TEXTURE_HEIGHT/2.0 };
}

spawn :: (floater: Floater, position: Vector2, text: string) -> *Floater {
    using state;

    new_floater := spawn(*floaters, floater);
    assert(!!new_floater);
    //if !new_floater then return null;

    new_floater.position         = position;
    new_floater.initial_position = position;
    new_floater.texture          = Simp.texture_create_render_target(Floater.TEXTURE_WIDTH, Floater.TEXTURE_HEIGHT, .RGBA8);

    Simp.set_render_target(new_floater.texture);

    font := assets.fonts[Font.FLOATER];
    text_width := Simp.prepare_text(font, text);
    text_pos := Vector2.{ Floater.TEXTURE_WIDTH/2.0 - text_width/2.0, Floater.TEXTURE_WIDTH/2.0 - font.character_height/2.0};
    draw_prepared_text_outlined(font, xx text_pos.x, xx text_pos.y, new_floater.color, new_floater.outline);

    Simp.set_render_target(window.handle);

    return new_floater;
}

spawn :: (floater: Floater, position: Vector2, number: int) -> *Floater {
    return spawn(floater, position, tprint("%", number));
}

simulate_floater_behavior :: inline (dt: float) {
    using state;

    for * floaters {
        if #complete it.scale_status == {
        case .STRETCHING;
            it.scale = ease(it.scale, Floater.SCALE_STRETCHED, Floater.SCALE_SPEED_INITIAL_TO_STRETCHED * dt);
            if values_are_close(it.scale, Floater.SCALE_STRETCHED, 0.1) then it.scale_status = .SQUISHING;
        case .SQUISHING;
            it.scale = ease(it.scale, Floater.SCALE_SQUISHED, Floater.SCALE_SPEED_STRETCHED_TO_SQUISHED * dt);
            if values_are_close(it.scale, Floater.SCALE_SQUISHED, 0.1) then it.scale = Floater.SCALE_SQUISHED;
        }

        if #complete it.status == {
        case .FLOATING;
            target_y := it.initial_position.y + it.float_distance;
            if #complete it.float_style == {
            case .LINEAR;
                it.position.y = min(it.position.y + it.float_speed * dt, target_y);
            case .EASED;
                it.position.y = ease(it.position.y, target_y, it.float_speed * dt);
            }
            if values_are_close(it.position.y, target_y, 0.1) then it.status = .FADING;
        case .FADING;
            it.opacity -= Floater.FADE_SPEED * dt;
            if it.opacity <= 0 {
                free_texture(it);
                despawn(it);
            }
        }
    }
}

free_texture :: inline (using floater: *Floater) { free(texture); }

reset_floaters :: () { for * state.floaters free_texture(it); }

render :: (using floater: Floater) {
    if !is_on_screen(floater) then return;

    Simp.set_shader_for_images(texture);

    pos := to_screen_space(position);
    p0 := pos - (TEXTURE_HALF_SIZE * scale);
    p1 := pos + (TEXTURE_HALF_SIZE * scale);

    Simp.immediate_quad(p0.x, p0.y, p1.x, p1.y, .{1,1,1, opacity});
}

/*

Something to think about is how floaters manage their memory. Right now we just allocate a new
Simp.Texture on spawn, and free it on despawn. It might be beneficial to think more about this and
use a Bucket_Array or something instead.

Also, now that we're rendering the floater text once on spawn, it might be useful to separate color
and outline out of Floater, and put it in a Floater_Definition struct or something, because Floaters
don't need to know about their color after they've spawned.

*/
