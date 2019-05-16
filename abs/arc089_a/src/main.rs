use std::io::BufRead;

fn main() {
    let stdin = std::io::stdin();
    let lines: Vec<String> = stdin.lock().lines().map(|x| x.unwrap()).collect();
    let n = lines[0].parse::<isize>().unwrap();
    // [[t1, x1, y1], [t2, x2, y2]]
    let routes: Vec<Vec<_>> = lines[1..]
        .iter()
        .map(|x| {
            x.split_whitespace()
                .map(|x| x.parse::<isize>().unwrap())
                .collect()
        })
        .collect();
}

fn is_reachable(routes: Vec<Vec<isize>>) -> bool {
    let mut current_location = vec![0, 0];

    for route in routes {
        if is_reachable_to_next_point(&route, &current_location) {
            current_location = route[1..=2].to_vec();
        } else {
            return false;
        }
    }

    return true;
}

fn is_reachable_to_next_point(route: &Vec<isize>, current_location: &Vec<isize>) -> bool {
    let steps = route[0];
    let min_steps = distance(current_location, &route[1..=2].to_vec());

    if steps == min_steps {
        return true
    } else if steps % 4 == min_steps {
        return true
    } else {
        return false
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
        let from = &vec![4, 4];
        let to = &vec![2, 2];
        assert_eq!(distance(from, to), 4);
    }

    #[test]
    fn test_is_reachable_to_next_point_1() {
        let from = &vec![0, 0];
        let route = &vec![3, 1, 2];
        assert_eq!(is_reachable_to_next_point(route, from), true);
    }

    #[test]
    fn test_is_reachable_to_next_point_2() {
        let from = &vec![0, 0];
        let route = &vec![3, 2, 2];
        assert_eq!(is_reachable_to_next_point(route, from), false);
    }

    #[test]
    fn test_is_reachable_to_next_point_3() {
        let from = &vec![0, 0];
        let route = &vec![5, 0, 1];
        assert_eq!(is_reachable_to_next_point(route, from), true);
    }

    #[test]
    fn test_is_reachable_to_next_point_4() {
        let from = &vec![4, 4];
        let route = &vec![4, 2, 2];
        assert_eq!(is_reachable_to_next_point(route, from), true);
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

    // this test hasn't passed yet!
    #[test]
    fn test_is_reachable_3() {
        let routes = vec![vec![5, 1, 1], vec![100, 1, 1]];
        assert_eq!(is_reachable(routes), false);
    }
}
