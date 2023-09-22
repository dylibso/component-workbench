export PATH := env_var("PATH") + ":" + env_var("HOME") + "/.wasmtime/bin"

_help:
  just --list

clean:
  rm -rf build

build:
  #!/bin/bash
  mkdir -p build/
  for file in $(find . -name '*.wat' | sort); do
    target=build/$(basename ${file%.wat}).wasm
    if [ ! -e $target ] || [ $file -nt $target ]; then
      echo -ne 'building \x1b[32m'$target'\x1b[0m...\n'
      wasm-tools parse $file -o $target
    fi
  done

set export
wasmtime *args:
  #!/bin/bash
  wasmtime $args
