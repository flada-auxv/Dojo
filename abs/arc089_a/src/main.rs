use std::io::BufRead;

fn main() {
    let stdin = std::io::stdin();
    let lines: Vec<String> = stdin.lock().lines().map(|x| x.unwrap()).collect();

    // [[t1, x1, y1], [t2, x2, y2]]
    let routes: Vec<Vec<_>> = lines[1..]
        .iter()
        .map(|x| {
            x.split_whitespace()
                .map(|x| x.parse::<isize>().unwrap())
                .collect()
        })
        .collect();

    if is_reachable(routes) {
        println!("Yes")
    } else {
        println!("No")
    }
}

fn is_reachable(routes: Vec<Vec<isize>>) -> bool {
    let mut steps_count: isize = 0;
    let mut current_location = vec![0, 0];

    for route in routes {
        let arrival_steps_count = route[0];
        if steps_count >= arrival_steps_count {
            return false;
        }

        let rest_steps = (steps_count - arrival_steps_count).abs();

        if is_reachable_to_next_point(&current_location, &route[1..3].to_vec(), rest_steps) {
            current_location = route[1..3].to_vec();
            steps_count = route[0];
        } else {
            return false;
        }
    }

    return true;
}

fn is_reachable_to_next_point(from: &Vec<isize>, to: &Vec<isize>, rest_steps: isize) -> bool {
    let min_steps = distance(from, to);
    if rest_steps < 1 {
        return false
    } else if min_steps > rest_steps {
        return false;
    } else if min_steps == rest_steps {
        return true;
    } else if min_steps % 2 == rest_steps % 2 {
        return true;
    } else {
        return false;
    }
}

fn distance(from: &Vec<isize>, to: &Vec<isize>) -> isize {
    let x_distance = (from[0] - to[0]).abs();
    let y_distance = (from[1] - to[1]).abs();

    x_distance + y_distance
}

#[cfg(test)]

mod tests {
    use super::*;

    #[test]
    fn test_distance_1() {
        let from = &vec![0, 0];
        let to = &vec![1, 2];
        assert_eq!(distance(from, to), 3);
    }

    #[test]
    fn test_distance_2() {
        let from = &vec![0, 0];
        let to = &vec![1, 2];
        assert_eq!(is_reachable_to_next_point(from, to, 2), false);
    }

    #[test]
    fn test_is_reachable_to_next_point_1() {
        let from = &vec![0, 0];
        let to = &vec![1, 2];
        assert_eq!(is_reachable_to_next_point(from, to, 3), true);
    }

    #[test]
    fn test_is_reachable_to_next_point_2() {
        let from = &vec![0, 0];
        let to = &vec![2, 2];
        assert_eq!(is_reachable_to_next_point(from, to, 3), false);
    }

    #[test]
    fn test_is_reachable_to_next_point_3() {
        let from = &vec![0, 0];
        let to = &vec![0, 1];
        assert_eq!(is_reachable_to_next_point(from, to, 5), true);
    }

    #[test]
    fn test_is_reachable_to_next_point_4() {
        let from = &vec![4, 4];
        let to = &vec![2, 2];
        assert_eq!(is_reachable_to_next_point(from, to, 4), true);
    }

    #[test]
    fn test_is_reachable_to_next_point_5() {
        let from = &vec![0, 0];
        let to = &vec![0, 0];
        assert_eq!(is_reachable_to_next_point(from, to, 1), false);
    }

    #[test]
    fn test_is_reachable_to_next_point_6() {
        let from = &vec![0, 0];
        let to = &vec![0, 0];
        assert_eq!(is_reachable_to_next_point(from, to, 0), false);
    }

    #[test]
    fn test_is_reachable_1() {
        let routes = vec![vec![3, 1, 2], vec![6, 1, 1]];
        assert_eq!(is_reachable(routes), true);
    }

    #[test]
    fn test_is_reachable_2() {
        let routes = vec![vec![2, 100, 100]];
        assert_eq!(is_reachable(routes), false);
    }

    #[test]
    fn test_is_reachable_3() {
        let routes = vec![vec![5, 1, 1], vec![100, 1, 1]];
        assert_eq!(is_reachable(routes), false);
    }

    #[test]
    fn test_is_reachable_4() {
        let routes = vec![vec![4, 2, 2], vec![8, 1, 3], vec![16, 3, 1]];
        assert_eq!(is_reachable(routes), true);
    }
}
