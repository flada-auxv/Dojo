fn main() {
    let mut input = String::new();
    std::io::stdin().read_line(&mut input).ok();
    let arr: Vec<usize> = input.trim().split_whitespace().map(|x| x.parse::<usize>().unwrap()).collect();

    match ((arr[0] * arr[1]) % 2) == 0 {
        true => println!("Even"),
        false => println!("Odd")
    }
}
