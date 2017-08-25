local WorldDrawSystem = class("WorldDrawSystem", System)

function WorldDrawSystem:draw()
    for _, entity in pairs(self.targets) do
        local world = entity:get("World")
        local camera = entity:get("Camera")

        for _, map in pairs(world.maps) do
            map:draw(-camera.vec.x + camera.dimension.x / 2, -camera.vec.y + camera.dimension.y / 2)

            -- Physics debugging
            --[[love.graphics.setColor(0, 255, 0)
            map:box2d_draw(-camera.vec.x + camera.dimension.x / 2, -camera.vec.y + camera.dimension.y / 2)
            love.graphics.setColor(255, 255, 255, 255)
            self:drawCollision(world, camera, 0.25)--]]

            -- Snapshot outline
            love.graphics.setLineWidth(20)
            if world.mode == "snapshot" then
            	love.graphics.line(
            		1, 1,
            		1, 719,
            		1279, 719,
            		1279, 1,
            		1, 1
            	)
            end
            love.graphics.setLineWidth(1)
        end
    end
end

function WorldDrawSystem:drawCollision(tWorld, camera, scale)
	local currentColor = {love.graphics.getColor()}
	local scale = scale or 1
	love.graphics.push()
	love.graphics.scale(scale, scale)
	love.graphics.translate(-camera.vec.x + camera.dimension.x / (2 * scale) , -camera.vec.y + camera.dimension.y / (2 * scale))
	love.graphics.setColor(255, 0, 0)
	love.graphics.setLineWidth(4)

	local category = 2
	if tWorld.mode == "snapshot" then
		category = 3
	end

    for k, body in pairs(world:getBodyList()) do
        for _, fixture in pairs(body:getFixtureList()) do
            if not fixture:isSensor() then
                if fixture:getCategory() == category then
                    local shape = fixture:getShape()
                    if shape:typeOf("CircleShape") then
                        local cx, cy = shape:getPoint()
                        love.graphics.circle("line", body:getX() + cx, body:getY() + cy, shape:getRadius())
                    elseif shape:typeOf("PolygonShape") then
                        local points = {body:getWorldPoints(shape:getPoints())}
                        for i=1, #points, 2 do
                            love.graphics.print(tostring(i/2+0.5), points[i], points[i+1], 4, 4)
                        end
                        love.graphics.polygon("line", points)
                    else
                        local points = {body:getWorldPoints(shape:getPoints())}
                        for i=1, #points, 2 do
                            love.graphics.print(tostring(i/2+0.5), points[i], points[i+1], 4, 4)
                        end
                        love.graphics.line(points)
                    end
                else
                    if fixture:getCategory() ~= 2 and fixture:getCategory() ~= 3 then
                        print("[!] WorldDrawSystem:drawCollision fixture category unknown", fixture:getCategory())
                    end
                end
            end
        end
    end
    love.graphics.setLineWidth(1)
    love.graphics.setColor(currentColor)
    love.graphics.pop()
end

function WorldDrawSystem:requires()
    return {"World", "Camera"}
end

return WorldDrawSystem