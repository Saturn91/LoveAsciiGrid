local AsciiEngine = {}

AsciiEngine.__index = AsciiEngine

function AsciiEngine:new(options)
    options = options or {}
    local instance = setmetatable({}, self)
    instance.layers = {}
    instance.scale = options.scale or 1
    instance.font = options.font or love.graphics.newFont(12) -- Default font size
    instance.gridSize = options.gridSize or { width = 80, height = 50 } -- Default grid size

    return instance
end

function AsciiEngine:addLayer(layer)
    layer:initialize(self)
    table.insert(self.layers, layer)
end

function AsciiEngine:update(dt)
    for _, layer in ipairs(self.layers) do
        if layer.update then
            layer:update(dt)
        end
    end
end

function AsciiEngine:draw()
    for _, layer in ipairs(self.layers) do
        if layer.draw then
            layer:draw()
        end
    end
end

function AsciiEngine:adjustToWindowSize()
    local windowWidth, windowHeight = love.graphics.getDimensions()
    self.scale = math.min(windowWidth / 800, windowHeight / 600) -- Example scaling based on a base resolution
end

return AsciiEngine