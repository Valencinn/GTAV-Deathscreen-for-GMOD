include("autorun/sh_deathscreen.lua")
MsgC(Color(0, 255, 0), "[Deathscreen] ", Color(255, 255, 255), "Cargado exitosamente\n")

print("cl_tutorial file loaded!")

surface.CreateFont( "tutorial_24", {
  font = "Roboto",
  size = 24,
  weight = 1000,
})

surface.CreateFont("GTA_Font", {
    font = "PricedownBl-Regular",
    size = 120,
    weight = 800,
})

local tab = {
	[ "$pp_colour_addr" ] = 0.,
	[ "$pp_colour_addg" ] = 0.,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 1,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0.,
	[ "$pp_colour_mulb" ] = 0
}

local deathT
local fadeT = 4
local camDist = 0
net.Receive("deathscreen_sendDeath", function()
    surface.PlaySound("deathscreen/wasted.mp3")
    deathT = CurTime()
    camDist = 0
    timer.Create(LocalPlayer():SteamID() .. "respawnTime", DEATHSCREEN.RespawnTime, 1, function() end)
end)

net.Receive("deathscreen_removeDeath", function()
    deathT = nil
    tab["$pp_colour_brightness" ] = 0
    tab["$pp_colour_colour" ] = 1
end)

hook.Add( "RenderScreenspaceEffects", "DeathScreenColorMods", function()
    if deathT and deathT + fadeT > CurTime() then
        local colorSub =  (.9 / fadeT) * FrameTime()
        local brightnessSub = (.2 / fadeT) * FrameTime()
        tab["$pp_colour_brightness"] = tab["$pp_colour_brightness"] - brightnessSub
        tab["$pp_colour_colour" ] = tab["$pp_colour_colour" ] - colorSub
    end
    DrawColorModify( tab )
end)

local red = Color(203, 91, 82)
hook.Add( "HUDPaint", "DrawDeathScreen", function()
    local ply = LocalPlayer()
    if ply:Alive() then return end
    if not deathT then return end
    local scrw, scrh = ScrW(), ScrH()
    local r = camDist / 25
    surface.SetAlphaMultiplier(r)
    draw.SimpleText("WASTED", "GTA_Font", scrw * .5 - 2, scrh * .5 - 2, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("WASTED", "GTA_Font", scrw * .5, scrh * .5, red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    if not timer.Exists(ply:SteamID().. "respawnTime") then
        draw.SimpleText("Presione la barra espaciadora para respawnear.", "tutorial_24", scrw * .5, scrh * .55, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)

hook.Add("CalcView", "DeathscreenCalcView", function(ply, origin, angles, fov, znear, zfar)
    if ply:Alive() then return end

    local view = {}

    camDist = math.Clamp(camDist + 5 * FrameTime(), 0, 50)
    local newAng = Angle(angles.x + 5 * math.sin(CurTime()* .5), angles.y, angles.z + 10 * math.sin(CurTime()* .5))
    view.origin = origin - (newAng:Forward() * camDist)
    view.angles = newAng
    view.fov = fov
    view.drawviewer = true

    return view
end)