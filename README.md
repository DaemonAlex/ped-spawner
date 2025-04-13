# QBCore Ped Spawner - Usage Guide

This standalone resource allows you to easily spawn and manage peds in your QBCore server.

## Installation

1. Create a new folder named `ped-spawner` in your server's resources directory
2. Copy the `client.lua` and `fxmanifest.lua` files into this folder
3. Add `ensure ped-spawner` to your server.cfg file
4. Restart your server or start the resource manually using `refresh` followed by `start ped-spawner`

## In-Game Commands

The script provides several commands for quick ped management:

- `/spawnped [model] [scenario]` - Spawn a ped 2 meters in front of you
  - Example: `/spawnped a_m_y_skater_01 WORLD_HUMAN_SMOKING`
  - If model/scenario are omitted, defaults will be used

- `/deleteped [distance]` - Delete the closest ped within the specified distance
  - Example: `/deleteped 10` (deletes closest ped within 10 meters)
  - Default distance is 5 meters if not specified

- `/deleteallpeds` - Delete all peds spawned by this script

- `/listpeds` - List all currently spawned peds with their details

## Using in Other Resources

The ped spawner exposes several exports that can be used in other resources:

```lua
-- Spawn a ped with full control
local pedId = exports['ped-spawner']:SpawnPed(
    modelName,     -- string: ped model name or hash
    coords,        -- vector3: position to spawn
    heading,       -- number: heading (direction)
    scenario,      -- string: scenario to play (optional)
    blockEvents,   -- boolean: block NPC from reacting to events (default: true)
    freeze         -- boolean: freeze in place (default: true)
)

-- Delete a specific ped
exports['ped-spawner']:DeletePed(pedId)

-- Delete all peds created by this resource
exports['ped-spawner']:DeleteAllPeds()

-- Find the closest ped within a certain distance
local closestPed, distance = exports['ped-spawner']:GetClosestPed(coords, maxDistance)

-- List all spawned peds (returns count)
local count = exports['ped-spawner']:ListSpawnedPeds()
```

## Common Ped Models

Here are some popular ped models you can use:

- `a_m_y_skater_01` - Young male skater
- `a_f_y_beach_01` - Young female beachgoer
- `s_m_y_cop_01` - Male police officer
- `s_m_y_firefighter_01` - Male firefighter
- `s_m_m_paramedic_01` - Male paramedic
- `cs_lestercrest` - Lester (story mode character)
- `u_m_y_gunvend_01` - Ammu-Nation clerk
- `mp_m_shopkeep_01` - Male shop keeper

## Common Scenarios

Some useful scenarios to make your peds more lifelike:

- `WORLD_HUMAN_STAND_IMPATIENT` - Standing impatiently
- `WORLD_HUMAN_SMOKING` - Smoking
- `WORLD_HUMAN_DRINKING` - Drinking
- `WORLD_HUMAN_CLIPBOARD` - Holding clipboard
- `WORLD_HUMAN_GUARD_STAND` - Standing guard
- `WORLD_HUMAN_SEAT_LEDGE` - Sitting on a ledge
- `WORLD_HUMAN_SEAT_BENCH` - Sitting on a bench
- `WORLD_HUMAN_LEANING` - Leaning against something
- `WORLD_HUMAN_MUSICIAN` - Playing an instrument
- `PROP_HUMAN_BBQ` - Using a BBQ

## Tips for Best Results

1. **Memory Management**: Delete peds when they're no longer needed to prevent memory leaks
2. **Performance**: Don't spawn too many peds at once, especially complex models
3. **Network Syncing**: This script handles client-side peds. For network-synced peds visible to all players, you'll need a server-side component
4. **Customization**: You can modify the Config values in client.lua to change default behaviors
