-- Copyright (c) Jérémie N'gadi
--
-- All rights reserved.
--
-- Even if 'All rights reserved' is very clear :
--
--   You shall not use any piece of this software in a commercial product / service
--   You shall not resell this software
--   You shall not provide any facility to install this particular software in a commercial product / service
--   If you redistribute this software, you must link to ORIGINAL repository at https://github.com/ESX-Org/es_extended
--   This copyright should appear in every part of the project code

Config = {}

Config.EnableControls      = true
Config.DrawDistance        = 20
Config.TestDriveTime       = 180
Config.EnableVehicleStats  = true
Config.FastestVehicleSpeed = 200 -- in MPH
Config.FastestVehicleAccel = 0.5
Config.MaxGears            = 8
Config.MaxCapacity         = 8
Config.ResellPercentage    = 50 -- in %
Config.PlateLetters        = 3
Config.PlateNumbers        = 3
Config.PlateUseSpace       = true

Config.VehicleShopZones = {
  Main = {
    Center = vector3(-43.958888888888889, -1098.6466666666668, 26.430000000000005),
    Points = {
      vector3(-60.61, -1096.77, 26.43),
      vector3(-58.26, -1100.57, 26.43),
      vector3(-35.93, -1108.96, 26.43),
      vector3(-34.64, -1108.39, 26.43),
      vector3(-32.12, -1101.61, 26.43),
      vector3(-33.18, -1101.18, 26.43),
      vector3(-31.32, -1095.34, 26.43),
      vector3(-52.6,  -1087.83, 26.43),
      vector3(-56.97, -1087.17, 26.43)
    },
    MaxLength = 17
  }
}

Config.Zones = {
  ShopSell  = {
    Pos   = vector3(-42.08379, -1115.916, 25.5),
    Size  = {x = 3.0, y = 3.0, z = 1.5},
    Type  = 27,
    Color = {r = 255, g = 0, b = 0, a = 255}
  }
}

Config.ShopInside = {
  Pos     = vector3(-47.5, -1097.2, 25.4),
  Heading = -20.0
}

Config.ShopOutside = {
  Pos     = vector3(-33.50243, -1079.901, 26.3878),
  Heading = 69.750938415527
}
