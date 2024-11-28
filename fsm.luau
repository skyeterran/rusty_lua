--!nolint FunctionUnused

function say(x)
    coroutine.yield(x)
end

function main()
    say("A")
    say("B")
    say("C")
    say(function()
        say("  D")
        say("  E")
        say("  F")
        say(function()
            say("    G")
            say("    H")
            say("    I")
        end)
    end)
    say("K")
    say("L")
    say("M")
    say(function()
        say("  N")
        say("  O")
        say("  P")
    end)
end

-- Stack of path coroutines
local paths = { coroutine.create(main) }

-- Progresses through paths
function step()
    local path = paths[#paths]
    local alive, value = coroutine.resume(path)
    if alive and value then
        if type(value) == "string" then
            print(value)
        end
        if type(value) == "function" then
            -- Add path to stack
            table.insert(
                paths,
                coroutine.create(value)
            )
            step()
        end
    else
        -- Pop finished path from stack
        table.remove(paths, #paths)
        step()
    end
end