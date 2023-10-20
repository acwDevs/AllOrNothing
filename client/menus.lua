local gameMaster = false

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

--Create menu called player menu
local hostMenu = Menu.new("Host Menu")

--Create player menu
local playerManageItem = hostMenu:AddItemMain("Player Management","Manage Players")
local playerMenu = Menu.new("Player Menu")
playerManageItem.Activated = function(sender, item)
    hostMenu.main:Visible(false)
    playerMenu.main:Visible(true)
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
end

--Set Game Master Status
RegisterNetEvent("setgamemasterclient")
AddEventHandler("setgamemasterclient", function(status)
    gameMaster = status
end)

local coords = Config.MarkerCoords
-- Update the menu pool
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        hostMenu.pool:ProcessMenus()
        playerMenu.pool:ProcessMenus()
        locationMenu.pool:ProcessMenus()
        weaponMenu.pool:ProcessMenus()
        --Press Q to open the menu
        if gameMaster == true then
            DrawText3D(coords.x, coords.y, coords.z + 0.2, "Press F to enter the Host Menu")
        end
        if IsControlJustPressed(0,49) and gameMaster == true then -- Q key
            playerMenu:ClearMain()          
            local players = GetConvar("playerIDs",tostring({}))
            local players = json.decode(players)
            local names = GetConvar("playerNames",tostring({}))
            local names = json.decode(names)
            if players and names then 
                for i, player in ipairs(players) do
                    local subMenu = playerMenu.pool:AddSubMenu(playerMenu.main, names[i],player,1)
                    subMenu = subMenu.SubMenu
                    local kick = NativeUI.CreateItem("Kick", "Kick the player from the game")
                    kick.Activated = function(sender, item)
                        TriggerServerEvent("kickplayerserverside", player)
                        subMenu:Visible(false)
                        subMenu = nil
                    end
                    subMenu:AddItem(kick)
                end
            end
            hostMenu.main:Visible(not hostMenu.main:Visible())
        end
    end
end)

--Create location menu 

