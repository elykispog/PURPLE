require("enum")

Actor = {}

Actor.__index = function(self, key)
    local value = rawget(Actor, key)
    if value ~= nil and key ~= "data" then
        return value
    end

    if self.id then
        if key == "x" then
            return handle_read_number(self.data, 0)
        elseif key == "y" then
            return handle_read_number(self.data, 8)
        elseif key == "frozen" then
            return handle_read_bool(self.data, 16)
        end
    end
end

function Actor:teleport_to(x, y)
    actor_teleport_to(self.id, x, y)
end

Actor.Facing = CreateEnum({
    Up = 0,
    Down = 1,
    Left = 2,
    Right = 3
})

function Actor:freeze()
    actor_freeze(self.id)
end

function Actor:unfreeze()
    actor_unfreeze(self.id)
end

function Actor:set_facing(direction)
    actor_set_facing(self.id, direction)
end

function actor(name)
    local self = setmetatable({}, Actor)

    self.id = handle_get("actor", name)
    assert(self.id >= 0, ("Unknown actor '%s'"):format(name))

    self.name = name;
    self.data = handle_get_data(self.id)

    return self
end