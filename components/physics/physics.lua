local Physics = Component.create("Physics")

function Physics:initialize(body, shape, entity, friction)
    self.body = body
    self.shape = shape
    self.fixture = love.physics.newFixture(body, shape)
    self.fixture:setCategory(2)
    self.fixture:setMask(1, 3)
    self.fixture:setUserData({gameObject=self})
    if friction then
    	self.fixture:setFriction(friction)
    end
end

return Physics