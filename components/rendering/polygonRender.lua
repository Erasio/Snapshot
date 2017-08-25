local PolygonRender = Component.create("PolygonRender")

function PolygonRender:initialize(color)
    self.color = color or {255, 255, 255}
end

return PolygonRender