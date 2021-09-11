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

ESX.RegisterServerCallback('org-system:getPlayers', function(source, cb) 
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier
    
    xPlayer.getPlayerGroup(xPlayer.identifier, function(data) 
        if data then
            MySQL.Async.fetchAll('SELECT * FROM orgmembers WHERE org_name = @orgName', {
                ['@orgName'] = data
            }, function(result)
                local members = {}

                for i=1, #result, 1 do
                    table.insert(members, {
                        fullName = result[i].characterName
                    })
                end

                cb(members)

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
        playerGroup.groupName = result[1].org_name
        playerGroup.playerRank = result[1].rank
        cb(playerGroup)
    end)
end)

RegisterCommand('createGroup', function(source, args) 
    createGroup(args[1])
end)

RegisterCommand('addPlayer', function(source, args) 
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local fullName = xPlayer.getName()

    -- ADD ID TO ADD SPECIFIC PLAYER!

    addPlayerToGroup(xPlayer.identifier, args[1], tonumber(args[2]), fullName)
end)

RegisterCommand('asd', function(source, args) 
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    xPlayer.getPlayerGroup(xPlayer.identifier, function(data) 
        if data then
            chuj = data
        end
    end)
end)