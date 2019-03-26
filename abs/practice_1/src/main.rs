use std::io::prelude::*;

fn main() {
    let stdin = std::io::stdin();

    let mut num: usize = 0;
    let mut string = String::new();

    for (i, line) in stdin.lock().lines().map(|x| x.unwrap()).enumerate() {
        match i {
            0 => num = num + line.parse::<usize>().unwrap(),
            1 => num = num + line.split_whitespace().map(|x| x.parse::<usize>().unwrap()).sum::<usize>(),
            2 => string = line,
            _ => panic!("error")
        }
    }

    println!("{} {}", num, string);
}
