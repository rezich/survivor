Font_Size_Proc :: #type () -> int;

assets: struct {
    textures: [#run type_info(Sprite).values.count] Simp.Texture;
    fonts:    [#run type_info(Font).values.count] *Simp.Dynamic_Font;

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
        proc := FONT_SIZE_PROCS[it_index];
        fonts[it_index] = Simp.get_font_at_size(".", "assets/fonts/OpenSans-BoldItalic.ttf", proc()); 
        assert(!!fonts[it_index]);
    }
}
