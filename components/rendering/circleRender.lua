local CircleRender = Component.create("CircleRender")

function CircleRender:initialize(color)
    self.color = color or {255, 255, 255}
end

return CircleRender