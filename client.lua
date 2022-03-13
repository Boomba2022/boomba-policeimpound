ESX = nil 
PlayerData = {}                                                               --
Citizen.CreateThread(function()                                           --
	while ESX == nil do                                                   --
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)  --
		Citizen.Wait(0)                                                   --
	end  
    while ESX.GetPlayerData().job == nil do -- Get players job 
        Citizen.Wait(1)
    end
    PlayerData = ESX.GetPlayerData() -- Get player data                                                                  --
end)     
---------------------------------------------------------------------------

local playerid = GetPlayerServerId(PlayerId())
local CurrentAction = nil 

RegisterNetEvent("boomba-pdimpound:hasEnteredMarker")
AddEventHandler('boomba-pdimpound:hasEnteredMarker', function(zone)
    if zone == 'GetImpoundedVehicle' then
		CurrentAction = 'insideseedzak'
	end
end)

RegisterNetEvent("boomba-pdimpound:hasExitedMarker")
AddEventHandler('boomba-pdimpound:hasExitedMarker', function(zone)
	CurrentAction = nil
end)

Citizen.CreateThread(function()
    while true do
		Citizen.Wait(0)
		local coords = GetEntityCoords(PlayerPedId())
		for k,v in pairs(Config.impoundLocation) do
			if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < 100.0) then
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do

		Citizen.Wait(100)

		local coords      = GetEntityCoords(PlayerPedId())
		local isInMarker  = false
		local currentZone = nil

		for k,v in pairs(Config.impoundLocation) do
			if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
				isInMarker  = true
				currentZone = k
			end
		end

		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
			HasAlreadyEnteredMarker = true
			LastZone                = currentZone
			TriggerEvent('boomba-pdimpound:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('boomba-pdimpound:hasExitedMarker', LastZone)
		end
	end
end)

local plate = nil 
local plateforcb = nil 
-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if CurrentAction then
			ESX.ShowHelpNotification(Config.notify)
			if IsControlJustReleased(0, 38) then
                ESX.TriggerServerCallback("boomba-ramkraak:getvehiclefromimpound", function(vehicles)
                    if not vehicles then
                        vehicles = {}
                    end
        
                    local elements = {}
        
                    if #vehicles == 0 then
                        table.insert(elements, {
                            label = Config.table, value = false
                        })
                    else
                        for k, v in pairs(vehicles) do
							plateforcb = v.plate
                            table.insert(elements, {
                                label = string.format(Config.table2, v.plate, Config.ImpoundPrice), value = v.plate
                            })
                        end
                    end
        
                    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "select_vehicle_retrieve", {
                        title = Config.table3,
                        align = "top-right",
                        elements = elements
                    }, function(data, menu)
                        plate = data.current.value
						TriggerServerEvent("boomba-pdimpound:getplate", plate)
                        if plate then
                            viewing = false
							ESX.TriggerServerCallback("boomba-pdimpound:getvehicleprice", function(cb)
                            	TriggerServerEvent("boomba-pdimpound:pay", cb/Config.devide)
							end, plateforcb)
                            menu.close()
                        end
        
                    end, function(data, menu)
                        viewing = false
                        menu.close()
                    end)
					Citizen.Wait(400)
                end, playerid)
				CurrentAction = nil
			end
		else
			Citizen.Wait(500)
		end
	end
end)