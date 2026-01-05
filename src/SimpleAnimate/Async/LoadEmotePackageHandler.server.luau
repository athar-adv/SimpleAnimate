local LoadPackage = require("../Utility/LoadPackage")

local loadEmotePackage = Instance.new("RemoteFunction")
loadEmotePackage.Name = "loadEmotePackage"
loadEmotePackage.Parent = script.Parent
script.Parent = loadEmotePackage

loadEmotePackage.OnServerInvoke = LoadPackage.getPlayerEmotePackage