(;

This is an example of exposing a component host interface to a core module. There are roughly
four steps:

1. Import the interface,
2. Define our target core module,
3. Create a trampoline that provides late-bindings for our imported host
   functions; use it to instantiate our target,
4. Create lowered forms of all imported interfaces using our target
   instance's memory and populate our trampoline's jump table.

I reverse-engineered this pattern from the output of `cargo component build`,
where it was obfuscated by repetition. (Each imported interface creates its own
trampoline, and I found it difficult to tell cargo-component *not* to import the
WASI interfaces.)

I've annotated the component with explanatory comments as best I can; there's an associated
runner so you can `just run 13` to see the output.
;)
(component $count_vowels
    (;
      First, import our interface, defining a type in-line. WIT "interfaces" roughly
      correspond to "component instances" (as distinct from "core instances.")
    ;)
    (import (interface "dylibso:example/api") (instance $dylibso
      (export "say-hello" (func (param "name" string) (result u32)))
    ))

    (;
      Second, we define our TARGET core module. This is just the counter module
      from "./08-count-vowels.wat" with two additions:

      1. we import the "say-hello" function from "dylibso:example/api" as `$say-hello`.
      2. we call the imported function.
    ;)
    (core module $TARGET
        ;; 1. The import.
        (import "dylibso:example/api" "say-hello" (func $say-hello (param i32) (param i32) (result i32)))

        (memory (export "memory") 64)

        (func (export "count-vowels") (param $ptr i32) (param $size i32) (result i32)
            (local $i i32)
            (local $chara i32)
            (local $count i32)

            ;; 2. The call.
            (call $say-hello (local.get $ptr) (local.get $size))

            (drop)
            (block $out_of_loop
              (loop $count_loop
                (if (i32.eq (local.get $i) (local.get $size)) (then br $out_of_loop))
                (local.set $chara
                    (i32.and
                      (i32.load8_u (i32.add (local.get $ptr) (local.get $i)))
                      (i32.const 0xdf)
                    )
                )
                (block $skip
                  (block $incr
                    (br_if $incr (i32.eq (i32.const 65) (local.get $chara)))
                    (br_if $incr (i32.eq (i32.const 69) (local.get $chara)))
                    (br_if $incr (i32.eq (i32.const 73) (local.get $chara)))
                    (br_if $incr (i32.eq (i32.const 79) (local.get $chara)))
                    (br_if $incr (i32.eq (i32.const 85) (local.get $chara)))
                    br $skip
                  )
                  (local.set $count (i32.add (local.get $count) (i32.const 1)))
                )
                (local.set $i (i32.add (i32.const 1) (local.get $i)))
                br $count_loop
              )
            )

            local.get $count
        )

        (func (export "realloc") (param i32 i32 i32 i32) (result i32)
            i32.const 1
            memory.grow
        )
    )

    (;
      Third, we create a TRAMPOLINE. This a core module that creates a funcref table
      and a series of functions, one for each method exported by our imported interface.
      `cargo component` exports these with numerical names -- "0", "1", "2" -- which I've
      preserved here.

      This module exists so that we can late-bind our *actual*
    ;)
    (core module $TRAMPOLINE
      (table (export "$imports") 1 1 funcref)
      (func (export "0") (param i32 i32) (result i32)
        local.get 0
        local.get 1
        i32.const 0
        call_indirect (type 0)
      )
    )

    ;; Instantiate TRAMPOLINE as `trampoline`, creating a module with N exports, "0", "1", ... N.
    (core instance $trampoline
      (instantiate $TRAMPOLINE)
    )

    ;; Bring `trampoline`'s exports into component scope so we can synthesize a *new* core instance
    ;; that remaps the exports ("0" -> "say-hello".)
    (alias core export $trampoline "$imports" (core table $trampoline-tables))
    (alias core export $trampoline "0" (core func $say-hello))
    (core instance $remapped-trampoline
      (export "say-hello" (func $say-hello)))

    ;; Instantiate TARGET as target using our synthesized trampoline. Anytime our target calls a host
    ;; function, it will bounce off our trampoline module.
    (core instance $target
      (instantiate $TARGET
        (with "dylibso:example/api" (instance $remapped-trampoline))
      )
    )

    (;
      Fourth: now that we've instantiated our TARGET module, we have access to that instance's
      exported *memory* and *realloc* functions. We can use these to define **lowered** versions
      of our component imports -- and complete the TRAMPOLINE we created in step 3.

      /!\ /!\ /!\

      The whole point of TRAMPOLINE is that we can't create lowered functions
      without already having access to the TARGET instance's memory and realloc
      machinery!

      /!\ /!\ /!\
    ;)
    (alias core export $target "realloc" (core func $realloc))
    (alias core export $target "memory" (core memory $memory))

    ;; Pull in $dylibso's "say-hello" func as component-say-hello...
    (alias export $dylibso "say-hello" (func $component-say-hello))

    ;; ... then use that function (along with our TARGET's exported realloc and memory) to define
    ;; a **new core function** using `canon lower`.
    (core func $core-say-hello
      (canon lower
        (func $component-say-hello)
        (memory $memory)
        (realloc $realloc)
      )
    )

    ;; Synthesize a core module that re-exports our trampoline's tables alongside our
    ;; newly lowered core functions representing our component imports. Again, `cargo-component`
    ;; exports these as integer-indexed properties, so I've replicated that here.
    (core instance $trampoline-tables
      (export "$imports" (table $trampoline-tables))
      (export "0" (func $core-say-hello))
    )

    ;; Define a new core module, ZIPPER, that imports a table and a set of 0-indexed functions.
    ;; ZIPPER only performs **one** action: statically defining an `elem` that references the
    ;; imported table and assigns each imported function to a slot in that table.
    (core module $ZIPPER
      (import "" "0" (func (param i32 i32) (result i32)))
      (import "" "$imports" (table 1 1 funcref))  ;; this defines "table 0"...
      (elem (i32.const 0) func 0)                 ;; ..which elem refers to via `(i32.const 0)`.
    )

    ;; Instantiate ZIPPER to invoke the `elem` statement, completing our TRAMPOLINE. As far as
    ;; importing a host function goes, we're done!
    (core instance
      (instantiate $ZIPPER
      (with "" (instance $trampoline-tables))))


    (; The rest of this is just the usual "lift a core function and export it" boilerplate. ;)
    (alias core export $target "count-vowels" (core func $core-counter))
    (func (export "count-vowels") (param "input" string) (result u32)
      (canon lift
        (core func $core-counter)
        (memory $memory)
        (realloc $realloc)
        string-encoding=utf8
      )
    )
)
