use std::collections::HashSet;
use std::io::BufRead;

fn main() {
    let stdin = std::io::stdin();
    let mut lines: Vec<usize> = stdin
        .lock()
        .lines()
        .map(|x| x.unwrap().parse::<usize>().unwrap())
        .collect();
    let mochi: HashSet<usize> = lines.drain(1..).collect();

    println!("{:?}", mochi.len());
}
