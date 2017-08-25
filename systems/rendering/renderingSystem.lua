local RenderingSystem = class("RenderingSystem", System)

function RenderingSystem:draw()
    local world, camera
    for _, entity in pairs(self.targets.world) do
        camera = entity:get("Camera")
        world = entity:get("World")
        break
    end

    local scale = 1

    love.graphics.push()
    love.graphics.scale(scale, scale)
    love.graphics.translate(-camera.vec.x + camera.dimension.x / (2 * scale) , -camera.vec.y + camera.dimension.y / (2 * scale))


    for k, entity in pairs(self.targets.coll) do
        local body = entity:get("Physics").body
        local shape = entity:get("Physics").shape
        local renderData = entity:get("RenderData")
        local color = renderData.color
        local collRender = entity:get("CollisionRender")
        love.graphics.setColor(color)
        collRender:draw(body, shape, renderData.offset[1], renderData.offset[2])
        if world.mode == "snapshot" then
            if entity:get("Wrappable") then
                if entity:get("Wrappable").wrap then
                    color[4] = color[4] * world.timeInMode * 700
                    love.graphics.setColor(color)

                    collRender:draw(body, shape, camera.dimension.x + renderData.offset[1], 0 + renderData.offset[2])
                    collRender:draw(body, shape, -camera.dimension.x + renderData.offset[1], 0 + renderData.offset[2])
                    collRender:draw(body, shape, 0 + renderData.offset[1], camera.dimension.y + renderData.offset[2])
                    collRender:draw(body, shape, 0 + renderData.offset[1], -camera.dimension.y + renderData.offset[2])

                    color[4] = 255
                end
            end
        end
    end

    love.graphics.setColor(255, 255, 255, 255)

    love.graphics.pop()
end

function RenderingSystem:requires()
    return {world = {"World", "Camera"}, coll = {"Physics", "Position", "CollisionRender", "RenderData"}}
end

return RenderingSystem