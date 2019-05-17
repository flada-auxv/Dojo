fn main() {
    let mut input = String::new();
    std::io::stdin().read_line(&mut input).ok();
    let nums: Vec<usize> = input
        .trim()
        .split_whitespace()
        .map(|x| x.parse::<usize>().unwrap())
        .collect();

    let n = nums[0];
    let amount = nums[1];
    let i_max = if n > (amount / 10_000) { amount / 10_000 } else { n };
    let j_max = if n > (amount /  5_000) { amount /  5_000 } else { n };

    for i in (0..i_max + 1).rev() {
        for j in (0..j_max + 1).rev() {
            if n >= i + j {
                let k = n - i - j;
                // DEBUG
                // println!("{} {} {}", i, j, k);
                if sum(i, j, k) == amount {
                    println!("{} {} {}", i, j, k);
                    return;
                }
            }
        }
    }

    println!("-1 -1 -1");
}

fn sum(i: usize, j: usize, k: usize) -> usize {
    i * 10_000 + j * 5_000 + k * 1_000
}
