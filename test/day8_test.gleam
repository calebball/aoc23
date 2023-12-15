import gleeunit/should
import day8
import utils.{PartOne, PartTwo}

pub fn solve_part_1_test() {
  day8.solve(
    "RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)",
    PartOne,
  )
  |> should.equal(Ok(2))

  day8.solve(
    "LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)",
    PartOne,
  )
  |> should.equal(Ok(6))
}

pub fn solve_part_2_test() {
  day8.solve(
    "LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)",
    PartTwo,
  )
  |> should.equal(Ok(6))
}
