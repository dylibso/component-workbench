(;
This is pulled from the "Instances" section of Ryan Levick's components git book [1].

[1]: https://wasm-components.fermyon.app/encoding.html#instances
;)
(component
  (core module $A
    (func (export "one") (result i32) (i32.const 1))
  )
  (core module $B
    (func (import "a" "one") (result i32))
  )
  (core instance $a (instantiate $A))
  (core instance $b (instantiate $B (with "a" (instance $a))))
)
