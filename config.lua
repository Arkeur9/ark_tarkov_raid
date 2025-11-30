-- ==========================================
-- ark_tarkov_raid/config.lua
-- Configuration du système de raid Tarkov
-- ==========================================

Config = {}

-- Paramètres généraux
Config.Framework = 'ESX' -- 'ESX' ou 'QBCore'
Config.Inventory = 'ox_inventory'
Config.Debug = true
Config.Currency = 'rouble' -- Item utilisé comme monnaie

-- Système de squad
Config.Squad = {
    Enabled = true,
    MaxSquadSize = 4,
    Types = {
        ['solo'] = {
            label = 'Solo',
            minPlayers = 1,
            maxPlayers = 1,
            icon = '👤',
            multiplier = 1.5, -- Bonus de loot pour solo
        },
        ['duo'] = {
            label = 'Duo',
            minPlayers = 2,
            maxPlayers = 2,
            icon = '👥',
            multiplier = 1.2,
        },
        ['trio'] = {
            label = 'Trio',
            minPlayers = 3,
            maxPlayers = 3,
            icon = '👥👤',
            multiplier = 1.0,
        },
        ['squad'] = {
            label = 'Squad (4)',
            minPlayers = 4,
            maxPlayers = 4,
            icon = '👥👥',
            multiplier = 0.9,
        },
    },
    FriendlyFire = true,
    SharedLoot = false, -- Loot partagé entre membres du squad
    LeaderOnly = true, -- Seul le leader peut lancer le raid
}

-- Système de matchmaking
Config.Matchmaking = {
    MinPlayers = 1,
    MaxPlayers = 4,
    WaitTime = 30,
    LobbyTimeout = 300,
    AllowRandomMatch = true, -- Permettre de rejoindre des squads aléatoires
}

-- Maps de raid disponibles
Config.Maps = {
    ['customs'] = {
        label = 'Customs',
        description = 'Zone industrielle avec usines et dortoirs',
        image = 'customs.png',
        difficulty = 'Medium',
        raidDuration = 2700, -- 45 minutes
        minLevel = 1,
        maxLevel = 100,
        entryFee = 15000,
        
        -- Spawns par type de squad
        spawns = {
            solo = {
                vector4(-1087.52, -2823.45, 13.94, 240.0),
                vector4(-1145.23, -2798.67, 13.94, 180.0),
                vector4(-1023.89, -2856.12, 13.94, 90.0),
            },
            duo = {
                {vector4(-1087.52, -2823.45, 13.94, 240.0), vector4(-1085.12, -2825.23, 13.94, 240.0)},
                {vector4(-1145.23, -2798.67, 13.94, 180.0), vector4(-1147.89, -2800.12, 13.94, 180.0)},
            },
            trio = {
                {
                    vector4(-1087.52, -2823.45, 13.94, 240.0),
                    vector4(-1085.12, -2825.23, 13.94, 240.0),
                    vector4(-1089.45, -2821.67, 13.94, 240.0),
                },
            },
            squad = {
                {
                    vector4(-1087.52, -2823.45, 13.94, 240.0),
                    vector4(-1085.12, -2825.23, 13.94, 240.0),
                    vector4(-1089.45, -2821.67, 13.94, 240.0),
                    vector4(-1083.78, -2827.89, 13.94, 240.0),
                },
            },
        },
        
        -- Points d'extraction
        extractions = {
            {
                name = 'Railway Exfil',
                coords = vector3(-1234.56, -2567.89, 13.94),
                radius = 5.0,
                extractTime = 10,
                alwaysOpen = true,
                requirements = {}, -- Conditions spéciales
                maxUses = -1, -- -1 = illimité
            },
            {
                name = 'RUAF Roadblock',
                coords = vector3(-1456.78, -2789.34, 13.94),
                radius = 4.0,
                extractTime = 8,
                alwaysOpen = false, -- S'ouvre aléatoirement
                openChance = 0.6, -- 60% de chance d'être ouverte
                requirements = {},
                maxUses = 4, -- 4 joueurs max
            },
            {
                name = 'Dorms V-Ex',
                coords = vector3(-1098.45, -2634.12, 13.94),
                radius = 3.0,
                extractTime = 15,
                alwaysOpen = true,
                requirements = {
                    money = 7000, -- Coûte 7000 roubles
                },
                maxUses = 1, -- Usage unique
            },
            {
                name = 'Smugglers Boat',
                coords = vector3(-1567.89, -2890.23, 13.94),
                radius = 4.0,
                extractTime = 12,
                alwaysOpen = false,
                openChance = 0.4,
                requirements = {
                    items = {'ark_keycard_blue'}, -- Nécessite une carte bleue
                },
                maxUses = 2,
            },
        },
        
        -- Zones de loot
        lootZones = {
            -- Dortoirs
            {
                name = 'Dorms 2 Story',
                coords = vector3(-1123.45, -2689.12, 13.94),
                radius = 40.0,
                lootTier = 'high',
                spawnChance = 0.8,
                maxContainers = 15,
            },
            {
                name = 'Dorms 3 Story',
                coords = vector3(-1089.67, -2734.56, 13.94),
                radius = 45.0,
                lootTier = 'high',
                spawnChance = 0.85,
                maxContainers = 20,
            },
            -- Gas Station
            {
                name = 'Gas Station',
                coords = vector3(-1234.89, -2823.45, 13.94),
                radius = 25.0,
                lootTier = 'medium',
                spawnChance = 0.9,
                maxContainers = 8,
            },
            -- Construction
            {
                name = 'Construction Site',
                coords = vector3(-1345.67, -2756.89, 13.94),
                radius = 35.0,
                lootTier = 'medium',
                spawnChance = 0.7,
                maxContainers = 12,
            },
            -- Big Red
            {
                name = 'Big Red Warehouse',
                coords = vector3(-1456.23, -2698.34, 13.94),
                radius = 30.0,
                lootTier = 'high',
                spawnChance = 0.75,
                maxContainers = 10,
            },
        },
    },
    
    ['factory'] = {
        label = 'Factory',
        description = 'Usine compacte, action rapide et intense',
        image = 'factory.png',
        difficulty = 'Hard',
        raidDuration = 1200, -- 20 minutes
        minLevel = 5,
        maxLevel = 100,
        entryFee = 25000,
        
        spawns = {
            solo = {
                vector4(1089.45, -2156.78, 30.45, 90.0),
                vector4(1134.56, -2189.23, 30.45, 270.0),
            },
            duo = {
                {vector4(1089.45, -2156.78, 30.45, 90.0), vector4(1087.12, -2158.34, 30.45, 90.0)},
            },
            trio = {
                {
                    vector4(1089.45, -2156.78, 30.45, 90.0),
                    vector4(1087.12, -2158.34, 30.45, 90.0),
                    vector4(1091.67, -2154.89, 30.45, 90.0),
                },
            },
            squad = {
                {
                    vector4(1089.45, -2156.78, 30.45, 90.0),
                    vector4(1087.12, -2158.34, 30.45, 90.0),
                    vector4(1091.67, -2154.89, 30.45, 90.0),
                    vector4(1085.23, -2160.45, 30.45, 90.0),
                },
            },
        },
        
        extractions = {
            {
                name = 'Gate 3',
                coords = vector3(1167.89, -2234.56, 30.45),
                radius = 3.0,
                extractTime = 5,
                alwaysOpen = true,
                requirements = {},
                maxUses = -1,
            },
            {
                name = 'Office Window',
                coords = vector3(1098.34, -2178.12, 35.67),
                radius = 2.0,
                extractTime = 8,
                alwaysOpen = true,
                requirements = {},
                maxUses = -1,
            },
            {
                name = 'Cellars',
                coords = vector3(1123.45, -2198.67, 25.34),
                radius = 4.0,
                extractTime = 10,
                alwaysOpen = false,
                openChance = 0.7,
                requirements = {},
                maxUses = 2,
            },
        },
        
        lootZones = {
            {
                name = 'Main Floor',
                coords = vector3(1112.34, -2189.45, 30.45),
                radius = 50.0,
                lootTier = 'medium',
                spawnChance = 0.85,
                maxContainers = 15,
            },
            {
                name = 'Office Area',
                coords = vector3(1098.67, -2176.89, 35.67),
                radius = 20.0,
                lootTier = 'high',
                spawnChance = 0.7,
                maxContainers = 8,
            },
            {
                name = 'Underground',
                coords = vector3(1125.89, -2201.23, 25.34),
                radius = 30.0,
                lootTier = 'high',
                spawnChance = 0.6,
                maxContainers = 10,
            },
        },
    },
    
    ['woods'] = {
        label = 'Woods',
        description = 'Grande forêt avec scierie et camps',
        image = 'woods.png',
        difficulty = 'Medium',
        raidDuration = 3000, -- 50 minutes
        minLevel = 3,
        maxLevel = 100,
        entryFee = 12000,
        
        spawns = {
            solo = {
                vector4(-456.78, 3289.45, 35.67, 180.0),
                vector4(-523.12, 3345.89, 35.67, 90.0),
                vector4(-389.34, 3256.12, 35.67, 270.0),
            },
            duo = {
                {vector4(-456.78, 3289.45, 35.67, 180.0), vector4(-454.23, 3287.12, 35.67, 180.0)},
                {vector4(-523.12, 3345.89, 35.67, 90.0), vector4(-525.67, 3343.45, 35.67, 90.0)},
            },
            trio = {
                {
                    vector4(-456.78, 3289.45, 35.67, 180.0),
                    vector4(-454.23, 3287.12, 35.67, 180.0),
                    vector4(-459.45, 3291.67, 35.67, 180.0),
                },
            },
            squad = {
                {
                    vector4(-456.78, 3289.45, 35.67, 180.0),
                    vector4(-454.23, 3287.12, 35.67, 180.0),
                    vector4(-459.45, 3291.67, 35.67, 180.0),
                    vector4(-451.89, 3284.78, 35.67, 180.0),
                },
            },
        },
        
        extractions = {
            {
                name = 'UN Roadblock',
                coords = vector3(-678.90, 3456.78, 35.67),
                radius = 6.0,
                extractTime = 12,
                alwaysOpen = true,
                requirements = {},
                maxUses = -1,
            },
            {
                name = 'Outskirts',
                coords = vector3(-234.56, 3123.45, 35.67),
                radius = 5.0,
                extractTime = 10,
                alwaysOpen = true,
                requirements = {},
                maxUses = -1,
            },
            {
                name = 'Bridge V-Ex',
                coords = vector3(-512.34, 3412.89, 35.67),
                radius = 4.0,
                extractTime = 15,
                alwaysOpen = true,
                requirements = {
                    money = 5000,
                },
                maxUses = 1,
            },
        },
        
        lootZones = {
            {
                name = 'Sawmill',
                coords = vector3(-489.12, 3312.45, 35.67),
                radius = 45.0,
                lootTier = 'high',
                spawnChance = 0.8,
                maxContainers = 18,
            },
            {
                name = 'Lumber Camp',
                coords = vector3(-567.89, 3389.23, 35.67),
                radius = 30.0,
                lootTier = 'medium',
                spawnChance = 0.85,
                maxContainers = 12,
            },
            {
                name = 'Scav House',
                coords = vector3(-412.45, 3245.67, 35.67),
                radius = 20.0,
                lootTier = 'low',
                spawnChance = 0.9,
                maxContainers = 8,
            },
        },
    },
}

-- Système de loot
Config.Loot = {
    Enabled = true,
    
    -- Types de conteneurs
    Containers = {
        ['weapon_crate'] = {
            label = 'Caisse d\'armes',
            model = 'prop_box_guncase_03a',
            searchTime = 5,
            lootTable = 'weapons',
        },
        ['medical_bag'] = {
            label = 'Sac médical',
            model = 'prop_ld_health_pack',
            searchTime = 3,
            lootTable = 'medical',
        },
        ['ammo_box'] = {
            label = 'Boîte de munitions',
            model = 'prop_box_ammo03a',
            searchTime = 4,
            lootTable = 'ammo',
        },
        ['food_crate'] = {
            label = 'Caisse de nourriture',
            model = 'prop_cs_cardbox_01',
            searchTime = 3,
            lootTable = 'food',
        },
        ['toolbox'] = {
            label = 'Boîte à outils',
            model = 'prop_tool_box_04',
            searchTime = 4,
            lootTable = 'tools',
        },
        ['safe'] = {
            label = 'Coffre-fort',
            model = 'p_v_43_safe_s',
            searchTime = 8,
            lootTable = 'valuable',
            requireKey = true,
        },
        ['jacket'] = {
            label = 'Veste',
            model = 'prop_michael_backpack',
            searchTime = 2,
            lootTable = 'random',
        },
    },
    
    -- Tables de loot par tier
    LootTables = {
        ['weapons'] = {
            tier = {
                low = {
                    {item = 'WEAPON_PISTOL', chance = 40, min = 1, max = 1},
                    {item = 'ark_pm_pistol', chance = 35, min = 1, max = 1},
                    {item = 'ark_tt_pistol', chance = 30, min = 1, max = 1},
                    {item = 'WEAPON_SMG', chance = 15, min = 1, max = 1},
                },
                medium = {
                    {item = 'WEAPON_ASSAULTRIFLE', chance = 25, min = 1, max = 1},
                    {item = 'ark_ak74', chance = 30, min = 1, max = 1},
                    {item = 'ark_akm', chance = 25, min = 1, max = 1},
                    {item = 'WEAPON_SMG', chance = 35, min = 1, max = 1},
                    {item = 'ark_mp5', chance = 30, min = 1, max = 1},
                },
                high = {
                    {item = 'ark_m4a1', chance = 20, min = 1, max = 1},
                    {item = 'ark_hk416', chance = 15, min = 1, max = 1},
                    {item = 'ark_ak74m', chance = 25, min = 1, max = 1},
                    {item = 'ark_val', chance = 18, min = 1, max = 1},
                    {item = 'WEAPON_SNIPERRIFLE', chance = 10, min = 1, max = 1},
                },
            },
        },
        
        ['medical'] = {
            tier = {
                low = {
                    {item = 'ark_bandage', chance = 60, min = 1, max = 3},
                    {item = 'ark_painkiller', chance = 40, min = 1, max = 2},
                },
                medium = {
                    {item = 'ark_medkit', chance = 50, min = 1, max = 2},
                    {item = 'ark_splint', chance = 35, min = 1, max = 1},
                    {item = 'ark_morphine', chance = 25, min = 1, max = 1},
                },
                high = {
                    {item = 'ark_cms_kit', chance = 30, min = 1, max = 1},
                    {item = 'ark_surv12_kit', chance = 20, min = 1, max = 1},
                    {item = 'ark_grizzly', chance = 35, min = 1, max = 1},
                    {item = 'ark_adrenaline', chance = 25, min = 1, max = 1},
                },
            },
        },
        
        ['ammo'] = {
            tier = {
                low = {
                    {item = 'ark_ammo_9mm', chance = 70, min = 30, max = 60},
                    {item = 'ark_ammo_45acp', chance = 50, min = 20, max = 40},
                },
                medium = {
                    {item = 'ark_ammo_556', chance = 60, min = 30, max = 90},
                    {item = 'ark_ammo_545', chance = 65, min = 30, max = 90},
                    {item = 'ark_ammo_762', chance = 55, min = 20, max = 60},
                },
                high = {
                    {item = 'ark_ammo_762x54', chance = 40, min = 20, max = 40},
                    {item = 'ark_ammo_338', chance = 25, min = 10, max = 30},
                    {item = 'ark_ammo_9x39', chance = 35, min = 20, max = 60},
                },
            },
        },
        
        ['food'] = {
            tier = {
                low = {
                    {item = 'ark_water_bottle', chance = 70, min = 1, max = 2},
                    {item = 'ark_crackers', chance = 60, min = 1, max = 3},
                    {item = 'ark_condensed_milk', chance = 50, min = 1, max = 2},
                },
                medium = {
                    {item = 'ark_energy_drink', chance = 55, min = 1, max = 2},
                    {item = 'ark_mre', chance = 45, min = 1, max = 2},
                    {item = 'ark_juice', chance = 50, min = 1, max = 2},
                },
                high = {
                    {item = 'ark_water_filter', chance = 30, min = 1, max = 1},
                    {item = 'ark_premium_food', chance = 25, min = 1, max = 1},
                    {item = 'ark_mayo', chance = 20, min = 1, max = 1},
                },
            },
        },
        
        ['tools'] = {
            tier = {
                low = {
                    {item = 'ark_screwdriver', chance = 50, min = 1, max = 1},
                    {item = 'ark_wrench', chance = 45, min = 1, max = 1},
                    {item = 'ark_duct_tape', chance = 40, min = 1, max = 2},
                },
                medium = {
                    {item = 'ark_drill', chance = 35, min = 1, max = 1},
                    {item = 'ark_multitool', chance = 30, min = 1, max = 1},
                    {item = 'ark_weapon_parts', chance = 40, min = 1, max = 3},
                },
                high = {
                    {item = 'ark_keycard_blue', chance = 15, min = 1, max = 1},
                    {item = 'ark_keycard_red', chance = 8, min = 1, max = 1},
                    {item = 'ark_intelligence', chance = 12, min = 1, max = 1},
                },
            },
        },
        
        ['valuable'] = {
            tier = {
                low = {
                    {item = 'rouble', chance = 80, min = 5000, max = 15000},
                    {item = 'ark_gold_chain', chance = 30, min = 1, max = 2},
                },
                medium = {
                    {item = 'rouble', chance = 70, min = 15000, max = 40000},
                    {item = 'ark_bitcoin', chance = 25, min = 1, max = 1},
                    {item = 'ark_gold_watch', chance = 30, min = 1, max = 2},
                },
                high = {
                    {item = 'rouble', chance = 60, min = 40000, max = 100000},
                    {item = 'ark_bitcoin', chance = 40, min = 1, max = 3},
                    {item = 'ark_rolex', chance = 20, min = 1, max = 1},
                    {item = 'ark_ledx', chance = 15, min = 1, max = 1},
                },
            },
        },
        
        ['random'] = {
            tier = {
                low = {
                    {item = 'ark_bandage', chance = 40, min = 1, max = 2},
                    {item = 'ark_water_bottle', chance = 35, min = 1, max = 1},
                    {item = 'rouble', chance = 50, min = 1000, max = 5000},
                },
                medium = {
                    {item = 'ark_ammo_9mm', chance = 30, min = 10, max = 30},
                    {item = 'ark_energy_drink', chance = 25, min = 1, max = 1},
                    {item = 'rouble', chance = 40, min = 5000, max = 15000},
                },
                high = {
                    {item = 'ark_bitcoin', chance = 15, min = 1, max = 1},
                    {item = 'ark_keycard_blue', chance = 10, min = 1, max = 1},
                    {item = 'rouble', chance = 35, min = 15000, max = 30000},
                },
            },
        },
    },
}

-- Effets de statut
Config.StatusEffects = {
    DehydrationRate = 0.1, -- Par minute
    HungerRate = 0.08,
    StaminaRegen = 2.0,
    HealthRegenRate = 0.0, -- Pas de régénération naturelle
    
    -- Pénalités
    LowHydration = {
        threshold = 30,
        effects = {
            staminaPenalty = 0.5,
            visionBlur = true,
        },
    },
    LowEnergy = {
        threshold = 30,
        effects = {
            staminaPenalty = 0.3,
            movementPenalty = 0.8,
        },
    },
}

-- Récompenses de raid
Config.Rewards = {
    Survived = {
        xp = 500,
        bonus = 0, -- Bonus en roubles
    },
    Extraction = {
        xp = 1000,
        bonus = 5000,
    },
    KilledInRaid = {
        xpPenalty = -200,
        lootLoss = 0.5, -- Perd 50% de l'inventaire
    },
}

-- Messages
Config.Messages = {
    ['no_money'] = 'Vous n\'avez pas assez de roubles pour ce raid.',
    ['level_required'] = 'Niveau %s requis pour cette map.',
    ['squad_full'] = 'Votre squad est complet.',
    ['not_leader'] = 'Seul le leader peut lancer le raid.',
    ['waiting_players'] = 'En attente de joueurs... (%s/%s)',
    ['raid_starting'] = 'Le raid commence dans %s secondes!',
    ['extraction_available'] = 'Point d\'extraction disponible: %s',
    ['extracting'] = 'Extraction en cours... Ne bougez pas!',
    ['extracted'] = 'Vous avez été extrait avec succès!',
    ['raid_time_left'] = 'Temps restant: %s',
    ['container_searched'] = 'Conteneur déjà fouillé.',
    ['searching'] = 'Fouille en cours...',
}