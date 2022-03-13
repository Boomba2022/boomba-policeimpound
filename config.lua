Config = {}
Config.Locale = 'en'

Config.notify = "Druk op ~INPUT_PICKUP~ om uw impounded vehicle terug te kopen!"

Config.ownedvehicledatabasetable = "owned_vehicles"
Config.cardealertable = "vehicles"
Config.cardealertable2 = "customvehicles"

Config.devide = 4 -- By how much do you want to devide the price? This is 25% 

Config.impoundLocation = {
	GetImpoundedVehicle = {
		Pos   = { x = 433.7285, y = -974.6749, z = 30.7098 },
		Size  = {x = 1.5, y = 1.5, z = 1.0},
		Color = {r = 204, g = 204, b = 0},
		Type  = 1
	} 
}

-- Locales 

Config.table = "U heeft geen in beslag genomen voertuigen."
Config.table2 = "ophalen %s voor 25 procent van de inkoopwaarde van dit voertuig"
Config.table3 = "[Politie] In beslag genomen voertuigen:"