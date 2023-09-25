(;
In this component, I'm manually walking the path of instantiating the
module from `./00-core-module-greet.wat` and writing the component model
instructions myself.

Not much to see here, but it can be run using "just run 02". It prints out
the address of the memory -- in this case, 0. You can change this behavior
by changing the `i32.const 0` line below to any other positive number.
;)
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

    (type $component-ret-u32 (func (result u32)))
    (func $canon-greeter-fn
      (type $component-ret-u32)
      (canon lift (core func $greeter-fn)))
    (export "hello-world" (func $canon-greeter-fn))
)
