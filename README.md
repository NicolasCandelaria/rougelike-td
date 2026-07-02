# TD Roguelike (v1.2)

A run-based tower defense roguelike built in Godot 4.3 with GDScript. Each run: survive 20 waves on a fixed-path map, picking one of three randomized reward cards between waves. Base destroyed = run over, restart from scratch. Currency carries within a run, resets on restart.

Art: Kenney "Tower Defense (top-down)" pack, CC0. See `assets/LICENSE-CC0.txt`.
Audio: Kenney Sci-Fi Sounds, Interface Sounds, and Digital Audio packs, CC0. See `assets/audio/LICENSE-CC0.txt`.

## Play online
[Play in your browser](https://nicolascandelaria.github.io/rougelike-td/) (GitHub Pages — built automatically on push to `main`).

## Run it locally
1. Install Godot 4.3+ (standard build).
2. Open this folder as a project (Import > select `project.godot`).
3. Press F5.

## Controls
- Click a tower button (or press 1-4), then click a grass tile to place. Placement stays active while you can afford more.
- Right-click or Esc cancels placement and deselects.
- Click a placed tower to see its live stats and range; sell for a 70% refund.
- Space or the Start Wave button launches the next wave. You can keep placing towers mid-wave.
- The Nx button cycles game speed (1x / 2x / 3x). The Snd button (or M) toggles sound.
- Between waves, pick one of three reward cards: new tower unlock, tower upgrade, or a run-wide relic.

## Content (v1)
- 4 towers: Gatling (fast single target), Cannon (slow splash), Frost (AoE slow), Sniper (long range burst). Gatling starts unlocked; the rest come from reward cards.
- 4 enemies: Grunt, Runner, Tank (armored), Swarm.
- 20 hand-authored waves, win at wave 20, optional endless mode after victory with procedurally generated waves.
- 12 relics plus per-tower damage/rate/range upgrade cards. Card weighting favors tower unlocks early, upgrades and relics late.

## v1.3 additions
- Background music: rotating playlist of Kenney Music Jingles steel-drum tracks, mixed quiet under the SFX
- Volume menu (Vol button) with separate SFX and music sliders
- Tower unlock reward cards now show the tower's sprite

## v1.2 additions
- Full sound pass: per-tower shot sounds, splash impacts, enemy deaths, base-damage alarm, tower place/sell, reward pick, wave start, coin drops, victory/defeat stings
- SFX system (`scripts/sfx.gd`) with a pooled player set, per-sound volume tuning, random pitch jitter, and per-sound throttling so rapid-fire towers don't stack into noise
- Mute toggle (Snd button or M key)
- Sound picks and volumes live in one table at the top of `scripts/sfx.gd` for easy swapping

## v1.1 additions
- Tower selection panel with live stats (upgrades reflected) and selling
- Hotkeys (1-4 towers, Space wave, Esc cancel), 1x/2x/3x speed toggle
- Next-wave composition preview and owned-relic readout in the HUD
- Floating damage numbers, muzzle flashes, enemy hit flashes, screen shake on leaks
- Map decorations (rocks, bushes) that block a few build cells
- New relics: Interest (+10% gold per wave end, capped) and AP Rounds (ignore armor)

## Rebalancing
Everything lives in `scripts/game_data.gd`: tower stats, enemy stats, the full 20-wave table, HP/bounty scaling curves, relic list, upgrade magnitudes. No game logic in that file, so balance passes never touch systems code.

## Architecture
- `scripts/game.gd` - root controller: run state machine (BUILD / WAVE / REWARD / GAME_OVER / VICTORY), placement, reward generation and application, economy.
- `scripts/map.gd` - grid, fixed path, waypoints, buildability.
- `scripts/enemy.gd`, `tower.gd`, `projectile.gd` - the actors. Towers read live multipliers from the game each frame, so upgrades apply to towers already placed.
- `scripts/wave_manager.gd` - data-driven spawn scheduler.
- `scripts/ui.gd` - HUD, build bar, reward overlay, end screens. All built in code.
- Scenes are constructed procedurally; `scenes/Main.tscn` is the only scene file.

## Headless testing hooks (used during development, safe to keep)
- `TD_SMOKE=1 godot --headless --path .` auto-plays a full run at 20x speed with basic towers and prints wave-by-wave progress. Add `TD_SMOKE_TANKY=1` to force the run to reach the victory path.
- `TD_SHOT=/path/out.png godot --path .` (with a display) places sample towers, starts a wave, and screenshots after 4 seconds. `TD_SHOT_MODE=reward` screenshots the reward overlay instead.

## Deferred to v2 (per spec)
- Maze-building with dynamic A* pathing
- Multiple simultaneous spawn points on later waves
- Multiple maps, meta-progression, sound design, mobile controls
