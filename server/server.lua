--[[
    Made by SzybkiRito#4211
]]

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local organization = {}

function isTableEmpty(tableName) 
    if next(tableName) == nil then
        return true
    else
        return false
     end
end

function createGroup(org_name) 
    if org_name == nil then return end
    MySQL.Async.fetchAll("SELECT org_name FROM organizations WHERE org_name = @org_name", {
        ['@org_name'] = org_name
    }, function(result) 
        if isTableEmpty(result) then
            MySQL.Async.execute("INSERT INTO organizations(org_name) VALUES(@org_name)", {
                ['@org_name'] = org_name
            })
            print('SHOW A NOTIFICATION HERE') -- SUCESFULLY CREATED
        else
            print('SHOW A NOTIFICATION HERE -- ERROR') -- ORG ALREADY EXISTS
        end
    end)
end

function addPlayerToGroup(identifier, org_name, rank, characterName)
    if identifier == nil or org_name == nil or rank == nil then return end

    MySQL.Async.fetchAll('SELECT org_name FROM organizations WHERE org_name = @org_name', {
        ['@org_name'] = org_name
    }, function(result) 
        if isTableEmpty(result) == false then
            MySQL.Async.fetchAll('SELECT identifier FROM orgmembers WHERE org_name = @org_name', {
                ['@org_name'] = org_name
            }, function(result) 
                if isTableEmpty(result) == false then
                    if result[1].identifier == identifier then
                        print('Player is already in a group')
                    else
                        MySQL.Async.execute("INSERT INTO orgmembers(identifier, org_name, rank, characterName) VALUES(@identifier, @org_name, @rank, @characterName)", {
                            ['@identifier'] = identifier, 
                            ['@org_name'] = org_name,
                            ['@rank'] = rank,
                            ['@characterName'] = characterName
                        })
                        print('Player added to organization')
                    end
                else
                    MySQL.Async.execute("INSERT INTO orgmembers(identifier, org_name, rank, characterName) VALUES(@identifier, @org_name, @rank, @characterName)", {
                        ['@identifier'] = identifier, 
                        ['@org_name'] = org_name,
                        ['@rank'] = rank,
                        ['@characterName'] = characterName
                    })
                    print('Player added to organization')
                end
            end) 
        else
            print('Nie ma takiej grupy')
        end
    end)
end

function deletePlayerFromGroup(identifier) 
    if identifier == nil then return end

    MySQL.Async.fetchAll('DELETE FROM orgmembers WHERE identifier = @identifier', {
     ['@identifier'] = identifier   
    })
end

function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function createMarker(orgname, markerName, x, y, z) 

    local possibleMarkerNames = {
        'stash',
        'management'
    }

    if orgname == nil or markerName == nil or x == nil then return end

    if has_value(possibleMarkerNames, markerName) then
        MySQL.Async.execute('INSERT INTO org_markers(org_name, markerName, x, y, z) VALUES(@orgname, @markerName, @x, @y, @z)', {
            ['@orgname'] = orgname,
            ['@markerName'] = markerName,
            ['@vector3Marker'] = vector3Marker,
            ['@x'] = x,
            ['@y'] = y,
            ['@z'] = z
        }) 
    else
        print('Nie można utworzyć takiego markera')
    end
end

ESX.RegisterServerCallback('org-system:getMarkers', function(source, cb) 
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier
    
    MySQL.Async.fetchAll("SELECT org_name, rank FROM orgmembers WHERE identifier = @identifier", {
        ['@identifier'] = identifier
    }, function(result) 
        if isTableEmpty(result) == false then
        local orgName = result[1].org_name
        MySQL.Async.fetchAll('SELECT * FROM org_markers WHERE org_name = @orgName', { ['@orgName'] = orgName}, function(result) 
            if isTableEmpty(result) == false then
                cb(result)
            end
        end)
      end
    end)
end)

ESX.RegisterServerCallback('org-system:getPlayers', function(source, cb) 
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier
    
    xPlayer.getPlayerGroup(xPlayer.identifier, function(data) 
        if data then
            MySQL.Async.fetchAll('SELECT * FROM orgmembers WHERE org_name = @orgName', {
                ['@orgName'] = data
            }, function(result)
                if isTableEmpty(result) == false then
                    local members = {}

                    for i=1, #result, 1 do
                        table.insert(members, {
                            fullName = result[i].characterName,
                            identifier = result[1].identifier
                        })
                    end
    
                    cb(members)
                end

            end)
        end
    end)
end)

ESX.RegisterServerCallback('org-system:isPlayerInGroup', function(src, cb) 
    local _source = src
    local xPlayer = ESX.GetPlayerFromId(_source)
    local identifier = xPlayer.identifier

    local playerGroup = {
        groupName = nil,
        playerRank = nil
    }

    MySQL.Async.fetchAll("SELECT org_name, rank FROM orgmembers WHERE identifier = @identifier", {
        ['@identifier'] = identifier
    }, function(result)
        if isTableEmpty(result) == false then
            playerGroup.groupName = result[1].org_name
            playerGroup.playerRank = result[1].rank
            cb(playerGroup)
        end
    end)
end)

RegisterServerEvent('org-system:deletePlayerFromGroup')
AddEventHandler('org-system:deletePlayerFromGroup', function(identifier) 
    deletePlayerFromGroup(identifier)
end)

RegisterServerEvent('org-system:addPlayerToGroup')
AddEventHandler('org-system:addPlayerToGroup', function(identifer, group, rank)
    local xPlayer = ESx.GetPlayerFromIdentifier(identifier)
    local fullName = xPlayer.getName()

    addPlayerToGroup(identifier, group, tonumber(rank), fullName)
end)

-- COMMANDS

RegisterCommand('createGroup', function(source, args) 
    createGroup(args[1])
end)

RegisterCommand('addPlayer', function(source, args) 
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(args[1])
    local fullName = xPlayer.getName()

    if xPlayer then
        addPlayerToGroup(xPlayer.identifier, args[2], tonumber(args[3]), fullName)
    else
        print('player is not online')
    end
end)


--[[ 
    @params(
        orgName,
        markerName,
        vector3Marker
    )    
--]]

RegisterCommand('createMarker', function(source, args) 
    local ped = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(ped)
    xx, yy, zz = table.unpack(playerCoords)

    createMarker(args[1], args[2], xx, yy, zz)
end)