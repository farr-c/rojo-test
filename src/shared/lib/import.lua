local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local modules = ReplicatedStorage.Shared:GetDescendants()

if RunService:IsServer() then
    table.insert(modules, game.ServerScriptService:GetDescendants())
else
    table.insert( modules, ReplicatedStorage.Client:GetDescendants())
end



local metatable = {
    __index = function (self, key)
        for _,v in pairs(modules) do 
            if v.Name == key then
                print("found module!", key)
                self[key] = v
                return v
            end
        end
        error(key.. "was not found!")
    end
    
}

local moduleLib = setmetatable({}, metatable)

function import(moduleName)
    return require(moduleLib[moduleName])
end

return import

