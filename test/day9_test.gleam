import gleeunit/should
import day9
import utils.{PartOne, PartTwo}

pub fn diff_test() {
  day9.diff([11, 7, -1, -10, 4, 101, 392])
  |> should.equal([-4, -8, -9, 14, 97, 291])
}

pub fn all_derivatives_test() {
  day9.all_derivatives([11, 7, -1, -10, 4, 101, 392])
  |> should.equal([
    [11, 7, -1, -10, 4, 101, 392],
    [-4, -8, -9, 14, 97, 291],
    [-4, -1, 23, 83, 194],
    [3, 24, 60, 111],
    [21, 36, 51],
    [15, 15],
  ])
}

pub fn solve_part_1_test() {
  day9.solve(
    "0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45",
    PartOne,
  )
  |> should.equal(Ok(114))
}

pub fn solve_part_2_test() {
  day9.solve(
    "0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45",
    PartTwo,
  )
  |> should.equal(Ok(2))
}
