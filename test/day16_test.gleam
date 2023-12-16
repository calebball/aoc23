import gleeunit/should
import day16
import utils.{PartOne, PartTwo}

pub fn solve_part_1_test() {
  day16.solve(
    ".|...\\....
|.-.\\.....
.....|-...
........|.
..........
.........\\
..../.\\\\..
.-.-/..|..
.|....-|.\\
..//.|....",
    PartOne,
  )
  |> should.equal(Ok(46))
}

pub fn solve_part_2_test() {
  day16.solve(
    ".|...\\....
|.-.\\.....
.....|-...
........|.
..........
.........\\
..../.\\\\..
.-.-/..|..
.|....-|.\\
..//.|....",
    PartTwo,
  )
  |> should.equal(Ok(51))
}
