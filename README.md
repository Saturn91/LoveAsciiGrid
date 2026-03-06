# loveAsciiGrid

A performant ASCII grid renderer for [LÖVE2D](https://love2d.org/).

- Buffered rendering — layers render to a canvas, only rebuilt on change (dirty flag)
- Per-cell `ox`/`oy` pixel offsets, included in buffered rendering
- Multiple named layers rendered in order
- Auto-scales to fit the window while keeping aspect ratio
- SpriteSheet support for tile-based graphics

---

## Quick Start

```lua
local Grid = require("asciiEngine.Grid")

function love.load()
    grid = Grid.new({cols = 80, rows = 25, font = love.graphics.newFont("font.ttf", 240)})
    layer = grid:addLayer("main")
    layer:write(1, 1, "Hello World!", {1, 1, 0, 1})
end

function love.draw()   grid:draw()   end
function love.resize() grid:resize() end
```

---

## Grid

```lua
local Grid = require("asciiEngine.Grid")

local grid = Grid.new({cols = 80, rows = 25, font = myFont})

grid:draw()                       -- render all layers
grid:resize()                     -- call from love.resize(w, h)
grid:setFont(newFont)             -- swap font, rebuilds canvases
grid:setGridSize(120, 35)         -- resize grid, resets all layers

grid:getGridSize()                -- → cols, rows
grid:getScale()                   -- → scale factor (fit-to-window)
grid:getCharSize()                -- → charWidth, charHeight (font pixels)
grid:screenToGrid(sx, sy)         -- → gx, gy  (clamped to grid)
grid:gridToScreen(gx, gy)         -- → sx, sy  (top-left of cell in screen px)
```

---

## Layers

Layers are rendered in the order they were added. Each has its own canvas.

```lua
local bg = grid:addLayer("background")   -- returns the Layer
local fg = grid:addLayer("foreground")

local bg = grid:layer("background")      -- retrieve by id later
```

---

## Cells

```lua
layer:set(x, y, {
    glyph      = "A",            -- character to display
    color      = {1, 0, 0, 1},   -- foreground RGBA (default white)
    background = {0, 0, 0, 1},   -- background RGBA (optional)
    sprite     = mySprite,       -- overrides glyph when set
    ox         = 0,              -- pixel offset X within cell
    oy         = 0,              -- pixel offset Y within cell
})

layer:get(x, y)      -- returns the cell table (or nil if out of bounds)
layer:clearAt(x, y)  -- reset a single cell to empty
layer:clear()        -- reset all cells
```

`ox`/`oy` are in unscaled font-pixel units and are applied during buffered canvas rendering, so there is no performance cost.

---

## Helpers

```lua
-- Write a string left-to-right starting at (x, y)
layer:write(x, y, "Hello!", {1, 1, 0, 1})
layer:write(x, y, "Hi", color, background)   -- optional background color

-- Fill a rectangle of cells
layer:fill(x1, y1, x2, y2, {glyph = ".", color = {0.5, 0.5, 0.5, 1}})

-- Draw a border of cells around the full grid
layer:border({glyph = "█", color = {0.8, 0.8, 0.8, 1}})
```

---

## SpriteSheet

```lua
local SpriteSheet = require("spriteSheet.SpriteSheet")

local sheet  = SpriteSheet.new("tiles.png", {gridWidth = 16, gridHeight = 16})
local sprite = sheet:getSprite(col, row)   -- 0-indexed col/row

layer:set(5, 3, {sprite = sprite})
layer:set(6, 3, {sprite = sprite, background = {0.2, 0.2, 0.2, 1}})
```

Sprite sheets are cached by path (or `id` if provided). Sprites are cached per col/row.

---

## Performance Notes

- Any call to `set`, `write`, `fill`, `border`, or `clear` marks the layer dirty.
- On `draw`, a dirty layer re-renders all cells to a canvas at screen-space resolution, then blits. Clean layers just blit.
- On `setFont` or `resize`, canvases are discarded and rebuilt on the next draw.
- Use multiple layers to isolate frequently-changing content — only the dirty layer pays the re-render cost.
