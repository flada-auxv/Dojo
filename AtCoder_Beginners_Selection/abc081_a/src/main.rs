fn main() {
    let mut input = String::new();
    std::io::stdin().read_line(&mut input).ok();
    let count = input.trim().split("").filter(|&x| x == "1").count();
    println!("{:?}", count);
}
