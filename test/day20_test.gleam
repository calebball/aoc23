import gleeunit/should
import day20
import utils.{PartOne}

pub fn solve_part_1_test() {
  day20.solve(
    "broadcaster -> a, b, c
%a -> b
%b -> c
%c -> inv
&inv -> a",
    PartOne,
  )
  |> should.equal(Ok(32_000_000))

  day20.solve(
    "broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output",
    PartOne,
  )
  |> should.equal(Ok(11_687_500))
}
