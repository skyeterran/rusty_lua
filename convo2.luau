type ConvoLine = {
    by: string?,
    text: string,
    fn: () -> ()?,
}

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

function say(args: ConvoLine)
    table.insert(convo.lines, args)
end

say { text = "Hello!" }
say {
    by = "Skye",
    text = "How are you?",
    fn = function()
        print("Nice!")
    end,
}

convo:read()