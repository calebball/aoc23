import gleam/option.{Some}
import gleeunit/should
import day5
import interval.{Closed}
import utils.{PartOne, PartTwo}

pub fn intersect_test() {
  interval.intersect(Closed(3, 6), Closed(1, 8))
  |> should.equal(#(Some(Closed(3, 6)), []))

  interval.intersect(Closed(1, 8), Closed(3, 6))
  |> should.equal(#(Some(Closed(3, 6)), [Closed(1, 2), Closed(7, 8)]))

  interval.intersect(Closed(1, 6), Closed(3, 8))
  |> should.equal(#(Some(Closed(3, 6)), [Closed(1, 2)]))

  interval.intersect(Closed(3, 8), Closed(1, 6))
  |> should.equal(#(Some(Closed(3, 6)), [Closed(7, 8)]))

  interval.intersect(Closed(57, 69), Closed(53, 60))
  |> should.equal(#(Some(Closed(57, 60)), [Closed(61, 69)]))
}

const example = "seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4"

pub fn solve_part_1_test() {
  day5.solve(example, PartOne)
  |> should.equal(Ok(35))
}

pub fn solve_part_2_test() {
  day5.solve(example, PartTwo)
  |> should.equal(Ok(46))
}
