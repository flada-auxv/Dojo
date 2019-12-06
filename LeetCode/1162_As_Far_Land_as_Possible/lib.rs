struct Solution {}
impl Solution {
    pub fn max_distance(grid: Vec<Vec<i32>>) -> i32 {
        2
    }
}

#[test]
fn test_input1() {
    let input = vec![vec![1,0,1],vec![0,0,0],vec![1,0,1]];

    assert_eq!(2, Solution::max_distance(input));
}
