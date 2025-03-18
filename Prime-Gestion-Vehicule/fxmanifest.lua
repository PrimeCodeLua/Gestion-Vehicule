fx_version 'cerulean'
game 'gta5'

author 'Brad'
description 'Régulateur de vitesse par Brad'
version '1.0.0'

dependencies {
    'ox_lib',
}


client_scripts {
    '@ox_lib/init.lua',
    'client/main.lua',
    'client/menu.lua'
}

lua54 'yes'