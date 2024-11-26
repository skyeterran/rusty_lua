convo = {
    lines = {}
}

function convo:read()
    for _, v in self.lines do
        local prefix = if v.by then `{v.by}: ` else ""
        print(`{prefix}\"{v.text}\"`)
        if v.fn then v.fn() end
    end
end

function say(
    by: string?,
    text: string,
    fn: (() -> ())?
)
    table.insert(convo.lines, {
        text = text,
        by = by,
        fn = fn,
    })
end

say(nil, "Hello!")
say("Skye", "How are you?", function()
    print("Nice!")
end)

convo:read()