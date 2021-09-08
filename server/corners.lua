--[[
    Made by SzybkiRito#4211
]]

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- local count = 0

local lowDrugs = {}
local lowDrugPrices = {}
local lowDrugPrices2 = {}

local normalDrugs = {}
local normalDrugsPrices = {}
local normalDrugsPrices2 = {}

local rareDrugs = {}
local rareDrugsPrices = {}
local rareDrugsPrices2 = {}

RegisterCommand('addCorner', function(source, args, rawCommand) 
    if IsPlayerAceAllowed(source, 'addCorner') then
    if args[1] ~= nil then

        local ped = GetPlayerPed(source)
        local playerCoords = GetEntityCoords(ped)
        xx, yy, zz = table.unpack(playerCoords)

        MySQL.Async.execute('INSERT INTO corners(corner_name, x, y, z) VALUES(@corner_name, @x, @y, @z)', {
            ['@corner_name'] = args[1],
            ['@x'] = xx,
            ['@y'] = yy,
            ['@z'] = zz,
        })
    else
        --TriggerClientEvent('ns_notify:SendNotification', 1, 'fas fa-capsules', 'error', 'Musisz podać nazwę cornera', 'top-right', 2000)
        TriggerClientEvent('ns_notify:SendNotification', source, 'fas fa-capsules', 'error', 'Musisz podać nazwę cornera', 'top-right', 2000)
    end
    else
        TriggerClientEvent('ns_notify:SendNotification', source, 'fas fa-capsules', 'error', 'Nie masz odpowiednich uprawnień', 'top-right', 2000)
    end
end)

RegisterCommand('deleteCorner', function(source, args, rawCommand) 
    if IsPlayerAceAllowed(source, 'deleteCorner') then
        if args[1] ~= nil then
            MySQL.Async.execute('DELETE FROM corners WHERE corner_name = @corner_name', {
                ['@corner_name'] = args[1],
            })
        else
            --TriggerClientEvent('ns_notify:SendNotification', 1, 'fas fa-capsules', 'error', 'Musisz podać nazwę cornera', 'top-right', 2000)
            TriggerClientEvent('ns_notify:SendNotification', source, 'fas fa-capsules', 'error', 'Musisz podać nazwę cornera', 'top-right', 2000)
        end
    else
        TriggerClientEvent('ns_notify:SendNotification', source, 'fas fa-capsules', 'error', 'Nie masz odpowiednich uprawnień', 'top-right', 2000)
    end
end)

ESX.RegisterServerCallback('newstate_corners:getMarkers', function(source, cb)
    MySQL.Async.fetchAll('SELECT x, y, z FROM corners', {}, function(result) 
        if result then
            cb(result)
        end
    end)
end)

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function randomChange (percent) -- returns true a given percentage of calls
    assert(percent >= 0 and percent <= 100) -- sanity check
    return percent >= math.random(1, 100)   -- 1 succeeds 1%, 50 succeeds 50%,
end
  

RegisterServerEvent('newstate_corners:sellDrug')
AddEventHandler('newstate_corners:sellDrug', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
	local x = 0
	local typnarko = ''

    local randomTypeOfDrugToSell = math.random(1, 20)

    if randomChange(70) then
        lowDrugFC()
        -- print('crack ' .. randomChange(70))
        sell(lowDrugs, lowDrugPrices, lowDrugPrices2, source)
    else if randomChange(10) then
        rareDrugsFC()
        -- print('koks ' .. randomChange(10))
        sell(rareDrugs, rareDrugsPrices, rareDrugsPrices2, source)
    else if randomChange(40) then 
        normalDrugsFC()
        -- print('hara ' .. randomChange(40))
        sell(normalDrugs, normalDrugsPrices, normalDrugsPrices2, source)
    end
    end
    end

    -- if randomTypeOfDrugToSell >= 1 and randomTypeOfDrugToSell <= 13 then
    --     lowDrugFC()
    --     sell(lowDrugs, lowDrugPrices, lowDrugPrices2, count, source)
    -- else if randomTypeOfDrugToSell >= 14 and randomTypeOfDrugToSell <= 17 then
    --     normalDrugsFC()
    --     sell(normalDrugs, normalDrugsPrices, normalDrugsPrices2, count, source)
    -- else if randomTypeOfDrugToSell >= 18 and randomTypeOfDrugToSell <= 20 then
    --     rareDrugsFC()
    --     sell(rareDrugs, rareDrugsPrices, rareDrugsPrices2, count, source)
    -- end
    -- end
    -- end
end)

function lowDrugFC() 
    for k, v in ipairs(Config.LowDrugs) do
        count = math.random(1, 5)
        table.insert(lowDrugs, v.drug)
        table.insert(lowDrugPrices, v.price)
        table.insert(lowDrugPrices2, v.price2)
    end
end

function normalDrugsFC() 
    for k, v in ipairs(Config.NormalDrugs) do
        count = math.random(1, 5)
        table.insert(normalDrugs, v.drug)
        table.insert(normalDrugsPrices, v.price)
        table.insert(normalDrugsPrices2, v.price2)
    end
end

function rareDrugsFC() 
    for k, v in ipairs(Config.RareDrugs) do
        count = math.random(1, 5)
        table.insert(rareDrugs, v.drug)
        table.insert(rareDrugsPrices, v.price)
        table.insert(rareDrugsPrices2, v.price2)
    end
end

function sell(drug, drugPrices, drugPrices2, source) 
        local _source = source
        local xPlayer = ESX.GetPlayerFromId(_source)
        local randomSeed = math.random(1, tablelength(drug))
        local drugToSell = drug[randomSeed]
        local drugCountToSell = xPlayer.getInventoryItem(drugToSell).count
        local count = math.random(0, drugCountToSell)
        local priceRandom = math.random(drugPrices[randomSeed], drugPrices2[randomSeed])
        local chanceToCallPD = math.random(1, 4)

        print(drugToSell)

        if count > 5 then
            count = 5
        end

        local priceDrugToSell = priceRandom * count

        if drugCountToSell >= 1 then
            local ped = GetPlayerPed(source)
            local playerCoords = GetEntityCoords(ped)
            xx, yy, zz = table.unpack(playerCoords)
            
            TriggerClientEvent('ns_notify:SendNotification', source, 'fas fa-capsules', 'success', "Sprzedałeś " .. count .. " gram/y narkotyku za $" .. priceDrugToSell, 'top-right', 2000)
            xPlayer.removeInventoryItem(drugToSell, count)
            xPlayer.addMoney(priceDrugToSell)
    
            if chanceToCallPD == 3 then
                -- TriggerEvent('mdt:newCall', 'Widziałem jak osoba podaje podejrzany pakunek drugiej w zamian za pieniądze!', 'Anonimowe Zgłoszenie', vector3(xx, yy, zz), true)
                local data = {displayCode = '1094', description = 'HIDTA', isImportant = 0, recipientList = {'police'}, length = '10000', infoM = 'fa-info-circle', info = 'High Intensity Drug Trafficking Area'}
                local dispatchData = {dispatchData = data, caller = 'Alarm', coords = vector3(xx, yy, zz)}
                TriggerEvent('wf-alerts:svNotify', dispatchData)

            end
    
        else
            TriggerClientEvent('ns_notify:SendNotification', source, 'fas fa-capsules', 'error', "Klient poszukuje innego rodzaju narkotyku", 'top-right', 2000)
        end
end
