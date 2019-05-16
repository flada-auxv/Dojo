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
        if is_reachable_to_next_point(&route, &current_location, steps_count) {
            current_location = route[1..3].to_vec();
            steps_count += route[0];
        } else {
            return false;
        }
    }

    return true;
}

fn is_reachable_to_next_point(
    route: &Vec<isize>,
    current_location: &Vec<isize>,
    current_steps_count: isize,
) -> bool {
    let arrival_steps_count = route[0];
    if current_steps_count >= arrival_steps_count {
        return false;
    }

    let rest_steps = (current_steps_count - arrival_steps_count).abs();
    let min_steps = distance(current_location, &route[1..3].to_vec());

    if min_steps > rest_steps || min_steps % 2 != rest_steps % 2 {
        return false;
    }

    return true;
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
        let from = &vec![4, 4];
        let to = &vec![2, 2];
        assert_eq!(distance(from, to), 4);
    }

    #[test]
    fn test_is_reachable_to_next_point_1() {
        let from = &vec![0, 0];
        let route = &vec![3, 1, 2];
        assert_eq!(is_reachable_to_next_point(route, from, 0), true);
    }

    #[test]
    fn test_is_reachable_to_next_point_2() {
        let from = &vec![0, 0];
        let route = &vec![3, 2, 2];
        assert_eq!(is_reachable_to_next_point(route, from, 0), false);
    }

    #[test]
    fn test_is_reachable_to_next_point_3() {
        let from = &vec![0, 0];
        let route = &vec![5, 0, 1];
        assert_eq!(is_reachable_to_next_point(route, from, 0), true);
    }

    #[test]
    fn test_is_reachable_to_next_point_4() {
        let from = &vec![4, 4];
        let route = &vec![4, 2, 2];
        assert_eq!(is_reachable_to_next_point(route, from, 0), true);
    }

    #[test]
    fn test_is_reachable_to_next_point_5() {
        let from = &vec![0, 0];
        let route = &vec![3, 1, 2];
        assert_eq!(is_reachable_to_next_point(route, from, 1), false);
    }

    #[test]
    fn test_is_reachable_to_next_point_6() {
        let from = &vec![0, 0];
        let route = &vec![1, 0, 0];
        assert_eq!(is_reachable_to_next_point(route, from, 0), false);
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
