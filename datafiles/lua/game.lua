Game = {}

function Game.quit(code)
    if code == nil and type(code) == "number" then
        code = 0
    end
    game_quit(code)
end