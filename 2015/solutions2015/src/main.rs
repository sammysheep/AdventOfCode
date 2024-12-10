use solutions2015::days::*;
use std::path::PathBuf;
use std::{env, fs};

// Thanks Claude!
macro_rules! dispatch_day {
    ($day:expr, $part:expr, $data:expr, $($day_str:literal),+) => {

        match $day {
            $(
                concat!("day_", $day_str) => {
                    if $part != "2" {
                        paste::paste! {
                            [<day_ $day_str>]::pt1($data)
                        }
                    } else {
                        paste::paste! {
                            [<day_ $day_str>]::pt2($data)
                        }
                    }
                }
            )+
            _ => panic!("No day given or day not supported!"),
        }
    };
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("cargo run -- <day_##> <1|2>");
        std::process::exit(0);
    }

    let mut filename = env::var("CARGO_MANIFEST_DIR")
        .map(PathBuf::from)
        .unwrap_or_else(|_| env::current_dir().expect("Cannot determine project directory"));
    filename.push("data");
    filename.push(&args[1]);
    filename.push("input.txt");

    let data = fs::read_to_string(&filename)
        .unwrap_or_else(|e| panic!("Err {e}: cannot read {f}", f = filename.display()));

    let (day, part) = (args[1].as_str(), args[2].as_str());

    let result =
        dispatch_day!(day, part, &data, "01", "02", "03", "04", "05", "06", "07", "08", "09");

    println!("Solution for {day}, part {part}: {result}");
}
