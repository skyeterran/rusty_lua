local module = {
    lines = {},
    props = {
        has_contraband = true,
    },
}

function module:say(text)
    print(`{self.name}: {text}`)
    coroutine.yield()
end

local input = nil
function module.input(input)
    input = input
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
    coroutine.yield("choice", args)
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

local current_choice = nil
function module.step()
    if not current_choice then
        local _, result, args = coroutine.resume(module.convo)
        if result == "choice" then
            current_choice = args
            for k, _ in current_choice do
                print(`- \"{k}\"`)
            end
        end
    else
        print(`-> Your choice: {input}`)
    end
end

return module