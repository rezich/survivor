Projectile :: struct {
    using #as entity: Entity;
    sprite:           Sprite;

    damage:           int;
    speed:            float;
    growth:           float;
    life:             float = FLOAT32_INFINITY;
    flags:            enum_flags {
        FOLLOWS_PLAYER;
        NOT_DESTROYED_UPON_COLLISION;
        IS_FIRE;
        ONLY_ONE_PROJECTILE;
    };

    invulnerability:  float = 0.5; // bad name; invulnerability that's conferred to enemy on hit

    MAXIMUM :: 10_000;
}

spawn :: (projectile: Projectile, weapon: Weapon, position: Vector2, direction: Vector2) -> *Projectile {
    using state;

    new_projectile := spawn(*projectiles, projectile);
    assert(!!new_projectile);
    //if !new_projectile then return null;
    
    new_projectile.position = position;
    new_projectile.velocity = direction * new_projectile.speed;
    new_projectile.damage   = weapon.shot_damage;
    new_projectile.radius  += weapon.shot_radius;
    new_projectile.growth  += weapon.shot_growth;

    return new_projectile;
}
simulate_projectile_behavior :: inline (dt: float) {
    using state;

    for * projectiles {
        if it.flags & .FOLLOWS_PLAYER then it.position = player.position;
        if it.growth then it.radius += it.growth * dt;
        if it.life != FLOAT32_INFINITY then it.life -= dt;
        if !is_on_screen(it) || it.radius <= 0 || it.life <= 0 then despawn(it);
    }
}
simulate_collisions_between_projectiles_and_enemies_and_destructibles :: inline () {
    using state;

    for * projectile: projectiles {
        if !projectile.damage then continue;
        for * enemy: enemies {
            they_will_collide := will_collide(projectile, enemy);
            if they_will_collide {
                if !(projectile.flags & .NOT_DESTROYED_UPON_COLLISION) then despawn(projectile);

                if projectile.flags & .IS_FIRE && enemy.flags & .IMMUNE_TO_FIRE {
                    spawn(FLOATER_ENEMY_IMMUNE, enemy.position, "IMMUNE!");
                    continue;
                }
                
                hurt(enemy, projectile.damage, projectile.id, projectile.invulnerability);
                //continue projectile;
            }
        }

        for * destructible: destructibles {
            they_will_collide := will_collide(projectile, destructible);
            if they_will_collide {
                if !(projectile.flags & .NOT_DESTROYED_UPON_COLLISION) then despawn(projectile);

                destroy(destructible);
            }
        }
    }
}
