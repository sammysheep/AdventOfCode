use super::Solution;
use regex::Regex;
use std::sync::LazyLock;

pub fn pt1(data: &str) -> Solution {
    let mut mb = Motherboard::new();
    for d in parse(data) {
        let (wire, id) = d.unwrap();
        mb.set_wire(id, wire);
    }

    mb.read_wire("a").into()
}

pub fn pt2(data: &str) -> Solution {
    let mut mb1 = Motherboard::new();
    for d in parse(data) {
        let (wire, id) = d.unwrap();
        mb1.set_wire(id, wire);
    }
    let mut mb2 = mb1.clone();
    mb2.override_wire("b", mb1.read_wire("a"));
    mb2.read_wire("a").into()
}

static PARSE: LazyLock<Regex> = LazyLock::new(|| {
    Regex::new(r"(\d+|[a-z]+)?\s*((RSHIFT|LSHIFT|AND|NOT|OR)\s+(\d+|[a-z]+))?\s+->\s+(\S+)")
        .expect("Malformed regex for day 7.")
});

fn parse(data: &str) -> impl Iterator<Item = Option<(WireInputs, ID)>> + '_ {
    data.lines().map(|line| {
        if let Some(caps) = PARSE.captures(line) {
            let id: ID = caps.get(5)?.as_str().into();
            let wire = match (
                caps.get(1).map(|m| m.as_str()),
                caps.get(3).map(|m| m.as_str()),
                caps.get(4).map(|m| m.as_str()),
            ) {
                (None, Some("NOT"), Some(o1)) => WireInputs::Not(o1.into()),
                (Some(o1), Some("AND"), Some(o2)) => WireInputs::And(o1.into(), o2.into()),
                (Some(o1), Some("OR"), Some(o2)) => WireInputs::Or(o1.into(), o2.into()),
                (Some(o1), Some("LSHIFT"), Some(o2)) => WireInputs::Lshift(o1.into(), o2.into()),
                (Some(o1), Some("RSHIFT"), Some(o2)) => WireInputs::Rshift(o1.into(), o2.into()),
                (Some(val), None, None) => WireInputs::Noop(val.into()),
                _ => panic!("Invalid pattern: {caps:?}\n\t{line}"),
            };

            let reformat = format!("{wire} -> {id}");
            assert_eq!(line, reformat);

            Some((wire, id))
        } else {
            eprintln!("Did not parse: {line}");
            None
        }
    })
}

#[derive(Debug, Copy, Clone)]
enum WireInputs {
    Not(Operand),
    And(Operand, Operand),
    Or(Operand, Operand),
    Lshift(Operand, Operand),
    Rshift(Operand, Operand),
    Noop(Operand),
}

impl std::fmt::Display for WireInputs {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            WireInputs::And(a, b) => write!(f, "{a} AND {b}"),
            WireInputs::Or(a, b) => write!(f, "{a} OR {b}"),
            WireInputs::Not(a) => write!(f, "NOT {a}"),
            WireInputs::Noop(a) => write!(f, "{a}"),
            WireInputs::Lshift(a, b) => write!(f, "{a} LSHIFT {b}"),
            WireInputs::Rshift(a, b) => write!(f, "{a} RSHIFT {b}"),
        }
    }
}

#[derive(Debug, Copy, Clone)]
enum Operand {
    Wire(ID),
    Literal(u16),
}

impl std::fmt::Display for Operand {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Operand::Literal(n) => write!(f, "{n}"),
            Operand::Wire(id) => write!(f, "{id}"),
        }
    }
}

impl From<&str> for Operand {
    fn from(s: &str) -> Self {
        if let Ok(d) = s.parse::<u16>() {
            Operand::Literal(d)
        } else {
            Operand::Wire(s.into())
        }
    }
}

#[derive(Clone, Copy)]
struct ID(u16);

impl std::fmt::Debug for ID {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let s = String::from(*self);
        write!(f, "{n}:{s}", n = self.0)
    }
}

impl std::fmt::Display for ID {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let s = String::from(*self);
        f.write_str(&s)
    }
}

impl ID {
    fn max_capacity() -> usize {
        Self::from("zz").0 as usize + 1
    }

    fn as_index(&self) -> usize {
        self.0 as usize
    }
}

impl From<&str> for ID {
    fn from(value: &str) -> Self {
        value.as_bytes().into()
    }
}

impl From<&[u8]> for ID {
    fn from(value: &[u8]) -> Self {
        let mut num = 0;
        for b in value.iter() {
            num *= 26 + 1;
            num += (b - b'a') as u16 + 1;
        }
        ID(num)
    }
}

impl From<ID> for String {
    fn from(id: ID) -> Self {
        let mut v = Vec::new();
        let mut num = id.0;
        while num != 0 {
            let digit = (num % 27) as u8 + b'a' - 1;
            v.push(digit);
            num /= 27;
        }
        v.reverse();
        String::from_utf8_lossy(&v).to_string()
    }
}

#[derive(Clone)]
struct Motherboard {
    wires: Vec<Option<WireInputs>>,
}

impl Motherboard {
    fn new() -> Self {
        Motherboard {
            wires: vec![None; ID::max_capacity()],
        }
    }

    fn set_literal(&mut self, id: ID, num: u16) {
        self.wires[id.as_index()].replace(WireInputs::Noop(Operand::Literal(num)));
    }

    fn set_wire(&mut self, id: ID, wire: WireInputs) {
        self.wires[id.as_index()] = Some(wire);
    }

    fn get_wire(&self, id: ID) -> WireInputs {
        self.wires[id.as_index()]
            .unwrap_or_else(|| panic!("Cannot find {id:?} in motherbaord (day 07)."))
    }

    fn read_wire(&mut self, s: &str) -> u16 {
        let id: ID = s.into();
        self.evaluate(id)
    }

    fn override_wire(&mut self, s: &str, num: u16) {
        let id: ID = s.into();
        self.set_literal(id, num);
    }

    fn fetch(&mut self, operand: Operand) -> u16 {
        match operand {
            Operand::Literal(num) => num,
            Operand::Wire(id) => self.evaluate(id),
        }
    }

    fn evaluate(&mut self, id: ID) -> u16 {
        let val = match self.get_wire(id) {
            WireInputs::Noop(op) => self.fetch(op),
            WireInputs::Not(op) => !self.fetch(op),
            WireInputs::And(op, op2) => self.fetch(op) & self.fetch(op2),
            WireInputs::Or(op, op2) => self.fetch(op) | self.fetch(op2),
            WireInputs::Lshift(op, op2) => self.fetch(op) << self.fetch(op2),
            WireInputs::Rshift(op, op2) => self.fetch(op) >> self.fetch(op2),
        };

        self.set_literal(id, val);

        val
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn id_regression_test() {
        let s1 = "im".to_string();
        let id: ID = s1.as_str().into();
        println!("{id:?}");
        let s2: String = id.into();
        assert_eq!(s1, s2);
    }

    #[test]
    fn id_self_test() {
        for a in 'a'..='z' {
            let s1 = a.to_string();
            let id: ID = s1.as_str().into();
            let s2: String = id.into();
            assert_eq!(s1, s2);
        }
    }

    #[test]
    fn double_self_test() {
        for a in 'a'..='z' {
            for b in 'a'..='z' {
                let mut s1 = a.to_string();
                s1.push(b);
                let id: ID = s1.as_str().into();
                let s2: String = id.into();
                assert_eq!(s1, s2);
            }
        }
    }
}
