Texture :: struct {}

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
    textures: [#run type_info(Sprite).values.count] Texture;
    //animations: 
}

load_assets :: () {
    for type_info(Sprite).names {
        //log("% %", it_index, it);
    }
}
