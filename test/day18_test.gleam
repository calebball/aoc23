import gleeunit/should
import day18
import utils.{PartOne, PartTwo}

pub fn solve_part_1_test() {
  day18.solve(
    "R 6 (#70c710)
  D 5 (#0dc571)
  L 4 (#5713f0)
  U 3 (#a77fa3)
  L 2 (#015232)
  U 2 (#7a21e3)",
    PartOne,
  )
  |> should.equal(Ok(36))

  day18.solve(
    "R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)",
    PartOne,
  )
  |> should.equal(Ok(62))
}

pub fn solve_part_2_test() {
  day18.solve(
    "R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)",
    PartTwo,
  )
  |> should.equal(Ok(952_408_144_115))
}
