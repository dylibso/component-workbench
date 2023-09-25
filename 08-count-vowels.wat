(component $count_vowels
    (core module $make_counter
        (memory $memory 64)

        (func $count (param $ptr i32) (param $size i32) (result i32)
            (local $i i32)
            (local $chara i32)
            (local $count i32)

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

        (func $realloc (param i32 i32 i32 i32) (result i32)
            i32.const 1
            memory.grow
        )

        (export "memory" (memory $memory))
        (export "count-vowels" (func $count))
        (export "realloc" (func $realloc))
    )
    (core instance $counter (instantiate $make_counter))

    (alias core export $counter "count-vowels" (core func $core-counter))
    (alias core export $counter "realloc" (core func $realloc))
    (alias core export $counter "memory" (core memory $memory))

    (type $t-count-vowels (func (param "input" string) (result u32)))

    (func $c-count-vowels (type $t-count-vowels) (canon lift (core func $core-counter) (memory $memory) (realloc $realloc) string-encoding=utf8))
    (export "count-vowels" (func $c-count-vowels))
)
