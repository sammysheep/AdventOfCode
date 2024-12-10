use regex::Regex;
use std::{
    collections::{BTreeMap, HashMap},
    sync::LazyLock,
};

use super::Solution;

pub fn pt1(data: &str) -> Solution {
    let matrix = parse(data);
    let pp = PathPermuter::new_from_matrx(&matrix);
    pp.min().unwrap().into()
}

pub fn pt2(data: &str) -> Solution {
    let matrix = parse(data);
    let pp = PathPermuter::new_from_matrx(&matrix);
    pp.max().unwrap().into()
}

static PARSE: LazyLock<Regex> =
    LazyLock::new(|| Regex::new(r"(\w+) to (\w+) = (\d+)").expect("Malformed regex for day 6."));

fn parse(data: &str) -> Vec<Vec<u32>> {
    let mut hm = BTreeMap::new();
    for line in data.lines() {
        if let Some(caps) = PARSE.captures(line) {
            let key1 = caps.get(1).unwrap().as_str();
            let key2 = caps.get(2).unwrap().as_str();
            let dist = caps
                .get(3)
                .unwrap()
                .as_str()
                .to_string()
                .parse::<u32>()
                .unwrap();

            hm.entry(key1).or_insert(HashMap::new()).insert(key2, dist);
            hm.entry(key2).or_insert(HashMap::new()).insert(key1, dist);
        }
    }

    let keys: Vec<_> = hm.keys().collect();
    let mut matrix = vec![vec![0; keys.len()]; keys.len()];

    for (i, key1) in keys.iter().enumerate() {
        for (j, key2) in keys.iter().enumerate() {
            if key1 != key2 {
                matrix[i][j] = hm[*key1][*key2];
            }
        }
    }
    matrix
}

#[derive(Clone)]
struct PathPermuter<'a> {
    c: Vec<usize>,
    index: usize,
    path: Vec<usize>,
    matrix: &'a Vec<Vec<u32>>,
}

impl<'a> PathPermuter<'a> {
    fn new_from_matrx(matrix: &'a Vec<Vec<u32>>) -> Self {
        PathPermuter {
            c: Vec::new(),
            index: 0,
            path: Vec::new(),
            matrix,
        }
    }

    fn sum_path(&self) -> u32 {
        self.path
            .array_windows::<2>()
            .map(|[a, b]| self.matrix[*a][*b])
            .sum()
    }
}

impl Iterator for PathPermuter<'_> {
    type Item = u32;

    // Iterative Heap's Algorithm
    fn next(&mut self) -> Option<Self::Item> {
        if self.c.is_empty() {
            self.path = (0..self.matrix.len()).collect();
            self.c = vec![0; self.path.len()];
            self.index = 1;

            return Some(self.sum_path());
        }

        let PathPermuter {
            c,
            index,
            path,
            matrix: _,
        } = self;

        if *index < path.len() {
            if c[*index] < *index {
                if *index % 2 == 0 {
                    path.swap(0, *index);
                } else {
                    path.swap(c[*index], *index);
                }
                c[*index] += 1;
                *index = 1;

                Some(self.sum_path())
            } else {
                c[*index] = 0;
                *index += 1;
                self.next()
            }
        } else {
            None
        }
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn unit_test() {
        let data =
            "London to Dublin = 464\nLondon to Belfast = 518\nDublin to Belfast = 141".to_string();
        let matrix = parse(&data);
        #[rustfmt::skip]
        let expected = vec![
            vec![0, 141, 518],
            vec![141, 0, 464],
            vec![518, 464, 0]
        ];

        assert_eq!(matrix, expected);

        let pp = PathPermuter::new_from_matrx(&matrix);
        let min = pp.clone().min();
        assert_eq!(min, Some(605));

        let max = pp.max();
        assert_eq!(max, Some(982));
    }
}
