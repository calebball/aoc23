import gleam/bool
import gleam/function
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/regex
import gleam/result
import gleam/string
import utils.{type ProblemPart, PartOne, PartTwo}
import interval.{type Interval, Closed, intersect, shift}

type Mapping {
  Mapping(interval: Interval, offset: Int)
}

fn parse_seeds_part_1(input: String) -> List(Interval) {
  let assert Ok(is_digit) = regex.from_string("(\\d+)")

  regex.scan(is_digit, input)
  |> list.map(fn(m) {
    let assert Ok(seed) = int.parse(m.content)
    Closed(seed, seed)
  })
}

fn parse_seeds_part_2(input: String) -> List(Interval) {
  let assert Ok(range_pattern) = regex.from_string("(\\d+)\\s+(\\d+)")

  regex.scan(range_pattern, input)
  |> list.map(fn(m) {
    let assert [Ok(start), Ok(length)] =
      m.submatches
      |> list.map(option.map(_, int.parse))
      |> list.map(option.to_result(_, Nil))
      |> list.map(result.flatten)

    Closed(start, start + length - 1)
  })
}

type MappingState {
  MappingState(unmapped: List(Interval), mapped: List(Interval))
}

fn parse_section(input: String) {
  let [_, ..numbers] = string.split(input, "\n")

  let mappings =
    numbers
    |> list.filter(fn(s) { bool.negate(string.is_empty(s)) })
    |> list.map(fn(ns) {
      let [Ok(to), Ok(from), Ok(count)] =
        string.split(ns, " ")
        |> list.map(int.parse)

      Mapping(interval: Closed(from, from + count - 1), offset: to - from)
    })

  fn(intervals) {
    list.fold(
      mappings,
      MappingState(intervals, []),
      fn(state, mapping) {
        list.fold(
          state.unmapped,
          MappingState([], state.mapped),
          fn(last_state, interval) {
            let #(intersection, exclusion) =
              intersect(interval, mapping.interval)

            let intersection =
              option.map(intersection, shift(_, mapping.offset))

            MappingState(
              list.append(last_state.unmapped, exclusion),
              case intersection {
                Some(i) -> [i, ..last_state.mapped]
                None -> last_state.mapped
              },
            )
          },
        )
      },
    )
    |> fn(state: MappingState) { list.append(state.unmapped, state.mapped) }
  }
}

pub fn solve(input: String, part: ProblemPart) -> Result(Int, String) {
  let assert [seeds, ..sections] = string.split(input, "\n\n")

  let seeds = case part {
    PartOne -> parse_seeds_part_1(seeds)
    PartTwo -> parse_seeds_part_2(seeds)
  }

  let assert seed_location =
    sections
    |> list.map(parse_section)
    |> list.fold(function.identity, fn(a, b) { function.compose(a, b) })

  seeds
  |> seed_location
  |> list.map(fn(interval) { interval.min })
  |> list.reduce(int.min)
  |> result.replace_error("oh noes!")
}
