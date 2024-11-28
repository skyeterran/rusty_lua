function say(x)
    coroutine.yield(x)
end

function run_path(fn)
    local path = coroutine.create(fn)
    while true do
        local alive, value = coroutine.resume(path)
        if alive and value then
            if type(value) == "string" then
                print(value)
            end
            if type(value) == "function" then
                run_path(value)
            end
        else
            break
        end
    end
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
end

run_path(main)