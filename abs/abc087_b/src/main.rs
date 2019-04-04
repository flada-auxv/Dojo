// https://stackoverflow.com/questions/43698191/how-do-i-include-the-end-value-in-a-range
// As of Rust 1.26, you can use "inclusive ranges": `0..=2` but AtCoder's rust version is 1.15.1 yet

use std::io::BufRead;

fn main() {
    let stdin = std::io::stdin();
    let lines: Vec<usize> = stdin
        .lock()
        .lines()
        .map(|x| x.unwrap().parse::<usize>().unwrap().clone())
        .collect();
    let coins: Vec<usize> = lines[0..3].to_vec();
    let total = lines[3];

    let mut count = 0;

    for a in 0..(coins[0] + 1) {
        for b in 0..(coins[1] + 1) {
            for c in 0..(coins[2] + 1) {
                let candidate = vec![a, b, c];
                if sum(&candidate) == total {
                    count = count + 1
                }
            }
        }
    }

    println!("{}", count)
}

fn sum(coins: &Vec<usize>) -> usize {
    coins[0] * 500 + coins[1] * 100 + coins[2] * 50
}
