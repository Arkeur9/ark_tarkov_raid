-- ==========================================
-- ark_tarkov_raid/fxmanifest.lua
-- Manifest du resource Tarkov Raid System
-- ==========================================

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Arkeur'
description 'Système de Raid Tarkov avec UI personnalisée'
version '1.0.0'

-- Scripts partagés
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

-- Scripts client
client_scripts {
    'client/main.lua',
    'client/ui.lua',
    'client/npc.lua'
}

-- Scripts serveur
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

-- Interface utilisateur
ui_page 'html/index.html'

-- Fichiers de l'interface
files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

-- Dépendances requises
dependencies {
    'es_extended',
    'ox_lib',
    'ox_target',
    'ox_inventory'
}

-- Exports côté client
client_export 'OpenRaidUI'
client_export 'CloseRaidUI'