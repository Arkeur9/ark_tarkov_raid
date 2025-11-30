-- ==========================================
-- ark_tarkov_raid/client/npc.lua
-- Gestion des PNJs pour les raids
-- ==========================================

local npcSpawned = false
local raidNPCs = {}

-- Configuration des PNJs
local NPCLocations = {
    {
        name = 'Agent Tarkov - Centre-ville',
        model = 's_m_m_security_01',
        coords = vector4(22.67, -640.00, 16.09, 80.36),
        blip = {
            sprite = 304,
            color = 5,
            scale = 0.8,
            label = 'Agent de Raid'
        },
        animation = {
            dict = 'amb@world_human_guard_stand@male@base',
            anim = 'base'
        }
    },
    {
        name = 'Agent Tarkov - Legion Square',
        model = 's_m_m_marine_02',
        coords = vector4(215.82, -945.67, 29.69, 90.0),
        blip = {
            sprite = 304,
            color = 5,
            scale = 0.8,
            label = 'Agent de Raid'
        },
        animation = {
            dict = 'amb@world_human_guard_stand@male@base',
            anim = 'base'
        }
    },
}

-- Créer les PNJs
CreateThread(function()
    for index, npcData in ipairs(NPCLocations) do
        RequestModel(npcData.model)
        while not HasModelLoaded(npcData.model) do
            Wait(100)
        end
        
        local npc = CreatePed(4, npcData.model, npcData.coords.x, npcData.coords.y, npcData.coords.z, npcData.coords.w, false, true)
        
        FreezeEntityPosition(npc, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        SetPedCanRagdollFromPlayerImpact(npc, false)
        SetPedCanBeTargetted(npc, false)
        
        if npcData.animation then
            RequestAnimDict(npcData.animation.dict)
            while not HasAnimDictLoaded(npcData.animation.dict) do
                Wait(100)
            end
            TaskPlayAnim(npc, npcData.animation.dict, npcData.animation.anim, 8.0, 0.0, -1, 1, 0, false, false, false)
        end
        
        local blip = AddBlipForCoord(npcData.coords.x, npcData.coords.y, npcData.coords.z)
        SetBlipSprite(blip, npcData.blip.sprite)
        SetBlipColour(blip, npcData.blip.color)
        SetBlipScale(blip, npcData.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(npcData.blip.label)
        EndTextCommandSetBlipName(blip)
        
        table.insert(raidNPCs, {
            entity = npc,
            blip = blip,
            data = npcData
        })
        
        -- ox_target pour interaction
        exports.ox_target:addLocalEntity(npc, {
            {
                name = 'raid_agent_' .. index,
                icon = 'fas fa-crosshairs',
                label = 'Accéder aux Raids Tarkov',
                distance = 2.5,
                onSelect = function()
                    OpenRaidUI()
                end
            },
            {
                name = 'raid_info_' .. index,
                icon = 'fas fa-info-circle',
                label = 'Informations',
                distance = 2.5,
                onSelect = function()
                    lib.alertDialog({
                        header = '📋 Système de Raid Tarkov',
                        content = [[
**Bienvenue au système de raid !**

- Formez un squad (Solo, Duo, Trio, Squad)
- Choisissez votre map de raid
- Combattez, lootez, survivez
- Extrayez-vous avec votre butin

**Types de squad :**
- Solo : +50% de loot
- Duo : +20% de loot
- Trio : Loot normal
- Squad (4) : -10% de loot

Bonne chance, mercenaire !
                        ]],
                        centered = true,
                    })
                end
            }
        })
        
        if Config.Debug then
            print(('[ARK RAID] PNJ créé: %s à %.2f, %.2f, %.2f'):format(
                npcData.name,
                npcData.coords.x,
                npcData.coords.y,
                npcData.coords.z
            ))
        end
    end
    
    npcSpawned = true
    if Config.Debug then
        print('[ARK RAID] Tous les PNJs ont été créés')
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    for _, npcInfo in ipairs(raidNPCs) do
        if DoesEntityExist(npcInfo.entity) then
            DeleteEntity(npcInfo.entity)
        end
        if DoesBlipExist(npcInfo.blip) then
            RemoveBlip(npcInfo.blip)
        end
    end
    
    if Config.Debug then
        print('[ARK RAID] PNJs supprimés')
    end
end)

if Config.Debug then
    print('[ARK RAID] Client NPC initialisé')
end