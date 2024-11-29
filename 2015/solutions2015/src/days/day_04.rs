use super::Solution;

pub fn pt1(data: &str) -> Solution {
    let mut result = None;
    let prefix = data.trim().to_owned();
    for i in 0..usize::MAX {
        // This is wasteful but it's fine!
        let message = format!("{prefix}{i}");
        let digest = md5::compute(&message);
        if digest_passes_5(digest) {
            result = Some(i);
            println!("{:x} for {message}", digest);
            break;
        }
    }
    result.into()
}

pub fn pt2(data: &str) -> Solution {
    let mut result = None;
    let prefix = data.trim().to_owned();
    for i in 0..usize::MAX {
        let message = format!("{prefix}{i}");
        let digest = md5::compute(&message);
        if digest_passes_6(digest) {
            result = Some(i);
            println!("{:x} for {message}", digest);
            break;
        }
    }
    result.into()
}

fn digest_passes_5(d: md5::Digest) -> bool {
    (d[2] & 0xF0) == 0 && d[1] == 0 && d[0] == 0
}

fn digest_passes_6(d: md5::Digest) -> bool {
    d[2] == 0 && d[1] == 0 && d[0] == 0
}

#[cfg(test)]
mod test {
    use crate::days::day_04::digest_passes_5;

    #[test]
    fn sanity_checks() {
        let digest = md5::compute(b"abcdef609043");
        assert!(digest_passes_5(digest));
        assert_eq!(format!("{:x}", digest), "000001dbbfa3a5c83a2d506429c7b00e");

        let digest = md5::compute(b"pqrstuv1048970");
        assert!(digest_passes_5(digest));
        assert_eq!(format!("{:x}", digest), "000006136ef2ff3b291c85725f17325c");
    }
}

#[cfg(test)]
mod bench {
    extern crate test;
    use test::Bencher;

    use super::*;

    #[bench]
    fn array_pass5(b: &mut Bencher) {
        let digest1 = md5::compute(b"pqrstuv1048970");
        let digest2 = md5::compute(b"pqrstuv10489701");

        b.iter(|| {
            let a = digest_passes_5(digest1);
            let b = digest_passes_5(digest2);
            a && b
        });
    }

    #[bench]
    fn array_pass6(b: &mut Bencher) {
        let digest1 = md5::compute(b"pqrstuv1048970");
        let digest2 = md5::compute(b"pqrstuv10489701");

        b.iter(|| {
            let a = digest_passes_6(digest1);
            let b = digest_passes_6(digest2);
            a && b
        });
    }
}
