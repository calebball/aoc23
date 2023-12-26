import gleeunit/should
import day25
import utils.{PartOne}

pub fn solve_part_1_test() {
  day25.solve(
    "jqt: rhn xhk nvd
rsh: frs pzl lsr
xhk: hfx
cmg: qnr nvd lhk bvb
rhn: xhk bvb hfx
bvb: xhk hfx
pzl: lsr hfx nvd
qnr: nvd
ntq: jqt hfx bvb xhk
nvd: lhk
lsr: lhk
rzs: qnr cmg lsr rsh
frs: qnr lhk lsr",
    PartOne,
  )
  |> should.equal(Ok(54))
}
