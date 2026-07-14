# Frost Farmer 4.0

Frost Farmer is a World of Warcraft Retail/Midnight addon for measuring farming sessions. It runs entirely inside WoW and does not control the character, press buttons, or use a remote server.

## Features

- start, stop, reset, and save farming sessions;
- track money gained or spent during a session;
- detect positive item-count changes in player bags;
- calculate vendor value and estimated value per hour;
- record player map coordinates as route points;
- show session duration, zone, loot, and recommendations;
- keep the latest completed sessions in `FrostFarmerDB`;
- movable in-game dashboard and slash commands;
- no external libraries, network service, or account credentials.

## Install

1. Download `FrostFarmer-4.0.0.zip` from Releases or create it with `scripts/package.ps1`.
2. Extract the `FrostFarmer` folder into:
   `World of Warcraft/_retail_/Interface/AddOns/`
3. The resulting path must contain `FrostFarmer/FrostFarmer.toc`.
4. Restart WoW or type `/reload` and enable **Frost Farmer** in the AddOns screen.

## Use

- `/ff` — open or close the dashboard;
- `/ff start` — begin a farming session;
- `/ff stop` — save the active session;
- `/ff point` — record the current map position;
- `/ff status` — print a compact status line;
- `/ff reset` — discard the current session;
- `/ff help` — list commands.

Item tracking compares bag snapshots. It records items added while a session is running. Auction-house prices are not guessed: the current version shows money changes and NPC vendor value only.

## Build and validate

On Windows PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate.ps1
powershell -ExecutionPolicy Bypass -File scripts/package.ps1
```

The release archive is written to `artifacts/FrostFarmer-4.0.0.zip`. CI also runs `luac -p` against every Lua source file.

## Saved data

WoW stores addon data in the account `SavedVariables/FrostFarmer.lua` file. Uninstalling the addon folder does not automatically delete that file.

## Limitations

- Retail/Midnight (`Interface 120000`) is the supported client.
- The addon cannot automate movement, combat, gathering, or protected actions.
- Route points are recorded only when the user presses **Add point** or runs `/ff point`.
- Auction pricing requires a future optional data-source integration; vendor value is available now.
- Final compatibility must be smoke-tested in the live WoW client because Blizzard's Lua runtime is not shipped with this repository.

## License

MIT. See [LICENSE](LICENSE).
