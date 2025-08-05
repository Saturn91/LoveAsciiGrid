local AsciiGrid = {}

AsciiGrid.__index = AsciiGrid

function AsciiGrid:new()
    return setmetatable({}, self)
end

function AsciiGrid:initialize(engine)
    self.engine = engine
    self.cells = {}
    for y = 1, engine.gridSize.height do
        self.cells[y] = {}
        for x = 1, engine.gridSize.width do
            self.cells[y][x] = Char:new(x, y)
        end
    end
end