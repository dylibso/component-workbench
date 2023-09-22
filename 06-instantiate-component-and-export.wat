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
