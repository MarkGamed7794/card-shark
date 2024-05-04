local events = {events = {}}

function events:newEvent(delay, callback)
    local idx = #self.events + 1
    table.insert(self.events, idx, {delay = delay, callback = callback})
    return idx
end

function events:update(dt)
    for id, event in pairs(self.events) do
        event.delay = event.delay - dt
        if(event.delay <= 0) then
            event.callback()
            self.events[id] = nil
        end
    end
end

return events