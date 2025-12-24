Sprite = {}
Sprite.__index = Sprite

function Sprite.new(quad, id)
    local instance = setmetatable({}, Sprite)
    instance.quad = quad
    instance.id = id
    return instance
end

function Sprite:draw(x, y, options)
    local options = options or {}
    local scaleX = options.scaleX or 1
    local scaleY = options.scaleY or 1
    local rotation = options.rotation or 0

    love.graphics.draw(
        SpriteSheet.getById(self.id).image,
        self.quad,
        x,
        y,
        rotation,
        scaleX,
        scaleY
    )
end