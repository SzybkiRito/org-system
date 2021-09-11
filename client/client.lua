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

Citizen.CreateThread(function() 
	while true do
		Citizen.Wait(1000)
		ESX.TriggerServerCallback('org-system:isPlayerInGroup', function(cb) 
			-- print('Getting Group from a player')
			--print(ESX.DumpTable(cb))
			Config.GroupName = cb.groupName
			Config.playerRank = cb.playerRank
		end)
	end
end)

Citizen.CreateThread(function() 
	while true do
		Citizen.Wait(1)	
			if Config.GroupName ~= nil and Config.playerRank == 1 then
				local coords = GetEntityCoords(PlayerPedId())
				local markerCoords = vector3(-26.22, -1447.91, 30.63-0.95)
				local distance = Vdist(vector3(coords), markerCoords)
  
				if distance < 10 then
			  		DrawMarker(27, markerCoords, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 217, 219, 61, 100, false, true, 2, true, false, false, false)
				end
  
				if distance < 1.2 then
			 		SetTextComponentFormat('STRING')
			  		AddTextComponentString('Kliknij ~INPUT_PICKUP~ aby zarządzać swoją grupą')
			  		DisplayHelpTextFromStringLabel(0, 0, 1, -1)
				if IsControlJustPressed(1, 38) then
					showManagementGroupMenu()
				end
			end
		end
	end
end)

function showManagementGroupMenu() 
	local elements = {}
	ESX.TriggerServerCallback('org-system:getPlayers', function(cb) 

		for k, v in ipairs(cb) do 
			table.insert(elements, {
				label = v.fullName,
				identifier = v.identifier
			})
		end
		
		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'manageGroup',
			{
				title    = 'Zarządzaj grupą',
				align    = 'top-left',
				elements = {
					{label = 'Delete player from group', value = 'delete'},
					{label = 'Add player to group', value = 'add'}
				},
			},
			function(data, menu)
				menu.close()

				if data.current.value == 'delete' then
					showDeletePlayersMenu(elements)
				elseif data.current.value == 'add' then
					showPlayersMenu()
				end

			end, function(data, menu)
				menu.close()
				--CurrentAction = 'open_garage_action'
			end
		)
	end)
end

function showDeletePlayersMenu(elements) 
	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'listPlayers',
		{
			title    = 'Gracze',
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)
			ESX.UI.Menu.Open(
				'default', GetCurrentResourceName(), 'delete',
				{
					title    = 'Gracze',
					align    = 'top-left',
					elements = {
						{label = 'Tak', value = 'yes'},
						{label = 'Nie', value = 'no'}
					},
				},
				function(data2, menu2)
					menu2.close()

					if data2.current.value == 'yes' then
						TriggerServerEvent('org-system:deletePlayerFromGroup', data.current.identifier)
						Config.GroupName = nil
						Config.playerRank = nil
					elseif data2.current.value == 'no' then
						menu2.cancel()
					end

				end, function(data, menu)
					--menu2.close()
					--CurrentAction = 'open_garage_action'
				end
			)
		end,
		function(data, menu)
			menu.close()
			--CurrentAction = 'open_garage_action'
		end
	)
end

function showPlayersMenu() 
	local elements = {}
    local players = ESX.Game.GetPlayers()

    for k, v in ipairs(players) do
		local playerData = ESX.GetPlayerData(v)
        table.insert(elements, {
			label = GetPlayerName(v),
			identifier = playerData.identifier
		})
    end

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'listPlayers',
		{
			title    = 'Gracze',
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)
			ESX.UI.Menu.Open(
				'default', GetCurrentResourceName(), 'delete',
				{
					title    = 'Usunąć gracza?',
					align    = 'top-left',
					elements = {
						{label = 'Tak', value = 'yes'},
						{label = 'Nie', value = 'no'}
					},
				},
				function(data2, menu2)
					menu2.close()

					if data2.current.value == 'yes' then
						TriggerServerEvent('org-system:addPlayerToGroup', data2.current.identifier, Config.GroupName, 0)
					elseif data2.current.value == 'no' then
						menu2.cancel()
					end

				end, function(data, menu)
					--menu2.close()
					--CurrentAction = 'open_garage_action'
				end
			)
		end,
		function(data, menu)
			menu.close()
			--CurrentAction = 'open_garage_action'
		end
	)
end

RegisterCommand('asd', function() 
	local players = ESX.Game.GetPlayers()

	for k,v in ipairs(players) do
		
	end
end)