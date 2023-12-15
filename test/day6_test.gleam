import gleeunit/should
import day6
import utils.{PartOne, PartTwo}

pub fn solve_part_1_test() {
  day6.solve(
    "Time:      7  15   30
Distance:  9  40  200",
    PartOne,
  )
  |> should.equal(Ok(288))
}

pub fn solve_part_2_test() {
  day6.solve(
    "Time:      7  15   30
Distance:  9  40  200",
    PartTwo,
  )
  |> should.equal(Ok(71_503))
}
