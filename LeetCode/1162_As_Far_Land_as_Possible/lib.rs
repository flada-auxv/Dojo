type Coordinate = (i32,i32);

struct Solution {}
impl Solution {
    pub fn max_distance(grid: Vec<Vec<i32>>) -> i32 {
        let mut max: i32 = 0;
        let (waters, lands) = Solution::coordinates(grid);

        if waters.len() == 0 || lands.len() == 0 {
            return -1
        }

        for water in waters {
            let distances: Vec<i32> = lands.iter().map(|land| Solution::distance(water, *land) ).collect();
            let min_distance = distances.iter().min().unwrap();

            if min_distance > &max {
                max = *min_distance
            }
        }

        max
    }

    fn coordinates(grid: Vec<Vec<i32>>) -> (Vec<Coordinate>, Vec<Coordinate>) {
        let mut lands = Vec::new();
        let mut waters = Vec::new();

        for (x, row) in grid.iter().enumerate() {
            for (y, elem) in row.iter().enumerate() {
                let coordinate: Coordinate = (x as i32, y as i32);
                match &elem {
                    0i32 => waters.push(coordinate),
                    1i32 => lands.push(coordinate),
                    _ => panic!("unreachable!"),
                }
            }
        }

        (waters, lands)
    }

    fn distance(from: Coordinate, to: Coordinate) -> i32 {
        (from.0 - to.0).abs() + (from.1 - to.1).abs()
    }
}

#[test]
fn test_input1() {
    let input = vec![vec![1,0,1],vec![0,0,0],vec![1,0,1]];
    assert_eq!(2, Solution::max_distance(input));
}

#[test]
fn test_input2() {
    let input = vec![vec![1,0,0],vec![0,0,0],vec![0,0,0]];
    assert_eq!(4, Solution::max_distance(input));
}

#[test]
fn test_input3() {
    let input = vec![vec![0,0,0],vec![0,0,0],vec![0,0,0]];
    assert_eq!(-1, Solution::max_distance(input));
}

#[test]
fn test_input4() {
    let input = vec![vec![1,1,1],vec![1,1,1],vec![1,1,1]];
    assert_eq!(-1, Solution::max_distance(input));
}

#[test]
fn test_input5() {
    let input = vec![vec![0,1,1],vec![1,1,1],vec![1,1,1]];
    assert_eq!(1, Solution::max_distance(input));
}
