import gleam/io
import gleam/float
import gleam/list
import gleam/int
import gleam/regex
import gleam/result
import gleam/string
import utils.{type ProblemPart, PartOne, PartTwo}

pub fn solve(input: String, part: ProblemPart) -> Result(Int, String) {
  let assert [times, distances, ..] = string.split(input, "\n")
  let assert [_, times] = string.split(times, ":")
  let assert [_, distances] = string.split(distances, ":")

  let assert Ok(is_digit) = regex.from_string("\\d+")

  let assert Ok(times) =
    regex.scan(is_digit, times)
    |> list.map(fn(match) { match.content })
    |> case part {
      PartOne -> fn(t) {
        list.map(t, int.parse)
        |> result.all
      }
      PartTwo -> fn(t) {
        string.concat(t)
        |> int.parse
        |> result.map(fn(n) { [n] })
      }
    }

  let assert Ok(distances) =
    regex.scan(is_digit, distances)
    |> list.map(fn(match) { match.content })
    |> case part {
      PartOne -> fn(t) {
        list.map(t, int.parse)
        |> result.all
      }
      PartTwo -> fn(t) {
        string.concat(t)
        |> int.parse
        |> result.map(fn(n) { [n] })
      }
    }

  list.zip(times, distances)
  |> list.map(fn(race) {
    let #(time, distance) = race

    let discriminant = time * time - 4 * distance
    let assert Ok(root) = int.square_root(discriminant)

    let first = { int.to_float(time) -. root } /. 2.0
    let second = { int.to_float(time) +. root } /. 2.0

    let left = float.min(first, second)
    let right = float.max(first, second)

    float.truncate(float.ceiling(right) -. float.floor(left) -. 1.0)
  })
  |> int.product
  |> Ok
}
