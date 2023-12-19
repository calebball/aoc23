import gleeunit/should
import day17
import utils.{PartOne, PartTwo}

pub fn solve_part_1_test() {
  day17.solve(
    "2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533",
    PartOne,
  )
  |> should.equal(Ok(102))
}

pub fn solve_part_2_test() {
  day17.solve(
    "2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533",
    PartTwo,
  )
  |> should.equal(Ok(94))
}