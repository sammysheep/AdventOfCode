use super::Solution;

pub fn pt1(data: &str) -> Solution {
    let mut sum = 0;
    for (l, w, h) in parse(data).flatten() {
        let (a, b, c) = (l * w, l * h, w * h);
        let min = a.min(b).min(c);
        sum += (a + b + c) * 2 + min;
    }
    sum.into()
}

pub fn pt2(data: &str) -> Solution {
    let mut sum = 0;
    for (l, w, h) in parse(data).flatten() {
        let perimeter = 2 * (l + w).min(l + h).min(w + h);
        let bow = l * w * h;
        sum += perimeter + bow;
    }
    sum.into()
}

fn parse(data: &str) -> impl Iterator<Item = Option<(usize, usize, usize)>> + '_ {
    data.lines().map(|line| {
        let mut split = line.split("x");
        Some((
            split.next()?.parse().ok()?,
            split.next()?.parse().ok()?,
            split.next()?.parse().ok()?,
        ))
    })
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn pt2_test() {
        let data = "2x3x4\n1x1x10".to_string();
        let total = pt2(&data);
        assert_eq!(total, 48_usize.into());
    }
}
