use std::fs;
use mlua::{prelude::*, UserData, FromLua};
use serde::{Deserialize, Serialize};

#[derive(
    Serialize,
    Deserialize,
    Clone,
    Debug,
    FromLua
)]
enum Kind {
    Cat,
    Dog,
    Fish,
}

impl UserData for Kind {}

fn main() -> LuaResult<()> {
    let filename = "test.lua";
    if let Ok(source) = fs::read_to_string(filename) {
        let lua = Lua::new();
        let globals = lua.globals();

        //let thing = Kind::Fish;
        //globals.set("thing", lua.create_ser_userdata(thing)?)?;

        let result = lua.load(source).eval()?;

        //let thing = globals.get::<Kind>("thing")?;
        //println!("{:?}", thing);

        let x = lua.from_value::<Kind>(result)?;
        println!("{:?}", x);
    };

    Ok(())
}