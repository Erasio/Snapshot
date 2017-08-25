local WrapSystem = class("WrapSystem", System)

WrapSystem.checkedTargets = {}

function WrapSystem:update(dt)
    self.checkedTargets = {}
    local world, camera
    for _, tempWorld in pairs(self.targets.world) do
        world = tempWorld:get("World")
        camera = tempWorld:get("Camera")
    end

    local physics, shape
    for _, entity in pairs(self.targets.entity) do
        physics = entity:get("Physics")
        shape = physics.shape

        -- Replicate remote objects
        for _, obj in pairs(entity:get("Wrappable").replicas) do
            local x, y = physics.body:getPosition()
            obj.body:setPosition(x + obj.ox, y + obj.oy)
            obj.body:setLinearVelocity(physics.body:getLinearVelocity())
            obj.body:setAngle(physics.body:getAngle())
            obj.body:setAngularVelocity(physics.body:getAngularVelocity())
            if entity:get("Wrappable").wrap then
                for _, obj in pairs(entity:get("Wrappable").replicas) do
                    if physics.fixture:isSensor() then
                        obj.fixture:setSensor(true)
                    else
                        obj.fixture:setSensor(false)
                    end
                end
            end
            
        end

        -- Do wrapping checks and warp if appropriate
        if world.mode == "snapshot" then
            if entity:get("Physics").body:getType() ~= "static" then
                entity:get("Wrappable").lastWrap = entity:get("Wrappable").lastWrap + dt
                if entity:get("Wrappable").lastWrap > 0.3 then
                    if entity:get("Wrappable").wrap then

                        local x, y = physics.body:getPosition()
                        local cX, cY = camera.vec:unpack()
                        local cW, cH = camera.dimension:unpack()
                        cX = cX - cW / 2
                        cY = cY - cH / 2
                        
                        local center = {0, 0}

                        if shape:typeOf("CircleShape") then
                            local sx, sy = shape:getPoint()
                            center[1] = physics.body:getX() + sx 
                            center[2] = physics.body:getY() + sy
                        else
                            local points = {physics.body:getWorldPoints(shape:getPoints())}
                            for i=1, #points, 2 do
                                center[1] = center[1] + points[i]
                                center[2] = center[2] + points[i+1]
                            end
                            center[1] = center[1] / (#points / 2)
                            center[2] = center[2] / (#points / 2)
                        end

                        if center[1] < cX then
                            entity:get("Wrappable").lastWrap = 0
                            physics.body:setX(physics.body:getX() + cW)
                        elseif center[1] > cX + cW then
                            entity:get("Wrappable").lastWrap = 0
                            physics.body:setX(physics.body:getX() - cW)
                        end

                        if center[2] < cY then
                            entity:get("Wrappable").lastWrap = 0
                            physics.body:setY(physics.body:getY() + cH)
                        elseif center[2] > cY + cH then
                            entity:get("Wrappable").lastWrap = 0
                            physics.body:setY(physics.body:getY() - cH)
                        end
                    end
                end
            end
        end
    end
end

function WrapSystem:requires()
    return {world = {"World", "Camera"}, entity = {"Physics", "Wrappable"}}
end

return WrapSystem