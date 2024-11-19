use std::fs;
use mlua::{prelude::*, UserData, FromLua, UserDataMethods, Function, Value, Vector};
use serde::{Deserialize, Serialize};

#[derive(
    Serialize,
    Deserialize,
    Clone,
    Debug,
    FromLua
)]
struct Library;

impl UserData for Library {
    fn add_methods<M: UserDataMethods<Self>>(methods: &mut M) {
        methods.add_function("hello", |_, ()| {
            println!("Hello, world!");
            Ok(())
        });
    }
}

#[derive(
    Serialize,
    Deserialize,
    Clone,
    Debug,
    FromLua,
)]
enum ObjectKind {
    Human,
    Alien,
    Animal,
    Other(String),
}

impl UserData for ObjectKind {}

#[derive(
    Serialize,
    Clone,
    Debug,
    FromLua,
)]
struct Template {
    name: Option<String>,
    components: Vec<isize>,
    position: Vector,
    kind: ObjectKind,
}

impl Default for Template {
    fn default() -> Self {
        Self {
            name: None,
            components: Vec::new(),
            position: Vector::new(0.0, 0.0, 0.0),
            kind: ObjectKind::Alien,
        }
    }
}

impl UserData for Template {
    fn add_fields<F: LuaUserDataFields<Self>>(fields: &mut F) {
        fields.add_field_method_get("name", |lua, this| {
            Ok(this.name.as_ref().map(|x| lua.create_string(x).unwrap()))
        });
        fields.add_field_method_set("name", |_, this, val: Value| {
            this.name = val.as_string_lossy();
            Ok(())
        });
        fields.add_field_method_get("position", |lua, this| {
            Ok(this.position)
        });
        fields.add_field_method_set("position", |_, this, val: Value| {
            let Value::Vector(v) = val else { todo!() };
            this.position = v;
            Ok(())
        });
        fields.add_field_method_get("kind", |lua, this| {
            Ok(lua.create_userdata(this.kind.clone())?)
        });
        fields.add_field_method_set("kind", |lua, this, val: Value| {
            this.kind = lua.from_value(val)?;
            Ok(())
        });
    }
    fn add_methods<M: UserDataMethods<Self>>(methods: &mut M) {
        methods.add_method_mut("add", |_, this, new: isize| {
            this.components.push(new);
            Ok(Self::default())
        });
        methods.add_method("debug", |_, this, ()| {
            println!("{:?}", this);
            Ok(())
        });
    }
}

pub fn construct_script<T>(path: &str) -> LuaResult<T>
where
    T: Default + UserData + FromLua + 'static
{
    let source = fs::read_to_string(path).unwrap();

    // Create the Lua environment
    let lua = Lua::new();
    let globals = lua.globals();

    // Always include our library
    let library = Library;
    globals.set("library", library)?;

    // Actually run the Lua script
    // This gives us access to its functions, etc.
    lua.load(source).exec()?;

    // Evaluate its construct() function and get the result
    let object = lua.create_userdata(T::default())?;
    let _: () = globals.get::<Function>("construct")?.call(&object)?;
    let object: T = object.take()?; // Retrieve the "self" object
    Ok(object)
}

fn main() -> LuaResult<()> {
    let result: Template = construct_script("template.luau")?;
    println!("{:?}", result);
    Ok(())
}