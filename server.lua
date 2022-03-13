ESX = nil 
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local playerid = nil
local impoundedcars = nil 

RegisterServerEvent("boomba-pdimpound:storedatabasedata")
AddEventHandler("boomba-pdimpound:storedatabasedata", function(data, state, id)
    playerid = id 
    local xPlayer = ESX.GetPlayerFromId(playerid)
    local identifier = xPlayer.identifier
    MySQL.Async.fetchAll("SELECT * FROM "..Config.ownedvehicledatabasetable.." WHERE owner = @identifier AND plate = @plate;", {["@owned_vehicles"] = Config.ownedvehicledatabasetable,["@identifier"] = identifier, ["@plate"] = data}, function(result)
        if result and #result > 0 then
            local to_return = {}
            for k, v in pairs(result) do
                table.insert(to_return, v)
                MySQL.Async.fetchAll("INSERT INTO impounded_vehicles (owner, plate, vehicle, type, job, stored, damages, garage, ispdimpound) VALUES(@owner, @plate, @vehicle, @type, @job, @stored, @damages, @garage, @ispdimpound)",     
                {["@owner"] = v.owner, ["@plate"] = v.plate, ["@vehicle"] = v.vehicle, ["@type"] = v.type, ["@job"] = v.job, ["@stored"] = v.stored, ["@damages"] = v.damages, ["@garage"] = v.garage, ["@ispdimpound"] = v.ispdimpound},
                function (result)
                    MySQL.Async.fetchAll("DELETE FROM "..Config.ownedvehicledatabasetable.." WHERE owner = @identifier AND plate = @plate;",     
                    {["@identifier"] = identifier, ["@plate"] = data},
                    function (result)
                        MySQL.Async.fetchAll("INSERT INTO pdimpound (identifier, plate) VALUES(@identifier, @plate)",     
                        {["@identifier"] = identifier, ["@plate"] = data},
                        function (result)
                            print("Saved to database")    
                        end)
                    end)
                end)
            end
        else
            print("false")
        end
    end)
end)

GetImpounded = function(source, cb, identifier)
    MySQL.Async.fetchAll("SELECT plate FROM pdimpound WHERE identifier = @identifier;", {["@identifier"] = identifier}, function(result)
        if result and #result > 0 then
            local to_return = {}
            for k, v in pairs(result) do
                table.insert(to_return, v)
            end
            cb(to_return)
        else
            cb(false)
        end
    end)
end

ESX.RegisterServerCallback("boomba-pdimpound:getvehicleprice", function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier
    local modelhash = nil 
    local price = nil 
    MySQL.Async.fetchAll("SELECT * FROM "..Config.ownedvehicledatabasetable.." WHERE owner = @identifier AND plate = @plate;", {["@identifier"] = identifier, ["@plate"] = plate}, function(result)
        if result and #result > 0 then
            local to_return = {}
            for k, v in pairs(result) do
                table.insert(to_return, v)
                modelhash = v.vehicle
            end
            MySQL.Async.fetchAll("SELECT * FROM "..Config.cardealertable..";", { }, function(result) 
                if result and #result > 0 then
                    local to_return = {}
                    for k, v in pairs(result) do
                        table.insert(to_return, v)
                        local hashed = GetHashKey(v.model)
                        if string.match(modelhash, hashed) then 
                            price = v.price
                            cb(price)
                        end 
                    end
                end 
            end)
            MySQL.Async.fetchAll("SELECT * FROM "..Config.cardealertable2..";", {  }, function(result) 
                if result and #result > 0 then
                    local to_return = {}
                    for k, v in pairs(result) do
                        table.insert(to_return, v)
                        local hashed = GetHashKey(v.model)
                        if string.match(modelhash, hashed) then 
                            price = v.price
                            cb(price)
                        end 
                    end
                end 
            end)
        end 
    end)
end)

--[[tijdelijk uit 
RegisterCommand("testpdimpound", function(source, args)
    local plate = table.concat(args, " ")
    TriggerEvent("boomba-pdimpound:storedatabasedata", plate, true, source)
end)]]

local data = nil 

ESX.RegisterServerCallback("boomba-ramkraak:getvehiclefromimpound", function(source, cb, id)
    RegisterServerEvent("boomba-pdimpound:getplate")
    AddEventHandler("boomba-pdimpound:getplate", function(plate)
        data = plate 
    end)
    playerid = id 
    local xPlayer = ESX.GetPlayerFromId(playerid)
    local identifier = xPlayer.identifier
    Citizen.Wait(200)
    GetImpounded(source, cb, identifier)
    MySQL.Async.fetchAll("SELECT * FROM impounded_vehicles WHERE owner = @identifier AND plate = @plate;", {["@identifier"] = identifier, ["@plate"] = data}, function(result)
        if result and #result > 0 then
            local to_return = {}
            for k, v in pairs(result) do
                table.insert(to_return, v)
                MySQL.Async.fetchAll("INSERT INTO "..Config.ownedvehicledatabasetable.." (owner, plate, vehicle, type, job, stored, damages, garage, ispdimpound) VALUES(@owner, @plate, @vehicle, @type, @job, @stored, @damages, @garage, @ispdimpound)",     
                {["@owner"] = v.owner, ["@plate"] = v.plate, ["@vehicle"] = v.vehicle, ["@type"] = v.type, ["@job"] = v.job, ["@stored"] = v.stored, ["@damages"] = v.damages, ["@garage"] = v.garage, ["@ispdimpound"] = v.ispdimpound},
                function (result)
                    MySQL.Async.fetchAll("DELETE FROM impounded_vehicles WHERE owner = @identifier AND plate = @plate;",     
                    {["@identifier"] = identifier, ["@plate"] = data},
                    function (result)
                        MySQL.Async.fetchAll("DELETE FROM pdimpound WHERE plate = @plate;",     
                        {["@plate"] = data},
                        function (result)
                            print("Deleted from database")    
                        end)
                    end)
                end)
            end
        else
            print("false")
        end
    end)
end)

RegisterServerEvent("boomba-pdimpound:pay")
AddEventHandler("boomba-pdimpound:pay", function(price)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeAccountMoney('bank', price)
end)