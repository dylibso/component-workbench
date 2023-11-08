;; This is an example of using a core module's function export as a component
;; "start" function, then using that "start" function to return a singleton value
;; which we then export.
;;
;; Unfortunately, while this is allowed by the spec, at the time of writing this is
;; not supported by wasmtime (2023-11-07, wasmtime @ 14.)
;;
;; Nevertheless, you can run this example using `just run 12` to get some error output.
(component
  (core module $Main
    (memory $memory (export "mem")
      (data "\08\00\00\00" "\15\00\00\00" "Hello from WAT!")
    )
    (func (export "start") (result i32)
      i32.const 0
    )
  )
  (core instance $main (instantiate $Main))

  (func $start (result string)
    (canon lift
      (core func $main "start")
      (memory $main "mem")
    )
  )

  (start $start (result (value $greeting)))
  (export "greeting" (value $greeting))
)
