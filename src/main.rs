use std::fs;
use mlua::{prelude::*, UserData, FromLua, UserDataMethods, Function, Value};
use serde::{Deserialize, Serialize, de::DeserializeOwned};

#[derive(
    Serialize,
    Deserialize,
    Clone,
    Debug,
    FromLua,
)]
struct Template {
    name: Option<String>,
    components: Vec<isize>,
}

impl Default for Template {
    fn default() -> Self {
        Self {
            name: Some("Fucky".to_string()),
            components: Vec::new(),
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

pub fn construct_script<T: UserData + FromLua + DeserializeOwned>(path: &str) -> LuaResult<T> {
    let source = fs::read_to_string(path).unwrap();

    // Create the Lua environment
    let lua = Lua::new();
    let globals = lua.globals();

    // Add our library table
    let library = Library;
    globals.set("library", library)?;

    globals.set("test", lua.create_userdata(Template::default())?)?;

    // Actually run the Lua script
    lua.load(source).exec()?;

    // Evaluate its construct() function and get teh result
    let construct: Function = globals.get("construct")?;
    let result: T = lua.from_value(construct.call(())?)?;

    Ok(result)
}

fn main() -> LuaResult<()> {
    let result: Template = construct_script("template.luau")?;
    println!("{:?}", result);
    Ok(())
}