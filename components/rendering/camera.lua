local Camera = Component.create("Camera")

function Camera:initialize(x, y, zoom, rot)
	local w, h = love.window.getMode()
	self.vec = Vector(x, y)
	self.targetVec = Vector(x, y)
	self.zoom = Vector(zoom, zoom)
	self.rot = rot
	self.dimension = Vector(1280, 720)
end

function Camera:setTarget(newTarget)
	self.target = newTarget
	self.player = newTarget
end

return Camera