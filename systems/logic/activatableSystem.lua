local ActivatableSystem = class("ActivatableSystem", System)

function ActivatableSystem:update(dt)
    for _, entity in pairs(self.targets) do
        local activatable = entity:get("Activatable")
        local renderData = entity:get("RenderData")

        if activatable.active then
            activatable.timeSinceActivation = activatable.timeSinceActivation + dt    
            
            if renderData then
                renderData.color[4] = 255 - 1200 * activatable.timeSinceActivation
            end
        else
            if renderData then
                renderData.color[4] = 255
            end
        end
        if not activatable.activeUpdated then
            if activatable.effect == "removeCollision" then
                entity:get("Physics").fixture:setSensor(activatable.active)
            end

            activatable.activeUpdated = true
        end
    end
end

function ActivatableSystem:requires()
    return {"Activatable", "Physics"}
end

return ActivatableSystem