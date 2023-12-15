import gleam/bool
import gleam/int
import gleam/iterator
import gleam/list.{Continue, Stop}
import gleam/string
import utils.{type ProblemPart, PartOne, PartTwo}

type Pattern =
  List(String)

fn transpose_pattern(pattern: Pattern) -> Pattern {
  pattern
  |> list.map(string.to_graphemes)
  |> list.transpose
  |> list.map(string.concat)
}

fn distance(list_a: List(t), list_b: List(t)) -> Int {
  list.zip(list_a, list_b)
  |> list.map(fn(p) {
    let #(a, b) = p
    bool.to_int(a != b)
  })
  |> int.sum
}

fn find_reflection(pattern: Pattern, target_distance: Int) -> Int {
  let #(left, right) = list.split(pattern, 1)

  let #(left, _, success) =
    iterator.range(1, list.length(right))
    |> iterator.fold_until(
      #(left, right, False),
      fn(state, _) {
        let #(left, right, _) = state
        let size = int.min(list.length(left), list.length(right))
        let left_image = list.take(left, size)
        let right_image = list.take(right, size)
        let d =
          distance(
            string.to_graphemes(string.concat(left_image)),
            string.to_graphemes(string.concat(right_image)),
          )

        case d == target_distance {
          True -> Stop(#(left, right, True))
          False -> {
            let [to_swap, ..right] = right
            Continue(#([to_swap, ..left], right, False))
          }
        }
      },
    )

  case success {
    True -> list.length(left)
    False -> 0
  }
}

fn find_reflections(pattern: Pattern, target_distance: Int) -> Int {
  let horizontal =
    pattern
    |> find_reflection(target_distance)

  let vertical =
    pattern
    |> transpose_pattern
    |> find_reflection(target_distance)

  vertical + 100 * horizontal
}

pub fn solve(input: String, part: ProblemPart) -> Result(Int, String) {
  let patterns =
    input
    |> string.split("\n\n")
    |> list.map(string.trim)
    |> list.map(string.split(_, "\n"))

  let target_distance = case part {
    PartOne -> 0
    PartTwo -> 1
  }

  patterns
  |> list.map(find_reflections(_, target_distance))
  |> int.sum
  |> Ok
}
