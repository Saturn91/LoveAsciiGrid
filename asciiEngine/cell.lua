local Cell = {}

Cell.__index = Cell

function Cell:new(glyph, color)
    local instance = setmetatable({}, self)
    instance.glyph = glyph or ' '
    instance.color = color or {1, 1, 1, 1}
    return instance
end

return Cell