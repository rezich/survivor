Texture :: struct {}

Sprite :: enum {
    PLAYER;
    VAMPIRE;
    GOBLIN;
    BULLET;
    EXPERIENCE_ORB;
    GOLD_PIECE;
    GOLD_PILE;
}

Entity :: struct {
    is_dead:  bool;
    position: Vector2;
    velocity: Vector2;
    radius:   float;
    sprite:   Sprite;
    //position_intended: Vector2;
}

// if the two Entities collide, returns true and position of collision
will_collide :: (a: *$A/Entity, b: *$B/Entity) -> bool, Vector2 {
    //TODO:
    // - return position of collision
    // - take position_intended of entities into account (swept collision)
    radii_sum := a.radius + b.radius;
    return distance_squared(a.position, b.position) <= radii_sum * radii_sum, .{};
}

//TODO
/*determine_position_intended :: (using entity: *$T/Entity, dt: float) {
    position_intended = velocity * dt;
}*/

move :: (using entity: *$T/Entity, dt: float) {
    //TODO
    //if !is_dead then position = position_intended;
    if !is_dead then position += velocity * dt;
}





Animation :: struct {
    is_looping:        bool;
    frames: [..]       Sprite;
    frames_per_second: float;
}

Animator :: struct {
    animation:     *Animation;
    frame:         int;
    partial_frame: float;
}

Animated_Entity :: struct {
    base:     Entity;
    animator: Animator;
}

animate :: (using entity: *$T/interface Animated_Entity, dt: float) {
    using animator;
    if !animation then return;
    partial_frame += animation.frames_per_second * dt;
    if partial_frame >= 1.0 {
        partial_frame -= 1.0;
        frame += 1;
        if frame == animation.frames.count then frame = ifx animation.is_looping then 0 else frame + 1;
    }
    sprite = animation.frames[frame];
}

begin_animation :: (using entity: *$T/interface Animated_Entity, animation: *Animation) {
    animator = .{ animation = animation };
}

is_done_animating :: (using entity: *$T/interface Animated_Entity) -> bool {
    using animator;
    return !animation || (!animation.is_looping && frame == animation.count-1);
}

move_and_animate :: inline (entity: *$T/interface Animated_Entity, dt: float) {
    if entity.is_dead then return;
    move(entity, dt);
    animate(entity, dt);
}




Character :: struct {
    health:     int;
    health_max: int;
}




Enemy :: struct {
    MAXIMUM :: 10_000;

    using #as base:      Entity;
    using #as character: Character;

    animator: Animator;
    speed: float;
}

spawn :: (enemy: Enemy, position: Vector2) {
    using state;

    assert(enemies.count < Enemy.MAXIMUM);

    new_enemy := array_add(*enemies);
    new_enemy.* = enemy;

    new_enemy.position   = position;
    new_enemy.health_max = new_enemy.health;
}

ENEMY_VAMPIRE :: Enemy.{
    radius = 16,
    speed  = 3,
    health = 10
};

ENEMY_GOBLIN :: Enemy.{
    radius = 8,
    speed  = 5,
    health = 4
};




Projectile :: struct {
    MAXIMUM :: 10_000;

    using #as base: Entity;

    damage: int;
}

spawn :: (projectile: Projectile, position: Vector2, velocity: Vector2) {
    using state;

    assert(projectiles.count < Projectile.MAXIMUM);

    new_projectile := array_add(*projectiles);
    new_projectile.* = projectile;

    new_projectile.position = position;
    new_projectile.velocity = velocity;
}

PROJECTILE_BULLET :: Projectile.{
    radius = 4
};




Pickup :: struct {
    MAXIMUM :: 10_000;

    using #as base: Entity;

    kind: enum { EXPERIENCE; GOLD; }
}




state: struct {
    enemies:     [..] Enemy;
    projectiles: [..] Projectile;

    player: struct {
        using #as base:      Entity;
        using #as character: Character;
    }

    camera: struct {
        position: Vector2;
    }

    time: float;

    is_exiting: bool;
}




assets: struct {
    textures: [#run type_info(Sprite).values.count] Texture;
}




init :: () {
    using state;

    array_reserve(*enemies,     Enemy.MAXIMUM);
    array_reserve(*projectiles, Projectile.MAXIMUM);

    INITIAL_WAVE_COUNT    :: 10;
    INITIAL_WAVE_DISTANCE :: 100;
    for 0..INITIAL_WAVE_COUNT-1 {
        theta := TAU / INITIAL_WAVE_COUNT * it;
        spawn(ENEMY_VAMPIRE, .{-cos(theta) * INITIAL_WAVE_DISTANCE, sin(theta) * INITIAL_WAVE_DISTANCE});
    }

    player.radius = 16;
    player.health, player.health_max = 100;
}

simulate :: (dt: float) {
    using state;

    time += dt;

    // spawn waves if needed

    // determine enemy behavior

    // handle player input

    // check for collisions
    for * projectile, projectile_index: projectiles {
        if projectile.is_dead continue; // might not be needed?
        for * enemy, enemy_index: enemies {
            if enemy.is_dead then continue;
            they_will_collide, collision_position := will_collide(projectile, enemy);
            if they_will_collide {
                projectile.is_dead = true;
                enemy.health = max(enemy.health - projectile.damage, 0);
                if enemy.health == 0 then enemy.is_dead = true;
                //continue projectile;
            }
        }
    }

    // move and animate everything
    for * enemies     move_and_animate(it, dt);
    for * projectiles move(it, dt);
    player.position += player.velocity;

    // remove anything that is_dead
    for enemies     if it.is_dead then remove it;
    for projectiles if it.is_dead then remove it;
}

render :: () {
    // render enemies
    // render player
    // render projectiles
}




main :: () {
    init();

    while (!state.is_exiting) { simulate(1.0 / 60.0); render(); }
}




#import "Basic";
#import "Math";