Config = {}

Config.Framework = 'qb' -- qb, esx, nd, ox

Config.Command = 'mditracker'

Config.RefreshMs = 5000

Config.DirectorKeywords = {
  'director',
  'directror'
}

Config.FrameworkMap = {
  qb = {
    charactersTable = 'players',
    idColumn = 'citizenid',
    nameColumn = 'name'
  },
  esx = {
    charactersTable = 'users',
    idColumn = 'identifier',
    nameColumn = 'firstname'
  },
  nd = {
    charactersTable = 'characters',
    idColumn = 'character_id',
    nameColumn = 'firstname'
  },
  ox = {
    charactersTable = 'character_inventory',
    idColumn = 'charid',
    nameColumn = 'charid'
  }
}

Config.BansTable = 'bans'

Config.MaxCharacters = 250
Config.MaxBans = 250
