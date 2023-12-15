import gleam/int
import gleam/list
import gleam/result
import gleam/string
import utils.{type ProblemPart, PartOne, PartTwo}

pub type Token {
  PartNumber(value: Int, x1: Int, x2: Int, y: Int)
  Gear(x: Int, y: Int)
  Symbol(x: Int, y: Int)
}

type ParseState {
  Idle(tokens: List(Token))
  ReadingNumber(tokens: List(Token), digits: List(Int), start: Int)
}

pub fn parse_line(y: Int, line: String) {
  let chars = string.to_graphemes(line)
  let parse_state =
    list.index_fold(
      over: chars,
      from: Idle([]),
      with: fn(state, char, x) {
        case state, char {
          Idle(tokens), "." -> Idle(tokens)
          Idle(tokens), "0"
          | Idle(tokens), "1"
          | Idle(tokens), "2"
          | Idle(tokens), "3"
          | Idle(tokens), "4"
          | Idle(tokens), "5"
          | Idle(tokens), "6"
          | Idle(tokens), "7"
          | Idle(tokens), "8"
          | Idle(tokens), "9" -> {
            let assert Ok(digit) = int.parse(char)
            ReadingNumber(tokens, [digit], x)
          }
          Idle(tokens), "*" -> Idle([Gear(x, y), ..tokens])
          Idle(tokens), _ -> Idle([Symbol(x, y), ..tokens])
          ReadingNumber(tokens, digits, start), "." -> {
            let assert Ok(value) = int.undigits(digits, 10)
            Idle([PartNumber(value, start, x - 1, y), ..tokens])
          }
          ReadingNumber(tokens, digits, start), "0"
          | ReadingNumber(tokens, digits, start), "1"
          | ReadingNumber(tokens, digits, start), "2"
          | ReadingNumber(tokens, digits, start), "3"
          | ReadingNumber(tokens, digits, start), "4"
          | ReadingNumber(tokens, digits, start), "5"
          | ReadingNumber(tokens, digits, start), "6"
          | ReadingNumber(tokens, digits, start), "7"
          | ReadingNumber(tokens, digits, start), "8"
          | ReadingNumber(tokens, digits, start), "9" -> {
            let assert Ok(digit) = int.parse(char)
            ReadingNumber(tokens, list.append(digits, [digit]), start)
          }
          ReadingNumber(tokens, digits, start), "*" -> {
            let assert Ok(value) = int.undigits(digits, 10)
            Idle([Gear(x, y), PartNumber(value, start, x - 1, y), ..tokens])
          }
          ReadingNumber(tokens, digits, start), _ -> {
            let assert Ok(value) = int.undigits(digits, 10)
            Idle([Symbol(x, y), PartNumber(value, start, x - 1, y), ..tokens])
          }
        }
      },
    )

  case parse_state {
    Idle(tokens) -> tokens
    ReadingNumber(tokens, digits, start) -> {
      let assert Ok(value) = int.undigits(digits, 10)
      [PartNumber(value, start, list.length(chars) - 1, y), ..tokens]
    }
  }
}

pub fn parse_schematic(input: String) {
  input
  |> string.split("\n")
  |> list.index_map(parse_line)
  |> list.concat
}

pub fn adjacent_parts(symbol: Token, part_numbers: List(Token)) {
  part_numbers
  |> list.filter(fn(p) {
    let assert PartNumber(_, x1, x2, y) = p
    case symbol {
      Symbol(xp, yp) ->
        int.absolute_value(y - yp) <= 1 && x1 - 1 <= xp && x2 + 1 >= xp
      Gear(xp, yp) ->
        int.absolute_value(y - yp) <= 1 && x1 - 1 <= xp && x2 + 1 >= xp
      _ -> False
    }
  })
  |> list.map(fn(p) {
    let assert PartNumber(value, _, _, _) = p
    value
  })
}

pub fn gear_ratio(part_numbers: List(Int)) {
  case part_numbers {
    [a, b] -> Ok(a * b)
    _ -> Error("did not receive two part numbers")
  }
}

pub fn solve(input: String, part: ProblemPart) {
  let #(part_numbers, symbols) =
    parse_schematic(input)
    |> list.partition(fn(t) {
      case t {
        PartNumber(_, _, _, _) -> True
        Symbol(_, _) -> False
        Gear(_, _) -> False
      }
    })

  case part {
    PartOne ->
      symbols
      |> list.flat_map(adjacent_parts(_, part_numbers))
      |> list.unique
    PartTwo ->
      symbols
      |> list.map(adjacent_parts(_, part_numbers))
      |> list.map(gear_ratio)
      |> result.values
  }
  |> int.sum
  |> Ok
}
