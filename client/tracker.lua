local QBCore = nil
local pendingCallbacks = {}
local requestCounter = 0
local trackerOpen = false

if Config.Framework == 'qb' then
  QBCore = exports['qb-core']:GetCoreObject()
end

local function triggerCallback(name, cb, ...)
  if QBCore then
    QBCore.Functions.TriggerCallback(name, cb, ...)
    return
  end

  requestCounter = requestCounter + 1
  pendingCallbacks[requestCounter] = cb
  TriggerServerEvent(name, requestCounter, ...)
end

local function requestTrackerData()
  triggerCallback('mdi:tracker:getLivePlayers', function(result)
    SendNUIMessage({
      action = 'tracker:setLivePlayers',
      data = result
    })
  end)

  triggerCallback('mdi:tracker:getCharacters', function(result)
    SendNUIMessage({
      action = 'tracker:setCharacters',
      data = result
    })
  end, Config.Framework)

  triggerCallback('mdi:tracker:getBans', function(result)
    SendNUIMessage({
      action = 'tracker:setBans',
      data = result
    })
  end)
end

local function openTracker()
  trackerOpen = true
  SetNuiFocus(true, true)
  SendNUIMessage({
    action = 'tracker:open',
    refreshMs = Config.RefreshMs,
    frameworkMap = Config.FrameworkMap
  })
  requestTrackerData()
end

local function closeTracker()
  trackerOpen = false
  SetNuiFocus(false, false)
  SendNUIMessage({
    action = 'tracker:close'
  })
end

RegisterCommand(Config.Command, function()
  openTracker()
end, false)

RegisterNUICallback('tracker:close', function(_, cb)
  closeTracker()
  cb({ ok = true })
end)

RegisterNUICallback('tracker:refresh', function(_, cb)
  requestTrackerData()
  cb({ ok = true })
end)

RegisterNUICallback('tracker:insertBan', function(data, cb)
  TriggerServerEvent('mdi:tracker:insertBan', data)
  cb({ ok = true })
end)

RegisterNetEvent('mdi:tracker:insertBanResult', function(result)
  SendNUIMessage({
    action = 'tracker:insertBanResult',
    data = result
  })
  requestTrackerData()
end)

RegisterNetEvent('mdi:tracker:getLivePlayers:response', function(requestId, result)
  if pendingCallbacks[requestId] then
    pendingCallbacks[requestId](result)
    pendingCallbacks[requestId] = nil
  end
end)

RegisterNetEvent('mdi:tracker:getCharacters:response', function(requestId, result)
  if pendingCallbacks[requestId] then
    pendingCallbacks[requestId](result)
    pendingCallbacks[requestId] = nil
  end
end)

RegisterNetEvent('mdi:tracker:getBans:response', function(requestId, result)
  if pendingCallbacks[requestId] then
    pendingCallbacks[requestId](result)
    pendingCallbacks[requestId] = nil
  end
end)

CreateThread(function()
  while true do
    if trackerOpen then
      requestTrackerData()
      Wait(Config.RefreshMs)
    else
      Wait(1000)
    end
  end
end)
