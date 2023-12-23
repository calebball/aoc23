import gleeunit/should
import day22
import utils.{PartOne, PartTwo}

pub fn solve_part_1_test() {
  day22.solve(
    "1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9",
    PartOne,
  )
  |> should.equal(Ok(5))
}

pub fn solve_part_2_test() {
  day22.solve(
    "1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9",
    PartTwo,
  )
  |> should.equal(Ok(7))
}
