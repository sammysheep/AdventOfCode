use std::collections::HashSet;

use super::Solution;

pub fn pt1(data: &str) -> Solution {
    let mut coords = HashSet::new();
    let (mut x, mut y) = (0, 0);
    coords.insert((x, y));
    for (dx, dy) in data.bytes().map(map_dir) {
        x += dx;
        y += dy;
        coords.insert((x, y));
    }

    coords.len().into()
}

pub fn pt2(data: &str) -> Solution {
    let (mut x1, mut y1) = (0, 0);
    let (mut x2, mut y2) = (0, 0);

    let mut coords = HashSet::new();
    coords.insert((x1, y1));
    coords.insert((x2, y2));

    for (i, (dx, dy)) in data.bytes().map(map_dir).enumerate() {
        if i % 2 == 0 {
            x1 += dx;
            y1 += dy;
            coords.insert((x1, y1));
        } else {
            x2 += dx;
            y2 += dy;
            coords.insert((x2, y2));
        }
    }

    coords.len().into()
}

fn map_dir(dir: u8) -> (isize, isize) {
    match dir {
        b'>' => (1, 0),
        b'<' => (-1, 0),
        b'^' => (0, 1),
        b'v' => (0, -1),
        _ => (0, 0),
    }
}
