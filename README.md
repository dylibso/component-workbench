# component workbench

This is a workbench repo for experimenting with the component model. Each WAT
file represents an attempt to answer a different question about how the
component model works.

## developing

Install [`just`](https://just.systems) and `wasm-tools`.

- `just build`: to build all `wat` files (to `build/`) and associated
  runners.
- `just run`: Some WAT files have an associated runner -- e.g.,
  `02-component-instantiate.wat` has an associated `02-runner`. Run these
  examples using `just run 02`, `just run 07`, etc.

## License

BSD-3-Clause
