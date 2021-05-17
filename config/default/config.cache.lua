Config.Modules.Cache = {
  -- in minutes, the amount of time between cache updates to the database
  ServerSaveInterval           = 10,
  EnableDebugging              = false,
  BasicCachedTables            = {
    "vehicles",
    "usedPlates"
  },
  IdentityCachedTables         = {
    "owned_vehicles",
    "identities"
  },
  BasicCachedTablesToUpdate    = {
  }
}
