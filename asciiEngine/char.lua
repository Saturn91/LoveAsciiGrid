local Char = {}
Char.__index = Char

function Char:new(x, y, options)
    options = options or {}
    local instance = setmetatable({}, self)
    instance.x = x
    instance.y = y
    instance.glyph = options.glyph or ' '
    instance.color = options.color or { r = 255, g = 255, b = 255 } -- Default to white
    instance.backgroundColor = options.backgroundColor
    return instance
end

return Char