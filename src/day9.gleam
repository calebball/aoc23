import gleam/function
import gleam/int
import gleam/iterator.{Done, Next}
import gleam/list
import gleam/regex
import gleam/result
import gleam/string
import utils.{type ProblemPart, PartOne, PartTwo}

pub fn diff(numbers: List(Int)) -> List(Int) {
  list.window_by_2(numbers)
  |> list.map(fn(p) {
    let #(a, b) = p
    b - a
  })
}

pub fn all_derivatives(numbers: List(Int)) {
  iterator.unfold(
    numbers,
    fn(ns) {
      case list.all(ns, fn(n) { n == 0 }) {
        True -> Done
        False -> {
          let d = diff(ns)
          Next(ns, d)
        }
      }
    },
  )
  |> iterator.to_list
}

pub fn solve(input: String, part: ProblemPart) -> Result(Int, String) {
  let assert Ok(is_digit) = regex.from_string("(-?\\d+)")

  string.split(input, "\n")
  |> list.map(fn(l) {
    regex.scan(is_digit, l)
    |> list.map(fn(d) {
      let assert Ok(d) = int.parse(d.content)
      d
    })
    |> fn(l) {
      case part {
        PartOne -> l
        PartTwo -> list.reverse(l)
      }
    }
    |> all_derivatives
    |> list.map(list.last)
    |> result.all
  })
  |> result.all
  |> result.map(fn(l) { list.map(l, int.sum) })
  |> result.map(int.sum)
  |> result.map_error(function.constant("oh noes!"))
}
