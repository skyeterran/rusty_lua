local module = {
    lines = {},
    props = {
        has_contraband = true,
    },
    input = nil,
}

function module:say(text)
    print(`{self.name}: {text}`)
    coroutine.yield("line")
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
            ["Never"] = function()
                shami("Really? That's unwise.")
            end,
            ["Sure"] = function()
                shami("Thank you for your cooperation.")
            end,
        }
    else
        shami("You seem trustworthy.")
    end
    -- Restart
    start()
end

local coroutines = { coroutine.create(start) }
local current_choice = nil
function module.step()
    if not current_choice then
        local _, result, args = coroutine.resume(
            coroutines[#coroutines]
        )
        if result == "choice" then
            current_choice = args
            print("Choose one:")
            for k, _ in current_choice do
                print(`  - \"{k}\"`)
            end
        end
    else
        print(`-> Your choice: {module.input}`)
        for k, v in current_choice do
            if k == module.input then
                table.insert(
                    coroutines,
                    coroutine.create(function()
                        v()
                    end)
                )
            end
        end
    end
end

return module