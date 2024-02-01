simulate_hud :: (dt: float) {
    using state; using state.hud;

    health_shake_amount = ifx is_approximately_zero(health_shake_amount, 1) then 0 else ease(health_shake_amount, 0, 10.0 * dt);

    health_value_color_is_flashing := health_shake_amount > 5.0;

    health_value_color_speed := ifx health_value_color_is_flashing then 60.0 else 20.0;

    health_value_color = ease_color(health_value_color, ifx health_value_color_is_flashing then Vector4.{1,0,0,1} else get_health_color(cast(float) player.health / cast(float) player.health_max), health_value_color_speed * dt);
    health_value_outline_color = ease_color(health_value_outline_color, ifx health_value_color_is_flashing then Vector4.{1,1,1,1} else .{0,0,0,1}, health_value_color_speed * dt);
}

render_hud :: () {
    using state;

    HUD_PADDING :: 8;
    clock_pos: Vector2;
    {
        font := assets.fonts[Font.CLOCK];
        text_width := Simp.prepare_text(font, format_time(time));
        clock_pos = Vector2.{ HUD_PADDING, xx (window.height - font.character_height) };
        draw_prepared_text_outlined(font, xx clock_pos.x, xx clock_pos.y);
    }{
        font := assets.fonts[Font.WAVE];
        text_width := Simp.prepare_text(font, tprint("Wave %0%", stage.current_wave+1, ifx stage.current_wave == stage.waves.count-1 then " (the last one for now—it goes on forever)"));
        stage_pos := clock_pos - Vector2.{ 0, xx font.character_height };
        draw_prepared_text_outlined(font, xx stage_pos.x, xx stage_pos.y);
    }

    health_top: int;
    {
        font := assets.fonts[Font.HEALTH];
        health_label_width := Simp.prepare_text(font, "Health: ");
        health_pos := Vector2.{ xx HUD_PADDING, xx HUD_PADDING };
        health_top = font.character_height + HUD_PADDING;
        draw_prepared_text_outlined(font, xx health_pos.x, xx health_pos.y, .{.9,.9,.9,1});

        health_right := health_pos.x + health_label_width;
        health_value_text := tprint("%", player.health);

        for 0..health_value_text.count-1 {
            digit := string.{ 1, health_value_text.data + it };
            digit_width := Simp.prepare_text(font, digit);
            shake := hud.health_shake_amount * .5;
            digit_pos := Vector2.{ health_right, health_pos.y } + .{ random_get_within_range(-shake, shake), random_get_within_range(-shake, shake) };
            draw_prepared_text_outlined(font, xx digit_pos.x, xx digit_pos.y, hud.health_value_color, hud.health_value_outline_color);

            health_right += digit_width;
        }
    }{
        font := assets.fonts[Font.GOLD];
        text_width := Simp.prepare_text(font, "Gold: ");
        gold_pos := Vector2.{ HUD_PADDING, xx health_top};
        draw_prepared_text_outlined(font, xx gold_pos.x, xx gold_pos.y, .{.9,.9,.9,1});

        gold_right := gold_pos.x + text_width;
        text_width = Simp.prepare_text(font, tprint("%", player.gold));
        gold_value_pos := Vector2.{ gold_right, gold_pos.y };
        draw_prepared_text_outlined(font, xx gold_value_pos.x, xx gold_value_pos.y);
    }
}

get_health_color :: (health_to_max_health_ratio: float) -> Vector4 {
    WHITE  :: Vector4.{1,1,1,1};
    YELLOW :: Vector4.{1,1,0,1};
    RED    :: Vector4.{1,0,0,1};

    if health_to_max_health_ratio > 0.5 then return ease_color(YELLOW, WHITE, (health_to_max_health_ratio - 0.5) * 2.0);
    return ease_color(RED, YELLOW, health_to_max_health_ratio * 2.0);
}
