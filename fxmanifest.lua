fx_version 'cerulean'
game 'gta5'

author 'DaemonAlex'
description 'Standalone Ped Spawner for QBCore'
version '1.0.0'

client_script 'client.lua'

-- Expose these exports
exports {
    'SpawnPed',
    'DeletePed',
    'DeleteAllPeds',
    'GetClosestPed',
    'ListSpawnedPeds'
}
