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

### What's Different About Core Modules and Base Modules?

Core modules are not intended to be edited unless you have a more proficient knowledge of ESX Reborn. The config files and locale code is contained within the root ESX Reborn folders, and is not accessed the same way as base modules.

Base modules, everything for them is contained within the module itself, so you can more easily edit the base modules. The config will be in the /data folder and the locales will be in the /data folder. (See already made module.lua for a base module to see how to declare the locales, and config)

### Why This Format Instead of Resources?

We have a much cleaner architecture through modules, and through testing so far, it is much more optimized to not need to GetSharedObject in each resource anymore.

## Guidance On Creating Modules

This will be more in-depth, so try to follow along. There is no substitution for playing with it yourself to learn it, though.

This tutorial will be based around creating **User** modules.


### Part 1 - Creating A Module

https://i.iodine.gg/ac23b.png

1. When you want to create a new module, the first step is to create the module folder inside of `__user__` folder.

2. After you create the folder, you want to create the client and server folders, and add the empty `module.lua`, `main.lua`, and `events.lua` inside of each folder.
   * It would look like this: `esx-reborn/modules/__user__/<moduleName>/client/module.lua` and so on.

