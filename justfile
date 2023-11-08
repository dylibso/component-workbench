export PATH := env_var("PATH") + ":" + env_var("HOME") + "/.wasmtime/bin"

_help:
  just --list

clean:
  rm -rf build
  cargo clean

_build_cargo:
  @cargo build --workspace --release --quiet

build: _build_cargo
  #!/bin/bash
  mkdir -p build/
  for file in $(find . -name '*.wat' | sort); do
    target=build/$(basename ${file%.wat}).wasm
    if [ ! -e $target ] || [ $file -nt $target ]; then
      echo -ne 'building \x1b[32m'$target'\x1b[0m...\n'
      wasm-tools parse $file -o $target
    fi
  done

run which='02': build
  @cargo run --quiet --release --bin $(cargo metadata --format-version=1 | jq --arg which {{which}} -r '.workspace_members[] | select(contains($which))' | awk '{print $1}')

set export
wasmtime *args:
  #!/bin/bash
  wasmtime $args
