-- ==========================================
-- ark_tarkov_raid/client/ui.lua
-- Gestion de l'interface React
-- ==========================================

local currentSquad = nil
local uiOpen = false

-- Ouvrir l'UI
function OpenRaidUI()
    if uiOpen then return end
    
    uiOpen = true
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        type = 'openRaidUI',
        data = {}
    })
    
    if Config.Debug then
        print('[ARK RAID] UI ouverte')
    end
end

-- Fermer l'UI
function CloseRaidUI()
    if not uiOpen then return end
    
    uiOpen = false
    SetNuiFocus(false, false)
    
    SendNUIMessage({
        type = 'closeRaidUI',
        data = {}
    })
    
    if Config.Debug then
        print('[ARK RAID] UI fermée')
    end
end

-- Callbacks NUI
RegisterNUICallback('closeUI', function(data, cb)
    CloseRaidUI()
    cb('ok')
end)

RegisterNUICallback('createSquad', function(data, cb)
    if Config.Debug then
        print('[ARK RAID] Création squad type:', data.type)
    end
    TriggerServerEvent('ark_raid:createSquad', data.type)
    cb('ok')
end)

RegisterNUICallback('invitePlayer', function(data, cb)
    if not currentSquad then 
        if Config.Debug then
            print('[ARK RAID] Erreur: Pas de squad actif')
        end
        return cb('error') 
    end
    TriggerServerEvent('ark_raid:inviteToSquad', currentSquad.id, data.playerId)
    cb('ok')
end)

RegisterNUICallback('startRaid', function(data, cb)
    if Config.Debug then
        print('[ARK RAID] Lancement raid:', data.mapName)
    end
    TriggerServerEvent('ark_raid:startRaid', data.squadId, data.mapName)
    CloseRaidUI()
    cb('ok')
end)

RegisterNUICallback('leaveSquad', function(data, cb)
    if not currentSquad then return cb('error') end
    TriggerServerEvent('ark_raid:leaveSquad', data.squadId)
    currentSquad = nil
    cb('ok')
end)

-- Mettre à jour le squad dans l'UI
RegisterNetEvent('ark_raid:squadCreated')
AddEventHandler('ark_raid:squadCreated', function(squadId, squadData)
    currentSquad = squadData
    
    if Config.Debug then
        print('[ARK RAID] Squad créé:', squadId)
    end
    
    local formattedSquad = {
        id = squadData.id,
        type = squadData.type,
        members = {}
    }
    
    for _, memberId in ipairs(squadData.members) do
        table.insert(formattedSquad.members, {
            id = memberId,
            name = GetPlayerName(GetPlayerFromServerId(memberId)),
            isLeader = memberId == squadData.leader
        })
    end
    
    SendNUIMessage({
        type = 'updateSquad',
        data = formattedSquad
    })
    
    lib.notify({
        type = 'success',
        description = 'Squad créé avec succès!'
    })
end)

RegisterNetEvent('ark_raid:squadUpdated')
AddEventHandler('ark_raid:squadUpdated', function(squadData)
    currentSquad = squadData
    
    local formattedSquad = {
        id = squadData.id,
        type = squadData.type,
        members = {}
    }
    
    for _, memberId in ipairs(squadData.members) do
        table.insert(formattedSquad.members, {
            id = memberId,
            name = GetPlayerName(GetPlayerFromServerId(memberId)),
            isLeader = memberId == squadData.leader
        })
    end
    
    SendNUIMessage({
        type = 'updateSquad',
        data = formattedSquad
    })
end)

RegisterNetEvent('ark_raid:squadDissolved')
AddEventHandler('ark_raid:squadDissolved', function()
    currentSquad = nil
    SendNUIMessage({
        type = 'updateSquad',
        data = nil
    })
    lib.notify({
        type = 'info',
        description = 'Le squad a été dissous'
    })
end)

RegisterNetEvent('ark_raid:receiveInvite')
AddEventHandler('ark_raid:receiveInvite', function(squadId, leaderName)
    local alert = lib.alertDialog({
        header = 'Invitation Squad',
        content = leaderName .. ' vous invite à rejoindre son squad',
        centered = true,
        cancel = true,
        labels = {
            confirm = 'Accepter',
            cancel = 'Refuser'
        }
    })
    
    if alert == 'confirm' then
        TriggerServerEvent('ark_raid:acceptInvite', squadId)
    end
end)

RegisterNetEvent('ark_raid:startLobby')
AddEventHandler('ark_raid:startLobby', function()
    SendNUIMessage({
        type = 'startLobby',
        data = {}
    })
end)

-- Mettre à jour les joueurs proches
CreateThread(function()
    while true do
        if uiOpen then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local nearbyPlayers = {}
            
            for _, player in ipairs(GetActivePlayers()) do
                if player ~= PlayerId() then
                    local targetPed = GetPlayerPed(player)
                    local targetCoords = GetEntityCoords(targetPed)
                    local distance = #(playerCoords - targetCoords)
                    
                    if distance < 10.0 then
                        table.insert(nearbyPlayers, {
                            id = GetPlayerServerId(player),
                            name = GetPlayerName(player),
                            distance = math.floor(distance)
                        })
                    end
                end
            end
            
            SendNUIMessage({
                type = 'updateNearbyPlayers',
                data = nearbyPlayers
            })
        end
        
        Wait(2000)
    end
end)

-- Commande pour ouvrir l'UI (pour debug)
RegisterCommand('raid', function()
    OpenRaidUI()
end, false)

-- Exports
exports('OpenRaidUI', OpenRaidUI)
exports('CloseRaidUI', CloseRaidUI)

if Config.Debug then
    print('[ARK RAID] Client UI initialisé')
end