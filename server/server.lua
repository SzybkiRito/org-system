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

function addPlayerToGroup(identifier, org_name, rank)
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
                        MySQL.Async.execute("INSERT INTO orgmembers(identifier, org_name, rank) VALUES(@identifier, @org_name, @rank)", {
                            ['@identifier'] = identifier, 
                            ['@org_name'] = org_name,
                            ['@rank'] = rank
                        })
                        print('Player added to organization')
                    end
                else
                    MySQL.Async.execute("INSERT INTO orgmembers(identifier, org_name, rank) VALUES(@identifier, @org_name, @rank)", {
                        ['@identifier'] = identifier, 
                        ['@org_name'] = org_name,
                        ['@rank'] = rank
                    })
                    print('Player added to organization')
                end
            end) 
        else
            print('Nie ma takiej grupy')
        end
    end)
end

function identiferToCharacterName(identifier, callback) 
    MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier', {
        ['@identifier'] = identifier  
    }, function(result) 
        local fullName = {
            firstname = result[1].firstname,
            lastname = result[1].lastname
        }
        callback(fullName)
    end)
end

ESX.RegisterServerCallback('org-system:getPlayers', function(source, cb) 
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier
    local fullName = nil
    
    xPlayer.getPlayerGroup(xPlayer.identifier, function(data) 
        if data then
            MySQL.Async.fetchAll('SELECT * FROM orgmembers WHERE org_name = @orgName', {
                ['@orgName'] = data
            }, function(result)
                for k, v in ipairs(result) do
                    identiferToCharacterName(v.identifier, function(data) 
                         fullName = string.format("%s %s", data.firstname, data.lastname)
                    end)
                end
                -- identiferToCharacterName(result[1].identifier, function(data) 
                --     local fullName = string.format("%s %s", data.firstname, data.lastname)
                --     cb(fullName)
                -- end)
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

    addPlayerToGroup(xPlayer.identifier, args[1], tonumber(args[2]))
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