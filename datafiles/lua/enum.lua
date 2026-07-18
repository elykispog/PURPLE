function CreateEnum(tbl)
    return setmetatable({}, {
        __index = tbl,
        __newindex = function()
            error("Errors: Attempt to modify a read-only enum.", 2)
        end,
        __metatable = false
    })
end