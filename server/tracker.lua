local Framework = _G.MDITrackerFramework

local function denied()
  return {
    ok = false,
    error = 'no_permission'
  }
end

local function mapCharacterRow(row, map)
  return {
    id = row[map.idColumn],
    name = row[map.nameColumn],
    raw = row
  }
end

Framework.RegisterCallback('mdi:tracker:getLivePlayers', function(source, cb)
  if not Framework.IsDirector(source) then
    return cb(denied())
  end

  cb({
    ok = true,
    players = Framework.GetLivePlayers()
  })
end)

Framework.RegisterCallback('mdi:tracker:getCharacters', function(source, cb, framework)
  if not Framework.IsDirector(source) then
    return cb(denied())
  end

  framework = framework or Config.Framework
  local map = Config.FrameworkMap[framework]

  if not map then
    return cb({
      ok = false,
      error = 'unsupported_framework'
    })
  end

  local query = ('SELECT * FROM `%s` LIMIT ?'):format(map.charactersTable)
  local rows = MySQL.query.await(query, { Config.MaxCharacters }) or {}
  local data = {}

  for _, row in ipairs(rows) do
    data[#data + 1] = mapCharacterRow(row, map)
  end

  cb({
    ok = true,
    framework = framework,
    map = map,
    characters = data
  })
end)

Framework.RegisterCallback('mdi:tracker:getBans', function(source, cb)
  if not Framework.IsDirector(source) then
    return cb(denied())
  end

  local query = ('SELECT name, license, discord, ip, reason, expire, bannedby FROM `%s` ORDER BY expire DESC LIMIT ?'):format(Config.BansTable)
  local rows = MySQL.query.await(query, { Config.MaxBans }) or {}

  cb({
    ok = true,
    bans = rows
  })
end)

RegisterNetEvent('mdi:tracker:insertBan', function(payload)
  local src = source

  if not Framework.IsDirector(src) then
    return TriggerClientEvent('mdi:tracker:insertBanResult', src, denied())
  end

  payload = payload or {}

  local query = ('INSERT INTO `%s` (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)'):format(Config.BansTable)
  local inserted = MySQL.insert.await(query, {
    payload.name or '',
    payload.license or '',
    payload.discord or '',
    payload.ip or '',
    payload.reason or '',
    tonumber(payload.expire) or 0,
    payload.bannedby or GetPlayerName(src) or 'MDI Tracker'
  })

  TriggerClientEvent('mdi:tracker:insertBanResult', src, {
    ok = inserted ~= nil,
    id = inserted
  })
end)
