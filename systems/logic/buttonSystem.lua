local ButtonSystem = class("ButtonSystem", System)

function ButtonSystem:update(dt)
    for _, buttonObj in pairs(self.targets) do
        local physics = buttonObj:get("Physics")
        local button = buttonObj:get("Button")

        local setActive = false

        for _, contact in pairs(physics.body:getContactList()) do
            local otherFixture 
            local fixA, fixB = contact:getFixtures()
            if fixA == physics.fixture then
                otherFixture = fixB
            else
                otherFixture = fixA
            end

            if otherFixture:getUserData().gameObject then
                setActive = true
            end
        end

        if setActive ~= button.active then
            button:setActive(setActive)
            if buttonObj:get("RenderData") then
                if setActive then
                    buttonObj:get("RenderData").offset[2] = buttonObj:get("RenderData").offset[2] + 15
                else
                    buttonObj:get("RenderData").offset[2] = buttonObj:get("RenderData").offset[2] - 15
                end
            end
        end
    end
end

function ButtonSystem:requires()
    return {"Button", "Physics"}
end

return ButtonSystem