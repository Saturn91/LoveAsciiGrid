love.graphics.setDefaultFilter('nearest', 'nearest')

local AsciiEngine = require("asciiEngine.engine")
local AsciiGrid = require("asciiEngine.asciiGrid")
require("spriteSheet.SpriteSheet")

-- Font paths array
local FONT_PATHS = {
    "assets/fonts/Ac437_IBM_BIOS.ttf",
    "assets/fonts/Ac437_IBM_BIOS-2x.ttf",
    "assets/fonts/Ac437_IBM_BIOS-2y.ttf",
    "assets/fonts/DejaVuSansMono.ttf"
}

local testSprites = SpriteSheet.new("resources/test-sprites.png", {
    gridWidth = 16,
    gridHeight = 16,
    id = "testsprites"
})

local engine
local time = 0
local currentFontIndex = 1

function love.load()    
    engine = AsciiEngine:new({
        gridCols = 80,
        gridRows = 25,
        font = love.graphics.newFont(FONT_PATHS[currentFontIndex], 240)
    })
    
    engine:addLayer(AsciiGrid:new("main"))
    
    engine:calculateScaling()
    
    love.window.setMode(800, 600, {resizable = true})
    
    setupDemo()
end

function love.update(dt)
    time = time + dt
    
    animateDemo(dt)
end

function love.draw()    
    engine:draw()
    drawInfo()
    love.graphics.setColor(1, 1, 1, 1)
end

function love.resize(w, h)
    engine:resize()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "1" then
        -- Change to 40x15 grid
        engine:setGridSize(40, 15)
        setupDemo()
    elseif key == "2" then
        -- Change to 80x25 grid
        engine:setGridSize(80, 25)
        setupDemo()
    elseif key == "3" then
        -- Change to 120x35 grid
        engine:setGridSize(120, 35)
        setupDemo()
    elseif key == "f" then
        -- Cycle through fonts
        currentFontIndex = currentFontIndex % #FONT_PATHS + 1
        local newFont = love.graphics.newFont(FONT_PATHS[currentFontIndex], 240)
        engine:setFont(newFont)
        setupDemo()
    elseif key == "c" then
        -- Clear and redraw
        setupDemo()
    end
end

function setupDemo()
    local mainGrid = engine:getLayerById("main")
    -- Clear the grid
    mainGrid:clear()
    
    local cols, rows = engine:getGridSize()
    
    -- Draw border
    mainGrid:drawBorder({
        glyph = "█",
    }, {0.8, 0.8, 0.8, 1})
    
    -- Draw title
    local title = "ASCII Grid Engine Demo"
    local titleX = math.floor((cols - #title) / 2) + 1
    mainGrid:writeText(titleX, 3, title, {1, 1, 0, 1}) -- Yellow
    
    -- Draw grid size info
    local gridInfo = "Grid: " .. cols .. "x" .. rows
    mainGrid:writeText(3, 5, gridInfo, {0.7, 0.7, 1, 1}) -- Light blue

    -- Draw some decorative elements
    for i = 1, 10 do
        local x = math.random(3, cols - 2)
        local y = math.random(7, rows - 7)
        mainGrid:setCell(x, y, {
            sprite = testSprites:getSprite({x = math.random(0, 1), y = math.random(0, 1)}),
        })
    end
    
    -- Draw instructions
    local instructions = {
        "Controls:",
        "1/2/3 - Change grid size",
        "F - Change font",
        "C - Clear and redraw",
        "ESC - Quit"
    }
    
    for i, instruction in ipairs(instructions) do
        mainGrid:writeText(3, rows - 7 + i, instruction, {0.8, 0.8, 0.8, 1})
    end
end

function animateDemo(dt)
    local cols, rows = engine:getGridSize()
    
    local mainGrid = engine:getLayerById("main")
    
    -- Animate some sparkles
    if math.random() < 0.1 then
        local x = math.random(3, cols - 2)
        local y = math.random(8, rows - 8)
        local sparkles = {"*", "·", "°", "•"}
        local sparkle = sparkles[math.random(#sparkles)]
        mainGrid:setCell(x, y, {
            glyph = sparkle,
            color = {1, 1, 0.5, 1}
        })
    end
    
    -- Animate a moving character
    local waveX = math.floor(math.sin(time) * (cols - 10) / 2 + cols / 2)
    local waveY = math.floor(rows / 2)
    mainGrid:setCell(waveX, waveY, {
        sprite = testSprites:getSprite({x = 0, y = 0}),
    }) -- Red character
end

function drawInfo()
    -- Draw info overlay (not part of the ASCII grid)
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.setFont(love.graphics.newFont(12))
    
    local scale = engine:getScale()
    local cols, rows = engine:getGridSize()
    local fontName = FONT_PATHS[currentFontIndex]:match("([^/\\]+)%.ttf$") or "Unknown"
    
    local info = string.format(
        "Scale: %.2f | Grid: %dx%d | Font: %s",
        scale, cols, rows, fontName
    )
    
    love.graphics.print(info, 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
end