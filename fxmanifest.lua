-- Resource Metadata
fx_version 'cerulean'

games { 'gta5' }

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'config.lua', 
    'server.lua'
}

client_scripts { 
    '@mysql-async/lib/MySQL.lua',
    'config.lua', 
    'client.lua'
}

lua54 'yes'

escrow_ignore {
    'config.lua'
}