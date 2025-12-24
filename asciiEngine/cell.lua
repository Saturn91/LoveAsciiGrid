local Cell = {}

Cell.__index = Cell

--[[
    Creates a new Cell instance.
    @param glyph The character to display in the cell.
    @param options A table containing optional parameters:
        - color: The color of the glyph (default is white).
        - sprite: Quad An optional sprite to display instead of the glyph.]]

function Cell.new(glyph, options)
    local options = options or {}
    local instance = setmetatable({}, Cell)
    instance.glyph = glyph or ' '
    instance.color = options.color or {1, 1, 1, 1}
    instance.sprite = options.sprite
    return instance
end

return Cell