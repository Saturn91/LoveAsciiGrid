require("spriteSheet.Sprite")

SpriteSheet = {}
SpriteSheet.__index = SpriteSheet

local cashedSpriteSheets = {}

function SpriteSheet.new(imagePath, options)
    local options = options or {}
    options.gridWidth = options.gridWidth or 16
    options.gridHeight = options.gridHeight or 16
    options.path = imagePath

    local id = options.id or imagePath

    if cashedSpriteSheets[id] then
        return cashedSpriteSheets[id]
    end

    local spriteSheet = setmetatable({
        id = id,
        image = love.graphics.newImage(imagePath),
        gridWidth = options.gridWidth,
        gridHeight = options.gridHeight,
        sprites = {}
    }, SpriteSheet)

    cashedSpriteSheets[id] = spriteSheet

    return spriteSheet
end

function SpriteSheet:getSprite(pos, options)
    local options = options or {
        gridWidth = self.gridWidth,
        gridHeight = self.gridHeight
    }

    if self.sprites[pos.x] and self.sprites[pos.x][pos.y] then
        return self.sprites[pos.x][pos.y]
    end

    -- Create new quad and cache it
    local quad = love.graphics.newQuad(
        pos.x * options.gridWidth,
        pos.y * options.gridHeight,
        options.gridWidth,
        options.gridHeight,
        self.image:getDimensions()
    )

    if self.sprites[pos.x] == nil then
        self.sprites[pos.x] = {}
    end

    self.sprites[pos.x][pos.y] = Sprite.new(quad, self.id)

    return self.sprites[pos.x][pos.y]
end

function SpriteSheet.drawSprite(sprite, x, y, options)
    sprite:draw(x, y, options)
end

function SpriteSheet.getById(id)
    return cashedSpriteSheets[id]
end