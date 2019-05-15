use std::io::BufRead;

fn main() {
    let stdin = std::io::stdin();
    let lines: Vec<String> = stdin.lock().lines().map(|x| x.unwrap()).collect();
    let n = lines[0].parse::<usize>().unwrap();
    // [[t1, x1, y1], [t2, x2, y2]]
    let routes: Vec<Vec<_>> = lines[1..]
        .iter()
        .map(|x| {
            x.split_whitespace()
                .map(|x| x.parse::<usize>().unwrap())
                .collect()
        })
        .collect();

    if steps(routes) > n {
        println!("No");
    }
}

fn steps(routes: Vec<Vec<usize>>) -> usize {
    let mut x_steps = 0;
    let mut y_steps = 0;

    for route in routes {
        x_steps += route[1];
        y_steps += route[2];
    }

    if x_steps > y_steps {
        x_steps
    } else {
        y_steps
    }
}

#[cfg(test)]

mod tests {
    use super::*;

    #[test]
    fn test_steps_1() {
        let routes = vec![vec![2, 100, 100]];
        assert_eq!(steps(routes), 100);
    }
}
