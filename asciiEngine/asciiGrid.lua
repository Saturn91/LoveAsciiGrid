require("spriteSheet.SpriteSheet")

local AsciiGrid = {}

AsciiGrid.__index = AsciiGrid

function AsciiGrid:new(id, options)
    local options = options or {}

    if options.blocking == false then
        options.blocking = false
    else
        options.blocking = true
    end

    if id == nil then error("AsciiGrid requires an id") end
    return setmetatable({
        id = id,
        blocking = options.blocking,
        engine = nil,
        cells = {},
        viewport = {
            x = 1,
            y = 1,
        },
        canvas = nil,
        dirty = true,
    }, self)
end

function AsciiGrid:initialize(engine, options)
    
    self.engine = engine
    self.cells = {}
    self.canvas = nil
    self.dirty = true
    self.viewport.rows = engine.gridRows
    self.viewport.cols = engine.gridCols

    local cols, rows =  engine:getGridSize()
    
    -- Initialize grid cells
    for y = 1, rows do
        self.cells[y] = {}
        for x = 1, cols do
            self.cells[y][x] = GridCell.new(x, y)
        end
    end
end

function AsciiGrid:setCell(x, y, options)
    local options = options or {}
    local cols, rows = self.engine:getGridSize()

    if x >= 1 and x <= cols and y >= 1 and y <= rows then
        local cell = self.cells[y][x]

        cell.glyph           = options.glyph
        cell.color           = options.color or {1, 1, 1, 1}
        cell.backgroundColor = options.backgroundColor
        cell.sprite          = options.sprite
        cell.offsetX         = options.offsetX or 0
        cell.offsetY         = options.offsetY or 0
        self.dirty = true
    end
end

function AsciiGrid:getCell(x, y)
    local cols, rows = self.engine:getGridSize()
    
    if x >= 1 and x <= cols and y >= 1 and y <= rows then
        return self.cells[y][x]
    end
    return nil
end

function AsciiGrid:clearCell(x, y, options)
   local cols, rows = self.engine:getGridSize()
    
    if x >= 1 and x <= cols and y >= 1 and y <= rows then
        self:setCell(x, y, options)
    end
end

function AsciiGrid:clear(options)
    local cols, rows = self.engine:getGridSize()

    for y = 1, rows do
        for x = 1, cols do
            self:clearCell(x, y, options)
        end
    end
    self.dirty = true
end

function AsciiGrid:fillRect(x1, y1, x2, y2, glyph, color, backgroundColor)
    local startX, endX = math.min(x1, x2), math.max(x1, x2)
    local startY, endY = math.min(y1, y2), math.max(y1, y2)
    
    for y = startY, endY do
        for x = startX, endX do
            self:setCell(x, y, {glyph = glyph, color = color, backgroundColor = backgroundColor})
        end
    end
end

function AsciiGrid:drawBorder(options)
    local options = options or {}
    local glyph = options.glyph or "█"
    local color = options.color or {1, 1, 1, 1}
    local sprite = options.sprite
    
    -- Top and bottom borders
    for x = self.viewport.x, self.viewport.x + self.viewport.cols - 1 do
        self:setCell(x, self.viewport.y, {glyph = glyph, color = color, sprite = sprite})
        self:setCell(x, self.viewport.y + self.viewport.rows - 1, {glyph = glyph, color = color, sprite = sprite})
    end
    
    -- Left and right borders
    for y = self.viewport.y, self.viewport.y + self.viewport.rows - 1 do
        self:setCell(self.viewport.x, y, {glyph = glyph, color = color, sprite = sprite})
        self:setCell(self.viewport.x + self.viewport.cols - 1, y, {glyph = glyph, color = color, sprite = sprite})
    end
end

function AsciiGrid:writeText(x, y, text, color, backgroundColor)
    color = color or {1, 1, 1, 1}
    
    local cols, rows = self.engine:getGridSize()
    
    for i = 1, #text do
        local char = text:sub(i, i)
        local posX = x + i - 1
        
        if posX <= cols and y <= rows then
            self:setCell(posX, y, {glyph = char, color = color, backgroundColor = backgroundColor})
        else
            break -- Stop if we exceed grid boundaries
        end
    end
end

function AsciiGrid:isDrawableCell(x, y, debug)
    if x < self.viewport.x or x >= self.viewport.x + self.viewport.cols then return false end
    if y < self.viewport.y or y >= self.viewport.y + self.viewport.rows then return false end
    if x < 1 or y < 1 then return false end
    if y < 1 or y > #self.cells then return false end
    if x < 1 or x > #self.cells[y] then return false end

    if debug then
        Log.log(self.cells[y][x])
    end
    
    if self.cells[y][x].glyph or self.cells[y][x].sprite or self.cells[y][x].backgroundColor then
        return true
    end

    return false
end

function AsciiGrid:drawCell(x, y, charWidth, charHeight)
    if not self:isDrawableCell(x, y) then return false end

    local cell = self.cells[y][x]

    if cell then
        local drawX = (x - 1) * charWidth  + (cell.offsetX or 0)
        local drawY = (y - 1) * charHeight + (cell.offsetY or 0)

        -- Draw background if specified
        if cell.backgroundColor then
            love.graphics.setColor(cell.backgroundColor)
            love.graphics.rectangle("fill", drawX, drawY, charWidth, charHeight)
        end
        -- Draw Sprite
        if cell.sprite then
            love.graphics.setColor(cell.color or {1, 1, 1, 1})
            cell.sprite:draw(drawX, drawY, {scaleX = charWidth / cell.sprite.width, scaleY = charHeight / cell.sprite.height})

        -- Draw character
        elseif cell.glyph and cell.glyph ~= ' ' then
            love.graphics.setColor(cell.color or {1, 1, 1, 1})
            love.graphics.print(cell.glyph, drawX, drawY)
        end

        return true
    end

    return false
end

-- Like drawCell but ignores offsetX/offsetY — used when rendering to a cached canvas.
function AsciiGrid:drawCellBuffered(x, y, charWidth, charHeight)
    if not self:isDrawableCell(x, y) then return false end

    local cell = self.cells[y][x]
    if cell then
        local drawX = (x - 1) * charWidth
        local drawY = (y - 1) * charHeight

        if cell.backgroundColor then
            love.graphics.setColor(cell.backgroundColor)
            love.graphics.rectangle("fill", drawX, drawY, charWidth, charHeight)
        end
        if cell.sprite then
            love.graphics.setColor(cell.color or {1, 1, 1, 1})
            cell.sprite:draw(drawX, drawY, {scaleX = charWidth / cell.sprite.width, scaleY = charHeight / cell.sprite.height})
        elseif cell.glyph and cell.glyph ~= ' ' then
            love.graphics.setColor(cell.color or {1, 1, 1, 1})
            love.graphics.print(cell.glyph, drawX, drawY)
        end
        return true
    end
    return false
end

-- Re-renders all cells onto self.canvas. Creates the canvas at scaled
-- (screen-space) dimensions so it never exceeds GPU texture size limits,
-- then applies the same scale factor inside so cells are drawn to fit.
function AsciiGrid:renderToCanvas(charWidth, charHeight)
    local cols, rows = self.engine:getGridSize()
    local scale = self.engine.scale

    -- Build a canvas that matches the final on-screen pixel size so we stay
    -- well within GPU max-texture-size limits regardless of font size or grid
    -- dimensions.  math.max(1, …) guards against degenerate zero sizes.
    local canvasWidth  = math.max(1, math.ceil(cols * charWidth  * scale))
    local canvasHeight = math.max(1, math.ceil(rows * charHeight * scale))

    if not self.canvas
        or self.canvas:getWidth()  ~= canvasWidth
        or self.canvas:getHeight() ~= canvasHeight
    then
        self.canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
    end

    love.graphics.push()
    love.graphics.origin()
    love.graphics.scale(scale, scale)
    love.graphics.setFont(self.engine.font)
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(0, 0, 0, 0)

    for y = 1, rows do
        for x = 1, cols do
            self:drawCellBuffered(x, y, charWidth, charHeight)
        end
    end

    love.graphics.setCanvas()
    love.graphics.pop()

    self.dirty = false
end

-- Called by the engine for non-advanced layers. Re-renders to canvas only when dirty.
function AsciiGrid:drawBuffered(charWidth, charHeight)
    if self.dirty then
        self:renderToCanvas(charWidth, charHeight)
    end
    -- The engine has already applied scale(self.scale, self.scale) before
    -- calling us.  Our canvas is pre-rendered at that scale, so undo the
    -- engine's scale before blitting to avoid double-scaling.
    local scale = self.engine.scale
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.push()
    love.graphics.scale(1 / scale, 1 / scale)
    love.graphics.draw(self.canvas, 0, 0)
    love.graphics.pop()
end

function AsciiGrid:setViewport(options)
    options = options or {}
    if options.x then self.viewport.x = options.x end
    if options.y then self.viewport.y = options.y end
    if options.cols then self.viewport.cols = options.cols end
    if options.rows then self.viewport.rows = options.rows end
end

return AsciiGrid