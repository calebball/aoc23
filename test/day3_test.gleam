import gleam/list
import gleeunit/should
import day3.{Gear, PartNumber, Symbol}
import utils.{PartOne, PartTwo}

pub fn parse_line_test() {
  let inputs = [
    "467..114..", "...*......", "..35..633.", "617*......", ".....+.58.",
    "...$.*42..",
  ]
  let expected = [
    [PartNumber(114, 5, 7, 3), PartNumber(467, 0, 2, 3)],
    [Gear(3, 3)],
    [PartNumber(633, 6, 8, 3), PartNumber(35, 2, 3, 3)],
    [Gear(3, 3), PartNumber(617, 0, 2, 3)],
    [PartNumber(58, 7, 8, 3), Symbol(5, 3)],
    [PartNumber(42, 6, 7, 3), Gear(5, 3), Symbol(3, 3)],
  ]

  inputs
  |> list.map(day3.parse_line(3, _))
  |> should.equal(expected)
}

pub fn solve_part_1_test() {
  day3.solve(
    "467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
....$*....
.664.598..",
    PartOne,
  )
  |> should.equal(Ok(4361))
}

pub fn solve_part_2_test() {
  day3.solve(
    "467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..",
    PartTwo,
  )
  |> should.equal(Ok(467_835))
}
