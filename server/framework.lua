local Framework = {}

local QBCore = nil

if Config.Framework == 'qb' then
  QBCore = exports['qb-core']:GetCoreObject()
end

local function containsDirectorKeyword(value)
  value = tostring(value or ''):lower()

  for _, keyword in ipairs(Config.DirectorKeywords) do
    if value:find(keyword, 1, true) then
      return true
    end
  end

  return false
end

function Framework.IsDirector(src)
  if Config.Framework == 'qb' and QBCore then
    local permission = QBCore.Functions.GetPermission(src)

    if type(permission) == 'string' then
      return containsDirectorKeyword(permission)
    end

    if type(permission) == 'table' then
      for group, enabled in pairs(permission) do
        if enabled and containsDirectorKeyword(group) then
          return true
        end
      end
    end

    local Player = QBCore.Functions.GetPlayer(src)
    local jobName = Player and Player.PlayerData and Player.PlayerData.job and Player.PlayerData.job.name
    local jobGrade = Player and Player.PlayerData and Player.PlayerData.job and Player.PlayerData.job.grade

    return containsDirectorKeyword(jobName) or containsDirectorKeyword(jobGrade and jobGrade.name)
  end

  return IsPlayerAceAllowed(src, 'mdi.tracker.director')
end

function Framework.GetLivePlayers()
  local players = {}

  if Config.Framework == 'qb' and QBCore then
    for _, src in pairs(QBCore.Functions.GetPlayers()) do
      local Player = QBCore.Functions.GetPlayer(src)

      if Player then
        local ped = GetPlayerPed(src)
        local coords = GetEntityCoords(ped)
        local charinfo = Player.PlayerData.charinfo or {}

        players[#players + 1] = {
          id = src,
          fivemName = GetPlayerName(src),
          firstname = charinfo.firstname or '',
          lastname = charinfo.lastname or '',
          citizenid = Player.PlayerData.citizenid or '',
          sourceplayer = Player.PlayerData.source or src,
          coords = {
            x = tonumber(string.format('%.2f', coords.x)),
            y = tonumber(string.format('%.2f', coords.y)),
            z = tonumber(string.format('%.2f', coords.z))
          },
          status = 'online'
        }
      end
    end
  else
    for _, src in ipairs(GetPlayers()) do
      local ped = GetPlayerPed(src)
      local coords = GetEntityCoords(ped)

      players[#players + 1] = {
        id = tonumber(src),
        fivemName = GetPlayerName(src),
        firstname = '',
        lastname = '',
        citizenid = '',
        sourceplayer = tonumber(src),
        coords = {
          x = tonumber(string.format('%.2f', coords.x)),
          y = tonumber(string.format('%.2f', coords.y)),
          z = tonumber(string.format('%.2f', coords.z))
        },
        status = 'online'
      }
    end
  end

  table.sort(players, function(a, b)
    return tonumber(a.id) < tonumber(b.id)
  end)

  return players
end

function Framework.RegisterCallback(name, cb)
  if Config.Framework == 'qb' and QBCore then
    QBCore.Functions.CreateCallback(name, cb)
    return
  end

  RegisterNetEvent(name, function(...)
    local src = source
    local requestId = ...
    local args = { select(2, ...) }

    cb(src, function(result)
      TriggerClientEvent(name .. ':response', src, requestId, result)
    end, table.unpack(args))
  end)
end

_G.MDITrackerFramework = Framework
