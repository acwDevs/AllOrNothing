ReviveEvent = function()
    TriggerEvent('esx_ambulancejob:revive')
end
Config = {}
Config.MarkerCoords = vector3(2669.2, 4130.8, 44.4)
Config.MaxPlayers = 2
Config.FrameWork = "ESX" --ESX
Config.team1Name = "Team 1"
Config.team2Name = "Team 2"
Config.Locations = {
    {
        name = "Sandy Shores",
        team1 = {
            x = 3789.9,
            y = 4502.7,
            z = 7.03
        },
        team2 = {
            x = 3801.2,
            y = 4505.0,
            z = 6.3
        }
    },
    {
        name = "Paleto Bay",
        team1 = {
            x = 2656.0,
            y = 4146.0,
            z = 43.08
        },
        team2 = {
            x = 2660.35,
            y = 4162.29,
            z = 42.96
        }
    },
    {
        name = "Grapeseed",
        team1 = {
            x = 1884.2,
            y = 4574.6,
            z = 36.6
        },
        team2 = {
            x = 1899.7,
            y = 4574.8,
            z = 37.1
        }
    }
}
Config.WeaponList = {
    {
        name = "weapon_pistol",
        label = "Pistol"
    },
    {
        name = "weapon_pistol_mk2",
        label = "Pistol MK2"
    },
    {
        name = "weapon_pumpshotgun",
        label = "Pump Shotgun"
    },
    {
        name = "weapon_sniperrifle",
        label = "Sniper Rifle"
    },
    {
        name = "weapon_assaultrifle",
        label = "Assault Rifle"
    },
    {
        name = "weapon_smg",
        label = "SMG"
    },
    {
        name = "weapon_hatchet",
        label = "Hatchet"
    },
    {
        name = "weapon_switchblade",
        label = "Switchblade"
    },
    {
        name = "weapon_poolcue",
        label = "Pool Cue"
    },
    {
        name = "weapon_battleaxe",
        label = "Battle Axe"
    },
}
