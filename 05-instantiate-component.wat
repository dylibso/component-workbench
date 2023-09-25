(;
An example of linking two component instances, written for a presentation.
;)
(component
  (component $tonight-show
      (core module $number-mystery
          (func $guess-the-number (result i32)
            i32.const 32
          )
          (export "get" (func $guess-the-number))
      )
      (core module $number-guesser
          (import "mystery" "get" (func $get (result i32)))
          (func $check
            call $get
            i32.const 13
            i32.eq
            (block
              br_if 0
              (; print something if it matched ... ;)
            )
          )
          (start $check)
      )

      (core instance $envelope (instantiate $number-mystery))
      (core instance $guesser (instantiate $number-guesser (with "mystery" (instance $envelope))))
  )
  (instance (instantiate $tonight-show))
)
