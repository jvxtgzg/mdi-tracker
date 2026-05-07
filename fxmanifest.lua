fx_version 'cerulean'
game 'gta5'

author 'MDI Systems'
description 'MDI Tracker - live player, character, and bans tracker for FiveM'
version '0.1.0'

lua54 'yes'

ui_page 'web/index.html'

shared_scripts {
  'shared/config.lua'
}

client_scripts {
  'client/tracker.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/framework.lua',
  'server/tracker.lua'
}

files {
  'web/index.html',
  'web/style.css',
  'web/app.js'
}
