love.graphics.setDefaultFilter("nearest", "nearest")

local Grid        = require("asciiEngine.Grid")
local SpriteSheet = require("spriteSheet.SpriteSheet")

local FONTS = {
    "assets/fonts/Ac437_IBM_BIOS.ttf",
    "assets/fonts/Ac437_IBM_BIOS-2x.ttf",
    "assets/fonts/Ac437_IBM_BIOS-2y.ttf",
    "assets/fonts/DejaVuSansMono.ttf",
}
local FONT_SIZE = 240

local grid
local sprites
local time      = 0
local fontIndex = 1

function love.load()
    love.window.setMode(800, 600, {resizable = true})
    love.window.setVSync(false)

    sprites = SpriteSheet.new("resources/test-sprites.png", {gridWidth = 16, gridHeight = 16})

    grid = Grid.new({
        cols = 80,
        rows = 25,
        font = love.graphics.newFont(FONTS[fontIndex], FONT_SIZE),
    })

    grid:addLayer("main")
    setupDemo()
end

function love.update(dt)
    time = time + dt
    animateDemo()
end

function love.draw()
    grid:draw()
    drawHUD()
    love.graphics.setColor(1, 1, 1, 1)
end

function love.resize(w, h)
    grid:resize()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "1" then
        grid:setGridSize(40, 15)
        setupDemo()
    elseif key == "2" then
        grid:setGridSize(80, 25)
        setupDemo()
    elseif key == "3" then
        grid:setGridSize(120, 35)
        setupDemo()
    elseif key == "f" then
        fontIndex = fontIndex % #FONTS + 1
        grid:setFont(love.graphics.newFont(FONTS[fontIndex], FONT_SIZE))
        setupDemo()
    elseif key == "c" then
        setupDemo()
    end
end

function setupDemo()
    local layer = grid:layer("main")
    layer:clear()

    local cols, rows = grid:getGridSize()

    layer:border({glyph = "█", color = {0.8, 0.8, 0.8, 1}})

    local title = "ASCII Grid Engine Demo"
    layer:write(math.floor((cols - #title) / 2) + 1, 3, title, {1, 1, 0, 1})
    layer:write(3, 5, "Grid: " .. cols .. "x" .. rows, {0.7, 0.7, 1, 1})

    for i = 1, 10 do
        layer:set(math.random(3, cols - 2), math.random(7, rows - 7), {
            sprite     = sprites:getSprite(math.random(0, 1), math.random(0, 1)),
            background = {0.5, 0.5, 0.5, 1},
        })
    end

    local controls = {"Controls:", "1/2/3 - Grid size", "F - Font", "C - Redraw", "ESC - Quit"}
    for i, text in ipairs(controls) do
        layer:write(3, rows - 6 + i, text, {0.8, 0.8, 0.8, 1})
    end
end

function animateDemo()
    local layer = grid:layer("main")
    local cols, rows = grid:getGridSize()

    if math.random() < 0.1 then
        local sparkles = {"*", "·", "°", "•"}
        layer:set(math.random(3, cols - 2), math.random(8, rows - 8), {
            glyph = sparkles[math.random(#sparkles)],
            color = {1, 1, 0.5, 1},
        })
    end

    local waveX = math.floor(math.sin(time) * (cols - 10) / 2 + cols / 2)
    layer:set(waveX, math.floor(rows / 2), {sprite = sprites:getSprite(0, 0)})
end

function drawHUD()
    local font = love.graphics.newFont(12)
    love.graphics.setFont(font)

    local cols, rows = grid:getGridSize()
    local cw, ch    = grid:getCharSize()
    local fontName  = FONTS[fontIndex]:match("([^/\\]+)%.ttf$") or "Unknown"
    local info      = string.format(
        "Scale: %.2f | Grid: %dx%d | Font: %s | Char: %.2fx%.2f | FPS: %d",
        grid:getScale(), cols, rows, fontName, cw / FONT_SIZE, ch / FONT_SIZE, love.timer.getFPS()
    )

    local tw = font:getWidth(info)
    local th = font:getHeight()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 5, 5, tw + 10, th + 10)
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.print(info, 10, 10)
end
