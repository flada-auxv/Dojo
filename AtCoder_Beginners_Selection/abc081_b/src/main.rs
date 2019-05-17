use std::io::BufRead;

fn main() {
    let stdin = std::io::stdin();
    let lines: Vec<String> = stdin.lock().lines().map(|x| x.unwrap()).collect();
    let numbers: Vec<usize> = lines[1]
        .split_whitespace()
        .map(|x| x.parse::<usize>().unwrap())
        .collect();

    let count = divide_recursively(&numbers, 0);
    println!("{}", count)
}

fn divide_recursively(numbers: &Vec<usize>, count: usize) -> usize {
    match is_all_even(numbers) {
        true => divide_recursively(&divide_each_num_by_two(numbers), count + 1),
        false => return count,
    }
}

fn divide_each_num_by_two(numbers: &Vec<usize>) -> Vec<usize> {
    numbers.iter().map(|x| x / 2).collect()
}

fn is_all_even(numbers: &Vec<usize>) -> bool {
    numbers.iter().all(|x| (x % 2) == 0)
}
