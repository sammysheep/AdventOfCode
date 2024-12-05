use super::Solution;

pub fn pt1(data: &str) -> Solution {
    let Some((total_text, total_bytes)) = parse(data)
        .map(|s| (s.len(), count_evaluated_bytes(s)))
        .reduce(|(s1, s2), (a, b)| (s1 + a, s2 + b))
    else {
        panic!("Could not some the data (day_08)");
    };

    (total_text - total_bytes).into()
}

pub fn pt2(data: &str) -> Solution {
    let Some((total_text, total_reencoded)) = parse(data)
        .map(|s| (s.len(), count_reencoded_bytes(s)))
        .reduce(|(s1, s2), (a, b)| (s1 + a, s2 + b))
    else {
        panic!("Could not some the data (day_08)");
    };

    (total_reencoded - total_text).into()
}

fn parse(data: &str) -> impl Iterator<Item = &str> + '_ {
    data.lines().map(|line| line.trim_ascii())
    //.inspect(|line| eprintln!("{line}"))
}

fn count_reencoded_bytes(line: &str) -> usize {
    let line = line.as_bytes();
    let mut count = 6;
    let mut i = 1;
    while i < line.len() - 1 {
        if line[i] == b'\\' {
            i += 1;
            if matches!(line[i], b'\\' | b'"') {
                i += 1;
                count += 4;
            } else {
                i += 3;
                count += 5;
            }
        } else {
            count += 1;
            i += 1;
        }
    }

    count
}

fn count_evaluated_bytes(line: &str) -> usize {
    let line = line.as_bytes();
    let mut count = 0;
    let mut i = 1;
    while i < line.len() - 1 {
        if line[i] == b'\\' {
            i += 1;
            if matches!(line[i], b'\\' | b'"') {
                i += 1;
                count += 1;
            } else {
                i += 3;
                count += 1;
            }
        } else {
            count += 1;
            i += 1;
        }
    }

    count
}

#[cfg(test)]
mod test {
    use super::*;
    #[test]
    fn unit_test_pt1() {
        let data = r#"""
                            "abc"
                            "aaa\"aaa"
                            "\x27""#;
        let (code, bytes) = parse(data)
            .map(|s| (s.len(), count_evaluated_bytes(s)))
            .reduce(|(s1, s2), (a, b)| (s1 + a, s2 + b))
            .unwrap();

        assert_eq!(code, 23);
        assert_eq!(bytes, 11);
    }

    #[test]
    fn unit_test_pt2() {
        let data = r#"""
                            "abc"
                            "aaa\"aaa"
                            "\x27""#;
        let (code, reencoded) = parse(data)
            .map(|s| (s.len(), count_reencoded_bytes(s)))
            .reduce(|(s1, s2), (a, b)| (s1 + a, s2 + b))
            .unwrap();

        assert_eq!(code, 23);
        assert_eq!(reencoded, 42);
    }
}
