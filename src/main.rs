use std::fs;
use mlua::{prelude::*, UserData, FromLua, UserDataMethods, Function, AnyUserData};
use serde::{Deserialize, Serialize};

#[derive(
    Serialize,
    Deserialize,
    Clone,
    Debug,
    FromLua
)]
struct Template {
    components: Vec<isize>,
}

impl Default for Template {
    fn default() -> Self {
        Self {
            components: Vec::new(),
        }
    }
}

impl UserData for Template {
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

pub fn construct_script<T: UserData + FromLua + Default>(path: &str) -> LuaResult<T> {
    let filename = "template.lua";
    let source = fs::read_to_string(filename).unwrap();

    // Create the Lua environment
    let lua = Lua::new();
    let globals = lua.globals();

    // Add our library table
    let library = Library;
    globals.set("library", library)?;

    // Actually run the Lua script
    lua.load(source).exec()?;

    // Add the template object
    globals.set("self", Template::default())?;

    // Evaluate its construct() function
    let construct: Function = globals.get("construct")?;
    //let object = construct.call::<Template>(Template::new())?;
    construct.call::<()>(())?;
    let object: T = globals.get("self")?;

    Ok(object)
}

fn main() -> LuaResult<()> {
    let result: Template = construct_script("template.lua")?;
    println!("{:?}", result);
    Ok(())
}