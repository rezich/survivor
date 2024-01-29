Sprite :: enum {
    PLAYER;
    VAMPIRE;
    GOBLIN;
    BULLET;
    PULSE_WAVE;
    EXPERIENCE_ORB;
    COIN;
    COIN_PILE;
}

assets: struct {
    textures: [#run type_info(Sprite).values.count] Simp.Texture;
    //animations: 
}

load_assets :: () {
    for type_info(Sprite).names assert(Simp.texture_load_from_file(*assets.textures[it_index], tprint("assets/sprites/%.png", it)));
}
