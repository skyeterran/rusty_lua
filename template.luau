--!nolint FunctionUnused
math.randomseed(os.time())
normalize = vector.normalize

function random(x)
    return x[math.random(1, #x)]
end

-- Helper function, maybe auto-include this?
function vec3(x: number, y: number, z: number): vector
    return vector.create(x, y, z)
end

-- Called when the object is created
function construct(self)
    self.name = random({
        "Lazer",
        "Salad",
        "Sock",
        "Smores",
        "Zeelay",
    })
    --self.position = vec3(1.0, 0.0, 0.0)
    self.position = normalize(
        vec3(
            math.random(),
            math.random(),
            math.random()
        )
    )
    self.kind = random({
        "Human",
        "Alien",
        "Animal",
        { Other = "Worm" },
        { Other = "Robot" },
    })
end