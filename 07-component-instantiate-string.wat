(;
Building on `./02-component-instantiate.wat`, in this file I'm manually walking
the steps to return a *string* instead of a *u32* pointer. Note that we have to
export the memory and refer to it in the `canon lift` line below.
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
    (alias core export $greeter "mem" (core memory $mem))

    (type $component-ret-str (func (result string)))
    (func $canon-greeter-fn
      (type $component-ret-str)
      (canon lift (core func $greeter-fn) (memory $mem)))
    (export "hello-world" (func $canon-greeter-fn))
)
