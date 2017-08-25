local ObjectEventSystem = class("ObjectEventSystem", System)

function ObjectEventSystem:fireEvent(event)
    if event.name == "active" then
        if event.target then
            if event.target:get("Activatable") then
                if event.params[1] then
                    event.target:get("Activatable"):activate()
                else
                    event.target:get("Activatable"):deactivate()
                end
            end
        end
    end
end

function ObjectEventSystem:requires()
    return {}
end

return ObjectEventSystem