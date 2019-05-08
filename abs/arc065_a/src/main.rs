fn main() {
    let stdin = std::io::stdin();
    let mut input = String::new();
    stdin.read_line(&mut input).ok();
    input.pop(); // trim newline

    match find(input.as_str()) {
        true => println!("YES"),
        false => println!("NO"),
    };
}

static WORDS: [&'static str; 4] = ["dream", "dreamer", "erase", "eraser"];

fn find(string: &str) -> bool {
    // println!("string: {:?}", string);

    for word in &WORDS {
        // println!("string: {:?}, check word: {:?}", string, word);

        if !string.starts_with(word) {
            // println!("not match");
            continue;
        }

        let rest = &string[word.len()..];
        // println!("rest: {:?}, len: {:?}", rest, rest.len());
        match rest.len() {
            0 => return true,
            1...4 => continue, // because min word length is 5
            _ => if find(rest) { return true } else { /* no-op */ }
        };
    }

    // println!("not match against any words");
    return false;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn input_1() {
        assert_eq!(find("erasedream"), true);
    }

    #[test]
    fn input_2() {
        assert_eq!(find("dreameraser"), true);
    }

    #[test]
    fn input_3() {
        assert_eq!(find("adreamersssersssss"), false);
    }

    #[test]
    fn input_4() {
        assert_eq!(find("eraserdreamer"), true);
    }

}

