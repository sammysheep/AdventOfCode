use std::collections::HashMap;

use super::Solution;

pub fn pt1(data: &str) -> Solution {
    data.lines()
        .filter(|l| naught_or_nice_pt1(l))
        .count()
        .into()
}

pub fn pt2(data: &str) -> Solution {
    data.lines()
        .filter(|l| naught_or_nice_pt2(l))
        .count()
        .into()
}

fn naught_or_nice_pt2(line: &str) -> bool {
    return triad_rule(line) && double_rule(line);

    fn triad_rule(line: &str) -> bool {
        for [p1, _, p3] in line.as_bytes().array_windows::<3>() {
            if p1 == p3 {
                return true;
            }
        }
        false
    }

    fn double_rule(line: &str) -> bool {
        let mut h = HashMap::new();
        let mut iter = line.as_bytes().array_windows::<2>().enumerate();
        if let Some((i, &w)) = iter.next() {
            h.insert(w, i);
        } else {
            return false;
        };

        for (i, &w) in iter {
            if let Some(&k) = h.get(&w) {
                if i > k + 1 {
                    return true;
                }
            } else {
                h.insert(w, i);
            }
        }
        false
    }
}

fn naught_or_nice_pt1(line: &str) -> bool {
    let mut iter = line.bytes();

    let Some(mut previous) = iter.next() else {
        return false;
    };

    let mut vowels = if matches!(previous, b'a' | b'e' | b'i' | b'o' | b'u') {
        1
    } else {
        0
    };
    let mut has_double = false;

    for current in iter {
        if matches!(
            (previous, current),
            (b'a', b'b') | (b'c', b'd') | (b'p', b'q') | (b'x', b'y')
        ) {
            return false;
        }

        if current == previous {
            has_double = true;
        }

        if matches!(current, b'a' | b'e' | b'i' | b'o' | b'u') {
            vowels += 1;
        }

        previous = current;
    }

    vowels >= 3 && has_double
}

#[cfg(test)]
mod test {
    use crate::days::day_05::naught_or_nice_pt1;

    #[test]
    fn unit_tests_pt1() {
        assert!(naught_or_nice_pt1("ugknbfddgicrmopn"));
        assert!(naught_or_nice_pt1("aaa"));
        assert!(!naught_or_nice_pt1("jchzalrnumimnmhp"));
        assert!(!naught_or_nice_pt1("haegwjzuvuyypxyu"));
        assert!(!naught_or_nice_pt1("dvszwmarrgswjxmb"));
    }
}
