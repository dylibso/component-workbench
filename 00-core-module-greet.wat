(;
This is a transliteration of the "hello from WAT" example 
from Kyle Brown's "Wasm Components for Every Language" [1] talk.

[1]: https://www.youtube.com/watch?v=IqehHuPYUSc&t=12s
;)
(component
  (core module $m
    (memory $memory (export "mem")
      (data "\08\00\00\00" "\15\00\00\00" "Hello from WAT!")
    )
    (func $m-greet (result i32)
      i32.const 0
    )
    (export "greet" (func $m-greet))
  )
  (core instance $M (instantiate $m))
  (alias core export $M "mem" (core memory $c-mem))
  (func $c-greet (result string)
    (canon lift (core func $M "greet")
      string-encoding=utf8
      (memory $c-mem)
    )
  )
  (instance (export (interface "wasmcon2023:greet/interface"))
    (export "greet" (func $c-greet))
  )
)
