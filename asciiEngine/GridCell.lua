Cell = require("asciiEngine.cell")

local GridCell = {}
GridCell.__index = GridCell
setmetatable(GridCell, Cell)

function GridCell.new(x, y, options)
    options = options or {}
    local instance = setmetatable(Cell.new(options.glyph, options), GridCell)
    instance.x = x
    instance.y = y
    return instance
end

return GridCell