Config.Modules.Interactions = {
  EnableDebugging = false,
  UseExternalEventHandler = true, -- requires external_handler resource
  
  Objects = {
    -- ATM
    ["prop_fleeca_atm"] = {
      interactable = "atm",
      type = "fleeca",
    },
    ["prop_atm_01"] = {
      interactable = "atm",
      type = "atm",
    },
    ["prop_atm_02"] = {
      interactable = "atm",
      type = "atm",
    },
    ["prop_atm_03"] = {
      interactable = "atm",
      type = "atm",
    },
    -- Doors
    ["v_ilev_genbankdoor1"] = {
      interactable = "door",
      type = "door"
    },
    ["v_ilev_genbankdoor2"] = {
      interactable = "door",
      type = "door"
    },
    -- Vehicles
    ["coquette"] = {
      interactable = "vehicle",
      type = "vehicle"
    },
    ["cavalcade"] = {
      interactable = "vehicle",
      type = "vehicle"
    },
    -- Vending
    ["prop_vend_snak_01_tu"] = {
      prop = "prop_candy_pqs",
      name = "PQs",
      interactable = "vending",
      type = "vending"
    },
    ["prop_vend_soda_01"] = {
      prop = "prop_ecola_can",
      name = "E-Cola",
      interactable = "vending",
      type = "vending"
    },
    ["prop_vend_soda_02"] = {
      prop = "prop_ld_can_01",
      name = "Sprunk",
      interactable = "vending",
      type = "vending"
    },
    ["prop_vend_water_01"] = {
      prop = "prop_cs_script_bottle",
      name = "Water",
      interactable = "vending",
      type = "vending"
    },
    ["prop_vend_coffe_01"] = {
      prop = "prop_orang_can_01",
      name = "Coffee",
      interactable = "vending",
      type = "vending"
    },
    -- NPC Vending
    ["prop_hotdogstand_01"] = {
      prop = "prop_cs_hotdog_01",
      name = "Hot Dog",
      interactable = "npcvending",
      type = "npcvending"
    },
    ["prop_burgerstand_01"] = {
      prop = "prop_cs_burger_01",
      name = "Burger",
      interactable = "npcvending",
      type = "npcvending"
    }
  },

  NPCEntities = {
  --   -- Hot Dog Stands
    ["hotdog1"] = {
      model = "g_f_y_families_01",
      coords = vector3(-1516.351, -951.9783, 9.316168),
      heading = 320.42535400391,
      entity = "prop_hotdogstand_01",
      prop = "prop_cs_hotdog_01",
      eCoords = vector3(-1515.9130859375, -951.26025390625, 8.32891464233398)
    },

    ["hotdog2"] = {
      model = "g_f_y_families_01",
      coords = vector3(-1630.241, -1076.041, 13.06238),
      heading = 179.49523925781,
      entity = "prop_hotdogstand_01",
      prop = "prop_cs_hotdog_01",
      eCoords = vector3(-1630.15234375, -1076.7509765625, 12.01726913452148)
    },

    ["hotdog3"] = {
      model = "g_f_y_families_01",
      coords = vector3(-1638.03, -1083.291, 13.07571),
      heading = 234.77383422852,
      entity = "prop_hotdogstand_01",
      prop = "prop_cs_hotdog_01",
      eCoords = vector3(-1637.45556640625, -1083.6231689453126, 12.05265426635742)
    },

    ["hotdog4"] = {
      model = "g_f_y_families_01",
      coords = vector3(-1683.452, -1124.266, 13.15217),
      heading = 109.55183410645,
      entity = "prop_hotdogstand_01",
      prop = "prop_cs_hotdog_01",
      eCoords = vector3(-1684.056640625, -1124.6685791015626, 12.14759445190429)
    },

    ["hotdog5"] = {
      model = "g_f_y_families_01",
      coords = vector3(-1720.065, -1103.902, 13.01745),
      heading = 43.118553161621,
      entity = "prop_hotdogstand_01",
      prop = "prop_cs_hotdog_01",
      eCoords = vector3(-1720.64208984375, -1103.3682861328126, 12.01334381103515)
    },

    ["hotdog6"] = {
      model = "g_f_y_families_01",
      coords = vector3(-1772.078, -1160.518, 13.01805),
      heading = 53.71923828125,
      entity = "prop_hotdogstand_01",
      prop = "prop_cs_hotdog_01",
      eCoords = vector3(-1772.726806640625, -1160.2430419921876, 12.01795578002929)
    },

    ["hotdog7"] = {
      model = "g_f_y_families_01",
      coords = vector3(-1835.359, -1234.005, 13.01728),
      heading = 39.069496154785,
      entity = "prop_hotdogstand_01",
      prop = "prop_cs_hotdog_01",
      eCoords = vector3(-1835.74169921875, -1233.313720703125, 12.01795578002929)
    },

    -- Burger Stands
    ["burger1"] = {
      model = "g_f_y_families_01",
      coords = vector3(-1692.087, -1136.143, 13.15225),
      heading = 4.2853965759277,
      entity = "prop_burgerstand_01",
      prop = "prop_cs_burger_01",
      eCoords = vector3(-1692.6435546875, -1135.1192626953126, 12.14330673217773)
    },

    ["burger2"] = {
      model = "g_f_y_families_01",
      coords = vector3(-1693.779, -1072.841, 13.01744),
      heading = 51.467578887939,
      entity = "prop_burgerstand_01",
      prop = "prop_cs_burger_01",
      eCoords = vector3(-1694.760986328125, -1072.5194091796876, 12.01250839233398)
    },

    ["burger3"] = {
      model = "g_f_y_families_01",
      coords = vector3(-1784.696, -1175.674, 13.02102),
      heading = 48.503238677979,
      entity = "prop_burgerstand_01",
      prop = "prop_cs_burger_01",
      eCoords = vector3(-1785.740478515625, -1175.4796142578126, 12.01726913452148)
    },

    ["burger4"] = {
      model = "g_f_y_families_01",
      coords = vector3(-1856.572, -1224.4, 13.02216),
      heading = 324.30230712891,
      entity = "prop_burgerstand_01",
      prop = "prop_cs_burger_01",
      eCoords = vector3(-1856.30224609375, -1223.4124755859376, 12.01726913452148)
    }
  }
}
