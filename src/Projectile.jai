Projectile :: struct {
    using #as base: Entity;

    damage: int;

    MAXIMUM :: 10_000;
}

spawn :: (projectile: Projectile, position: Vector2, velocity: Vector2) -> *Projectile {
    using state;

    new_projectile := spawn(*projectiles, projectile);
    new_projectile.position = position;
    new_projectile.velocity = velocity;

    return new_projectile;
}
