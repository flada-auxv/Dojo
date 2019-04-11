fn main() {
    let stdin = std::io::stdin();
    let mut line = String::new();
    stdin.read_line(&mut line).ok();
    let inputs = line
        .split_whitespace()
        .map(|x| x.parse::<usize>().unwrap())
        .collect::<Vec<usize>>();

    let mut result = 0;

    for i in 1..(inputs[0] + 1) {
        let total = nums(i).iter().sum::<usize>();

        if inputs[1] <= total && total <= inputs[2] {
            result = result + i;
        }
    }

    println!("{:?}", result);
}

fn nums(num: usize) -> Vec<usize> {
    num.to_string()
        .split("")
        .filter(|x| !x.is_empty())
        .map(|x| x.parse::<usize>().unwrap())
        .collect::<Vec<usize>>()
}
