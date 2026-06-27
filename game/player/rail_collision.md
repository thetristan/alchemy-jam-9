# Rail collision detection — `PlayerStateHanging`

This documents the collision-handling logic that runs every frame while the
player is hanging from a rail, in [`player_state_hanging.gd`](player_state_hanging.gd)
inside `apply_rail_movement(delta)` (called from `on_physics_process`).

The player is a `CharacterBody2D` whose foot is pinned to a `Curve2D` rail via a
`PathFollow2D` (`player.rail_follower`). Movement along the rail and collisions
with the world are reconciled each frame so that:

- travel direction is owned by `current_speed` (input), never by what we bump into;
- pushing *into* a wall stops us, but brushing *along* one does not;
- running off an open rail end drops us into `falling`.

---

## The per-frame pipeline

```mermaid
flowchart TD
    A[apply_rail_movement] --> B[Resolve input → current_speed<br/>rail_motion = current_speed * delta]
    B --> C[Pin follower to player's foot<br/>record foot_pos]
    C --> D[Advance follower by rail_motion<br/>step = new pos - foot_pos]
    D --> E["Compose motion:<br/>step + perpendicular pull to rail"]
    E --> F[move_and_collide(motion)]
    F --> G{collision AND<br/>normal · motion < 0?}
    G -- yes --> H[hit_wall = true<br/>slide remainder, re-pin follower]
    G -- no --> I[hit_wall = false]
    H --> J{follower at an<br/>open rail end?}
    I --> J
    J -- left & open_on_left --> K[drop_off_rail(left)]
    J -- right & open_on_right --> L[drop_off_rail(right)]
    J -- no --> M{blocked?<br/>hit_wall OR at a closed end}
    M -- yes --> N[current_speed = 0<br/>play recoil once per contact]
    M -- no --> O[has_recoiled = false<br/>arm recoil for next contact]
    N --> P{jump pressed?}
    O --> P
    P -- yes --> Q[drop → falling]
    P -- no --> R[done this frame]
```

---

## 1. Stepping by the follower's own motion

Instead of moving the body and re-deriving rail progress from the new position,
we drive the step from the `PathFollow2D` itself:

```gdscript
var foot_local: Vector2 = player.attached_rail.path.to_local(player.global_position)
player.rail_follower.progress = player.attached_rail.path.curve.get_closest_offset(foot_local)
var foot_pos: Vector2 = player.rail_follower.global_position   # where we are on the rail
player.rail_follower.progress += rail_motion                   # where we want to be
var step: Vector2 = player.rail_follower.global_position - foot_pos
```

`rail_motion = current_speed * delta`, so the sign of `step` is tied to
`current_speed` (which only input changes). This is the key invariant:

> An obstacle that shoves the body along the rail cannot reverse our direction
> and re-pin us, because we never read direction back out of the body's position.

```
rail curve:   ────●━━━━━━━━━━●────────────────
              foot_pos      follower after += rail_motion
                  └──── step ────┘   (sign follows current_speed)
```

---

## 2. Composing the motion vector

The body sits at the player's `global_position`, which may have drifted off the
exact curve (collisions, the curve bending under it). We want to both **advance
along the rail** and **re-center onto it**, without those two fighting:

```gdscript
var step: Vector2    = follower_after - foot_pos          # along the rail
var to_rail: Vector2 = foot_pos - player.global_position  # body → rail point
var tangent: Vector2 = step.normalized()
var motion: Vector2  = step + to_rail - tangent * to_rail.dot(tangent)
player.velocity = motion / delta
```

`to_rail` is split into a tangential part (along the rail) and a perpendicular
part. We **drop the tangential part** and keep only the perpendicular pull, so
re-centering never adds to or subtracts from the rail step:

```
        body ●
              \
       to_rail \         tangent (= step direction)
                \      ┌───────────────────────►
                 \     │
            rail  ●━━━━┿━━━━━━━━━━━━► step
               foot_pos│
                       │  ← perpendicular part of to_rail  (KEPT)
                       └──────────► tangential part of to_rail  (DROPPED)

   motion = step  +  (perpendicular part only)
```

Setting `player.velocity = motion / delta` keeps the engine's velocity
consistent with the manual move that follows.

---

## 3. Detecting a real wall hit (the normal check)

```gdscript
var collision: KinematicCollision2D = player.move_and_collide(motion)
var hit_wall: bool = collision != null and collision.get_normal().dot(motion) < 0.0
```

`move_and_collide` returns a collision even when we're sliding *along* a surface
we're merely touching. We only treat it as a block when we're driving **into**
the surface — i.e. the contact normal opposes our motion (`normal · motion < 0`):

```
 Driving INTO wall (blocked)            Moving ALONG / AWAY (not blocked)
 ───────────────────────────           ─────────────────────────────────
        motion →                              motion →
   ┌──────────┐                          ┌──────────┐
   │ wall     │ normal ◄────             │ wall     │ normal ◄──── │ motion
   │          │                          │          │     (normal ⟂ motion,
   └──────────┘  normal·motion < 0       └──────────┘      dot ≥ 0 → reversible)
```

Using the normal keeps the stop **reversible**: the instant the player steers
away from the wall, `hit_wall` goes false and motion resumes.

When `hit_wall` is true we consume the leftover motion and re-pin the follower
to wherever the body actually ended up:

```gdscript
player.move_and_collide(collision.get_remainder())
var local_point: Vector2 = player.attached_rail.path.to_local(player.global_position)
player.rail_follower.progress = player.attached_rail.path.curve.get_closest_offset(local_point)
```

---

## 4. Running off an open end

Because the curve is not a loop, `progress` is clamped to `[0, baked_length]`,
so the end tests are exact:

```gdscript
var at_left_end:  bool = player.rail_follower.progress <= 0.0
var at_right_end: bool = player.rail_follower.progress >= rail_len
if at_left_end and player.attached_rail.open_on_left:
    drop_off_rail(true);  return
elif at_right_end and player.attached_rail.open_on_right:
    drop_off_rail(false); return
```

A rail end may be **open** (rolls off into a fall) or **closed** (acts like a
wall). Only open ends call `drop_off_rail`, which hands `current_speed` to
`velocity.x`, nudges the body off the end, and transitions to `falling_state`.

```
   progress = 0                              progress = rail_len
        │                                          │
   [open]●━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━●[closed]
        ↓ drop off into fall                       ↑ treated as a wall (recoil)
```

---

## 5. Blocked → stop and recoil once per contact

A "block" is either a real wall hit or a closed rail end:

```gdscript
var blocked: bool = hit_wall or at_left_end or at_right_end
if blocked:
    player.current_speed = 0
    if not has_recoiled and not (rotation_tween running):
        has_recoiled = true
        var recoil_sign: float = signf(rail_motion) if hit_wall else (-1.0 if at_left_end else 1.0)
        play_recoil(recoil_sign)
else:
    has_recoiled = false   # free again → re-arm recoil for the next fresh contact
```

`has_recoiled` is a one-shot latch: the bounce animation plays **once** per
contact and only re-arms after the player has moved freely again, so holding
into a wall doesn't spam the recoil tween.

---

## Invariants worth keeping

| Concern | How it's preserved |
| --- | --- |
| Direction owned by input | Step derived from `current_speed`, never read back from body position |
| Sliding ≠ stopping | `hit_wall` requires `normal · motion < 0` |
| Re-centering ≠ extra travel | Tangential part of `to_rail` is dropped |
| Exact end detection | `loop = false`, so `progress` is clamped to `[0, rail_len]` |
| One bounce per contact | `has_recoiled` latch, re-armed only when free |
| `velocity` stays truthful | Set to `motion / delta` before the manual move |
