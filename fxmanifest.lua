fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Overdose'
description 'Round based 4v4 gamemode for FiveM'
version '1.0.0'

client_scripts {
    "src/UIMenu/elements/*.lua",
    "src/UIMenu/items/*.lua",
    "src/UIMenu/windows/*.lua",
    "src/UIMenu/panels/*.lua",
    "src/UIMenu/*.lua",
}

client_scripts {
    'Reloaded/src/NativeUI.lua',
    'Reloaded/src/NativeUIReloaded.lua',
    'client/*.lua'
}

server_scripts {
    'server/server.lua',
    'server/events.lua'
}

shared_scripts {
    'shared/*.lua'
}

contributor {
    'Dylan Malandain',
    'Parow',
    'Frazzle'
}

--Setup nui
ui_page 'Front-End/index.html'

files {
    'Front-End/index.html',
    'Front-End/*.js',
    'Front-End/*.css',
    'Front-End/UIKit/css/*.css',
    'Front-End/UIKit/js/*.js',
}

-- exclude file from encryption
escrow_ignore {
    'shared/convars.lua',
    'Reloaded/*.*',
    'MenuExample/*.*'
}