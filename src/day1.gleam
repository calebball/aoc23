import gleam/bool
import gleam/int
import gleam/list
import gleam/option
import gleam/regex
import gleam/result
import gleam/string
import utils.{type ProblemPart, PartOne, PartTwo}

fn parse_digit(m: regex.Match) {
  let assert Ok(option.Some(s)) = list.first(m.submatches)
  case s {
    "one" -> Ok(1)
    "two" -> Ok(2)
    "three" -> Ok(3)
    "four" -> Ok(4)
    "five" -> Ok(5)
    "six" -> Ok(6)
    "seven" -> Ok(7)
    "eight" -> Ok(8)
    "nine" -> Ok(9)
    d -> int.parse(d)
  }
}

pub fn find_number_part_1(line: String) {
  let assert Ok(digit_pattern) = regex.from_string("(\\d)")

  let digits = regex.scan(with: digit_pattern, content: line)

  let tens =
    list.first(digits)
    |> result.try(parse_digit)

  let ones =
    list.last(digits)
    |> result.try(parse_digit)

  case tens, ones {
    Ok(a), Ok(b) -> Ok(10 * a + b)
    _, _ -> Error("No number found")
  }
}

pub fn find_number_part_2(line: String) {
  let assert Ok(digit_pattern) =
    regex.from_string("(?=(one|two|three|four|five|six|seven|eight|nine|\\d))")

  let digits = regex.scan(with: digit_pattern, content: line)

  let tens =
    list.first(digits)
    |> result.try(parse_digit)

  let ones =
    list.last(digits)
    |> result.try(parse_digit)

  case tens, ones {
    Ok(a), Ok(b) -> Ok(10 * a + b)
    _, _ -> Error("No number found")
  }
}

pub fn solve(input: String, part: ProblemPart) {
  let find_number = case part {
    PartOne -> find_number_part_1
    PartTwo -> find_number_part_2
  }

  string.split(input, "\n")
  |> list.filter(fn(s) { bool.negate(string.is_empty(s)) })
  |> list.map(find_number)
  |> result.all
  |> result.map(int.sum)
}
