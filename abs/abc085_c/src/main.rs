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

    for i in 0..(n + 1) {
        for j in 0..(n + 1) {
            if n >= i + j {
                let k = n - i - j;
                let nums = vec![i, j, k];
                // DEBUG
                // println!("{:?}", &nums);
                if sum(&nums) == amount {
                    println!("{} {} {}", &nums[0], &nums[1], &nums[2]);
                    return;
                }
            }
        }
    }

    println!("-1 -1 -1");
}

fn sum(nums: &Vec<usize>) -> usize {
    nums[0] * 10_000 + nums[1] * 5_000 + nums[2] * 1_000
}
