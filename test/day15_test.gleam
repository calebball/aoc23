import gleeunit/should
import day15
import utils.{PartOne, PartTwo}

pub fn solve_part_1_test() {
  day15.solve("rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7", PartOne)
  |> should.equal(Ok(1320))
}

pub fn solve_part_2_test() {
  day15.solve("rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7", PartTwo)
  |> should.equal(Ok(145))
}
