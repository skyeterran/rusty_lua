--!nolint FunctionUnused
math.randomseed(os.time())
vec3 = vector.create
normalize = vector.normalize

random = {
    choice = function(x: {any}): any
        return x[math.random(1, #x)]
    end,
    unit_vector = function(): vector
        return normalize(
            vec3(
                math.random(),
                math.random(),
                math.random()
            )
        )
    end,
}

-- Called when the object is created
function construct(self)
    self.name = random.choice({
        "Lazer",
        "Salad",
        "Sock",
        "Smores",
        "Zeelay",
    })
    self.position = random.unit_vector()

    possible_kinds = {
        "Human",
        "Alien",
        "Animal",
    }
    for k, v in { "Worm", "Slime", "Puppy", "Kitty" } do
        table.insert(possible_kinds, { Other = v })
    end
    self.kind = random.choice(possible_kinds)
end