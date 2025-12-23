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
        image = love.graphics.newImage(imagePath),
        gridWidth = options.gridWidth,
        gridHeight = options.gridHeight,
        quads = {}
    }, SpriteSheet)

    cashedSpriteSheets[id] = spriteSheet

    return spriteSheet
end

function SpriteSheet:getSprite(pos, options)
    local options = options or {
        gridWidth = self.gridWidth,
        gridHeight = self.gridHeight
    }

    if self.quads[pos.x] and self.quads[pos.x][pos.y] then
        return self.quads[pos.x][pos.y]
    end

    -- Create new quad and cache it
    local quad = love.graphics.newQuad(
        pos.x * options.gridWidth,
        pos.y * options.gridHeight,
        options.gridWidth,
        options.gridHeight,
        self.image:getDimensions()
    )

    if self.quads[pos.x] == nil then
        self.quads[pos.x] = {}
    end

    self.quads[pos.x][pos.y] = quad

    return quad
end

function SpriteSheet:drawSprite(pos, x, y, options)
    local quad = self:getSprite(pos, options)
    love.graphics.draw(self.image, quad, x, y)
end

function SpriteSheet.getById(id)
    return cashedSpriteSheets[id]
end