# Screening Pathways Prototype

A small Godot 4 endless-runner prototype for cervical cancer screening awareness. The project is designed around a 720 x 1280 virtual viewport, scalable UI, touch gestures, and the Web-compatible GL Compatibility renderer.

## Scene structure

- `scenes/main.tscn`: run state, HUD, start/game-over screens, scoring, and procedural segment lifecycle.
- `scenes/player.tscn`: player body, supplied Sprout Lands character animation, following camera, lane movement, jumping, keyboard input, and swipe input.
- `scenes/track_segment.tscn`: reusable 640-pixel path section with generated lane markings and supplied Sprout Lands vegetation.
- `scenes/obstacle.tscn`: reusable symbolic sign obstacle with collision and a data-provided barrier label.
- `scenes/npc.tscn`: side-of-path community voices with respectful, data-provided misconception messages.
- `scenes/support_pickup.tscn`: trusted-information and support pickups that build confidence and clear an upcoming stigma barrier.
- `scenes/support_popup.tscn`: a formatted nearby health-service result shown after collecting support.
- `scenes/api_client.tscn`: the small HTTP client used by the support popup.
- `scenes/clinic_finish.tscn`: the fixed health-service destination and finish trigger.

Scripts mirror those scene names under `scripts/`. Barrier names and display colours are data entries in `scripts/main.gd`, leaving room for later translation resources and educational message data.

## Coding style

PEP 8 is a Python style guide, while Godot uses GDScript for this project. The scripts follow the corresponding conventions: `snake_case` functions and variables, `UPPER_CASE` constants, descriptive names, focused functions, blank lines between functions, and lines kept to 88 characters where practical. Indentation uses tabs because that is the Godot GDScript convention.

## Controls

- Desktop: Left/Right arrows or A/D change lanes. Up arrow, W, or Space jumps.
- Touch: swipe left/right to change lanes and swipe up to jump.

## Level-one gameplay

The first route focuses on stigma, shame, misconceptions, and social pressure. The player has three lives and a short invulnerability period after a hit. Every NPC speech bubble animates into a physical quote barrier after the player has time to read it. Each support pickup appears before a three-lane barrier row and clears that complete row when collected. A missed pickup leaves jumping as the avoidance option. The finite 1500 m route ends at a health service with the message, "You made an informed choice."

## Reused assets

- `assets/sprout_lands/character.png`: player and NPC character animation.
- `assets/sprout_lands/grass_scenery.png`: repeated verge vegetation.
- `assets/sprout_lands/clinic_building.png`: clinic destination artwork.
- The pack's palette and pixel-art proportions guide the generated path and signs.

Sprout Lands assets are by Cup Nooble and are used under the terms in `assets/sprout_lands/LICENSE.txt`.

## Running

Open the folder containing `project.godot` in Godot 4.7 and run the project. For a Web build, add a Web export preset in the editor; no filesystem, threading, native extension, or non-Web renderer features are used by the prototype. The Web build calls an external health-service endpoint, so the hosting site must allow that address in its Content Security Policy and the endpoint must allow browser cross-origin requests.
