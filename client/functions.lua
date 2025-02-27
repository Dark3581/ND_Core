function GetCoreObject()
    return NDCore
end

function NDCore.Functions.GetSelectedCharacter()
    return NDCore.SelectedCharacter
end

function NDCore.Functions.GetCharacters()
    return NDCore.Characters
end

-- Callbacks are licensed under LGPL v3.0
-- <https://github.com/overextended/ox_lib>
NDCore.callback = {}
local events = {}

RegisterNetEvent("ND:callbacks", function(key, ...)
	local cb = events[key]
	return cb and cb(...)
end)

local function triggerCallback(_, name, cb, ...)
    local key = ("%s:%s"):format(name, math.random(0, 100000))
	TriggerServerEvent(("ND:%s_cb"):format(name), key, ...)
    
    local promise = not cb and promise.new()

	events[key] = function(response, ...)
        response = { response, ... }
		events[key] = nil

		if promise then
			return promise:resolve(response)
		end

        if cb then
            cb(table.unpack(response))
        end
	end

	if promise then
		return table.unpack(Citizen.Await(promise))
	end
end

setmetatable(NDCore.callback, {
	__call = triggerCallback
})

function NDCore.callback.await(name, ...)
    return triggerCallback(nil, name, false, ...)
end

function NDCore.callback.register(name, callback)
    RegisterNetEvent(("ND:%s_cb"):format(name), function(key, ...)
        TriggerServerEvent("ND:callbacks", key, callback(...))
    end)
end