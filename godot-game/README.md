# Screening Pathways Prototype

A small Godot 4 endless-runner prototype for cervical cancer screening awareness. The project is designed around a 720 x 1280 virtual viewport, scalable UI, touch gestures, and the Web-compatible GL Compatibility renderer.

## Scene structure

- `scenes/main.tscn`: run state, HUD, start/game-over screens, scoring, and procedural segment lifecycle.
- `scenes/player.tscn`: player body, supplied Sprout Lands character animation, following camera, lane movement, jumping, keyboard input, and swipe input.
- `scenes/track_segment.tscn`: reusable 640-pixel path section with generated lane markings and supplied Sprout Lands vegetation.
- `scenes/obstacle.tscn`: reusable symbolic sign obstacle with collision and a data-provided barrier label.
- `scenes/npc.tscn`: side-of-path community voices with respectful, data-provided misconception messages.
- `scenes/support_pickup.tscn`: trusted-information and support pickups that build confidence and clear an upcoming stigma barrier.
- `scenes/support_popup.tscn`: a random screening fact shown after collecting support.
- `scenes/clinic_finish.tscn`: the fixed health-service destination and finish trigger.

Scripts mirror those scene names under `scripts/`. Barrier names and display colours are data entries in `scripts/main.gd`, leaving room for later translation resources and educational message data.

## Coding style

PEP 8 is a Python style guide, while Godot uses GDScript for this project. The scripts follow the corresponding conventions: `snake_case` functions and variables, `UPPER_CASE` constants, descriptive names, focused functions, blank lines between functions, and lines kept to 88 characters where practical. Indentation uses tabs because that is the Godot GDScript convention.

## Controls

- Desktop: Left/Right arrows or A/D change lanes. Up arrow or W jumps.
- Space starts the game, continues fact popups, and restarts after an ending.
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

Open the folder containing `project.godot` in Godot 4.7 and run the project. For a Web build, use the included Web export preset; no filesystem, threading, native extension, external API, or non-Web renderer features are required by the prototype.

## Game 3: A few minutes with Luna

Game 3 is a separate, modular screening-appointment experience. It starts with
Luna following a floor path into a top-down RPG doctor's office composed from
the supplied Top Down Hospital pack's patterned walls, tiled floor,
examination chair, standing lamp, cabinets, seating, rug, and other room
details. The pack's usage terms are preserved in
`assets/topdown_hospital/README.txt`.
The healthcare professional uses a 32 x 48 pixel front-facing Luna sprite with
a white doctor's coat and brown glasses. The doctor is displayed at the same
height as Luna in the office and character cards. Luna uses her right-facing
walk animation and then turns to face the player. The game
continues through three supportive conversation questions, a brief procedure
introduction, a short visual instruction screen, and then a solvable 3 x 3
sliding puzzle made from an enlarged crop of Luna's front-facing cat sprite.
Game 3 uses the bundled Noto Sans variable font for clearer text and broad
language coverage. Its SIL Open Font License is stored beside the font in
`assets/fonts/`.
Its prominent timer counts upward to a two-minute limit. At 02:00, a fact
overlay explains
that the sample-collection part can take only a few minutes and distinguishes
this from the whole appointment. The player can continue the same puzzle or
finish immediately. Each new puzzle briefly shows Luna's complete picture
before the tiles are scrambled. The completed Luna portrait remains visible
above the puzzle as a reference. The final popup explains that the sample is
sent to a laboratory, the result
arrives later, and routine screening is generally every five years when no
earlier follow-up is needed. Luna then follows a densely decorated Sprout Lands
garden path vertically toward a warm pixel-art sunset. At the two-minute puzzle
limit, the player can use **Finish puzzle** to continue immediately. Luna
disappears where the path meets the horizon before the completion
congratulations appear.

Game 3 files are grouped under `scripts/game3/` with these reusable scenes:

- `scenes/game3_main.tscn`: Game 3 flow and transitions.
- `scenes/doctor_conversation.tscn`: the three-question conversation.
- `scenes/sliding_puzzle.tscn`: the puzzle, timer, moves, reset, and completion.
- `scenes/screening_complete.tscn`: final information popup and ending.
- `scenes/pack_lunas_bag.tscn`: optional standalone preparation mini game.

The standard project Run button still opens the original runner. To run Game 3
inside Godot, open `scenes/game3_main.tscn` and use **Run Current Scene** (F6).
The bag mini game can be run independently in the same way.

The `Game 3 Web` export preset writes to
`../frontend/public/godot/game3/index.html`. The Vue route `/game3` embeds that
export. The `Pack Luna's Bag Web` preset is available if a separate browser
build of the optional mini game is needed later.
