local Wrappable =  Component.create("Wrappable")

function Wrappable:initialize(body, shape, w, h, entity)
	self.wrap = false
	self.replicas = {}
	self.body = body
	self.shape = shape
	self.preSolve = {}
	self.lastWrap = 0

	table.insert(self.replicas, self:createOffset(-w, 0, body, shape, entity))
	table.insert(self.replicas, self:createOffset(w, 0, body, shape, entity))
	table.insert(self.replicas, self:createOffset(0, h, body, shape, entity))
	table.insert(self.replicas, self:createOffset(0, -h, body, shape, entity))
end

function Wrappable:setCollision()
	for _, obj in pairs(self.replicas) do
		obj.fixture:setSensor(not self.wrap)
	end
end

function Wrappable:createOffset(ox, oy, body, shape, entity)
	local x, y = body:getPosition()
	local tempBody = love.physics.newBody(body:getWorld(), x + ox, y + oy, body:getType())
	tempBody:setMass(0)
	local tempFixture = love.physics.newFixture(tempBody, shape)
	tempFixture:setCategory(3)
	tempFixture:setMask(1, 2)
	tempFixture:setUserData({replicated=true, targetBody=body, gameObject=entity})
	return {body=tempBody, fixture=tempFixture, shape=shape, ox=ox, oy=oy}
end

return Wrappable