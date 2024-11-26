local module = {
    lines = {},
    props = {
        has_contraband = true,
    },
}

function module:say(text)
    table.insert(module.lines, {
        by = self.name,
        text = text,
    })
end

function module.input(input)
    --[[
    for k, v in choices do
        if k == input then
            choosing = false
            print(`-> Your choice: {k}`)
            v()
        end
    end
    ]]
end

function module.choice(args)
end

local shami = { name = "Shami" }
setmetatable(shami, { __call = module.say })

--
local props = module.props

local function start()
    shami("Welcome to space station 9.")
    if props.has_contraband then
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

function module.step()
    coroutine.resume(module.convo)
end

return module