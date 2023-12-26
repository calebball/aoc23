import gleeunit/should
import day24
import utils.{PartTwo}

pub fn solve_part_1_test() {
  let input =
    "19, 13, 30 @ -2,  1, -2
18, 19, 22 @ -1, -1, -2
20, 25, 34 @ -2, -2, -4
12, 31, 28 @ -1, -2, -1
20, 19, 15 @  1, -5, -3"

  day24.solve_part_1(day24.parse_hailstones(input), 7, 27)
  |> should.equal(2)
}

pub fn solve_part_2_test() {
  day24.solve(
    "19, 13, 30 @ -2,  1, -2
18, 19, 22 @ -1, -1, -2
20, 25, 34 @ -2, -2, -4
12, 31, 28 @ -1, -2, -1
20, 19, 15 @  1, -5, -3",
    PartTwo,
  )
  |> should.equal(Ok(47))
}
