local Layer = {}
Layer.__index = Layer

local function newCell()
    return {glyph = nil, color = {1, 1, 1, 1}, background = nil, sprite = nil, ox = 0, oy = 0}
end

local function hasContent(cell)
    return cell.glyph or cell.sprite or cell.background
end

function Layer.new(id)
    if not id then error("Layer requires an id") end
    return setmetatable({id = id, grid = nil, cells = {}, canvas = nil, isDirty = true}, Layer)
end

function Layer:_init(grid)
    self.grid = grid
    self.cells = {}
    for y = 1, grid.rows do
        self.cells[y] = {}
        for x = 1, grid.cols do
            self.cells[y][x] = newCell()
        end
    end
    self.canvas = nil
    self.isDirty = true
end

function Layer:set(x, y, cell)
    if x < 1 or x > self.grid.cols or y < 1 or y > self.grid.rows then return end
    local c = self.cells[y][x]
    c.glyph      = cell.glyph
    c.color      = cell.color or {1, 1, 1, 1}
    c.background = cell.background
    c.sprite     = cell.sprite
    c.ox         = cell.ox or 0
    c.oy         = cell.oy or 0
    self.isDirty = true
end

function Layer:get(x, y)
    if x < 1 or x > self.grid.cols or y < 1 or y > self.grid.rows then return nil end
    return self.cells[y][x]
end

function Layer:clearAt(x, y)
    self:set(x, y, {})
end

function Layer:clear()
    for y = 1, self.grid.rows do
        for x = 1, self.grid.cols do
            local c = self.cells[y][x]
            c.glyph = nil
            c.color = {1, 1, 1, 1}
            c.background = nil
            c.sprite = nil
            c.ox = 0
            c.oy = 0
        end
    end
    self.isDirty = true
end

function Layer:write(x, y, text, color, background)
    color = color or {1, 1, 1, 1}
    for i = 1, #text do
        local px = x + i - 1
        if px > self.grid.cols or y > self.grid.rows then break end
        self:set(px, y, {glyph = text:sub(i, i), color = color, background = background})
    end
end

function Layer:fill(x1, y1, x2, y2, cell)
    local sx, ex = math.min(x1, x2), math.max(x1, x2)
    local sy, ey = math.min(y1, y2), math.max(y1, y2)
    for y = sy, ey do
        for x = sx, ex do
            self:set(x, y, cell)
        end
    end
end

function Layer:border(cell)
    local cols, rows = self.grid.cols, self.grid.rows
    for x = 1, cols do
        self:set(x, 1, cell)
        self:set(x, rows, cell)
    end
    for y = 2, rows - 1 do
        self:set(1, y, cell)
        self:set(cols, y, cell)
    end
end

function Layer:_drawCell(x, y, charWidth, charHeight)
    local cell = self.cells[y][x]
    if not hasContent(cell) then return end

    local drawX = (x - 1) * charWidth + cell.ox
    local drawY = (y - 1) * charHeight + cell.oy

    if cell.background then
        love.graphics.setColor(cell.background)
        love.graphics.rectangle("fill", drawX, drawY, charWidth, charHeight)
    end

    if cell.sprite then
        love.graphics.setColor(cell.color)
        cell.sprite:draw(drawX, drawY, {
            scaleX = charWidth / cell.sprite.width,
            scaleY = charHeight / cell.sprite.height,
        })
    elseif cell.glyph and cell.glyph ~= " " then
        love.graphics.setColor(cell.color)
        love.graphics.print(cell.glyph, drawX, drawY)
    end
end

function Layer:_renderToCanvas(charWidth, charHeight)
    local scale = self.grid.scale
    local canvasW = math.max(1, math.ceil(self.grid.cols * charWidth * scale))
    local canvasH = math.max(1, math.ceil(self.grid.rows * charHeight * scale))

    if not self.canvas or self.canvas:getWidth() ~= canvasW or self.canvas:getHeight() ~= canvasH then
        self.canvas = love.graphics.newCanvas(canvasW, canvasH)
    end

    love.graphics.push()
    love.graphics.origin()
    love.graphics.scale(scale, scale)
    love.graphics.setFont(self.grid.font)
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(0, 0, 0, 0)

    for y = 1, self.grid.rows do
        for x = 1, self.grid.cols do
            self:_drawCell(x, y, charWidth, charHeight)
        end
    end

    love.graphics.setCanvas()
    love.graphics.pop()
    self.isDirty = false
end

function Layer:_draw(charWidth, charHeight)
    if self.isDirty then
        self:_renderToCanvas(charWidth, charHeight)
    end
    local scale = self.grid.scale
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.push()
    love.graphics.scale(1 / scale, 1 / scale)
    love.graphics.draw(self.canvas, 0, 0)
    love.graphics.pop()
end

return Layer
