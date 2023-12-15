import gleeunit/should
import day13
import utils.{PartOne, PartTwo}

pub fn solve_part_1_test() {
  day13.solve(
    "#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#",
    PartOne,
  )
  |> should.equal(Ok(405))
}

pub fn solve_part_2_test() {
  day13.solve(
    "#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#",
    PartTwo,
  )
  |> should.equal(Ok(400))
}
