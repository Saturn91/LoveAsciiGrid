# Love ASCII Grid Engine

A solid foundation for creating ASCII-based games in Love2D. This engine provides a flexible grid-based rendering system with layer support, perfect for roguelikes, text adventures, and retro-style games.

## Features

- **Grid-based ASCII rendering** with automatic scaling and centering
- **Multi-layer system** for organizing different game elements
- **Font support** with easy font switching
- **Responsive scaling** that maintains aspect ratio
- **Coordinate conversion** between screen and grid coordinates
- **Modular design** for easy integration into other projects

## Getting Started

### Prerequisites

- [Love2D](https://love2d.org/) (LÖVE) game framework

### Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/LoveAsciiGrid.git
cd LoveAsciiGrid
```

2. Run the demo:
```bash
love .
```

## Usage

### Basic Setup

```lua
local AsciiEngine = require("asciiEngine.engine")
local AsciiGrid = require("asciiEngine.asciiGrid")

function love.load()
    -- Create the engine
    local engine = AsciiEngine:new({
        gridCols = 80,
        gridRows = 25,
        font = love.graphics.newFont("path/to/font.ttf", 16)
    })
    
    -- Add a grid layer
    local mainGrid = AsciiGrid:new("main")
    engine:addLayer(mainGrid)
    
    -- Calculate initial scaling
    engine:calculateScaling()
end

function love.draw()
    engine:draw()
end

function love.resize()
    engine:resize()
end
```

### Working with Grids

```lua
local grid = engine:getLayerById("main")

-- Set individual characters
grid:setCell(x, y, "@", {1, 1, 1, 1}) -- White @ symbol

-- Write text
grid:writeText(10, 5, "Hello World!", {1, 1, 0, 1}) -- Yellow text

-- Draw borders
grid:drawBorder("█", {0.8, 0.8, 0.8, 1}) -- Gray border

-- Clear the grid
grid:clear()
```

### Multiple Layers

```lua
-- Background layer
local bgGrid = AsciiGrid:new("background")
engine:addLayer(bgGrid)

-- Main game layer
local gameGrid = AsciiGrid:new("game")
engine:addLayer(gameGrid)

-- UI layer
local uiGrid = AsciiGrid:new("ui")
engine:addLayer(uiGrid)
```

## Demo Controls

- **1/2/3** - Switch between different grid sizes (40x15, 80x25, 120x35)
- **F** - Cycle through different fonts
- **C** - Clear and redraw the demo
- **ESC** - Quit

## API Reference

### AsciiEngine

#### Constructor
- `AsciiEngine:new(options)` - Create a new engine instance

#### Methods
- `setFont(font)` - Change the font
- `setGridSize(cols, rows)` - Change grid dimensions
- `addLayer(layer)` - Add a new layer
- `getLayerById(id)` - Retrieve a layer by ID
- `draw()` - Render all layers
- `resize()` - Recalculate scaling after window resize
- `screenToGrid(x, y)` - Convert screen coordinates to grid coordinates
- `gridToScreen(x, y)` - Convert grid coordinates to screen coordinates

### AsciiGrid

#### Constructor
- `AsciiGrid:new(id)` - Create a new grid layer

#### Methods
- `setCell(x, y, char, color)` - Set a character at position
- `getCell(x, y)` - Get character and color at position
- `writeText(x, y, text, color)` - Write text starting at position
- `drawBorder(char, color)` - Draw a border around the grid
- `clear()` - Clear all cells

## File Structure

```
LoveAsciiGrid/
├── main.lua                    # Demo application
├── asciiEngine/
│   ├── engine.lua             # Core engine
│   └── asciiGrid.lua          # Grid layer implementation
├── assets/
│   └── fonts/                 # Font files
└── README.md
```

## Integration into Your Project

### Option 1: Copy Module Files
Copy the `asciiEngine/` folder to your project and require the modules:

```lua
local AsciiEngine = require("asciiEngine.engine")
local AsciiGrid = require("asciiEngine.asciiGrid")
```

### Option 2: Git Submodule
Add as a git submodule:

```bash
git submodule add https://github.com/yourusername/LoveAsciiGrid.git lib/AsciiEngine
```

### Option 3: Create Library Entry Point
Create an `init.lua` in the asciiEngine folder for cleaner imports:

```lua
local AsciiEngine = require("asciiEngine")
local engine = AsciiEngine.Engine:new({...})
local grid = AsciiEngine.Grid:new("main")
```

## Example Games

This engine is perfect for creating:

- **Roguelike games** (dungeon crawlers, RPGs)
- **Text adventures** and interactive fiction
- **ASCII art applications**
- **Terminal-style interfaces**
- **Retro puzzle games**
- **Code editors** and development tools

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built with [Love2D](https://love2d.org/)
- Inspired by classic ASCII games and roguelikes
- Font support includes IBM BIOS fonts and DejaVu Sans Mono