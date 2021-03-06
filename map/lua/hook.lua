
function hook_UnitWakeUp(u, f)
	game.initHero(u)
end

function hook_SetUnitRescueRange(u, r, f)
    if jass.GetUnitTypeId(u) == 0 then
        if r + 0 == 23333 then
	        cmd.start()
        end
        return
    end
    if r < 0 then
        game[math.floor(0 - r)](u)
    else
        return f(u, r)
    end
end

timer.loop(30, true, function()
	hook.UnitWakeUp = hook_UnitWakeUp
	hook.SetUnitRescueRange = hook_SetUnitRescueRange
end)
