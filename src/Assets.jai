SPRITES :: struct
     { name: string;     color: Vector4; }.[
    .{ "PLAYER",         .{ 0, 1, 0, 1}  },

    .{ "SPIDER",         .{.7,.7,.7, 1}  },
    .{ "BAT",            .{.5,.5,.5, 1}  },
    .{ "ZOMBIE",         .{.3,.9,.6, 1}  },
    .{ "VAMPIRE",        .{ 0, 0, 0, 1}  },
    .{ "GOBLIN",         .{.5, 0, 0, 1}  },
    .{ "SKELETON",       .{ 1, 1, 1, 1}  },
    .{ "BULLET",         .{ 1, 0, 1, 1}  },
    .{ "PULSE_WAVE",     .{.5, 0,.5,.5}  },

    .{ "EXPERIENCE_ORB", .{ 0, 1, 1, 1}  },
    .{ "COIN",           .{ 1, 1, 0, 1}  },
    .{ "COIN_PILE",      .{.5,.5, 0, 1}  },
    .{ "CHICKEN",        .{ 0,.5, 0, 1}  },

    .{ "LAMP",           .{ 1,.5, 0, 1}  },
];
FONTS :: struct
     { name: string;  size_denominator: int; }.[
    .{ "FLOATER"    , 48                     },
    .{ "HUD_LARGE"  , 16                     },
    .{ "HUD_MEDIUM" , 24                     },
    .{ "HUD_SMALL"  , 36                     },
    .{ "HUD_TINY"   , 48                     },
    .{ "HALF_WINDOW", 2                      },
];




#placeholder Sprite;
#placeholder Font;
#placeholder SPRITE_COLORS;
#placeholder FONT_SIZE_DENOMINATORS;

Font_Size_Proc :: #type () -> int;

#insert -> string {
    builder: String_Builder;
    append(*builder, "Sprite :: enum {\n")               ; for SPRITES print_to_builder(*builder, "    %;\n" , it.name);             append(*builder, "}\n");
    append(*builder, "SPRITE_COLORS :: Vector4.[\n")     ; for SPRITES print_to_builder(*builder, "    .%,\n", it.color);            append(*builder, "];\n");
    append(*builder, "Font :: enum {\n")                 ; for FONTS   print_to_builder(*builder, "    %;\n" , it.name);             append(*builder, "}\n");
    append(*builder, "FONT_SIZE_DENOMINATORS :: int.[\n"); for FONTS   print_to_builder(*builder, "    %,\n" , it.size_denominator); append(*builder, "];\n");
    return builder_to_string(*builder);
}
assets: struct {
    textures: [#run type_info(Sprite).values.count] Simp.Texture;
    fonts:    [#run type_info(Font).values.count]   *Simp.Dynamic_Font;

    //animations: 
    working_directory_set: bool;
}

load_assets :: () {
    using assets;

    load_fonts();

    for type_info(Sprite).names assert(Simp.texture_load_from_file(*textures[it_index], tprint("assets/sprites/%.png", it)));
}
load_fonts :: () {
    using assets;

    if !working_directory_set {
        path := path_strip_filename(get_path_of_running_executable());
        set_working_directory(path);
        working_directory_set = true;
    }

    for type_info(Font).names {
        font_size := window.height / FONT_SIZE_DENOMINATORS[it_index];
        //log("loading font % (%) at size % (%/%)", it, it_index, font_size, window.height, FONT_SIZE_DENOMINATORS[it_index]);
        fonts[it_index] = Simp.get_font_at_size(".", "assets/fonts/OpenSans-BoldItalic.ttf", font_size); 
        assert(!!fonts[it_index]);
    }

    on_reload_fonts();
}
