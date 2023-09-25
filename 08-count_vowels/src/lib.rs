cargo_component_bindings::generate!();

use bindings::Guest;

struct Component;

impl Guest for Component {
    fn count_vowels(input: String) -> u32 {
        input.chars().fold(0, |acc, ch| match ch {
            'a' | 'e' | 'i' | 'o' | 'u' => acc + 1,
            _ => acc
        })
    }
}
