import gleam/list
import gleeunit/should
import day1
import utils.{PartOne, PartTwo}

pub fn find_number_part_1_test() {
  let inputs = ["1abc2", "pqr3stu8vwx", "a1b2c3d4e5f", "treb7uchet"]
  let expected = [Ok(12), Ok(38), Ok(15), Ok(77)]

  inputs
  |> list.map(day1.find_number_part_1)
  |> should.equal(expected)
}

pub fn solve_part_1_test() {
  day1.solve(
    "1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet",
    PartOne,
  )
  |> should.equal(Ok(142))
}

pub fn find_number_part_2_test() {
  let inputs = [
    "1abc2", "pqr3stu8vwx", "a1b2c3d4e5f", "treb7uchet", "two1nine",
    "eightwothree", "abcone2threexyz", "xtwone3four", "4nineeightseven2",
    "zoneight234", "7pqrstsixteen", "1twone",
  ]
  let expected = [
    Ok(12),
    Ok(38),
    Ok(15),
    Ok(77),
    Ok(29),
    Ok(83),
    Ok(13),
    Ok(24),
    Ok(42),
    Ok(14),
    Ok(76),
    Ok(11),
  ]

  inputs
  |> list.map(day1.find_number_part_2)
  |> should.equal(expected)
}

pub fn solve_part_2_test() {
  day1.solve(
    "two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen",
    PartTwo,
  )
  |> should.equal(Ok(281))
}
