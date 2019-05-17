use std::io::BufRead;

fn main() {
    let stdin = std::io::stdin();
    let lines: Vec<String> = stdin.lock().lines().map(|x| x.unwrap()).collect();

    let mut cards: Vec<usize> = lines[1]
        .split_whitespace()
        .map(|x| x.parse::<usize>().unwrap())
        .collect();
    cards.sort_by(|a, b| b.cmp(a));

    let mut a_cards = vec![];
    let mut b_cards = vec![];

    for i in 0..cards.len() {
        match i % 2 == 0 {
            true => a_cards.push(cards[i]),
            false => b_cards.push(cards[i]),
        }
    }

    let sub = a_cards.iter().sum::<usize>() - b_cards.iter().sum::<usize>();
    println!("{:?}", sub);
}
