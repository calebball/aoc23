import gleam/list
import gleam/string
import gleeunit/should
import day14
import utils.{PartOne, PartTwo}

pub fn spin_cycle_test() {
  let input =
    "O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#...."
    |> string.trim
    |> string.split("\n")
    |> list.map(string.to_graphemes)

  let output =
    ".....#....
....#...O#
...OO##...
.OO#......
.....OOO#.
.O#...O#.#
....O#....
......OOOO
#...O###..
#..OO#...."
    |> string.trim
    |> string.split("\n")
    |> list.map(string.to_graphemes)

  day14.spin_cycle(input)
  |> should.equal(output)
}

pub fn solve_part_1_test() {
  day14.solve(
    "O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....",
    PartOne,
  )
  |> should.equal(Ok(136))
}

pub fn solve_part_2_test() {
  day14.solve(
    "O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....",
    PartTwo,
  )
  |> should.equal(Ok(64))
}
