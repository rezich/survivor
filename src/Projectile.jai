Projectile :: struct {
    using #as base: Entity;

    damage: int;
    speed:  float;
    growth: float;
    life:   float = FLOAT32_INFINITY;
    flags:  enum_flags { FOLLOWS_PLAYER; NOT_DESTROYED_UPON_COLLISION; };

    MAXIMUM :: 10_000;
}

spawn :: (projectile: Projectile, position: Vector2, direction: Vector2) -> *Projectile {
    using state;

    new_projectile := spawn(*projectiles, projectile);
    assert(!!new_projectile);
    //if !new_projectile then return null;
    
    new_projectile.position = position;
    new_projectile.velocity = direction * new_projectile.speed;

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

simulate_collisions_between_projectiles_and_enemies :: inline () {
    using state;

    for * projectile: projectiles {
        for * enemy: enemies {
            they_will_collide := will_collide(projectile, enemy);
            if they_will_collide {
                if !(projectile.flags & .NOT_DESTROYED_UPON_COLLISION) then despawn(projectile);
                enemy.health = max(enemy.health - projectile.damage, 0);
                if enemy.health == 0 then kill(enemy);
                //continue projectile;
            }
        }
    }
}
