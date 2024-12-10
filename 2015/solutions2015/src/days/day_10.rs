use super::Solution;

pub fn pt1(data: &str) -> Solution {
    let mut data = data.to_string();

    for _ in 0..40 {
        data = look_and_say(&data);
    }

    data.len().into()
}

pub fn pt2(data: &str) -> Solution {
    let mut data = data.to_string();

    (0..50).for_each(|_| data = look_and_say(&data));

    data.len().into()
}

fn look_and_say(data: &str) -> String {
    let mut s = String::new();
    let mut bytes = data.chars();
    let mut prev = bytes.next().expect("Data should not be empty (day 10)");
    let mut count = 1;

    for current in bytes {
        if current != prev {
            s.push_str(&format!("{count}{prev}"));
            prev = current;
            count = 1;
        } else {
            count += 1;
        }
    }
    s.push_str(&format!("{count}{prev}"));
    s
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn unit_test() {
        let input = "111221";
        let output = look_and_say(input);
        assert_eq!(&output, "312211")
    }
}
