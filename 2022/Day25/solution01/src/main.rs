// Sam Shepard - 2023

use std::{env, fs};

fn main() {
    let args: Vec<String> = env::args().collect();
    let filename = if args.len() < 2 { "test.txt" } else { &args[1] };
    let data =
        fs::read_to_string(filename).unwrap_or_else(|e| panic!("Err {e}: cannot read {filename}"));

    let sum: i64 = data.lines().map(snafu_to_number).sum();

    println!(
        "Snafu sum was: {sum}\nThat's '{}' in SNAFU!",
        number_to_snafu(sum)
    );
}

fn snafu_to_number(s: &str) -> i64 {
    s.chars()
        .rev()
        .map(|c| match c {
            '0' => 0_i64,
            '1' => 1,
            '2' => 2,
            '-' => -1,
            '=' => -2,
            _ => panic!("Illegal character {c}"),
        })
        .fold((0_u32, 0_i64), |(exp, sum), d| {
            (exp + 1, sum + 5_i64.pow(exp) * d)
        })
        .1
}

fn number_to_quintary(mut x: i64) -> Vec<u8> {
    let mut v = Vec::new();
    while x > 0 {
        v.push((x % 5) as u8);
        x /= 5;
    }
    v
}

fn number_to_snafu(x: i64) -> String {
    let v = number_to_quintary(x);
    let mut s = Vec::new();

    let digits = ['=', '-', '0', '1', '2'];
    let mut carry = 0;

    for mut pos in v {
        pos += 2 + carry;
        let (d, q) = (pos / 5, pos % 5);
        s.push(digits[q as usize]);
        carry = d;
    }

    if carry > 0 {
        s.push(digits[carry as usize]);
    }

    s.iter().rev().collect()
}
