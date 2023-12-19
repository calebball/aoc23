import gleam/float
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regex
import gleam/result
import utils.{type ProblemPart, PartOne, PartTwo}

type Position(number) =
  #(number, number)

type Direction {
  Up
  Down
  Left
  Right
}

type Move {
  Move(direction: Direction, distance: Int)
}

fn parse_direction(input: String) -> Direction {
  case input {
    "U" -> Up
    "D" -> Down
    "L" -> Left
    "R" -> Right

    "0" -> Right
    "1" -> Down
    "2" -> Left
    "3" -> Up
  }
}

fn parse_part1_moves(input: String) -> List(Move) {
  let assert Ok(pattern) =
    regex.from_string("([UDLR]) (\\d+) \\(#[a-f0-9]{6}\\)")

  regex.scan(pattern, input)
  |> list.map(fn(match) {
    let assert [Some(direction), Some(distance)] = match.submatches

    let direction = parse_direction(direction)
    let assert Ok(distance) = int.parse(distance)

    Move(direction, distance)
  })
}

fn parse_part2_moves(input: String) -> List(Move) {
  let assert Ok(pattern) =
    regex.from_string("[UDLR] \\d+ \\(#([a-f0-9]{5})([a-f0-9])\\)")

  regex.scan(pattern, input)
  |> list.map(fn(match) {
    let assert [Some(distance), Some(direction)] = match.submatches

    let direction = parse_direction(direction)
    let assert Ok(distance) = int.base_parse(distance, 16)

    Move(direction, distance)
  })
}

fn find_positions(moves: List(Move)) -> List(Position(Int)) {
  list.scan(
    moves,
    #(0, 0),
    fn(last, move) {
      let #(x, y) = last
      case move.direction {
        Up -> #(x, y + move.distance)
        Down -> #(x, y - move.distance)
        Left -> #(x - move.distance, y)
        Right -> #(x + move.distance, y)
      }
    },
  )
}

fn int_trapezoid_formula(vertices: List(Position(Int))) -> Int {
  let [first, ..] = vertices

  list.append(vertices, [first])
  |> list.window_by_2
  |> list.fold(
    0,
    fn(total, points) {
      let #(#(x1, y1), #(x2, y2)) = points
      total + { y1 + y2 } * { x1 - x2 }
    },
  )
  |> int.divide(2)
  |> result.unwrap(0)
}

fn float_trapezoid_formula(vertices: List(Position(Float))) -> Float {
  let [first, ..] = vertices

  list.append(vertices, [first])
  |> list.window_by_2
  |> list.fold(
    0.0,
    fn(total, points) {
      let #(#(x1, y1), #(x2, y2)) = points
      total +. { y1 +. y2 } *. { x1 -. x2 }
    },
  )
  |> float.divide(2.0)
  |> result.unwrap(0.0)
  |> float.absolute_value
}

fn expand_polygon(moves: List(Move)) -> List(Position(Float)) {
  let positions = find_positions(moves)

  let moving_clockwise =
    positions
    |> int_trapezoid_formula
    |> fn(a) { a < 0 }

  moves
  |> list.map(fn(m) { m.direction })
  |> fn(l) {
    let [first, ..] = l
    list.append(l, [first])
  }
  |> list.window_by_2
  |> list.zip(positions)
  |> list.map(fn(inputs) {
    let #(#(first_direction, second_direction), #(x, y)) = inputs

    let x = int.to_float(x)
    let y = int.to_float(y)

    case moving_clockwise, first_direction, second_direction {
      True, Up, Left -> #(x -. 0.5, y -. 0.5)
      True, Up, Right -> #(x -. 0.5, y +. 0.5)
      True, Down, Left -> #(x +. 0.5, y -. 0.5)
      True, Down, Right -> #(x +. 0.5, y +. 0.5)
      True, Left, Up -> #(x -. 0.5, y -. 0.5)
      True, Left, Down -> #(x +. 0.5, y -. 0.5)
      True, Right, Up -> #(x -. 0.5, y +. 0.5)
      True, Right, Down -> #(x +. 0.5, y +. 0.5)

      False, Up, Left -> #(x +. 0.5, y +. 0.5)
      False, Up, Right -> #(x +. 0.5, y -. 0.5)
      False, Down, Left -> #(x -. 0.5, y +. 0.5)
      False, Down, Right -> #(x -. 0.5, y -. 0.5)
      False, Left, Up -> #(x +. 0.5, y +. 0.5)
      False, Left, Down -> #(x -. 0.5, y +. 0.5)
      False, Right, Up -> #(x +. 0.5, y -. 0.5)
      False, Right, Down -> #(x -. 0.5, y -. 0.5)
    }
  })
}

pub fn solve(input: String, part: ProblemPart) -> Result(Int, String) {
  let moves = case part {
    PartOne -> parse_part1_moves(input)
    PartTwo -> parse_part2_moves(input)
  }

  moves
  |> expand_polygon
  |> float_trapezoid_formula
  |> float.truncate
  |> Ok
}
