local WorldUpdateSystem = class("WorldUpdateSystem", System)

function WorldUpdateSystem:update(dt)

    for _, entity in pairs(self.targets.world) do
        local world = entity:get("World")
        local camera = entity:get("Camera")

        world.timeInMode = world.timeInMode + dt

        -- Update camera location
        if world.mode == "normal" then
            if camera.target then
                if camera.target:get("Position") then
                    local vec = camera.target:get("Position").vec:clone()
                    local velX, velY = camera.target:get("Physics").body:getLinearVelocity()
                    camera.targetVec = vec --+ Vector(velX, velY):trimmed(200)
                end
            end
        end

        camera.vec = camera.vec + (camera.targetVec - camera.vec) * (dt * 3)

        if world.desiredMode ~= world.mode then
            world.mode = world.desiredMode
            world.timeInMode = 0
            -- Check all active maps
            if world.mode == "snapshot" then
                for _, entity in pairs(self.targets.wrappable) do
                    local shapeType = entity:get("Physics").shape:type()

                    local x, y = entity:get("Physics").body:getPosition()
                    local cX, cY = camera.vec:unpack()
                    local cW, cH = camera.dimension:unpack()

                    if shapeType == "CircleShape" then
                        local radius = entity:get("Physics").shape:getRadius()
                        local sx, sy = entity:get("Physics").shape:getPoint()
                        x = x + sx
                        y = y + sy
                        local wrap = false
                        if x + radius >= cX - cW / 2 and x - radius <= cX + cW / 2 and y + radius >= cY - cH / 2 and y + radius <= cY + cH / 2 then
                            wrap = true
                        end
                        entity:get("Wrappable").wrap = wrap
                        if wrap then
                            entity:get("Physics").fixture:setCategory(3)
                            entity:get("Physics").fixture:setMask(1, 2)
                        end
                    elseif shapeType == "PolygonShape" then
                        local points = {entity:get("Physics").shape:getPoints()}
                        local points = {entity:get("Physics").body:getWorldPoints(unpack(points))}
                        local inside = false
                        
                        for i=1, #points, 2 do
                            if points[i] >= cX - cW / 2 and points[i] <= cX + cW / 2 and points[i+1] >= cY - cH / 2 and points[i+1] <= cY + cH / 2 then
                                inside = true
                                break 
                            end
                        end
                        entity:get("Wrappable").wrap = inside
                        if inside then
                            entity:get("Physics").fixture:setCategory(3)
                            entity:get("Physics").fixture:setMask(1, 2)
                        end
                    end
                    -- Set all entity replicas that do not wrap to sensors
                    entity:get("Wrappable"):setCollision()
                end

                for _, map in pairs(world.maps) do
                    map:box2d_createSnapShot(camera.vec.x - camera.dimension.x / 2, camera.vec.y - camera.dimension.y / 2, camera.dimension.x, camera.dimension.y)
                    camera.target = nil
                    camera.targetVec = camera.vec:clone()
                end
            else
                for _, entity in pairs(self.targets.wrappable) do
                    entity:get("Physics").fixture:setCategory(2)
                    entity:get("Physics").fixture:setMask(1, 3)
                end

                for _, map in pairs(world.maps) do
                    map:box2d_destroySnapshot()
                end

                camera.target = camera.player
            end
        end
    end
end

function WorldUpdateSystem:requires()
    return {world = {"World", "Camera"}, wrappable = {"Wrappable", "Physics"}}
end

return WorldUpdateSystem