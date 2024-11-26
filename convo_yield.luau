local module = {}

function module:say(text)
    print(`{self.name}: {text}`)
    coroutine.yield(true)
    --return #convo.lines
end

function module.choice(args)
    for k, v in args do
        -- Just pick the first choice for now
        print(`-> Your choice: {k}`)
        v()
        return
    end
end

local shami = { name = "Shami" }
setmetatable(shami, { __call = module.say })

--
local has_contraband = true

local function start()
    shami("Welcome to space station 9.")
    if has_contraband then
        shami("Please leave any contraband in the bin.")
        module.choice{
            ["Never!"] = function()
                shami("Really? That's unwise.")
            end,
            ["Sure, here."] = function()
                shami("Thank you for your cooperation.")
            end,
        }
    else
        shami("You seem trustworthy.")
    end
    -- Restart
    start()
end

module.convo = coroutine.create(start)

function module.next()
    coroutine.resume(module.convo)
end

--[[
for i = 1, 20 do
    local _, result = coroutine.resume(c)
    if result == nil then break end
end
]]

return module