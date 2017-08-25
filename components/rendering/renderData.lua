local RenderData = Component.create("RenderData")

-- stencil expects an object with the following attributes:
-- 	For stencil creation:
-- 		stencilFunction
-- 		stencilAction
-- 		stencilValue
-- 		stencilKeepValues
--	For stencil usage:
-- 		compareMode
--		compareValue

-- All values are according to the docs:
-- https://love2d.org/wiki/love.graphics.stencil
-- https://love2d.org/wiki/love.graphics.setStencilTest

function RenderData:initialize(color, offset, stencil)
    self.color = color or {255, 255, 255, 255}
    if not self.color[4] then
    	self.color[4] = 255
    end
    self.offset = offset or {0, 0}
    self.stencil = stencil
end

return RenderData