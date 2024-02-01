simulate_hud :: (dt: float) {
    using state; using state.hud;

    health_shake_amount = ifx is_approximately_zero(health_shake_amount, 1) then 0 else ease(health_shake_amount, 0, 10.0 * dt);

    health_value_color_is_flashing := health_shake_amount >= 5.0;

    health_value_color_speed := ifx health_value_color_is_flashing then 60.0 else 20.0;

    health_value_color = ease_color(health_value_color, ifx health_value_color_is_flashing then ifx most_recent_health_change == .HURT then Vector4.{1,0,0,1} else Vector4.{0,1,0,1} else get_health_color(player.health, player.health_max), health_value_color_speed * dt);
    health_value_outline_color = ease_color(health_value_outline_color, ifx health_value_color_is_flashing then Vector4.{1,1,1,1} else .{0,0,0,1}, health_value_color_speed * dt);
}

render_hud :: () {
    using state;

    HUD_PADDING :: 8;
    clock_pos: Vector2;
    {
        font := assets.fonts[Font.HUD_LARGE];
        text_width := Simp.prepare_text(font, format_time(time));
        clock_pos = Vector2.{ HUD_PADDING, xx (window.height - font.character_height) };
        draw_prepared_text_outlined(font, xx clock_pos.x, xx clock_pos.y);
    }{
        font := assets.fonts[Font.HUD_SMALL];
        text_width := Simp.prepare_text(font, tprint("Wave %0%", stage.current_wave+1, ifx stage.current_wave == stage.waves.count-1 then " (the last one for now—it goes on forever)"));
        stage_pos := clock_pos - Vector2.{ 0, xx font.character_height };
        draw_prepared_text_outlined(font, xx stage_pos.x, xx stage_pos.y);
    }

    health_top: int;
    {
        font := assets.fonts[Font.HUD_LARGE];
        health_label_width := Simp.prepare_text(font, "Health: ");
        health_pos := Vector2.{ xx HUD_PADDING, xx HUD_PADDING };
        health_top = font.character_height + xx health_pos.y;
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
    }

    experience_top: int;
    {
        font := assets.fonts[Font.HUD_SMALL];
        text_width := Simp.prepare_text(font, "Experience: ");
        experience_pos := Vector2.{ HUD_PADDING, xx health_top};
        experience_top = font.character_height + xx experience_pos.y;
        draw_prepared_text_outlined(font, xx experience_pos.x, xx experience_pos.y, .{.9,.9,.9,1});

        experience_right := experience_pos.x + text_width;
        text_width = Simp.prepare_text(font, tprint("%", player.experience));
        experience_value_pos := Vector2.{ experience_right, experience_pos.y };
        draw_prepared_text_outlined(font, xx experience_value_pos.x, xx experience_value_pos.y);
    }

    gold_top: int;
    {
        font := assets.fonts[Font.HUD_SMALL];
        text_width := Simp.prepare_text(font, "Gold: ");
        gold_pos := Vector2.{ HUD_PADDING, xx experience_top};
        gold_top = font.character_height + xx gold_pos.y;
        draw_prepared_text_outlined(font, xx gold_pos.x, xx gold_pos.y, .{.9,.9,.9,1});

        gold_right := gold_pos.x + text_width;
        text_width = Simp.prepare_text(font, tprint("%", player.gold));
        gold_value_pos := Vector2.{ gold_right, gold_pos.y };
        draw_prepared_text_outlined(font, xx gold_value_pos.x, xx gold_value_pos.y);
    }

    kills_top: int;
    {
        font := assets.fonts[Font.HUD_SMALL];
        text_width := Simp.prepare_text(font, "Kills: ");
        kills_pos := Vector2.{ HUD_PADDING, xx gold_top};
        kills_top = font.character_height + xx kills_pos.y;
        draw_prepared_text_outlined(font, xx kills_pos.x, xx kills_pos.y, .{.9,.9,.9,1});

        kills_right := kills_pos.x + text_width;
        text_width = Simp.prepare_text(font, tprint("%", player.kills));
        kills_value_pos := Vector2.{ kills_right, kills_pos.y };
        draw_prepared_text_outlined(font, xx kills_value_pos.x, xx kills_value_pos.y);
    }
    
    
}

get_health_color :: (health: int, max_health: int) -> Vector4 {
    WHITE  :: Vector4.{ 1, 1, 1,1};
    YELLOW :: Vector4.{ 1, 1, 0,1};
    RED    :: Vector4.{ 1, 0, 0,1};
    MAROON :: Vector4.{.5, 0, 0,1};

    ratio := cast(float) health / cast(float) max_health;

    if ratio > 0.5  then return ease_color(YELLOW, WHITE , (ratio - 0.5) * 2.0);
    if ratio > 0.25 then return ease_color(RED   , YELLOW,  ratio        * 2.0);
                         return ease_color(MAROON, RED   ,  ratio        * 4.0);
}
