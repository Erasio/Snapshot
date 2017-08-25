local Position  = Component.create("Position")

function Position:initialize(x, y)
    self.vec = Vector(x, y)
end

return Position