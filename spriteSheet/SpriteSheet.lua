local Sprite = require("spriteSheet.Sprite")

local SpriteSheet = {}
SpriteSheet.__index = SpriteSheet

local cache = {}

function SpriteSheet.new(imagePath, options)
    options = options or {}
    local id = options.id or imagePath
    if cache[id] then return cache[id] end

    local self = setmetatable({}, SpriteSheet)
    self.id         = id
    self.image      = love.graphics.newImage(imagePath)
    self.cellWidth  = options.gridWidth  or 16
    self.cellHeight = options.gridHeight or 16
    self.sprites    = {}
    cache[id] = self
    return self
end

function SpriteSheet:getSprite(col, row)
    if not self.sprites[col] then self.sprites[col] = {} end
    if self.sprites[col][row] then return self.sprites[col][row] end

    local quad = love.graphics.newQuad(
        col * self.cellWidth,
        row * self.cellHeight,
        self.cellWidth,
        self.cellHeight,
        self.image:getDimensions()
    )
    self.sprites[col][row] = Sprite.new(quad, self.image)
    return self.sprites[col][row]
end

return SpriteSheet
