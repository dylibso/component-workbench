use std::{borrow::Borrow, path::PathBuf};

use anyhow::Result;
use wasmtime::{
    component::{Component, Linker},
    Config, Engine, Store, WasmBacktraceDetails,
};

wasmtime::component::bindgen!({
    world: "root",
    path: "wit/root.wit",
});

fn main() -> Result<()> {
    let args: Vec<String> = std::env::args().collect();
    let target: PathBuf = args
        .get(1)
        .map(String::as_str)
        .unwrap_or_else(|| "banana-wasi.wasm")
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
    let linker = Linker::new(&engine);

    let component = Component::from_file(&engine, &target).unwrap();

    let mut store = Store::new(
        &engine,
        ()
    );

    let (instance, _instance) = Root::instantiate(&mut store, &component, &linker)?;

    let res = instance.call_hello_world(store)?;

    println!("{}", res);
    Ok(())
}
