-- Helper function, maybe auto-include this?
function vec3(x: number, y: number, z: number): vector
    return vector.create(x, y, z)
end

-- Called when the object is created
function construct(self)
    self.name = "Lazer"
    self.position = vec3(1.0, 0.0, 0.0)
end