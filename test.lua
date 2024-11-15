math.randomseed(os.time())

function random_item(table)
    local i = math.random(1, #table)
    return table[i]
end

local kinds = { "Cat", "Dog", "Fish" }

return random_item(kinds)