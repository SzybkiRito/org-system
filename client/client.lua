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
					showPlayersMenu()
				end
			end
		end
	end
end)

function showPlayersMenu() 
	local elements = {}
	ESX.TriggerServerCallback('org-system:getPlayers', function(cb) 

		print(ESX.DumpTable(cb))

		for k, v in ipairs(cb) do 
			table.insert(elements, {
				label = v.fullName
			})
		end
		
		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'spawn_vehicle',
			{
				title    = 'Gracze',
				align    = 'top-left',
				elements = elements,
			},
			function(data, menu)
				-- if (data.current.state == "notexist") then
				-- 	menu.close()
				-- else
				-- 	TriggerEvent('esx:showNotification', 'Pojazd już jest na mapie')
				-- end
			end,
			function(data, menu)
				menu.close()
				--CurrentAction = 'open_garage_action'
			end
		)

	end)

end

function getOwnedVehicles()
	local elements, vehiclePropsList = {}, {}
	local vehiclePos = {}
	local exists = false

	ESX.TriggerServerCallback('project_vehicles:getVehicles', function(result)

		for k,v in ipairs(result) do
			local vehicleProps = json.decode(v.vehicle)
			vehiclePropsList[vehicleProps.plate] = vehicleProps
			local vehicleHash = vehicleProps.model
			local vehicleName = GetDisplayNameFromVehicleModel(vehicleHash)
			local vehicleLabel

			if (v.exist == "notexist") then
				vehicleLabel = vehicleName.. ' ' .. v.plate .. ' Garage'
			else
				vehicleLabel = vehicleName.. ' ' .. v.plate .. ' Impound'
			end

			table.insert(elements, {
				label = vehicleLabel,
				state = v.exist,
				x = tonumber(v.x),
				y = tonumber(v.y),
				z = tonumber(v.z),
				engine = v.engine,
				bodyHealth2 = v.bodyHealth,
				heading = tonumber(v.heading),
				color1 = v.color_1,
				color2 = v.color_2,
				plate = vehicleProps.plate
			})
		end

		ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'spawn_vehicle',
		{
			title    = 'Garage',
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)
			if (data.current.state == "notexist") then
				menu.close()
				local vehicleProps = vehiclePropsList[data.current.plate]
				vehicleProps["engineHealth"] = data.current.engine + 0.0
				-- vehicleProps["bodyHealth"] = bodyHealth2
				SpawnVehicle(vehicleProps, data.current.x, data.current.y, data.current.z, data.current.heading, data.current.engine, data.current.bodyHealth2, data.current.color1, data.current.color2)
			else
				TriggerEvent('esx:showNotification', 'Pojazd już jest na mapie')
			end
		end,
		function(data, menu)
			menu.close()
			--CurrentAction = 'open_garage_action'
		end
	)
	end)
end