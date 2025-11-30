-- ==========================================
-- ark_tarkov_raid/client/main.lua
-- Logique client principale
-- ==========================================

local ESX = exports['es_extended']:getSharedObject()
local PlayerData = {}
local inRaid = false
local currentRaidData = nil

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

-- Entrer en raid
RegisterNetEvent('ark_raid:enterRaid')
AddEventHandler('ark_raid:enterRaid', function(raidId, mapName, spawnPos)
    inRaid = true
    currentRaidData = {
        id = raidId,
        mapName = mapName,
    }
    
    DoScreenFadeOut(1000)
    Wait(1000)
    
    SetEntityCoords(PlayerPedId(), spawnPos.x, spawnPos.y, spawnPos.z)
    SetEntityHeading(PlayerPedId(), spawnPos.w)
    
    Wait(500)
    DoScreenFadeIn(1000)
    
    lib.notify({
        type = 'info',
        description = 'Raid commencé: ' .. Config.Maps[mapName].label,
        duration = 5000,
    })
    
    if Config.Debug then
        print('[ARK RAID] Entrée en raid:', raidId, mapName)
    end
    
    StartRaidLoop()
end)

-- Boucle de raid
function StartRaidLoop()
    CreateThread(function()
        while inRaid do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            -- Vérifier les extractions proches
            if currentRaidData then
                local mapConfig = Config.Maps[currentRaidData.mapName]
                if mapConfig then
                    for i, extraction in ipairs(mapConfig.extractions) do
                        local distance = #(playerCoords - extraction.coords)
                        
                        if distance < extraction.radius then
                            -- Afficher le marker
                            DrawMarker(
                                1, -- Type
                                extraction.coords.x, extraction.coords.y, extraction.coords.z - 1.0,
                                0.0, 0.0, 0.0,
                                0.0, 0.0, 0.0,
                                extraction.radius * 2, extraction.radius * 2, 1.0,
                                0, 255, 0, 100,
                                false, true, 2, false, nil, nil, false
                            )
                            
                            if distance < 2.0 then
                                -- Afficher le texte
                                lib.showTextUI('[E] Extraire: ' .. extraction.name, {
                                    position = "top-center",
                                    icon = 'fa-solid fa-helicopter',
                                    style = {
                                        borderRadius = 0,
                                        backgroundColor = '#2ecc71',
                                        color = 'white'
                                    }
                                })
                                
                                if IsControlJustReleased(0, 38) then -- E
                                    lib.hideTextUI()
                                    TriggerServerEvent('ark_raid:extract', currentRaidData.id, i)
                                end
                            elseif distance < extraction.radius then
                                lib.hideTextUI()
                            end
                        end
                    end
                end
            end
            
            Wait(0)
        end
        
        lib.hideTextUI()
    end)
end

-- Commencer l'extraction
RegisterNetEvent('ark_raid:startExtracting')
AddEventHandler('ark_raid:startExtracting', function(duration)
    if lib.progressBar({
        duration = duration * 1000,
        label = 'Extraction en cours...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
        },
        anim = {
            dict = 'mp_common',
            clip = 'givetake1_a'
        },
    }) then
        if Config.Debug then
            print('[ARK RAID] Extraction en cours...')
        end
    else
        lib.notify({type = 'error', description = 'Extraction annulée'})
    end
end)

-- Sortir du raid
RegisterNetEvent('ark_raid:exitRaid')
AddEventHandler('ark_raid:exitRaid', function(success)
    inRaid = false
    currentRaidData = nil
    
    DoScreenFadeOut(1000)
    Wait(1000)
    
    -- Téléporter au spawn
    local spawn = vector4(195.52, -934.23, 30.69, 180.0)
    SetEntityCoords(PlayerPedId(), spawn.x, spawn.y, spawn.z)
    SetEntityHeading(PlayerPedId(), spawn.w)
    
    Wait(500)
    DoScreenFadeIn(1000)
    
    if success then
        lib.notify({
            type = 'success', 
            description = 'Extraction réussie! Bonus: ' .. Config.Rewards.Extraction.bonus .. '$'
        })
    else
        lib.notify({type = 'error', description = 'Vous êtes mort en raid'})
    end
    
    if Config.Debug then
        print('[ARK RAID] Sortie du raid, succès:', success)
    end
end)

if Config.Debug then
    print('[ARK RAID] Client main initialisé')
end