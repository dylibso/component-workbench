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
    (alias core export $greeter "greet" (core func $greeter-fn))
    (alias core export $greeter "mem" (core memory $mem))

    (type $component-ret-u32 (func (result string)))
    (func $canon-greeter-fn
      (type $component-ret-u32)
      (canon lift (core func $greeter-fn) (memory $mem)))
    (export "hello-world" (func $canon-greeter-fn))
)
