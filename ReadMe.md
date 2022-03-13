Boomba Police Impound: 

Features:

+ Police can impound vehicles 

+ Civilians can buy vehicles back 

+ Works with esx_vehicleshop 

Discord: Boomba#0001 

Installation: 

Add this trigger for Police 

local plate = table.concat(args, " ")
TriggerEvent("boomba-pdimpound:storedatabasedata", plate, true, source)

SQL: 

CREATE TABLE IF NOT EXISTS `impounded_vehicles` (
  `owner` varchar(40) NOT NULL,
  `plate` varchar(12) NOT NULL,
  `vehicle` longtext DEFAULT NULL,
  `type` varchar(20) NOT NULL DEFAULT 'car',
  `job` varchar(20) DEFAULT '',
  `stored` tinyint(1) NOT NULL DEFAULT 0,
  `damages` longtext DEFAULT NULL,
  `garage` varchar(255) NOT NULL DEFAULT 'square',
  `ispdimpound` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `pdimpound` (
  `identifier` varchar(50) DEFAULT NULL,
  `plate` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;