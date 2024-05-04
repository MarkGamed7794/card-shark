local fonts = {}

setmetatable(fonts, {
    __index = function(t, k)
        if(not rawget(t, k)) then
            rawset(t, k, love.graphics.newFont(k))
        end
        return rawget(t, k)
    end
})

return fonts