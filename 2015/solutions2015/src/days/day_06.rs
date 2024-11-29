use regex::Regex;
use std::{
    io::{Error as IOError, ErrorKind},
    num::IntErrorKind,
    ops::RangeInclusive,
    sync::LazyLock,
};

use super::Solution;

pub fn pt1(data: &str) -> Solution {
    let mut grid = vec![vec![0; 1000]; 1000];

    for cmd in parse(data).flatten() {
        for r in cmd.get_rows() {
            for c in cmd.get_cols() {
                grid[r][c] = cmd.action.modify_light_pt1(grid[r][c]);
            }
        }
    }

    grid.iter().flatten().sum::<usize>().into()
}

pub fn pt2(data: &str) -> Solution {
    let mut grid = vec![vec![0; 1000]; 1000];

    for cmd in parse(data).flatten() {
        for r in cmd.get_rows() {
            for c in cmd.get_cols() {
                grid[r][c] = cmd.action.modify_light_pt2(grid[r][c]);
            }
        }
    }

    grid.iter().flatten().sum::<usize>().into()
}

static PARSE: LazyLock<Regex> = LazyLock::new(|| {
    Regex::new(r"(toggle|off|on).+?(\d+,\d+).+?(\d+,\d+)").expect("Malformed regex for day 6.")
});

fn parse(data: &str) -> impl Iterator<Item = Option<LightCommand>> + '_ {
    data.lines().map(|line| {
        if let Some(caps) = PARSE.captures(line) {
            Some(LightCommand {
                p1: caps.get(2)?.as_str().try_into().ok()?,
                p2: caps.get(3)?.as_str().try_into().ok()?,
                action: caps.get(1)?.as_str().try_into().ok()?,
            })
        } else {
            None
        }
    })
}

#[derive(Debug)]
struct LightCommand {
    p1: Point,
    p2: Point,
    action: Action,
}

impl LightCommand {
    fn get_rows(&self) -> RangeInclusive<usize> {
        let start = self.p1.1.min(self.p2.1);
        let end = self.p1.1.max(self.p2.1);
        start..=end
    }

    fn get_cols(&self) -> RangeInclusive<usize> {
        let start = self.p1.0.min(self.p2.0);
        let end = self.p1.0.max(self.p2.0);
        start..=end
    }
}

#[derive(Debug)]
enum Action {
    On,
    Off,
    Toggle,
}

impl Action {
    fn modify_light_pt2(&self, other: usize) -> usize {
        match self {
            Self::On => other + 1,
            Self::Off => other.saturating_sub(1),
            Self::Toggle => other + 2,
        }
    }

    fn modify_light_pt1(&self, other: usize) -> usize {
        match self {
            Self::On => 1,
            Self::Off => 0,
            Self::Toggle => other ^ 1,
        }
    }
}

impl TryFrom<&str> for Action {
    type Error = IOError;
    fn try_from(value: &str) -> Result<Self, Self::Error> {
        Ok(match value {
            "on" => Action::On,
            "off" => Action::Off,
            "toggle" => Action::Toggle,
            _ => Err(IOError::new(
                ErrorKind::InvalidData,
                "Invalid input to day 6",
            ))?,
        })
    }
}

#[derive(Debug)]
struct Point(usize, usize);

impl TryFrom<&str> for Point {
    type Error = IntErrorKind;
    fn try_from(value: &str) -> Result<Self, Self::Error> {
        let mut split = value.split(",");
        Ok(Point(
            split
                .next()
                .ok_or(IntErrorKind::Empty)?
                .parse::<usize>()
                .map_err(|e| e.kind().clone())?,
            split
                .next()
                .ok_or(IntErrorKind::Empty)?
                .parse::<usize>()
                .map_err(|e| e.kind().clone())?,
        ))
    }
}
