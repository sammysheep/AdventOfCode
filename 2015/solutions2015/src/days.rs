pub mod day_01;
pub mod day_02;
pub mod day_03;
pub mod day_04;
pub mod day_05;
pub mod day_06;

use std::fmt::Display;

#[derive(Default, Debug, PartialEq, Eq)]
pub enum Solution {
    #[default]
    None,
    Unsigned(usize),
    Signed(isize),
}

impl From<i32> for Solution {
    fn from(value: i32) -> Self {
        Solution::Signed(value as isize)
    }
}

impl From<isize> for Solution {
    fn from(value: isize) -> Self {
        Solution::Signed(value)
    }
}

impl From<usize> for Solution {
    fn from(value: usize) -> Self {
        Solution::Unsigned(value)
    }
}

impl From<Option<isize>> for Solution {
    fn from(value: Option<isize>) -> Self {
        if let Some(v) = value {
            Solution::Signed(v)
        } else {
            Solution::None
        }
    }
}

impl From<Option<usize>> for Solution {
    fn from(value: Option<usize>) -> Self {
        if let Some(v) = value {
            Solution::Unsigned(v)
        } else {
            Solution::None
        }
    }
}

impl Display for Solution {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Solution::None => f.write_str("None"),
            Solution::Signed(i) => write!(f, "{i}"),
            Solution::Unsigned(i) => write!(f, "{i}"),
        }
    }
}

/*
use super::Solution;

pub fn pt1(data: &str) -> Solution {
    unimplemented!()
}

pub fn pt2(data: &str) -> Solution {
    unimplemented!()
}
*/
