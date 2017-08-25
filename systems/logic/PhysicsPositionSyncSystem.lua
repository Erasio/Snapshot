-- Synchronizes the Position Component with the Position of the Body Component, if an Entity has both.
local PhysicsPositionSyncSystem = class("PhysicsPositionSyncSystem", System)

function PhysicsPositionSyncSystem:update(dt)
    for k, entity in pairs(self.targets) do
        entity:get("Position").vec.x = entity:get("Physics").body:getX()
        entity:get("Position").vec.y = entity:get("Physics").body:getY()
    end
end

function PhysicsPositionSyncSystem:requires()
    return {"Physics", "Position"}
end

return PhysicsPositionSyncSystem