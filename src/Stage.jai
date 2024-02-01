Stage :: struct {
    background: Vector4;
    waves:      [] struct {
        minimum:  int;
        interval: float;
        enemies:  [] Enemy;
    };
    destructibles: struct {
        chance:        float;
        maximum:       int;
        destructibles: [] Destructible;
    };

    ENEMY_SPAWN_MAXIMUM   :: STAGE_ENEMY_SPAWN_MAXIMUM;
    SECONDS_BETWEEN_WAVES :: STAGE_SECONDS_BETWEEN_WAVES;
}

simulate_stage :: (dt: float) {
    using state.stage;

    // wave
    if current_wave < waves.count-1 && state.time > xx (SECONDS_BETWEEN_WAVES * (current_wave+1)) {
        current_wave += 1;
        time_until_next_enemy_spawn = 0;
    }

    // enemy spawn
    time_until_next_enemy_spawn = max(time_until_next_enemy_spawn - dt, 0);
    if time_until_next_enemy_spawn == 0 {
        wave := waves[current_wave];
        enemy_index := 0;

        if state.enemies.count < wave.minimum then while state.enemies.count < wave.minimum {
            spawn_somewhere_off_screen(wave.enemies[enemy_index]);
            enemy_index = (enemy_index + 1) % wave.enemies.count;
        } else if state.enemies.count < ENEMY_SPAWN_MAXIMUM then for wave.enemies spawn_somewhere_off_screen(it);

        time_until_next_enemy_spawn = wave.interval;
    }

    // destructible spawn
    time_until_next_destructible_spawn = max(time_until_next_destructible_spawn - dt, 0);
    if time_until_next_destructible_spawn == 0 {

        if random_get_zero_to_one() <= destructibles.chance {
            spawning_destructible := true;
            if state.destructibles.count >= destructibles.maximum {
                index_of_off_screen_destructible := -1;
                for state.destructibles if !is_on_screen(it) { index_of_off_screen_destructible = it_index; break; }
                if index_of_off_screen_destructible != -1 then despawn(state.destructibles[index_of_off_screen_destructible]);
                else spawning_destructible = false;
            }
            if spawning_destructible then spawn_somewhere_off_screen(destructibles.destructibles[cast(int) (random_get() % xx destructibles.destructibles.count)]);
        }

        time_until_next_destructible_spawn = Destructible.TIME_BETWEEN_SPAWNS;
    }
}

change_stage :: (stage: Stage) { state.stage.stage = stage; } //TODO: reinit
