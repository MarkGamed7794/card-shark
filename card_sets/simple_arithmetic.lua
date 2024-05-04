local cards = {}

for a = 1, 10 do
    for b = a, 10 do
        table.insert(cards, {
            front = a .. " + " .. b,
            back = tostring(a+b)
        })
        table.insert(cards, {
            front = a .. " - " .. b,
            back = tostring(a-b)
        })
        table.insert(cards, {
            front = a .. " x " .. b,
            back = tostring(a*b)
        })
        if(b % a == 0) then
            table.insert(cards, {
                front = b .. " ÷ " .. a,
                back = tostring(b/a)
            })
        end
    end
end

return {
    name = "Simple Arithmetic",
    reversible = false,
    disable_repeats = false,
    cards = cards
}