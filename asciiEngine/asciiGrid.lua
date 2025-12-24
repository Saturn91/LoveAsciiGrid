local AsciiGrid = {}

AsciiGrid.__index = AsciiGrid

function AsciiGrid:new(id)
    if id == nil then error("AsciiGrid requires an id") end
    return setmetatable({id = id}, self)
end

function AsciiGrid:initialize(engine)
    self.engine = engine
    self.cells = {}

    local cols, rows = engine:getGridSize()
    
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
    local glyph = options.glyph
    local color = options.color or {1, 1, 1, 1}
    local backgroundColor = options.backgroundColor
    local sprite = options.sprite
    local cols, rows = self.engine:getGridSize()
    
    if x >= 1 and x <= cols and y >= 1 and y <= rows then
        local cell = self.cells[y][x]
        if glyph then cell.glyph = glyph end
        if color then cell.color = color end
        if backgroundColor then cell.backgroundColor = backgroundColor end
        cell.sprite = sprite
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
    local options = options or {}
    local glyph = options.glyph or ' '
    local color = options.color or {1, 1, 1, 1} -- White
    local backgroundColor = options.backgroundColor or nil
    local sprite = options.sprite or nil
    
    local cols, rows = self.engine:getGridSize()
    
    if x >= 1 and x <= cols and y >= 1 and y <= rows then
        self:setCell(x, y, {glyph = glyph, color = color, backgroundColor = backgroundColor, sprite = sprite})
    end
end

function AsciiGrid:clear(options)
    local options = options or {}
    local glyph = options.glyph or ' '
    local color = options.color or {1, 1, 1, 1} -- White
    local backgroundColor = options.backgroundColor or nil
    local sprite = options.sprite or nil
    
    local cols, rows = self.engine:getGridSize()
    
    for y = 1, rows do
        for x = 1, cols do
            self:setCell(x, y, {glyph = glyph, color = color, backgroundColor = backgroundColor, sprite = sprite})
        end
    end
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
    local glyph = options.glyph or "█"
    local color = options.color or {1, 1, 1, 1}
    local sprite = options.sprite
    
    local cols, rows = self.engine:getGridSize()
    
    -- Top and bottom borders
    for x = 1, cols do
        self:setCell(x, 1, {glyph = glyph, color = color, sprite = sprite})
        self:setCell(x, rows, {glyph = glyph, color = color, sprite = sprite})
    end
    
    -- Left and right borders
    for y = 1, rows do
        self:setCell(1, y, {glyph = glyph, color = color, sprite = sprite})
        self:setCell(cols, y, {glyph = glyph, color = color, sprite = sprite})
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

function AsciiGrid:draw()
    local charWidth, charHeight = self.engine:getCharSize()
    local cols, rows = self.engine:getGridSize()
    
    for y = 1, rows do
        for x = 1, cols do
            local cell = self.cells[y][x]
            
            if cell then
                local drawX = (x - 1) * charWidth
                local drawY = (y - 1) * charHeight
                
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
            end
        end
    end
    
    -- Reset color to white
    love.graphics.setColor(1, 1, 1, 1)
end

return AsciiGrid