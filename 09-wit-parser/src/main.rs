use std::path::Path;

use wit_parser::UnresolvedPackage;

fn main() -> anyhow::Result<()> {
    let Some(target) = std::env::args().nth(1) else {
        anyhow::bail!("usage: wit-parser <path/to/wit/file>");
    };

    let content = std::fs::read_to_string(target.as_str())?;

    dbg!(UnresolvedPackage::parse(Path::new(target.as_str()), content.as_str())?);

    println!("{}", content);

    Ok(())
}
