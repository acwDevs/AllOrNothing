--Game is defined as a 4v4 round based survival game. The game will start when 8 players join the game. 
--The round will end when one team has killed the entire other team.
--The game will end when one team has won 3 rounds.

--Spawn a ped at the config marker location
local ped = CreatePed(4, 0x9E08633D, Config.MarkerCoords.x, Config.MarkerCoords.y, Config.MarkerCoords.z, 0.0, false, true)
FreezeEntityPosition(ped, true)
--Establish Convars
SetConvarReplicated("AllOrNothingMatchPed",json.encode(NetworkGetNetworkIdFromEntity(ped)))
SetConvarReplicated("AllOrNothingPC", "0")
SetConvarReplicated("playerIDs", "")
SetConvarReplicated("playerNames", "")
SetConvarReplicated("AllOrNothingTeam1", json.encode({}))
SetConvarReplicated("AllOrNothingTeam2", json.encode({}))
--Active Weapons
local WeaponPool = {}
for i, weapons in ipairs(Config.WeaponList) do
    local temp = {weapons.name, false}
    table.insert(WeaponPool, temp)
end
--Active Locations
local LocationPool = {}
for i, location in ipairs(Config.Locations) do
    local temp = {location, false}
    table.insert(LocationPool, temp)
end

function merge(t1, t2)
    for k, v in pairs(t2) do
        if (type(v) == "table") and (type(t1[k] or false) == "table") then
            merge(t1[k], t2[k])
        else
            t1[k] = v
        end
    end
    return t1
end

--Import json into lua
local json = require "json"
--Setup Framework
if Config.FrameWork == "ESX" then
    ESX = nil
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end
-- Define the Game class
local Game = {}
Game.__index = Game

-- Constructor function for Game class
function Game.new()
    local self = setmetatable({}, Game)
    self.gameBlip = AddBlipForCoord(Config.MarkerCoords.x, Config.MarkerCoords.y, Config.MarkerCoords.z)
    self.team1Name = Config.team1Name
    self.team2Name = Config.team2Name
    self.team1Lives = 0
    self.team2Lives = 0
    self.team1Score = 0
    self.team2Score = 0
    self.playerCount = 0
    self.maxPlayers = Config.MaxPlayers
    self.players = {}
    self.names = {}
    self.team1Names = {}
    self.team2Names = {}
    self.gameMaster = 0
    self.team1players = {}
    self.team2players = {}
    self.activeWeapons = Config.WeaponList[1]
    self.currentWeapon = ''
    self.activeLocations = Config.Locations[1]
    self.locations = Config.Locations
    self.currentLocation = Config.MarkerCoords
    return self
end

-- Method to get the number of lives for a given team
function Game:getLives(teamName)
    if teamName == self.team1Name then
        return self.team1Lives
    elseif teamName == self.team2Name then
        return self.team2Lives
    else
        error("Invalid team name")
    end
end

-- Method to decrement the number of lives for a given team
function Game:decrementLives(teamName)
    if teamName == self.team1Name then
        self.team1Lives = self.team1Lives - 1
    elseif teamName == self.team2Name then
        self.team2Lives = self.team2Lives - 1
    else
        error("Invalid team name")
    end
end


-- Method to add a player to the game
function Game:addPlayer(player)
    table.insert(self.players, player)
    if self.playerCount == 0 then 
        table.insert(self.team1players, player)
        self.playerCount = self.playerCount + 1
        self.team1Lives = self.team1Lives + 1
        --Trigger client set game master
        TriggerClientEvent("setgamemasterclient", player, true)
        self.gameMaster = player
    elseif self.playerCount < (self.maxPlayers / 2)then
        self.playerCount = self.playerCount + 1
        table.insert(self.team1players, player)
        self.team1Lives = self.team1Lives + 1
        --Trigger client set player
        TriggerClientEvent("setplayerclient", player, true)
    elseif self.playerCount < self.maxPlayers then
        self.playerCount = self.playerCount + 1
        table.insert(self.team2players, player)
        self.team2Lives = self.team2Lives + 1
        TriggerClientEvent("setplayerclient", player, true)
    else
        TriggerClientEvent("tooManyPlayersClientMessage", player)
    end
    -- print(json.encode(self.players))
    --Get player names from esx 
    local names = {}
    for i, player in ipairs(self.players) do
        TriggerClientEvent("playerEnteredGameMessage", player)
        local xPlayer = ESX.GetPlayerFromId(player)
        table.insert(names, xPlayer.name)
        -- print(xPlayer.name)
    end
    self.names = names
    -- Get names of team1
    local team1Names = {}
    for i, player in ipairs(self.team1players) do
        local xPlayer = ESX.GetPlayerFromId(player)
        table.insert(team1Names, xPlayer.name)
    end
    self.team1Names = team1Names
    -- Get names of team2
    local team2Names = {}
    for i, player in ipairs(self.team2players) do
        local xPlayer = ESX.GetPlayerFromId(player)
        table.insert(team2Names, xPlayer.name)
    end
    self.team2Names = team2Names
    SetConvarReplicated("AllOrNothingTeam1", json.encode(team1Names))
    SetConvarReplicated("AllOrNothingTeam2", json.encode(team2Names))
    SetConvarReplicated("AllOrNothingPC", tostring(self.playerCount))
    SetConvarReplicated("playerIDs", json.encode(self.players))
    SetConvarReplicated("playerNames", json.encode(self.names))
    -- for k,v in ipairs(self.names) do print(k,v) end
    for i, player in ipairs(self.players) do
        TriggerClientEvent("getTeamPlayerListClient", player)
    end
    -- if self.playerCount == self.maxPlayers then
    --     self:startGame()
    -- end
end
-- Define the startGame method
function Game:startGame()
    print(self.team1Lives, self.team2Lives)
    if self.team1Lives < 1 or self.team2Lives < 1 then
        return
    end
    for i, player in ipairs(self.players) do
        RemoveAllPedWeapons(player, true)
    end
    --GetActiveWeaponsList
    while self.team1Score < 3 and self.team2Score < 3 do
        Citizen.Wait(0)
        self:roundStart()
        while self.team1Lives > 0 and self.team2Lives > 0 do
            Citizen.Wait(1000)
        end
        if self.team1Lives <= 0 then
            self.team2Score = self.team2Score + 1
        end
        if self.team2Lives <= 0 then
            self.team1Score = self.team1Score + 1
        end
        if self.team1Lives <= 0 or self.team2Lives <= 0 then
            self.team1Lives = #self.team1players
            self.team2Lives = #self.team2players
            self:roundEnd()
        end
    end
    if self.team1Score == 3 then
        self:winMessage(self.team1Name)
    end
    if self.team2Score == 3 then
        self:winMessage(self.team2Name)
    end
    self:endGame()
end
-- Define the endGame method
function Game:endGame()
    --Teleport all players to config marker coords
    self.currentLocation = Config.MarkerCoords
    for i, player in ipairs(self.players) do
        self:teleportPlayer(player, self.currentLocation.x, self.currentLocation.y, self.currentLocation.z)
    end
    TriggerClientEvent('setgamemasterclient', self.gameMaster, false)
    self:removePlayers()
    self.team1Lives = 0
    self.team2Lives = 0
    self.team1Score = 0
    self.team2Score = 0
    self.playerCount = 0
    self.team1players = {}
    self.team2players = {}
    self.players = {}
    self.names = {}
    self.activeWeapons = {}
    self.activeLocations = {}
    self.gameMaster = 0
    self.currentWeapon = ''
    SetConvarReplicated("AllOrNothingPC", tostring(0))
    SetConvarReplicated("playerNames", tostring({}))  
end

-- Define the winMessage method
function Game:winMessage(teamName)
    local clr = ''
    if teamName == self.team1Name then
        clr = '~b~'
    end
    if teamName == self.team2Name then
        clr = '~r~'
    end
    for i, player in ipairs(self.players) do
        TriggerClientEvent("countdown", player, clr .. teamName .. ' wins!')
    end
end

-- Define roundStart method
function Game:roundStart()
    for i, weapon in ipairs(WeaponPool) do
        if weapon[2] == true then
            table.insert(self.activeWeapons, weapon[1])
            print(weapon[1], i)
        end
    end
    --GetActiveLocationsList
    for i, location in ipairs(LocationPool) do
        if location[2] == true then
            table.insert(self.activeLocations, location[1])
        end
    end
    self.currentWeapon = self.activeWeapons[math.random(#self.activeWeapons)]
    if self.currentWeapon == nil then
        self.currentWeapon = Config.WeaponList[1].name
    end
    self.currentLocation = self.activeLocations[math.random(#self.activeLocations)]
    if self.currentLocation == nil then
        self.currentLocation = Config.Locations[1]
    end
    print(self.currentLocation.name)
    self:teleportPlayers()
    self:freezePlayers()
    self:countdown()
    for i, player in ipairs(self.players) do
        TriggerClientEvent("setShootingState", player,true)
    end
    for i, player in ipairs(self.players) do
        self.currenWeapon = self.currentWeapon.name
        self:giveWeaponToPlayer(player, self.currentWeapon)
    end
    self:unfreezePlayers()
    for i, player in ipairs(self.players) do
        TriggerClientEvent("startRoundClient", player)
    end
end

function Game:giveWeaponToPlayer(player, weaponName)
    -- Give the player the weapon
    print(weaponName)
    GiveWeaponToPed(player, GetHashKey(weaponName), 100, false, true)
end

function Game:removeWeaponFromPlayer(player, weaponName)
    -- Remove the weapon from the player
    RemoveWeaponFromPed(player, GetHashKey(weaponName))
end

-- Define the roundEnd method
function Game:roundEnd()
    --wait 3 seconds using game time
    local start = GetGameTimer()
    local time = 0
    while time < 3000 do
        Citizen.Wait(0)
        time = GetGameTimer() - start
    end
    for i, player in ipairs(self.players) do
        print(self.currentWeapon,'end')
        self:removeWeaponFromPlayer(player, self.currentWeapon)
    end
    print("Round ended")
    self:revivePlayers()
    --wait 1 seconds using game time
    local start = GetGameTimer()
    local time = 0
    while time < 1000 do
        Citizen.Wait(0)
        time = GetGameTimer() - start
    end
    for i, player in ipairs(self.players) do
        TriggerClientEvent("endRoundClient", player)
    end
end

--Revive player
function Game:revivePlayer(player)
    TriggerClientEvent("12312asd1242g1", player)
end

--Revive all players
function Game:revivePlayers()
    for i, player in ipairs(self.players) do
        self:revivePlayer(player)
    end
end



-- Define the countdown function
function Game:countdown()
    local count = 3 -- Set the starting count
    local clrs = {'~g~', '~y~', '~y~', '~r~'}
    while count > 0 do -- Loop until count reaches 0
        for i, player in ipairs(self.players) do
            TriggerClientEvent("countdown", player, clrs[count + 1]..count) -- Send the current count to all clients
        end
        count = count - 1 -- Decrement the count
        Citizen.Wait(1000) -- Wait for 1 second
    end
    for i, player in ipairs(self.players) do
        TriggerClientEvent("countdown", player, clrs[1].."GO!") -- Send "GO!" to all clients
    end
end
-- Method to teleport a player to a given location
function Game:teleportPlayer(player, x, y, z)
    SetEntityCoords(player, x, y, z-1, false, false, false, false)
end
-- Set Entity Freeze State to freeze
function Game:toggleFreeze(player)
    FreezeEntityPosition(player, 1)
    --Call client event that stops all players from shooting
    for i, player in ipairs(self.players) do
        TriggerClientEvent("setShootingState", player,false)
    end

end
-- Set Entity Freeze State to unfreeze
function Game:toggleUnFreeze(player)
    FreezeEntityPosition(player, 0)
end
-- Teloport players to their spawn points
function Game:teleportPlayers()
    for i, player in ipairs(self.team1players) do
        self:teleportPlayer(player, self.currentLocation.team1.x, self.currentLocation.team1.y + i, self.currentLocation.team1.z)
    end
    for i, player in ipairs(self.team2players) do
        self:teleportPlayer(player, self.currentLocation.team2.x, self.currentLocation.team2.y + i, self.currentLocation.team2.z)
    end
end
-- Freeze players
function Game:freezePlayers()
    for i, player in ipairs(self.players) do
        self:toggleFreeze(player)
    end
end
-- Unfreeze players
function Game:unfreezePlayers()
    for i, player in ipairs(self.players) do
        self:toggleUnFreeze(player)
    end
end

function Game:removePlayers() 
    for i, player in ipairs(self.players) do
        TriggerClientEvent("leaveplayerclient", player)
    end
    self.players = {}
end

function Game:removePlayer(remove) 
    for i, player in ipairs(self.players) do
        if player == remove then
            table.remove(self.players, i)
            table.remove(self.names, i)
            local team = self:isPlayerOnTeam(player)
            if team == self.team1Name then
                for i, team1player in ipairs(self.team1players) do
                    if team1player == player then
                        table.remove(self.team1players, i)
                        table.remove(self.team1Names, i)
                        self.team1Lives = self.team1Lives - 1
                        break
                    end
                end
            end
            if team == self.team2Name then
                for i, team2player in ipairs(self.team2players) do
                    if team2player == player then
                        table.remove(self.team2players, i)
                        table.remove(self.team2Names, i)
                        self.team2Lives = self.team2Lives - 1
                        break
                    end
                end
            end
            TriggerClientEvent("leaveplayerclient", player)
            TriggerClientEvent("setplayerclient", player, false)
            self.playerCount = self.playerCount - 1
            SetConvarReplicated("AllOrNothingPC", tostring(self.playerCount))
            SetConvarReplicated("playerIDs", json.encode(self.players))
            SetConvarReplicated("playerNames", json.encode(self.names))
        end
    end
end

-- Add a method to check if a player is on team one or two
function Game:isPlayerOnTeam(player)
    for i, team1player in ipairs(self.team1players) do
        if team1player == player then
            return self.team1Name -- Player is on team one
        end
    end
    for i, team2player in ipairs(self.team2players) do
        if team2player == player then
            return self.team2Name -- Player is on team two
        end
    end
    return 0 -- Player is not on either team
end

function Game:changeTeam(player, newTeam)
    local oldTeam = self:isPlayerOnTeam(player)
    print(oldTeam, newTeam)
    if oldTeam == newTeam then
        print('Same team')
        -- Player is already on the new team, do nothing
        return
    end
    if oldTeam ~= 0 then
        print('Different team')
        -- Remove player from old team
        if oldTeam == self.team1Name then
            for i, team1player in ipairs(self.team1players) do
                if team1player == player then
                    table.remove(self.team1players, i)
                    table.remove(self.team1Names, i)
                    local xPlayer = ESX.GetPlayerFromId(player)
                    table.insert(self.team2Names, xPlayer.name)
                    self.team1Lives = self.team1Lives - 1
                    break
                end
            end
        end
        if oldTeam == self.team2Name then
            for i, team2player in ipairs(self.team2players) do
                if team2player == player then
                    table.remove(self.team2players, i)
                    table.remove(self.team2Names, i)
                    local xPlayer = ESX.GetPlayerFromId(player)
                    table.insert(self.team1Names, xPlayer.name)
                    self.team2Lives = self.team2Lives - 1
                    break
                end
            end
        end
        SetConvarReplicated("AllOrNothingTeam2", json.encode(self.team2Names))
        SetConvarReplicated("AllOrNothingTeam1", json.encode(self.team1Names))
        for i, player in ipairs(self.players) do
            TriggerClientEvent("getTeamPlayerListClient", player)
        end
    end
    -- Add player to new team
    if newTeam == self.team1Name then
        table.insert(self.team1players, player)
    elseif newTeam == self.team2Name then
        table.insert(self.team2players, player)
    end
end

local game = Game.new("Team 1", "Team 2", 0.0, 0.0)

-- OnResourceStop
AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        DeleteEntity(ped)
    end
end)

--Change team server
RegisterServerEvent('changeteamserver')
-- Define the event handler function
AddEventHandler('changeteamserver', function(newTeam)
    local player = source
    game:changeTeam(player, newTeam)
end)

--Start game event
RegisterServerEvent('startgame')
-- Define the event handler function
AddEventHandler('startgame', function()
    game:startGame()
end)

--End game event
RegisterServerEvent('endgameserverside')
-- Define the event handler function
AddEventHandler('endgameserverside', function()
    game:endGame()
end)

-- Register the 'enterplayerserver' event
RegisterServerEvent('enterplayerserver')
-- Define the event handler function
AddEventHandler('enterplayerserver', function()
    local player = source
    game:addPlayer(player)
end)

-- Register the 'leaveplayerserver' event
RegisterServerEvent('leaveplayerserver')
-- Define the event handler function
AddEventHandler('leaveplayerserver', function(player)
    TriggerClientEvent("leaveplayerclient", player)
end)

-- Register the 'playerkilledserver' event
RegisterServerEvent('playerkilledserver')
-- Define the event handler function
AddEventHandler('playerkilledserver', function(player)
    local player = source
    local playerTeam = game:isPlayerOnTeam(player)
    game:decrementLives(playerTeam)
end)

-- Print coords event
RegisterServerEvent('printCoordsserverside')
-- Define the event handler function
AddEventHandler('printCoordsserverside', function(x,y,z)
    print(x,y,z)
end)

-- Kick player event
RegisterServerEvent('kickplayerserverside')
-- Define the event handler function
AddEventHandler('kickplayerserverside', function(player)
    game:removePlayer(player)
end)

-- Set weapon event
RegisterServerEvent('setweapon')
-- Define the event handler function
AddEventHandler('setweapon', function(weaponName, state)
    for i, weapon in ipairs(WeaponPool) do
        if weapon[1] == weaponName then
            weapon[2] = state
        end
    end
end)

-- Set location event
RegisterServerEvent('setlocation')
-- Define the event handler function
AddEventHandler('setlocation', function(locationName,state)
    print('here')
    for i, location in ipairs(LocationPool) do
        if location[1].name == locationName then
            location[2] = state
        end
    end
end)