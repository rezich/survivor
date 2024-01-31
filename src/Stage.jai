Stage :: struct {
    background: Vector4;
    waves:      [] struct {
        minimum:  int;
        interval: float;
        enemies:  [] Enemy;
    };

    ENEMY_SPAWN_MAXIMUM   :: STAGE_ENEMY_SPAWN_MAXIMUM;
    SECONDS_BETWEEN_WAVES :: STAGE_SECONDS_BETWEEN_WAVES;
}

simulate_stage :: (dt: float) {
    using state.stage;

    if current_wave < waves.count-1 && state.time > xx (SECONDS_BETWEEN_WAVES * (current_wave+1)) {
        current_wave += 1;
        time_until_next_spawn = 0;
    }

    time_until_next_spawn = max(time_until_next_spawn - dt, 0);
    if time_until_next_spawn == 0 {
        wave := waves[current_wave];
        enemy_index := 0;

        if state.enemies.count < wave.minimum then while (state.enemies.count < wave.minimum) {
            spawn_somewhere_off_screen(wave.enemies[enemy_index]);
            enemy_index = (enemy_index + 1) % wave.enemies.count;
        } else if state.enemies.count < ENEMY_SPAWN_MAXIMUM then for wave.enemies spawn_somewhere_off_screen(it);

        time_until_next_spawn = wave.interval;
    }
}

change_stage :: (stage: Stage) { state.stage.stage = stage; } //TODO: reinit
