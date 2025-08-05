local Char = {}
Char.__index = Char

function Char:new(x, y, options)
    options = options or {}
    local instance = setmetatable({}, self)
    instance.x = x
    instance.y = y
    instance.glyph = options.glyph or ' '
    instance.color = options.color or {1, 1, 1, 1} -- Default to white (LOVE2D color format)
    instance.backgroundColor = options.backgroundColor -- Can be nil for transparent
    return instance
end

function Char:setGlyph(glyph)
    self.glyph = glyph
end

function Char:setColor(color)
    self.color = color
end

function Char:setBackgroundColor(backgroundColor)
    self.backgroundColor = backgroundColor
end

function Char:clone()
    return Char:new(self.x, self.y, {
        glyph = self.glyph,
        color = {self.color[1], self.color[2], self.color[3], self.color[4]},
        backgroundColor = self.backgroundColor and {self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4]} or nil
    })
end

return Char