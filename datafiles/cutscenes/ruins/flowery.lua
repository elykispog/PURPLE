require("actor")
require("game")

local player = actor("player")

print("Does something, haha");

player:freeze();

wait(1000);

player:unfreeze();