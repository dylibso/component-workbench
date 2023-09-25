(;
Playing with instantiating & exporting a component (vs. instantiating a module
and exporting canon functions.) Check out the difference in the wit:

```
$ just build && wasm-tools component wit build/02-component-instantiate.wasm
package root:component

world root {
  export hello-world: func() -> u32
}

$ just build && wasm-tools component wit build/06-instantiate-component-and-export.wasm
package root:component

world root {
  export ok: interface {
    hello-world: func() -> u32
  }
}
```
;)
(component
  (component $greet
      (core module $make_greeter
          (memory $memory (export "mem")
              (data "\08\00\00\00" "\15\00\00\00" "Hello from WAT!")
          )
          (func $m-greet (result i32)
            i32.const 0
          )
          (export "greet" (func $m-greet))
      )
      (core instance $greeter (instantiate 0))
      (alias core export $greeter "greet" (core func))

      (type (func (result u32)))
      (func (type 0) (canon lift (core func 0)))
      (export "hello-world" (func 0))
  )
  (instance (instantiate 0))
  (export "ok" (instance 0))
)
