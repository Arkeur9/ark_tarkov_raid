/* ==========================================
   html/script.js - Tarkov Raid UI Logic
   ========================================== */

// Variables globales
let currentView = 'menu';
let currentSquad = null;
let selectedMap = null;
let nearbyPlayers = [];
let lobbyTimer = 30;
let lobbyInterval = null;

// Configuration des types de squad
const squadTypes = {
    solo: { 
        label: 'Solo', 
        icon: '👤', 
        min: 1, 
        max: 1, 
        multiplier: 1.5,
        description: '1 joueur • Bonus x1.5'
    },
    duo: { 
        label: 'Duo', 
        icon: '👥', 
        min: 2, 
        max: 2, 
        multiplier: 1.2,
        description: '2 joueurs • Bonus x1.2'
    },
    trio: { 
        label: 'Trio', 
        icon: '👥👤', 
        min: 3, 
        max: 3, 
        multiplier: 1.0,
        description: '3 joueurs • Bonus x1.0'
    },
    squad: { 
        label: 'Squad', 
        icon: '👥👥', 
        min: 4, 
        max: 4, 
        multiplier: 0.9,
        description: '4 joueurs • Bonus x0.9'
    },
};

// Configuration des maps
const maps = {
    customs: {
        name: 'Customs',
        description: 'Zone industrielle avec usines et dortoirs',
        duration: 45,
        difficulty: 'Medium',
        difficultyClass: 'difficulty-medium',
        fee: 15000,
        level: 1,
        extractions: 4,
        icon: '🏭'
    },
    factory: {
        name: 'Factory',
        description: 'Usine compacte, action rapide et intense',
        duration: 20,
        difficulty: 'Hard',
        difficultyClass: 'difficulty-hard',
        fee: 25000,
        level: 5,
        extractions: 3,
        icon: '🏗️'
    },
    woods: {
        name: 'Woods',
        description: 'Grande forêt avec scierie et camps',
        duration: 50,
        difficulty: 'Medium',
        difficultyClass: 'difficulty-medium',
        fee: 12000,
        level: 3,
        extractions: 3,
        icon: '🌲'
    }
};

/**
 * Envoyer un message NUI à FiveM
 */
function sendNuiMessage(action, data = {}) {
    fetch(`https://${getResourceName()}/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    }).catch(err => {
        console.error('[Raid UI] Erreur NUI:', err);
    });
}

/**
 * Obtenir le nom de la ressource
 */
function getResourceName() {
    if (window.location.hostname === '' || window.location.hostname === 'localhost') {
        return 'ark_tarkov_raid';
    }
    return window.location.hostname;
}

/**
 * Formater un nombre avec séparateurs
 */
function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ");
}

/**
 * Créer un squad
 */
function createSquad(type) {
    console.log('[Raid UI] Création squad:', type);
    sendNuiMessage('createSquad', { type });
    changeView('squad');
}

/**
 * Inviter un joueur
 */
function invitePlayer(playerId) {
    if (!currentSquad) {
        console.error('[Raid UI] Aucun squad actif');
        return;
    }
    console.log('[Raid UI] Invitation joueur:', playerId);
    sendNuiMessage('invitePlayer', { playerId });
}

/**
 * Sélectionner une map
 */
function selectMap(mapKey) {
    console.log('[Raid UI] Map sélectionnée:', mapKey);
    selectedMap = mapKey;
    renderMapsView();
}

/**
 * Lancer le raid
 */
function startRaid() {
    if (!selectedMap || !currentSquad) {
        console.error('[Raid UI] Map ou squad non sélectionné');
        return;
    }
    
    console.log('[Raid UI] Lancement raid:', selectedMap);
    sendNuiMessage('startRaid', { 
        squadId: currentSquad.id, 
        mapName: selectedMap 
    });
}

/**
 * Quitter le squad
 */
function leaveSquad() {
    if (!currentSquad) return;
    
    console.log('[Raid UI] Quitter squad:', currentSquad.id);
    sendNuiMessage('leaveSquad', { squadId: currentSquad.id });
    currentSquad = null;
    changeView('menu');
}

/**
 * Fermer l'UI
 */
function closeUI() {
    console.log('[Raid UI] Fermeture UI');
    sendNuiMessage('closeUI');
    document.body.style.display = 'none';
    
    if (lobbyInterval) {
        clearInterval(lobbyInterval);
        lobbyInterval = null;
    }
}

/**
 * Changer de vue
 */
function changeView(view) {
    console.log('[Raid UI] Changement vue:', view);
    currentView = view;
    renderCurrentView();
}

/**
 * Démarrer le timer du lobby
 */
function startLobbyTimer() {
    console.log('[Raid UI] Démarrage timer lobby');
    lobbyTimer = 30;
    
    if (lobbyInterval) {
        clearInterval(lobbyInterval);
    }
    
    lobbyInterval = setInterval(() => {
        lobbyTimer--;
        renderLobbyView();
        
        if (lobbyTimer <= 0) {
            clearInterval(lobbyInterval);
            lobbyInterval = null;
        }
    }, 1000);
}

/**
 * Rendre la vue actuelle
 */
function renderCurrentView() {
    const contentArea = document.getElementById('raid-content');
    if (!contentArea) {
        console.error('[Raid UI] Element #raid-content introuvable');
        return;
    }
    
    switch(currentView) {
        case 'menu':
            renderMenuView();
            break;
        case 'squad':
            renderSquadView();
            break;
        case 'maps':
            renderMapsView();
            break;
        case 'lobby':
            renderLobbyView();
            break;
        default:
            renderMenuView();
    }
}

/**
 * Rendre le menu principal
 */
function renderMenuView() {
    const contentArea = document.getElementById('raid-content');
    
    contentArea.innerHTML = `
        <div class="grid grid-cols-2 gap-4">
            <!-- Créer un Squad -->
            <div class="raid-panel">
                <div class="raid-panel-header">
                    <h2>Créer un Squad</h2>
                </div>
                <div style="display: flex; flex-direction: column; gap: 15px;" id="squad-types-list"></div>
            </div>
            
            <!-- Mon Squad -->
            <div class="raid-panel">
                <div class="raid-panel-header">
                    <h2>Mon Squad</h2>
                </div>
                <div id="current-squad-info"></div>
            </div>
        </div>
    `;
    
    renderSquadTypes();
    renderCurrentSquadInfo();
}

/**
 * Rendre les types de squad
 */
function renderSquadTypes() {
    const container = document.getElementById('squad-types-list');
    if (!container) return;
    
    container.innerHTML = Object.entries(squadTypes).map(([key, type]) => `
        <div class="squad-type-card" onclick="createSquad('${key}')">
            <div class="squad-type-info">
                <div class="squad-type-icon">${type.icon}</div>
                <div class="squad-type-details">
                    <h3>${type.label}</h3>
                    <p>${type.description}</p>
                </div>
            </div>
            <div style="color: var(--tarkov-text-secondary); font-size: 24px;">→</div>
        </div>
    `).join('');
}

/**
 * Rendre les infos du squad actuel
 */
function renderCurrentSquadInfo() {
    const container = document.getElementById('current-squad-info');
    if (!container) return;
    
    if (currentSquad) {
        const squadType = squadTypes[currentSquad.type];
        
        container.innerHTML = `
            <div style="background: linear-gradient(135deg, rgba(45, 80, 22, 0.2) 0%, rgba(45, 80, 22, 0.3) 100%); 
                        border: 1px solid var(--tarkov-green); padding: 20px; margin-bottom: 20px;">
                <div style="font-size: 13px; color: var(--tarkov-green-light); margin-bottom: 10px;">Type de squad</div>
                <div style="font-family: 'Orbitron', sans-serif; font-size: 24px; font-weight: 700; color: var(--tarkov-text-primary);">
                    ${squadType?.label || 'N/A'}
                </div>
                <div style="font-size: 14px; color: var(--tarkov-text-secondary); margin-top: 5px;">
                    ${currentSquad.members?.length || 0} / ${squadType?.max || 0} membres
                </div>
            </div>
            
            <div style="display: flex; flex-direction: column; gap: 10px; margin-bottom: 20px;">
                ${(currentSquad.members || []).map(member => `
                    <div style="background: rgba(40, 40, 40, 0.6); border: 1px solid var(--tarkov-border); 
                                padding: 15px; display: flex; align-items: center; gap: 10px;">
                        <span style="font-size: 20px;">${member.isLeader ? '👑' : '👤'}</span>
                        <span style="color: var(--tarkov-text-primary); font-weight: 600;">${member.name}</span>
                    </div>
                `).join('')}
            </div>
            
            <div style="display: flex; gap: 10px;">
                <button class="raid-btn" style="flex: 1;" onclick="changeView('squad')">
                    Gérer
                </button>
                <button class="raid-btn" style="flex: 1;" onclick="changeView('maps')">
                    Lancer Raid
                </button>
            </div>
        `;
    } else {
        container.innerHTML = `
            <div style="background: rgba(40, 40, 40, 0.6); border: 1px solid var(--tarkov-border); 
                        padding: 40px; text-align: center;">
                <div style="font-size: 60px; margin-bottom: 20px; opacity: 0.3;">⚠️</div>
                <p style="color: var(--tarkov-text-secondary); font-size: 16px;">Vous n'êtes dans aucun squad</p>
                <p style="color: var(--tarkov-text-dim); font-size: 14px; margin-top: 10px;">Créez un squad pour commencer</p>
            </div>
        `;
    }
}

/**
 * Rendre la vue de gestion du squad
 */
function renderSquadView() {
    const contentArea = document.getElementById('raid-content');
    
    if (!currentSquad) {
        changeView('menu');
        return;
    }
    
    contentArea.innerHTML = `
        <button class="raid-btn-danger" onclick="changeView('menu')" style="margin-bottom: 20px; padding: 10px 20px;">
            ← Retour
        </button>
        
        <div class="raid-panel">
            <div class="raid-panel-header">
                <h2>Gestion du Squad</h2>
            </div>
            
            <div class="grid grid-cols-2 gap-4">
                <!-- Membres du squad -->
                <div>
                    <h3 style="font-size: 20px; font-weight: 700; color: var(--tarkov-text-primary); margin-bottom: 20px;">
                        Membres du squad
                    </h3>
                    <div id="squad-members-list"></div>
                </div>
                
                <!-- Joueurs à proximité -->
                <div>
                    <h3 style="font-size: 20px; font-weight: 700; color: var(--tarkov-text-primary); margin-bottom: 20px;">
                        Joueurs à proximité
                    </h3>
                    <div id="nearby-players-list"></div>
                </div>
            </div>
            
            <div style="margin-top: 30px; padding-top: 30px; border-top: 1px solid var(--tarkov-border); display: flex; gap: 20px;">
                <button class="raid-btn" style="flex: 1;" onclick="changeView('maps')">
                    Sélectionner une Map
                </button>
                <button class="raid-btn-danger" onclick="leaveSquad()" style="padding: 15px 30px;">
                    Quitter le Squad
                </button>
            </div>
        </div>
    `;
    
    renderSquadMembers();
    renderNearbyPlayers();
}

/**
 * Rendre les membres du squad
 */
function renderSquadMembers() {
    const container = document.getElementById('squad-members-list');
    if (!container || !currentSquad) return;
    
    container.innerHTML = (currentSquad.members || []).map(member => `
        <div style="background: rgba(40, 40, 40, 0.6); border: 1px solid var(--tarkov-border); 
                    padding: 20px; margin-bottom: 10px; display: flex; align-items: center; justify-content: space-between;">
            <div style="display: flex; align-items: center; gap: 15px;">
                <span style="font-size: 24px;">${member.isLeader ? '👑' : '👤'}</span>
                <div>
                    <div style="color: var(--tarkov-text-primary); font-weight: 700; font-size: 16px;">
                        ${member.name}
                    </div>
                    <div style="color: var(--tarkov-text-secondary); font-size: 13px;">
                        ${member.isLeader ? 'Leader' : 'Membre'}
                    </div>
                </div>
            </div>
        </div>
    `).join('');
}

/**
 * Rendre les joueurs à proximité
 */
function renderNearbyPlayers() {
    const container = document.getElementById('nearby-players-list');
    if (!container) return;
    
    if (nearbyPlayers.length === 0) {
        container.innerHTML = `
            <div style="background: rgba(40, 40, 40, 0.6); border: 1px solid var(--tarkov-border); 
                        padding: 40px; text-align: center;">
                <p style="color: var(--tarkov-text-secondary);">Aucun joueur à proximité</p>
            </div>
        `;
        return;
    }
    
    container.innerHTML = nearbyPlayers.map(player => `
        <div style="background: rgba(40, 40, 40, 0.6); border: 1px solid var(--tarkov-border); 
                    padding: 20px; margin-bottom: 10px; display: flex; align-items: center; justify-content: space-between;">
            <div style="display: flex; align-items: center; gap: 15px;">
                <span style="font-size: 24px;">👤</span>
                <span style="color: var(--tarkov-text-primary); font-weight: 700;">
                    ${player.name}
                </span>
            </div>
            <button class="raid-btn" onclick="invitePlayer(${player.id})" style="padding: 10px 20px; font-size: 14px;">
                Inviter
            </button>
        </div>
    `).join('');
}

/**
 * Rendre la sélection de map
 */
function renderMapsView() {
    const contentArea = document.getElementById('raid-content');
    
    contentArea.innerHTML = `
        <button class="raid-btn-danger" onclick="changeView(currentSquad ? 'squad' : 'menu')" style="margin-bottom: 20px; padding: 10px 20px;">
            ← Retour
        </button>
        
        <div class="raid-panel">
            <div class="raid-panel-header">
                <h2>Sélectionner une Map</h2>
            </div>
            
            <div class="grid grid-cols-3 gap-4" id="maps-grid"></div>
            
            <div id="start-raid-button" style="margin-top: 30px; padding-top: 30px; border-top: 1px solid var(--tarkov-border);"></div>
        </div>
    `;
    
    renderMapCards();
    renderStartRaidButton();
}

/**
 * Rendre les cartes de map
 */
function renderMapCards() {
    const container = document.getElementById('maps-grid');
    if (!container) return;
    
    container.innerHTML = Object.entries(maps).map(([key, map]) => `
        <div class="map-card ${selectedMap === key ? 'selected' : ''}" onclick="selectMap('${key}')">
            ${selectedMap === key ? '<div style="position: absolute; top: 20px; right: 20px; font-size: 30px; color: var(--tarkov-green-light);">✓</div>' : ''}
            
            <div class="map-card-icon">${map.icon}</div>
            <div class="map-card-title">${map.name}</div>
            <div class="map-card-desc">${map.description}</div>
            
            <div class="map-card-stats">
                <div class="map-stat-row">
                    <span class="map-stat-label">Difficulté</span>
                    <span class="map-stat-value ${map.difficultyClass}">${map.difficulty}</span>
                </div>
                <div class="map-stat-row">
                    <span class="map-stat-label">Durée</span>
                    <span class="map-stat-value">${map.duration} min</span>
                </div>
                <div class="map-stat-row">
                    <span class="map-stat-label">Frais d'entrée</span>
                    <span class="map-stat-value" style="color: var(--tarkov-yellow);">${formatNumber(map.fee)} $</span>
                </div>
                <div class="map-stat-row">
                    <span class="map-stat-label">Niveau requis</span>
                    <span class="map-stat-value">${map.level}+</span>
                </div>
                <div class="map-stat-row">
                    <span class="map-stat-label">Extractions</span>
                    <span class="map-stat-value">${map.extractions}</span>
                </div>
            </div>
        </div>
    `).join('');
}

/**
 * Rendre le bouton de lancement du raid
 */
function renderStartRaidButton() {
    const container = document.getElementById('start-raid-button');
    if (!container) return;
    
    if (selectedMap) {
        container.innerHTML = `
            <button class="raid-btn" onclick="startRaid()" style="width: 100%; font-size: 20px; padding: 20px;">
                🛡️ LANCER LE RAID
            </button>
        `;
    } else {
        container.innerHTML = '';
    }
}

/**
 * Rendre le lobby
 */
function renderLobbyView() {
    const contentArea = document.getElementById('raid-content');
    const mapData = selectedMap ? maps[selectedMap] : null;
    
    contentArea.innerHTML = `
        <div class="lobby-container">
            <div class="lobby-icon" style="font-size: 120px;">🛡️</div>
            
            <h2 class="lobby-title">PRÉPARATION DU RAID</h2>
            <p style="color: var(--tarkov-text-secondary); font-size: 16px; margin-bottom: 40px;">
                Le raid va commencer dans quelques instants...
            </p>
            
            <div class="lobby-timer">
                <div class="lobby-timer-value">${lobbyTimer}</div>
                <div class="lobby-timer-label">Secondes restantes</div>
            </div>
            
            <div class="lobby-stats-grid">
                <div class="lobby-stat-card">
                    <div class="lobby-stat-icon" style="font-size: 40px;">⏱️</div>
                    <div class="lobby-stat-value">${mapData?.duration || 0} min</div>
                    <div class="lobby-stat-label">Durée du raid</div>
                </div>
                
                <div class="lobby-stat-card">
                    <div class="lobby-stat-icon" style="font-size: 40px;">📍</div>
                    <div class="lobby-stat-value">${mapData?.extractions || 0}</div>
                    <div class="lobby-stat-label">Points d'extraction</div>
                </div>
                
                <div class="lobby-stat-card">
                    <div class="lobby-stat-icon" style="font-size: 40px;">👥</div>
                    <div class="lobby-stat-value">${currentSquad?.members?.length || 0}</div>
                    <div class="lobby-stat-label">Membres du squad</div>
                </div>
                
                <div class="lobby-stat-card">
                    <div class="lobby-stat-icon" style="font-size: 40px;">💰</div>
                    <div class="lobby-stat-value">${formatNumber(mapData?.fee || 0)} $</div>
                    <div class="lobby-stat-label">Frais d'entrée</div>
                </div>
            </div>
        </div>
    `;
}

/**
 * Écouter les messages de FiveM
 */
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (!data || !data.type) return;
    
    console.log('[Raid UI] Message reçu:', data.type);
    
    switch(data.type) {
        case 'openRaidUI':
            document.body.style.display = 'block';
            currentView = 'menu';
            renderCurrentView();
            console.log('[Raid UI] UI ouverte');
            break;
            
        case 'closeRaidUI':
            document.body.style.display = 'none';
            if (lobbyInterval) {
                clearInterval(lobbyInterval);
                lobbyInterval = null;
            }
            console.log('[Raid UI] UI fermée');
            break;
            
        case 'updateSquad':
            currentSquad = data.data;
            console.log('[Raid UI] Squad mis à jour:', currentSquad);
            renderCurrentView();
            break;
            
        case 'updateNearbyPlayers':
            nearbyPlayers = data.data || [];
            console.log('[Raid UI] Joueurs proches:', nearbyPlayers.length);
            if (currentView === 'squad') {
                renderNearbyPlayers();
            }
            break;
            
        case 'startLobby':
            currentView = 'lobby';
            startLobbyTimer();
            renderLobbyView();
            console.log('[Raid UI] Lobby démarré');
            break;
    }
});

/**
 * Gestion des touches clavier
 */
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        closeUI();
    }
});

/**
 * Initialisation au chargement
 */
document.addEventListener('DOMContentLoaded', function() {
    console.log('[Raid UI] Interface chargée avec succès');
    
    // Cacher l'UI par défaut
    document.body.style.display = 'none';
    
    // Créer la structure HTML de base
    const container = document.createElement('div');
    container.className = 'raid-ui-container';
    container.innerHTML = `
        <div class="raid-ui-main">
            <div class="raid-ui-header">
                <div class="header-logo">
                    <div class="logo-icon">🛡️</div>
                    <div class="logo-title">
                        <h1>Tarkov Raid System</h1>
                        <p class="logo-subtitle">Escape From Tarkov</p>
                    </div>
                </div>
                <button class="header-close-btn" onclick="closeUI()">
                    ✕
                </button>
            </div>
            <div class="raid-ui-content" id="raid-content"></div>
        </div>
    `;
    
    const appContainer = document.getElementById('app-container');
    if (appContainer) {
        appContainer.appendChild(container);
    } else {
        document.body.appendChild(container);
    }
    
    // Rendre le menu initial
    renderMenuView();
    
    console.log('[Raid UI] Initialisation terminée');
});