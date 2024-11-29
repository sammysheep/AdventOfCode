use super::*;

pub fn pt1(data: &str) -> Solution {
    let data = data.as_bytes();
    data.iter()
        .map(|b| match b {
            b'(' => 1,
            b')' => -1,
            _ => 0,
        })
        .sum::<isize>()
        .into()
}

pub fn pt2(data: &str) -> Solution {
    let data = data.as_bytes();
    let mut sum = 0;
    let mut result = None;
    for (i, n) in data
        .iter()
        .map(|b| match b {
            b'(' => 1,
            b')' => -1,
            _ => 0,
        })
        .enumerate()
    {
        sum += n;
        if sum < 0 {
            result = Some(i + 1);
            break;
        }
    }

    result.into()
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn pt2_test() {
        let data = "()())".to_string();
        let result = pt2(&data);
        assert_eq!(result, 5usize.into());

        let data = ")".to_string();
        let result = pt2(&data);
        assert_eq!(result, 1usize.into());
    }
}
