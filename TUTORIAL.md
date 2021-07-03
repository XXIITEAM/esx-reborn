# Module Creation Tutorial By ESX Framework

### How Are Modules Different From Normal Resources

Modules all exist within 1 resource. There is no longer many resources to install for ESX Framework, as everything is contained within a single resource. You'll simply add files to the esx-reborn resource when you wish to add modules, rather than having to add resource files and update server.cfg

### What Are Modules?

Modules are a "resource" within a "resource", for lack of better description.

There are 3 kinds of modules currently in ESX Reborn.
* Core Modules - The Core of ESX Reborn
* Base Modules - The more modular code that is part of the official ESX Reborn code
* User Modules - End-user created modules will go here

Within each module, there are 4 possible folders:
* client - All client logic (as usual)
* server - All server logic (as usual)
* shared - Shared logic (as usual)
* data - Locales, HTML, and other files will go here
* migrations - SQL to be imported automatically will go inside of here and be named 0.sql

Client/Server/Shared are divided into 3 files:
* main.lua - Threads
* module.lua - Variables and Functions
* events.lua - Events

### Enabling/Disabling Modules

In each module folder (`__core__`,`__base__`,`__user__`) there is a `modules.json` file. When you add a module to these files, it will search for that folder and try to activate that module. You can easily disable modules by removing their string from the `modules.json`

### SQL in ESX-Reborn

In each module folder, if you need SQL for that module (most of the ESX Reborn SQL is declared in the core modules, but you can do these in Base and User Modules as well) it will search each module for the 0.sql, 1.sql and so on in the migrations folder for that module. (There is code that you need to add to the server-side events.lua in order for it to migrate)

### Importing Already Existing Modules

If you need to access other modules, it's a fairly simple system. By importing a module, you will gain access to that modules functions. For this example I will use a shared functions in `utils/shared/module.lua`: `module.string.random(length, recurse)` (Please note that you can only access client-side functions in client-side, and server-side functions in server-side, shared you can do both, provided you aren't doing anything that requires server-side only, or client-side only)

1. How to Import A Module

   * Top of lua file (can work in `events.lua`, `module.lua`, or `main.lua`)
   * `local utils = M('utils')`

2. Why Import A Module?

   * By importing a module, you gain access to all of that modules functions.
   * In the module itself, it will be created in the original module as `module.someFunction = function()`, but when you access it by importing it into other modules, since you declared it as `local utils = M('utils')` in your module you will access it with `utils.someFunction()`

### What's Different About Core Modules and Base Modules?

Core modules are not intended to be edited unless you have a more proficient knowledge of ESX Reborn. The config files and locale code is contained within the root ESX Reborn folders, and is not accessed the same way as base modules.

Base modules, everything for them is contained within the module itself, so you can more easily edit the base modules. The config will be in the /data folder and the locales will be in the /data folder. (See already made module.lua for a base module to see how to declare the locales, and config)

### Why This Format Instead of Resources?

We have a much cleaner architecture through modules, and through testing so far, it is much more optimized to not need to GetSharedObject in each resource anymore.

## Guidance On Creating Modules

This will be more in-depth, so try to follow along. There is no substitution for playing with it yourself to learn it, though.

This tutorial will be based around creating **User** modules.


### Part 1 - Creating A Module

![Folder Structure](https://i.iodine.gg/ac23b.png)

1. When you want to create a new module, the first step is to create the module folder inside of `__user__` folder.

2. After you create the folder, you want to create the client and server folders, and add the empty `module.lua`, `main.lua`, and `events.lua` inside of each folder.
   * It would look like this: `esx-reborn/modules/__user__/<moduleName>/client/module.lua` and so on.

### Part 2 - Migrations (If Any)

1. If you wish to add SQL to be imported automatically, you need to do the following:
   * Top of server-side `events.lua`: `local migrate = M('migrate')` (This will import the migrate module)
   * Actual event to enable migrations in module:
```
on("esx:db:ready", function()
  migrate.Ensure("vehicles", "core")
end)
```
   * `migrate.Ensure(moduleName, core/base/user)
   * It will search for `0.sql`, `1.sql` and so on inside of the migrations folder of that module for migrations to do. You can look at `__core__/vehicles/migrations/0.sql` for an example SQL file

### Part 3 - Config Files (If Any)

1. Config files (as long as it's not a **Core** module will be in `<moduleName>/data/config.lua`)
   * For client: Inside `<moduleName>/client/module.lua` add `module.Config = run('data/config.lua', {vector3 = vector3})['Config']`
   * For server: Inside `<moduleName>/server/module.lua` add `module.Config = run('data/config.lua', {vector3 = vector3})['Config']`
   * You can see `__base__/vehicleshop/data/config.lua` for examples on how to create the config
   * You will access Config variables in that file by using `module.Config.variableHere`
2. **Core** Module config files will be located in `esx-reborn/config/defaults` and they aren't require to be declared in individual module files as they are globals.

### Part 4 - Locale Files (If Any)

1. Locale files (as long as it's not a **Core** module will be in `<moduleName>/data/locales/`)
   * For client+server: Inside client/server module.lua add: 
```
local translations = run('data/locales/' .. Config.Locale .. '.lua')['Translations']
LoadLocale('vehicleshop', Config.Locale, translations)
```
   * See `__base__/vehicleshop/client/module.lua` for examples
2. **Core** Module locales will be located inside of `esx-reborn/locales` and they are globals as well.

### Part 5 - Events

1. Triggers are used differently in ESX Reborn:
   * **Client-side to Server-side:** `TriggerServerEvent()` = `emitServer()`
   * **Server-side to Client-side:** `TriggerClientEvent()` = `emitClient()`
   * **Server-side from Client-side:** `AddEventHandler()` = `onClient()`
   * **Client-side from Server-side:** `AddEventHandler()` = `onServer()`
   * **Client-side to Client-side:** `TriggerEvent()` = `emit()`
   * **Server-side to Server-side:** `TriggerEvent()` = `emit()`
   * **Client-side from Client-side:** `AddEventHandler()` = `on()`
   * **Server-side from Server-side:** `AddEventHandler()` = `on()`

2. You do not need to use RegisterNetEvent at all, as this is done automatically inside of ESX Reborn

### Part 6 = Callbacks

1. Callbacks in ESX Reborn are also different:
   * Send request to server: ESX.TriggerServerCallback() = request()
   * Get Request From Server: ESX.RegisterServerCallback() = onRequest()

### Part 7 = Functions

1. When you wish to create a function in a module:
   * declare the function as:
```
module.someFunction = function(param1, param2)
    -- code here
end
```

2. If you are accessing a function within the **SAME** module, you'll just use module.someFunction()
3. If you imported your module to another module with `local moduleName = M('moduleName')` and you want to access that function within that module, then you will access it in that module with `moduleName.someFunction()`

### Part 8 = Threads

1. There are multiple way to create threads, but it's different than normal FiveM:
   * Generic thread: (This will automatically run every 5000ms without needing any while true)(Downside: You cannot break this thread)
```
ESX.SetInterval(5000, function()
  if module.IsInShopMenu then
    emitServer('vehicleshop:stillUsingMenu')
  end
end)
```
   * Breakable thread: (Will run every 50ms, until ESX.ClearInterval(interval) is run)
```
    interval = ESX.SetInterval(50, function()
      if HasAnimDictLoaded(model) then
        ESX.ClearInterval(interval)

        if cb ~= nil then
          cb()
        end
      end
    end)
```
