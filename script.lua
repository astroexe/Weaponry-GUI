local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/astroexe/Weaponry-GUI/main/UILibrary"))()
main = lib:Window()
local ClientVars = getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.WeaponryClientFramework).UpdateBackpackButtons
local RecoilHandler = require(game:GetService("ReplicatedStorage").ClientModules.RecoilCamHandler)
local RayCastClient = require(game:GetService("ReplicatedStorage").ClientModules.RayCastClient)

Client = {
    Toggles = {
        InfAmmo = false,
        SilentAim = false,
        NoSpread = false,
        NoRecoil = false
    }
}

local Main = main:Tab("Main")
Main:Toggle('Silent Aim',function(state)
    Client.Toggles.SilentAim = state
end)
Main:Toggle('Inf Ammo',function(state)
    Client.Toggles.InfAmmo = state
end)
Main:Toggle('No Spread',function(state)
    Client.Toggles.NoSpread = state
end)
Main:Toggle('No Recoil',function(state)
    Client.Toggles.NoRecoil = state
end)
OldRecoil = RecoilHandler.accelerate
RecoilHandler.accelerate = function(...)
    if Client.Toggles.NoRecoil then
        return
    end
    return OldRecoil(...)
end
game:GetService('RunService').RenderStepped:Connect(function()
    if Client.Toggles.InfAmmo then
        pcall(function() getupvalue(ClientVars,1)[1].WeaponStates.CurrentAmmo = getupvalue(ClientVars,1)[1].WeaponStats.MaxAmmo end)
    end
    if Client.Toggles.NoSpread then
        pcall(function() getupvalue(ClientVars,1)[1].WeaponStates.CurrentAccuracy = 0 end)
    end
end)
function GetClosestPlr()
    Plr = nil
    MaxDis = math.huge
    for i,v in pairs(game.Players.GetPlayers(game.Players)) do
        if v ~= game.Players.LocalPlayer and v.TeamColor ~= game.Players.LocalPlayer.TeamColor and v.Character and v.Character.FindFirstChild(v.Character,"Head") then
            local Pos, Vis = game.Workspace.CurrentCamera.WorldToScreenPoint(game.Workspace.CurrentCamera,v.Character.FindFirstChild(v.Character,"Head").Position)
            if Vis then
                mag = (Vector2.new(Pos.X,Pos.Y) - Vector2.new(game.Players.LocalPlayer.GetMouse(game.Players.LocalPlayer).X,game.Players.LocalPlayer.GetMouse(game.Players.LocalPlayer).Y)).magnitude
                if mag < MaxDis and mag <= 200 then
                    Plr = v
                    MaxDis = mag
                end
            end
        end
    end
    return Plr
end
Old = RayCastClient.CastRayMouse
RayCastClient.CastRayMouse = function(p31,p32,p33)
    if Client.Toggles.SilentAim and GetClosestPlr() ~= nil then
        NewPoint = p31:WorldToScreenPoint(GetClosestPlr().Character.Head.Position)
        p32 = NewPoint.X
        p33 = NewPoint.Y + game:GetService('GuiService'):GetGuiInset().Y;
    end
    return Old(p31,p32,p33)
end
