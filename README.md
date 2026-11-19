# BRAINROT MEGA UNIVERSE v1.6

[![roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/RenzzHGE/roblox-brainrot-64/rank.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/RenzzHGE/roblox-brainrot-64/reward.svg)](https://make.fun/bounty/roblox-brainrot-01)

A forest hangout by a lake, NGOBROL-style: golden-hour sunset, dense cone-pine
forest, a karaoke deck on the lake shore, a waterfall with mist and a rainbow,
a round stone fountain, a log cabin with glowing windows, market stalls, a rope
bridge and a treehouse. Sit on a bench, queue a song, and ngobrol with friends.

Play it here: https://make.fun/bounty/roblox-brainrot-01

## v1.6 — bulletproof spawn

v1.5's character fell through the world in Studio Play, respawning and falling
forever. v1.6 fixes that in three independent layers:

1. **Code-created spawn platform** — a 40×2×40 stud wood plaza deck (top at
   y=1) built by the server at startup, independent of the model ground.
2. **Fall safety net** — every 0.5 seconds any character below y=0.5 is
   teleported back onto the spawn with velocity zeroed (`[v1.6] Rescued …`).
3. **CharacterAutoLoads = true** plus a `LoadCharacter()` safety call, and the
   HUD shows **v1.6** next to the title so you can see which version is running.

## How to play

- Walk around the forest, the dirt paths and the lake.
- Sit on any bench (proximity prompt "Duduk").
- Go to the karaoke deck, open the queue panel, and submit a song title —
  the current singer shows on the deck screen for 30 seconds per song.
- Read the signpost for directions: Hutan, Air Terjun, Air Mancur, Karaoke Deck.

## Build

Rojo project. Build the place with:

```sh
rojo build default.project.json --output game.rbxl
```

`main.ts` hands the entry in (copies `game.rbxl`, `src/`, `screenshots/` and
`PLAY.json` to `/output` and writes `dossier.json`).

## License

MIT — see LICENSE.
