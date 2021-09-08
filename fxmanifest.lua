fx_version 'cerulean'
games { 'gta5' }

author 'SzybkiRito'
description 'Your own group system'
version '1.0.0'

-- What to run
client_scripts {
    'client/client.lua',
    'client/corners.lua',
    'config.lua'
}

server_script {
    '@mysql-async/lib/MySQL.lua',
    'server/server.lua',
    'server/corners.lua',
    'config.lua'
}