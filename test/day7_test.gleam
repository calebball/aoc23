import gleeunit/should
import day7
import utils.{PartOne, PartTwo}

pub fn solve_part_1_test() {
  day7.solve(
    "32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483",
    PartOne,
  )
  |> should.equal(Ok(6440))
}

pub fn solve_part_2_test() {
  day7.solve(
    "32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483",
    PartTwo,
  )
  |> should.equal(Ok(5905))
}
