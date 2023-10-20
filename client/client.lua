local coords = Config.MarkerCoords
local playerEntered = false
local inRound = false
local shootingState = true
local marker = nil

--AddBlip function
function AddBlip(coords, sprite, colour, text)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, colour)
    SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
end
AddBlip(coords, 1, 5, "All Or Nothing")

--Marker Thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if marker == nil then
            marker = DrawMarker(1, coords.x, coords.y, coords.z - 1, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 2.0, 255, 0, 0, 200, false, true, 2, false, nil, nil, false)
        end
        
        DrawMarker(1, coords.x, coords.y, coords.z - 1, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 2.0, 255, 0, 0, 200, false, true, 2, false, nil, nil, false)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if marker ~= nil then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - coords)
            if distance < 1.5 then
                local playerCount = GetConvarInt("AllOrNothingPC", 0)
                DrawText3D(coords.x, coords.y, coords.z + 1, playerCount.."/"..Config.MaxPlayers.." players")
                DrawText3D(coords.x, coords.y, coords.z, "Press E to enter the match")
                if IsControlJustPressed(0, 38) then -- E key
                    -- Do something when the player interacts with the marker
                    TriggerEvent("enterplayerclient")
                    print("Player entered the game")
                end
            end
        end
    end
end)

RegisterNetEvent("enterplayerclient")
AddEventHandler("enterplayerclient", function()
    if playerEntered == false then
        playerEntered = true
        TriggerServerEvent("enterplayerserver")
    end
end)

--revive player client
RegisterNetEvent("12312asd1242g1")
AddEventHandler("12312asd1242g1", function()
    print('Revive event')
    local playerPed = PlayerPedId()
    if IsEntityDead(playerPed) then
        SetEntityHealth(playerPed, 200)
        ClearPedBloodDamage(playerPed)
        ResetPedVisibleDamage(playerPed)
        ClearPedLastWeaponDamage(playerPed)
        ReviveEvent()
    else
        -- Player is alive
    end
end)

--set shooting state client
RegisterNetEvent("setShootingState")
AddEventHandler("setShootingState", function(state)
    local playerPed = PlayerPedId()
    shootingState = state;
    if shootingState == false then 
        Citizen.CreateThread(function()
            while shootingState == false do
                Citizen.Wait(0)
                DisablePlayerFiring(playerPed, true)
            end
        end)
    end
    if state == true then
        SetPlayerCanDoDriveBy(playerPed, false)
    else
        SetPlayerCanDoDriveBy(playerPed, true)
    end
end)

RegisterNetEvent("startRoundClient")
AddEventHandler("startRoundClient", function()
    print('Round started')
    inRound = true
    Citizen.CreateThread(function()
        local playerPed = PlayerPedId()
        while playerEntered == true and inRound == true do
            Citizen.Wait(100)
            if IsEntityDead(playerPed) then
                -- Player is dead
                TriggerServerEvent("playerkilledserver")
                break
            else
                -- Player is alive
            end
        end
    end)
end)

RegisterNetEvent("endRoundClient")
AddEventHandler("endRoundClient", function()
    inRound = false
end)

RegisterNetEvent("leaveplayerclient")
AddEventHandler("leaveplayerclient", function()
    playerEntered = false
end)

RegisterNetEvent("tooManyPlayersClientMessage")
AddEventHandler("tooManyPlayersClientMessage", function()
     TriggerEvent("chatMessage", "[Server]", {255, 0, 0}, "Max players met")
end)

RegisterNetEvent("playerEnteredGameMessage")
AddEventHandler("playerEnteredGameMessage", function()
    TriggerEvent("chatMessage", "[Server]", {255, 255, 255}, "You have entered the game.")
end)

RegisterNetEvent("countdown")
AddEventHandler("countdown", function(message)
    Citizen.CreateThread(function()
        --Draw text 2d in a 1 second loop using os time
        local start = GetGameTimer()
        local time = 0
        while time < 1000 do
            Citizen.Wait(0)
            DrawText2D(message,2.0,2.0,0.5,0.2)
            time = GetGameTimer() - start
        end
    end)
end)

function DrawText2D(text,sX,sY,x,y)
    SetTextFont(0)
    SetTextScale(sX, sY)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
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

RegisterCommand("getcoords", function()
    local test = GetEntityCoords(PlayerPedId())
    print("Coords set to: " .. test.x .. ", " .. test.y .. ", " .. test.z)
    --Trigger server event print coords
    TriggerServerEvent("printCoordsserverside", test.x, test.y, test.z)
end)

