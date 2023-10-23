local gameMaster = false
local player = false

--Set focus state.
local focused = false
function setFocus(bool)
    focused = bool
    SetNuiFocus(bool,bool)
end

function GetResolution()
    local W, H = GetActiveScreenResolution()
    if (W/H) > 3.5 then
        return GetScreenResolution()
    else
        return W, H
    end
end


function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local scale = 0.45
    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.045 + factor, 0.03, 41, 11, 41, 100)
    end
end

local x,y = GetResolution()
-- Define the Game class
local Menu = {}
Menu.__index = Menu

function Menu.new(title,sub)
    local self = setmetatable({}, Menu)
    self.title = title
    self.pool = NativeUI.CreatePool()
    self.main = NativeUI.CreateMenu(title, sub,x/2.5,y/15)
    self.pool:Add(self.main)
    return self
end


function Menu:AddItemMain(title,sub)
    local item = NativeUI.CreateItem(title, sub)
    self.main:AddItem(item)
    return item
end
--Replace Main
function Menu:ClearMain()
    self.main:Clear()
    self.pool:Add(self.main)
    return self.main
end
--Set Main
function Menu:SetMain(title,sub)
    self.main = NativeUI.CreateMenu(title, sub,x/2.5,y/15)
    self.pool:Add(self.main)
    return self.main
end

--Create host menu
local hostMenu = Menu.new("Host Menu", "Manage Game")

--Create player menu
local playerManageItem = hostMenu:AddItemMain("Player Management","Manage Players")
local playerManageMenu = Menu.new("Player Menu")
playerManageItem.Activated = function(sender, item)
    hostMenu.main:Visible(false)
    playerManageMenu.main:Visible(true)
end
--Create location menu
local locationManageItem = hostMenu:AddItemMain("Location Management","Manage Locations")
local locationMenu = Menu.new("Location Menu")
locationManageItem.Activated = function(sender, item)
    hostMenu.main:Visible(false)
    locationMenu.main:Visible(true)
end
--Populate location menu
for i, location in ipairs(Config.Locations) do
    local locationItem = UIMenuCheckboxItem.New(location.name, false, "Select this location")
    locationMenu.main:AddItem(locationItem)
    locationItem.CheckboxEvent = function(sender, item)
        TriggerServerEvent("setlocation", location.name, locationItem.Checked)
    end
end
--Create Weapon menu
local weaponManageItem = hostMenu:AddItemMain("Weapon Management","Manage Weapons")
local weaponMenu = Menu.new("Weapon Menu")
weaponManageItem.Activated = function(sender, item)
    hostMenu.main:Visible(false)
    weaponMenu.main:Visible(true)
end
--Populate weapon menu
for i, weapon in ipairs(Config.WeaponList) do
    local weaponItem = UIMenuCheckboxItem.New(weapon.label, false, "Select this weapon")
    weaponMenu.main:AddItem(weaponItem)
    weaponItem.CheckboxEvent = function()
        TriggerServerEvent("setweapon", weapon.name, weaponItem.Checked)
    end
end
--Create start game menu
local startGameItem = hostMenu:AddItemMain("Start Game","Start Game")
startGameItem.Activated = function(sender, item)
    TriggerServerEvent("startgame")
    hostMenu.main:Visible(false)
end

--Create player menu
local playerMenu = Menu.new("Player Menu", "Change Teams/Leave Game")
local team1  = playerMenu.pool:AddSubMenu(playerMenu.main, Config.team1Name,'Description', 1, 1)
team1 = team1.SubMenu
local team2  = playerMenu.pool:AddSubMenu(playerMenu.main, Config.team2Name,'Description', 1, 1)
team2 = team2.SubMenu
local leaveGameItem = playerMenu:AddItemMain("Leave Game","Leave Game")
leaveGameItem.Activated = function(sender, item)
    print(GetPlayerServerId(PlayerId()))
    TriggerServerEvent("kickplayerserverside", GetPlayerServerId(PlayerId()))
    playerMenu.main:Visible(false)
end

--Set Game Master Status
RegisterNetEvent("setgamemasterclient")
AddEventHandler("setgamemasterclient", function(status)
    gameMaster = status
end)

--Set Player Master Status
RegisterNetEvent("setplayerclient")
AddEventHandler("setplayerclient", function(status)
    player = status
end)

--Get Team Player List Client
RegisterNetEvent("getTeamPlayerListClient")
AddEventHandler("getTeamPlayerListClient", function(teamOne, teamTwo)
    print('here')
    SendNUIMessage({
        type = "teamListUpdate"
    })
end)

local coords = Config.MarkerCoords
-- Update the menu pool
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        --Press F to open the menu
        if IsControlJustPressed(0,49) then -- F key
            if gameMaster == true then
                focused = not focused
                print(focused)
                SetNuiFocus(focused, focused)
                SendNUIMessage({
                    type = "hostMenu",
                    focus = focused
                })
            end
            if player == true then
                focused = not focused
                print(focused)
                SetNuiFocus(focused, focused)
                SendNUIMessage({
                    type = "playerMenu",
                    focus = focused
                })
            end
        end
    end
end)

-- Game master thread
Citizen.CreateThread(function()
    local inRange = false
    local playerPed = GetPlayerPed(-1)
    local locationCoords = Config.MarkerCoords
    while true do
        Citizen.Wait(200)
        -- Check if the player is close enough to the location
        local playerCoords = GetEntityCoords(playerPed)
        local distance = GetDistanceBetweenCoords(playerCoords, Config.MarkerCoords, true)
            if distance  < 5.0 then

                inRange = true
                if gameMaster == true then
                    while gameMaster == true and inRange == true do
                        Citizen.Wait(0)
                        -- Define the location's coordinates
                        playerCoords = GetEntityCoords(playerPed)
                        distance = GetDistanceBetweenCoords(playerCoords, Config.MarkerCoords, true)
                        if distance < 5.0 then
                            -- Player is close enough, do something
                            DrawText3D(coords.x, coords.y, coords.z + 0.2, "Press F to enter the Host Menu")
                        else
                            inRange = false
                            -- Player is too far away
                        end
                    end
                end
                if player == true then 
                    local wait = 100
                    while player == true and inRange == true do
                        Citizen.Wait(0)
                        -- Define the location's coordinates
                        playerCoords = GetEntityCoords(playerPed)
                        distance = GetDistanceBetweenCoords(playerCoords, Config.MarkerCoords, true)
                        if distance < 5.0 then
                            wait = 0
                            -- Player is close enough, do something
                            DrawText3D(coords.x, coords.y, coords.z + 0.2, "Press F to enter the Player Menu")
                        else
                            wait = 100
                            inRange = false
                            -- Player is too far away
                        end
                    end
                end
            end
    end
end)

-- RegisterNUICallback('test', function(data, cb)
--     print("test")
-- end)

--RegisterNUICallback setFocus
RegisterNUICallback('setFocus', function(data, cb)
    setFocus(data.focus)
    cb({})
end)

--RegisterNUICallback changeTeam
RegisterNUICallback('switchTeam', function(data, cb)
    TriggerServerEvent("changeteamserver",GetPlayerServerId(PlayerId()))
    cb({})
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if(IsControlJustPressed(0,256))then
            focused = not focused
            print(focused)
            SetNuiFocus(focused, focused)
            SendNUIMessage({
                type = "hostMenu",
                focus = focused
            })
        end
    end
end)




--RegisterNUICallback getPlayerList
RegisterNUICallback('getPlayerList', function(data, cb)
    local players = GetConvar("playerIDs",tostring({}))
    local players = json.decode(players)
    local names = GetConvar("playerNames",tostring({}))
    local names = json.decode(names)
    if players and names then 
        cb({players = players, names = names})
    end
end)

--RegisterNUICallback getLocationList
RegisterNUICallback('getLocationList', function(data, cb)
    local names = {}
    for i, location in ipairs(Config.Locations) do
        table.insert(names, location.name)
        print(location.name)
    end

        cb({locations = names})
end)

--RegisterNUICallback getWeaponList
RegisterNUICallback('getWeaponList', function(data, cb)
    local names = {}
    for i, weapon in ipairs(Config.WeaponList) do
        table.insert(names, weapon.label)
        print(weapon.label)
    end

        cb({weapons = names})
end)

--RegisterNUICallback getTeamPlayerList
RegisterNUICallback('getTeamsPlayerList', function(data, cb)
    local team1Names = GetConvar("AllOrNothingTeam1",tostring({}))
    local team1Names = json.decode(team1Names)
    local team2Names = GetConvar("AllOrNothingTeam2",tostring({}))
    local team2Names = json.decode(team2Names)
    if team1Names and team2Names then 
        cb({teamOne = team1Names, teamTwo = team2Names})
    end
end)

--RegisterNUICallback kickPlayer
RegisterNUICallback('kickPlayer', function(data, cb)

    if GetPlayerFromServerId(data.id) == NetworkGetPlayerIndexFromPed(GetPlayerPed(-1)) then
        gameMaster = false
        TriggerServerEvent("endgameserverside")
    end
    TriggerServerEvent("kickplayerserverside", data.id)
    cb({})
end)

--RegisterNUICallback setWeapon
RegisterNUICallback('setWeapon', function(data, cb)
    for i, weapon in ipairs(Config.WeaponList) do
        if weapon.label == data.weaponName then
            TriggerServerEvent("setweapon", weapon.name, data.checked)
        end
    end
    cb({})
end)

--RegisterNUICallback setLocation
RegisterNUICallback('setLocation', function(data, cb)
    TriggerServerEvent("setlocation", data.locationName, data.checked)
    cb({})
end)

--RegisterNUICallback startGame
RegisterNUICallback('startGame', function(data, cb)
    TriggerServerEvent("startgame")
    cb({started = true})
end)

