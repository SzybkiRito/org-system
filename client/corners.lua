--[[
    Made by SzybkiRito#4211
]]

-- ESX
ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)
--END ESX

local corners = {}
local peds = {
  'g_m_y_mexgoon_01',
  'g_m_m_casrn_01',
  'g_m_y_ballaeast_01'
}


AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end

    ESX = nil
    Citizen.CreateThread(function()
	    while ESX == nil do
		    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		    Citizen.Wait(0)
	    end
    end)

    Citizen.Wait(1000)

    ESX.TriggerServerCallback('newstate_corners:getMarkers', function(result)
        corners = result
    end)

    print('==> Generating markers for corners...')
end)

AddEventHandler('skinchanger:loadSkin', function(character)
	playerGender = character.sex
	karnacja = character.skin
end)

Citizen.CreateThread(function() 
  while true do 
    Citizen.Wait(60000)
    ESX.TriggerServerCallback('newstate_corners:getMarkers', function(result)
      corners = result
    end) 
  end
end)

Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(0)

      if Config.GroupName ~= nil then
        for k,v in ipairs(corners) do
          local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
          local distance = Vdist(x, y, z, tonumber(v.x), tonumber(v.y), tonumber(v.z))

          if distance < 10 then
            DrawMarker(27, tonumber(v.x), tonumber(v.y), tonumber(v.z)-0.95, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 217, 219, 61, 100, false, true, 2, true, false, false, false)
          end

          if distance < 1.2 then
            SetTextComponentFormat('STRING')
            AddTextComponentString('Kliknij ~INPUT_PICKUP~ aby rozpocząć sprzedaż narkotyków')
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)
			      if IsControlJustPressed(1, 38) then
				      startSelling()
			      end
          end
        end
      end

    end
end)

function startSelling()
  local cooldown = false
  local chances = math.random(1, 10)

  exports['ns_notify']:send('fas fa-capsules', 'success', 'Rozpocząłeś sprzedaż narkotyków', 'top-right', 2000)

  if cooldown == false then
    if chances >= 1 and chances <= 10 then
      TriggerEvent('newstate_corners:sellDrugs')
      cooldown = true
      Citizen.Wait(40000)
      cooldown = false
    elseif chances == 11 or chances == 12 then
      TriggerEvent('newstate_corners:cancelSelling')
      cooldown = true
      Citizen.Wait(40000)
      cooldown = false
    elseif chances >= 13 and chances <= 15 then
      TriggerEvent('newstate_corners:callingPD')
      cooldown = true
      Citizen.Wait(40000)
      cooldown = false
    end
  else
    exports['ns_notify']:send('fas fa-capsules', 'success', 'Odczekaj chwile przed następnym klientem', 'top-right', 2000)
  end


end 

function sellingAnimation(ped) 
  local player = GetPlayerPed(-1)
  local playerCoords = GetEntityCoords(player)

    local ground = GetGroundZFor_3dCoord(playerCoords.x, playerCoords.y, playerCoords.z, 0)
    local createPed = CreatePed(26, ped, playerCoords.x + 5.0, playerCoords.y + 3.0, playerCoords.z + 1.25, 50.0, false)
    PlaceObjectOnGroundProperly(createPed)
    SetEntityAsMissionEntity(createPed)
    SetBlockingOfNonTemporaryEvents(createPed, true)
    SetPedKeepTask(createPed, true)
    TaskGoToEntity(createPed, player, -1, 1.5, 1.0, 1073741824.0, 0)
    SetPedKeepTask(createPed, true)

    local o = 0
    local whil = true

    while whil do
        Citizen.Wait(1000)
        local playerCoords2 = GetEntityCoords(GetPlayerPed(-1))
        local pedCoords = GetEntityCoords(createPed)
        local pedHealth = GetEntityHealth(createPed)
        local odlegosc = Vdist(pedCoords.x, pedCoords.y, pedCoords.z, playerCoords2.x, playerCoords2.y, playerCoords2.z)
        o = o + 1
        if odlegosc <= 1.5 or o >= 100 or pedHealth < 100 then 
            whil = false
        end
    end

    local pedHeading = GetEntityHeading(createPed)

    if o >= 100 then
       -- TriggerEvent('pNotify:SendNotification', {text = 'Klient anulował zamówienie w ostatniej chwili, skontakuj się z kolejnym klientem.'})
        exports['ns_notify']:send('fas fa-capsules', 'error', 'Klient nie zjawił się na miejsce spotkania', 'top-right', 2000)
        TaskWanderStandard(createPed, 10.0, 10)
        SetPedAsNoLongerNeeded(createPed)
    else
        SetEntityHeading(player, pedHeading - 180.0)
        RequestAnimDict('mp_common')
        while not HasAnimDictLoaded('mp_common') do
            Citizen.Wait(10)
        end
        local playerPed = PlayerPedId()
        local playerBone = GetPedBoneIndex(playerPed, 57005)
        local pedBone = GetPedBoneIndex(createPed, 57005)
        local prop1 = CreateObject(GetHashKey('prop_weed_bottle'), 0, 0, 0, true)
        local prop2 = CreateObject(GetHashKey('hei_prop_heist_cash_pile'), 0, 0, 0, true)
        AttachEntityToEntity(prop1, playerPed, playerBone, 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
        AttachEntityToEntity(prop2, createPed, pedBone, 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
        TaskPlayAnim(player, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 0, 0, false, false, false)
        TaskPlayAnim(createPed, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 0, 0, false, false, false)
        Citizen.Wait(1550)
        DeleteEntity(prop1)
        DeleteEntity(prop2)
        ClearPedTasks(player)
        ClearPedTasks(createPed)
        TaskWanderStandard(createPed, 10.0, 10)
        TriggerServerEvent('newstate_corners:sellDrug')
        Citizen.Wait(5000)
        DeletePed(createPed)
    end
end


RegisterNetEvent('newstate_corners:sellDrugs')
AddEventHandler('newstate_corners:sellDrugs', function() 
  local randomPed = math.random(1, 3)
  ped = peds[randomPed]
  
  RequestModel(ped)
  while not HasModelLoaded(ped) do
      Citizen.Wait(10)
  end
  sellingAnimation(ped)
end)

RegisterNetEvent('newstate_corners:callingPD')
AddEventHandler('newstate_corners:callingPD', function()
    local randomPed = math.random(1, 3)
    ped = peds[randomPed]
    RequestModel(ped)
    while not HasModelLoaded(ped) do
        Citizen.Wait(10)
    end

    sellingAnimation(ped)
    local player = GetPlayerPed(-1)
    local playerCoords = GetEntityCoords(player)
    streetName,_ = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
		streetName = GetStreetNameFromHashKey(streetName)
    
    TriggerServerEvent('newstate_outlawalert:cornerSelling',  {
        x = ESX.Math.Round(playerCoords.x, 1),
        y = ESX.Math.Round(playerCoords.y, 1),
        z = ESX.Math.Round(playerCoords.z, 1)
      }, streetName, playerGender)
end)

RegisterCommand('testpd', function() 
  local player = GetPlayerPed(-1)
  local playerCoords = GetEntityCoords(player)
  streetName,_ = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
  streetName = GetStreetNameFromHashKey(streetName)

  TriggerServerEvent('newstate_outlawalert:cornerSelling',  {
    x = ESX.Math.Round(playerCoords.x, 1),
    y = ESX.Math.Round(playerCoords.y, 1),
    z = ESX.Math.Round(playerCoords.z, 1)
  }, streetName, playerGender, karnacja)
end)

RegisterNetEvent('newstate_corners:cancelSelling')
AddEventHandler('newstate_corners:cancelSelling', function()

    local randomPed = math.random(1, 3)
    ped = peds[randomPed] 
    RequestModel(ped)
      while not HasModelLoaded(ped) do
        Citizen.Wait(10)
    end

    local player = GetPlayerPed(-1)
    local playerCoords = GetEntityCoords(player)

    local ground = GetGroundZFor_3dCoord(playerCoords.x, playerCoords.y, playerCoords.z, 0)
    local createPed = CreatePed(26, ped, playerCoords.x + 5.0, playerCoords.y + 3.0, playerCoords.z + 1.25, 50.0, false)
    PlaceObjectOnGroundProperly(createPed)
    SetEntityAsMissionEntity(createPed)
    SetBlockingOfNonTemporaryEvents(createPed, true)
    SetPedKeepTask(createPed, true)
    TaskGoToEntity(createPed, player, -1, 1.5, 1.0, 1073741824.0, 0)
    SetPedKeepTask(createPed, true)

    local o = 0
    local whil = true

    while whil do
        Citizen.Wait(1000)
        local playerCoords2 = GetEntityCoords(GetPlayerPed(-1))
        local pedCoords = GetEntityCoords(createPed)
        local pedHealth = GetEntityHealth(createPed)
        local odlegosc = Vdist(pedCoords.x, pedCoords.y, pedCoords.z, playerCoords2.x, playerCoords2.y, playerCoords2.z)
        o = o + 1
        if odlegosc <= 1.5 or o >= 100 or pedHealth < 100 then 
            whil = false
        end
    end

    local pedHeading = GetEntityHeading(createPed)

    if o >= 100 then
        exports['ns_notify']:send('fas fa-capsules', 'error', 'Klient nie zjawił się na miejsce spotkania', 'top-right', 2000)
        TaskWanderStandard(createPed, 10.0, 10)
        SetPedAsNoLongerNeeded(createPed)
    else
        SetEntityHeading(player, pedHeading - 180.0)
        RequestAnimDict('mp_common')
        while not HasAnimDictLoaded('mp_common') do
            Citizen.Wait(10)
        end
        local playerPed = PlayerPedId()
        local playerBone = GetPedBoneIndex(playerPed, 57005)
        local pedBone = GetPedBoneIndex(createPed, 57005)
        local prop1 = CreateObject(GetHashKey('prop_weed_bottle'), 0, 0, 0, true)
        local prop2 = CreateObject(GetHashKey('hei_prop_heist_cash_pile'), 0, 0, 0, true)
        AttachEntityToEntity(prop1, playerPed, playerBone, 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
        TaskPlayAnim(player, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 0, 0, false, false, false)
        Citizen.Wait(1000)
        AttachEntityToEntity(prop1, createPed, pedBone, 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
        TaskPlayAnim(createPed, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 0, 0, false, false, false)
        DeleteEntity(prop1)
        ClearPedTasks(player)
        ClearPedTasks(createPed)
        TaskWanderStandard(createPed, 10.0, 10)
        exports['ns_notify']:send('fas fa-capsules', 'error', 'Klient po usłyszeniu ceny odszedł szybkim krokiem', 'top-right', 2000)
        Citizen.Wait(5000)
        DeletePed(createPed)
    end
end)
