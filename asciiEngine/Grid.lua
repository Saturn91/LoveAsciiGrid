local Layer = require("asciiEngine.Layer")

local Grid = {}
Grid.__index = Grid

function Grid.new(options)
    options = options or {}
    local self = setmetatable({}, Grid)
    self.cols      = options.cols or 80
    self.rows      = options.rows or 25
    self.font      = options.font
    self.scale     = 1
    self.offsetX   = 0
    self.offsetY   = 0
    self.charWidth  = 0
    self.charHeight = 0
    self._layers   = {}
    self._layerMap = {}

    if self.font then
        self:_measureFont()
        self:_recalcScale()
    end

    return self
end

function Grid:_measureFont()
    self.charWidth  = self.font:getWidth("M")
    self.charHeight = self.font:getHeight()
end

function Grid:_recalcScale()
    if not self.font then return end
    local winW, winH = love.graphics.getDimensions()
    local gridW = self.cols * self.charWidth
    local gridH = self.rows * self.charHeight
    self.scale = math.min(winW / gridW, winH / gridH)
    self.offsetX = (winW - gridW * self.scale) / 2
    self.offsetY = (winH - gridH * self.scale) / 2
end

function Grid:_invalidateCanvases()
    for _, layer in ipairs(self._layers) do
        layer.canvas   = nil
        layer.isDirty  = true
    end
end

function Grid:setFont(font)
    self.font = font
    love.graphics.setFont(font)
    self:_measureFont()
    self:_recalcScale()
    self:_invalidateCanvases()
end

function Grid:setGridSize(cols, rows)
    self.cols = cols
    self.rows = rows
    self:_recalcScale()
    for _, layer in ipairs(self._layers) do
        layer:_init(self)
    end
end

function Grid:addLayer(id)
    if self._layerMap[id] then error("Layer '" .. id .. "' already exists") end
    local layer = Layer.new(id)
    layer:_init(self)
    self._layerMap[id] = layer
    table.insert(self._layers, layer)
    return layer
end

function Grid:layer(id)
    return self._layerMap[id]
end

function Grid:draw()
    love.graphics.push()
    love.graphics.translate(self.offsetX, self.offsetY)
    love.graphics.scale(self.scale, self.scale)
    love.graphics.setFont(self.font)

    for _, layer in ipairs(self._layers) do
        layer:_draw(self.charWidth, self.charHeight)
    end

    love.graphics.pop()
end

function Grid:resize()
    self:_recalcScale()
    self:_invalidateCanvases()
end

function Grid:getGridSize()
    return self.cols, self.rows
end

function Grid:getCharSize()
    return self.charWidth, self.charHeight
end

function Grid:getScale()
    return self.scale
end

function Grid:screenToGrid(sx, sy)
    local gx = math.floor((sx - self.offsetX) / (self.charWidth  * self.scale)) + 1
    local gy = math.floor((sy - self.offsetY) / (self.charHeight * self.scale)) + 1
    return math.max(1, math.min(self.cols, gx)), math.max(1, math.min(self.rows, gy))
end

function Grid:gridToScreen(gx, gy)
    return (gx - 1) * self.charWidth  * self.scale + self.offsetX,
           (gy - 1) * self.charHeight * self.scale + self.offsetY
end

return Grid
