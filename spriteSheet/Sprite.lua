local Sprite = {}
Sprite.__index = Sprite

function Sprite.new(quad, image)
    local self = setmetatable({}, Sprite)
    self.quad  = quad
    self.image = image
    local _, _, w, h = quad:getViewport()
    self.width  = w
    self.height = h
    return self
end

function Sprite:draw(x, y, options)
    options = options or {}
    love.graphics.draw(
        self.image,
        self.quad,
        x, y,
        options.rotation or 0,
        options.scaleX   or 1,
        options.scaleY   or 1
    )
end

return Sprite
