use std::path::PathBuf;

use anyhow::Result;
use wasmtime::{
    component::{Component, Linker},
    Config, Engine, Store, WasmBacktraceDetails,
};

wasmtime::component::bindgen!({
    world: "root",
    path: "wit/root.wit"
});

fn main() -> Result<()> {
    let args: Vec<String> = std::env::args().collect();
    let target: PathBuf = args
        .get(1)
        .map(String::as_str)
        .unwrap_or_else(|| "build/13-host-fn.wasm")
        .into();

    if !target.as_path().is_file() {
        return Err(anyhow::anyhow!(
            "target wasm file \"{}\" does not exist",
            target.to_string_lossy()
        ));
    }

    let mut config = Config::new();
    config.cache_config_load_default().unwrap();
    config.wasm_backtrace_details(WasmBacktraceDetails::Enable);
    config.wasm_component_model(true);

    let engine = Engine::new(&config)?;
    let mut linker = Linker::new(&engine);

    let component = Component::from_file(&engine, &target).unwrap();

    let mut store = Store::new(
        &engine,
        ()
    );

    // ### HOST API.
    //
    // We're sidestepping *quite a bit* of the `wasmtime::component-bindgen` machinery here.
    // In particular, in lieu of associating some state with the store via the generated
    // `add_to_linker` function, we're directly creating a component instance using the linker
    // and defining a function.
    //
    // If you've ever run `wasm-tools component wit` on the output of `cargo component build`, you
    // might've noticed that the WIT produced includes WASI imports whether or not your
    // `wit/root.wit` file contains them or not.
    //
    // This implementation of `dylibso:example` is similar to WASI's approach -- it means the
    // component WIT we work against _does not have to_ import our interfaces. Our host functions
    // are ambiently available to components, like WASI's.
    let mut inst = linker.instance("dylibso:example/api")?;
    inst.func_wrap(
        "say-hello",
        move |
            mut _caller: wasmtime::StoreContextMut<'_, _>,
            (_arg0,): (String,)|
        {
            eprintln!("SUCCESS! Hello from the host.");
            Ok((0xdeadbeefu32,))
        },
    )?;


    let (instance, _instance) = Root::instantiate(&mut store, &component, &linker)?;

    let res = instance.call_count_vowels(store, "It's a nice day. wow!")?;

    println!("{}", res);
    Ok(())
}
