(;
And this one is just the core module from `./00-core-module-greet.wat`.
;)
(module $make_greeter
  (memory $memory (export "mem")
    (data "\08\00\00\00" "\15\00\00\00" "Hello from WAT!")
  )
  (func $m-greet (result i32)
    i32.const 0
  )
  (export "greet" (func $m-greet))
)
