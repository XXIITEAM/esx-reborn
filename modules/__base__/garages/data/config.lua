-- Copyright (c) Jérémie N'gadi
--
-- All rights reserved.
--
-- Even if 'All rights reserved' is very clear :
--
--   You shall not use any piece of this software in a commercial product / service
--   You shall not resell this software
--   You shall not provide any facility to install this particular software in a commercial product / service
--   If you redistribute this software, you must link to ORIGINAL repository at https://github.com/esx-framework/esx-reborn
--   This copyright should appear in every part of the project code

Config = {}

Config.DrawDistance              = 100.0
Config.ZDiff                     = 0.5
Config.MinimumHealthPercent      = 0
Config.FastestVehicleSpeed       = 200 -- in MPH
Config.FastestVehicleAccel       = 0.5
Config.MaxGears                  = 8
Config.MaxCapacity               = 8
Config.GarageMenuLocation        = vector3(227.6369, -990.8311, -99.06071)
Config.GarageMenuLocationHeading = 205.80000305176

Config.GarageEntrances = {
  MiltonDrive = {
    Pos    = vector3(-800.4819, 333.4093, 84.763),
    Size   = {x = 3.0, y = 3.0, z = 1.5},
    Type   = 27,
    Garage = "public",
    Color  = {r = 0, g = 255, b = 0, a = 225}
  },
  SanAndreasAve = {
    Pos    = vector3(213.6633, -809.0292, 30.1),
    Size   = {x = 2.0, y = 2.0, z = 1.5},
    Type   = 27,
    Garage = "public",
    Color  = {r = 0, g = 255, b = 0, a = 225}
  },
  DidionWay = {
    Pos    = vector3(-259.88, 395.19, 109.12),
    Size   = {x = 3.0, y = 3.0, z = 1.5},
    Type   = 27,
    Garage = "public",
    Color  = {r = 0, g = 255, b = 0, a = 225},
  },
  ImaginationCt265 = {
    Pos    = vector3(-1129.65, -1072.38, 1.15),
    Size   = {x = 3.0, y = 3.0, z = 1.5},
    Type   = 27,
    Garage = "public",
    Color  = {r = 0, g = 255, b = 0, a = 225},
  },
  SteeleWay1150 = {
    Pos    = vector3(-924.81, 211.54, 66.46),
    Size   = {x = 3.0, y = 3.0, z = 1.5},
    Type   = 27,
    Garage = "public",
    Color  = {r = 0, g = 255, b = 0, a = 225}
  },
  Route68 = {
    Pos    = vector3(986.5052, 2648.922, 39.2),
    Size   = {x = 3.0, y = 3.0, z = 1.5},
    Type   = 27,
    Garage = "public",
    Color  = {r = 0, g = 255, b = 0, a = 225}
  },
  PaletoBlvd = {
    Pos    = vector3(-231.6472, 6350.395, 31.6),
    Size   = {x = 3.0, y = 3.0, z = 1.5},
    Type   = 27,
    Garage = "public",
    Color  = {r = 0, g = 255, b = 0, a = 225}
  },
  GrapeseedAve = {
    Pos    = vector3(2553.722, 4669.251, 33.1),
    Size   = {x = 3.0, y = 3.0, z = 1.5},
    Type   = 27,
    Garage = "public",
    Color  = {r = 0, g = 255, b = 0, a = 225}
  },
  AlgonquinBlvd = {
    Pos    = vector3(1725.834, 3707.835, 33.3),
    Size   = {x = 3.0, y = 3.0, z = 1.5},
    Type   = 27,
    Garage = "public",
    Color  = {r = 0, g = 255, b = 0, a = 225}
  },
  AltaSt = {
    Pos    = vector3(-298.0355, -990.6277, 30.2),
    Size   = {x = 3.0, y = 3.0, z = 1.5},
    Type   = 27,
    Garage = "AltaSt",
    Color  = {r = 0, g = 255, b = 0, a = 225}
  }
}

Config.GarageReturns = {
  MiltonDrive = {
    Pos    = vector3(-791.6684, 333.6367, 84.763),
    Size   = {x = 3.0, y = 3.0, z = 1.5},
    Type   = 27,
    Garage = "public",
    Color  = {r = 255, g = 0, b = 0, a = 225}
  },

  SanAndreasAve = {
    Pos    = vector3(221.1162, -806.5679, 29.8),
    Size   = {x = 3.0, y = 3.0, z = 1.5},
    Type   = 27,
    Garage = "public",
    Color  = {r = 255, g = 0, b = 0, a = 225}
  },

  DidionWay = {
    Pos    = vector3(-264, 396.2157, 109.1),
    Size   = {x = 3.0, y = 3.0, z = 1.5},
    Type   = 27,
    Garage = "public",
    Color  = {r = 255, g = 0, b = 0, a = 225}
  },

  ImaginationCt265 = {
    Pos    = vector3(-1121.867, -1065.195, 1.1),
    Size   = {x = 3.0, y = 3.0, z = 1.5},
    Type   = 27,
    Garage = "public",
    Color  = {r = 255, g = 0, b = 0, a = 225}
  },

  SteeleWay1150 = {
    Pos    = vector3(-931.3825, 213.0508, 66.47),
    Size   = {x = 3.0, y = 3.0, z = 1.5},
    Type   = 27,
    Garage = "public",
    Color  = {r = 255, g = 0, b = 0, a = 225}
  },

  Route68 = {
    Pos    = vector3(994.3171, 2650.206, 39.2),
    Size   = {x = 3.0, y = 3.0, z = 1.5},
    Type   = 27,
    Garage = "public",
    Color  = {r = 255, g = 0, b = 0, a = 225}
  },

  PaletoBlvd = {
    Pos    = vector3(-225.2677, 6352.1, 31.2),
    Size   = {x = 3.0, y = 3.0, z = 1.5},
    Type   = 27,
    Garage = "public",
    Color  = {r = 255, g = 0, b = 0, a = 225}
  },

  GrapeseedAve = {
    Pos    = vector3(2560.347, 4673.213, 33.2),
    Size   = {x = 3.0, y = 3.0, z = 1.5},
    Type   = 27,
    Garage = "public",
    Color  = {r = 255, g = 0, b = 0, a = 225}
  },

  AlgonquinBlvd = {
    Pos    = vector3(1730.628, 3709.852, 33.3),
    Size   = {x = 3.0, y = 3.0, z = 1.5},
    Type   = 27,
    Garage = "public",
    Color  = {r = 255, g = 0, b = 0, a = 225}
  },

  AltaSt = {
    Pos    = vector3(-304.747, -988.2321, 30.2),
    Size   = {x = 3.0, y = 3.0, z = 1.5},
    Type   = 27,
    Garage = "AltaSt",
    Color  = {r = 255, g = 0, b = 0, a = 225}
  }
}

Config.GarageSpawns = {
  MiltonDrive = {
    Pos     = vector3(-796.501, 302.271, 85.000),
    Heading = 180.0
  },

  SanAndreasAve = {
    Pos     = vector3(229.83, -804.35, 29.7),
    Heading = 160.25
  },

  DidionWay = {
    Pos     = vector3(-259.82, 397.33, 109.01),
    Heading = 12.15
  },

  ImaginationCt265 = {
    Pos     = vector3(-1126.48, -1069.065, 1.1),
    Heading = 15.87
  },

  SteeleWay1150 = {
    Pos     = vector3(-933.3, 209.06, 66.46),
    Heading = 158.79
  },

  Route68 = {
    Pos     = vector3(993.63, 2672.98, 38.7),
    Heading = 1.81
  },

  PaletoBlvd = {
    Pos     = vector3(-212.94, 6339.37, 30.19),
    Heading = 12.15
  },

  GrapeseedAve = {
    Pos     = vector3(2550.69, 4682.46, 32.5),
    Heading = 12.55
  },

  AlgonquinBlvd = {
    Pos     = vector3(1720.83, 3716.37, 32.86),
    Heading = 21.85
  },

  AltaSt = {
    Pos     = vector3(-314.3498, -976.5259, 31.08063),
    Heading = 246.54820251465
  }
}
-- Config.Zones = {
--   MiltonDrive = {
--     VehicleSpawner = {
--       Pos         = vector3(-800.4819, 333.4093, 84.763),
--       Size        = {x = 3.0, y = 3.0, z = 1.5},
--       Type        = 27,
--       Color       = {r = 0, g = 255, b = 0, a = 225}
--     },
--     VehicleReturn = {
--       Pos         = vector3(-791.6684, 333.6367, 84.763),
--       Size        = {x = 3.0, y = 3.0, z = 1.5},
--       Type        = 27,
--       Color       = {r = 255, g = 0, b = 0, a = 225}
--     },
--     VehicleSpawnPoint = {
--       Pos         = vector3(-796.501, 302.271, 85.000),
--       Heading     = 180.0
--     }
--   },

--   SanAndreasAve = {
--     VehicleSpawner = {
--       Pos         = vector3(213.6633, -809.0292, 30.1),
--       Size        = {x = 2.0, y = 2.0, z = 1.5},
--       Type        = 27,
--       Color       = {r = 0, g = 255, b = 0, a = 225}
--     },
--     VehicleReturn = {
--       Pos         = vector3(221.1162, -806.5679, 29.8),
--       Size        = {x = 3.0, y = 3.0, z = 1.5},
--       Type        = 27,
--       Color       = {r = 255, g = 0, b = 0, a = 225}
--     },
--     VehicleSpawnPoint = {
--       Pos         = vector3(-34.79, -697.73, 32.34),
--       Heading     = 350.42
--     }
--   },

--   DidionWay = {
--     VehicleSpawner = {
--       Pos                = vector3(-259.88, 395.19, 109.12),
--       Size               = {x = 3.0, y = 3.0, z = 1.5},
--       Type               = 27,
--       Color              = {r = 0, g = 255, b = 0, a = 225},
--       GarageMenuLocation = vector3(227.6369, -990.8311, -99.06071)
--     },
--     VehicleReturn = {
--       Pos         = vector3(-264, 396.2157, 109.1),
--       Size        = {x = 3.0, y = 3.0, z = 1.5},
--       Type        = 27,
--       Color       = {r = 255, g = 0, b = 0, a = 225}
--     },
--     VehicleSpawnPoint = {
--       Pos         = vector3(-259.82, 397.33, 109.01),
--       Heading     = 12.15
--     }
--   },

--   ImaginationCt265 = {
--     VehicleSpawner = {
--       Pos                = vector3(-1129.65, -1072.38, 1.15),
--       Size               = {x = 3.0, y = 3.0, z = 1.5},
--       Type               = 27,
--       Color              = {r = 0, g = 255, b = 0, a = 225},
--       GarageMenuLocation = vector3(227.6369, -990.8311, -99.06071)
--     },
--     VehicleReturn = {
--       Pos         = vector3(-1121.867, -1065.195, 1.1),
--       Size        = {x = 3.0, y = 3.0, z = 1.5},
--       Type        = 27,
--       Color = {r = 255, g = 0, b = 0, a = 225}
--     },
--     VehicleSpawnPoint = {
--       Pos         = vector3(-1126.48, -1069.065, 1.1),
--       Heading     = 15.87
--     }
--   },

--   SteeleWay1150 = {
--     VehicleSpawner = {
--       Pos         = vector3(-924.81, 211.54, 66.46),
--       Size        = {x = 3.0, y = 3.0, z = 1.5},
--       Type        = 27,
--       Color = {r = 0, g = 255, b = 0, a = 225}
--     },
--     VehicleReturn = {
--       Pos         = vector3(-931.3825, 213.0508, 66.47),
--       Size        = {x = 3.0, y = 3.0, z = 1.5},
--       Type        = 27,
--       Color = {r = 255, g = 0, b = 0, a = 225}
--     },
--     VehicleSpawnPoint = {
--       Pos         = vector3(-931.5, 210.98, 66.46),
--       Heading     = 12.15
--     }
--   },

--   Route68 = {
--     VehicleSpawner = {
--       Pos         = vector3(986.5052, 2648.922, 39.2),
--       Size        = {x = 3.0, y = 3.0, z = 1.5},
--       Type        = 27,
--       Color = {r = 0, g = 255, b = 0, a = 225}
--     },
--     VehicleReturn = {
--       Pos         = vector3(994.3171, 2650.206, 39.2),
--       Size        = {x = 3.0, y = 3.0, z = 1.5},
--       Type        = 27,
--       Color = {r = 255, g = 0, b = 0, a = 225}
--     },
--     VehicleSpawnPoint = {
--       Pos         = vector3(-931.5, 210.98, 66.46),
--       Heading     = 12.15
--     }
--   },

--   PaletoBlvd = {
--     VehicleSpawner = {
--       Pos         = vector3(-231.6472, 6350.395, 31.6),
--       Size        = {x = 3.0, y = 3.0, z = 1.5},
--       Type        = 27,
--       Color = {r = 0, g = 255, b = 0, a = 225}
--     },
--     VehicleReturn = {
--       Pos         = vector3(-225.2677, 6352.1, 31.2),
--       Size        = {x = 3.0, y = 3.0, z = 1.5},
--       Type        = 27,
--       Color = {r = 255, g = 0, b = 0, a = 225}
--     },
--     VehicleSpawnPoint = {
--       Pos         = vector3(-931.5, 210.98, 66.46),
--       Heading     = 12.15
--     }
--   },

--   GrapeseedAve = {
--     VehicleSpawner = {
--       Pos        = vector3(2553.722, 4669.251, 33.1),
--       Size        = {x = 3.0, y = 3.0, z = 1.5},
--       Type        = 27,
--       Color = {r = 0, g = 255, b = 0, a = 225}
--     },
--     VehicleReturn = {
--       Pos         = vector3(2560.347, 4673.213, 33.2),
--       Size        = {x = 3.0, y = 3.0, z = 1.5},
--       Type        = 27,
--       Color = {r = 255, g = 0, b = 0, a = 225}
--     },
--     VehicleSpawnPoint = {
--       Pos         = vector3(-931.5, 210.98, 66.46),
--       Heading     = 12.15
--     }
--   },

--   AlgonquinBlvd = {
--     VehicleSpawner = {
--       Pos         = vector3(1725.834, 3707.835, 33.3),
--       Size        = {x = 3.0, y = 3.0, z = 1.5},
--       Type        = 27,
--       Color = {r = 0, g = 255, b = 0, a = 225}
--     },
--     VehicleReturn = {
--       Pos         = vector3(1730.628, 3709.852, 33.3),
--       Size        = {x = 3.0, y = 3.0, z = 1.5},
--       Type        = 27,
--       Color = {r = 255, g = 0, b = 0, a = 225}
--     },
--     VehicleSpawnPoint = {
--       Pos         = vector3(-931.5, 210.98, 66.46),
--       Heading     = 12.15
--     }
--   },

--   AltaSt = {
--     VehicleSpawner = {
--       Pos         = vector3(-298.0355, -990.6277, 30.2),
--       Size        = {x = 3.0, y = 3.0, z = 1.5},
--       Type        = 27,
--       Color = {r = 0, g = 255, b = 0, a = 225}
--     },
--     VehicleReturn = {
--       Pos         = vector3(-304.747, -988.2321, 30.2),
--       Size        = {x = 3.0, y = 3.0, z = 1.5},
--       Type        = 27,
--       Color = {r = 255, g = 0, b = 0, a = 225}
--     },
--     VehicleSpawnPoint = {
--       Pos         = vector3(-314.3498, -976.5259, 31.08063),
--       Heading     = 246.54820251465
--     }
--   }
-- }
