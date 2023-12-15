import gleam/int
import gleam/iterator.{Next}
import gleam/list.{Continue, Stop}
import gleam/option.{Some}
import gleam/pair
import gleam/result
import gleam/set
import gleam/string
import utils.{type ProblemPart, PartOne, PartTwo, list_index}

pub type Direction {
  North
  South
  East
  West
}

pub type Map =
  List(List(String))

pub type Coordinate =
  #(Int, Int)

pub type Move {
  Move(bearing: Direction, coord: Coordinate)
}

pub fn find_start(map: Map) -> Coordinate {
  let assert Some(y) = list_index(map, fn(l) { list.contains(l, "S") })
  let assert Ok(row) = list.at(map, y)
  let assert Some(x) = list_index(row, fn(c) { c == "S" })
  #(x, y)
}

pub fn pipe_at(map: Map, coord: Coordinate) -> Result(String, Nil) {
  let #(x, y) = coord

  map
  |> list.at(y)
  |> result.map(fn(r) { list.at(r, x) })
  |> result.flatten
}

pub fn was_valid(map: Map, move: Move) -> Bool {
  let pipe = pipe_at(map, move.coord)

  case move.bearing, pipe {
    North, Ok("|") -> True
    North, Ok("F") -> True
    North, Ok("7") -> True
    South, Ok("|") -> True
    South, Ok("L") -> True
    South, Ok("J") -> True
    East, Ok("-") -> True
    East, Ok("J") -> True
    East, Ok("7") -> True
    West, Ok("-") -> True
    West, Ok("L") -> True
    West, Ok("F") -> True
    _, _ -> False
  }
}

pub fn follow(map: Map, move: Move) -> Move {
  let pipe = pipe_at(map, move.coord)
  let #(x, y) = move.coord

  case move.bearing, pipe {
    North, Ok("|") -> Move(North, #(x, y - 1))
    North, Ok("F") -> Move(East, #(x + 1, y))
    North, Ok("7") -> Move(West, #(x - 1, y))
    South, Ok("|") -> Move(South, #(x, y + 1))
    South, Ok("L") -> Move(East, #(x + 1, y))
    South, Ok("J") -> Move(West, #(x - 1, y))
    East, Ok("-") -> Move(East, #(x + 1, y))
    East, Ok("J") -> Move(North, #(x, y - 1))
    East, Ok("7") -> Move(South, #(x, y + 1))
    West, Ok("-") -> Move(West, #(x - 1, y))
    West, Ok("L") -> Move(North, #(x, y - 1))
    West, Ok("F") -> Move(South, #(x, y + 1))
  }
}

pub fn find_starting_moves(map: Map) -> List(Move) {
  map
  |> find_start
  |> fn(position) {
    let #(x, y) = position
    [
      Move(North, #(x, y - 1)),
      Move(South, #(x, y + 1)),
      Move(East, #(x + 1, y)),
      Move(West, #(x - 1, y)),
    ]
  }
  |> list.filter(was_valid(map, _))
}

pub fn follow_loop(map: Map, starting_moves: List(Move)) {
  iterator.unfold(
    starting_moves,
    fn(moves) {
      let positions = list.map(moves, fn(m) { m.coord })
      let next = list.map(moves, follow(map, _))
      Next(positions, next)
    },
  )
}

pub fn replace_start(map: Map) -> Map {
  let #(x, y) = find_start(map)

  let north = pipe_at(map, #(x, y - 1))
  let south = pipe_at(map, #(x, y + 1))
  let east = pipe_at(map, #(x + 1, y))
  let west = pipe_at(map, #(x - 1, y))

  let replacement = case north, south, east, west {
    Ok("|"), Ok("|"), _, _ -> "|"
    Ok("|"), Ok("J"), _, _ -> "|"
    Ok("|"), Ok("L"), _, _ -> "|"
    Ok("F"), Ok("|"), _, _ -> "|"
    Ok("F"), Ok("J"), _, _ -> "|"
    Ok("F"), Ok("L"), _, _ -> "|"
    Ok("7"), Ok("|"), _, _ -> "|"
    Ok("7"), Ok("J"), _, _ -> "|"
    Ok("7"), Ok("L"), _, _ -> "|"

    _, Ok("|"), Ok("-"), _ -> "F"
    _, Ok("|"), Ok("7"), _ -> "F"
    _, Ok("|"), Ok("J"), _ -> "F"
    _, Ok("J"), Ok("-"), _ -> "F"
    _, Ok("J"), Ok("7"), _ -> "F"
    _, Ok("J"), Ok("J"), _ -> "F"
    _, Ok("L"), Ok("-"), _ -> "F"
    _, Ok("L"), Ok("7"), _ -> "F"
    _, Ok("L"), Ok("J"), _ -> "F"

    _, Ok("|"), _, Ok("-") -> "7"
    _, Ok("|"), _, Ok("L") -> "7"
    _, Ok("|"), _, Ok("F") -> "7"
    _, Ok("J"), _, Ok("-") -> "7"
    _, Ok("J"), _, Ok("L") -> "7"
    _, Ok("J"), _, Ok("F") -> "7"
    _, Ok("L"), _, Ok("-") -> "7"
    _, Ok("L"), _, Ok("L") -> "7"
    _, Ok("L"), _, Ok("F") -> "7"

    Ok("|"), _, _, Ok("-") -> "J"
    Ok("|"), _, _, Ok("F") -> "J"
    Ok("|"), _, _, Ok("L") -> "J"
    Ok("F"), _, _, Ok("-") -> "J"
    Ok("F"), _, _, Ok("F") -> "J"
    Ok("F"), _, _, Ok("L") -> "J"
    Ok("7"), _, _, Ok("-") -> "J"
    Ok("7"), _, _, Ok("F") -> "J"
    Ok("7"), _, _, Ok("L") -> "J"

    Ok("|"), _, Ok("-"), _ -> "L"
    Ok("|"), _, Ok("7"), _ -> "L"
    Ok("|"), _, Ok("J"), _ -> "L"
    Ok("F"), _, Ok("-"), _ -> "L"
    Ok("F"), _, Ok("7"), _ -> "L"
    Ok("F"), _, Ok("J"), _ -> "L"
    Ok("7"), _, Ok("-"), _ -> "L"
    Ok("7"), _, Ok("7"), _ -> "L"
    Ok("7"), _, Ok("J"), _ -> "L"

    _, _, Ok("-"), Ok("-") -> "-"
    _, _, Ok("J"), Ok("-") -> "-"
    _, _, Ok("7"), Ok("-") -> "-"
    _, _, Ok("-"), Ok("L") -> "-"
    _, _, Ok("J"), Ok("L") -> "-"
    _, _, Ok("7"), Ok("L") -> "-"
    _, _, Ok("-"), Ok("F") -> "-"
    _, _, Ok("J"), Ok("F") -> "-"
    _, _, Ok("7"), Ok("F") -> "-"
  }

  map
  |> list.map(fn(row) {
    row
    |> list.map(fn(c) {
      case c {
        "S" -> replacement
        _ -> c
      }
    })
  })
}

pub type MarkingState {
  Outside
  TopEdge(from: MarkingState)
  BottomEdge(from: MarkingState)
  Inside
}

pub fn mark_internal(map: Map) -> Map {
  map
  |> list.map(fn(row) {
    list.map_fold(
      row,
      Outside,
      fn(state, char) {
        case state, char {
          Outside, "F" -> #(TopEdge(Outside), "F")
          Outside, "L" -> #(BottomEdge(Outside), "L")
          Outside, "|" -> #(Inside, "|")
          Outside, c -> #(Outside, c)
          TopEdge(from), "-" -> #(TopEdge(from), "-")
          TopEdge(from), "7" -> #(from, "7")
          TopEdge(Outside), "J" -> #(Inside, "J")
          TopEdge(Inside), "J" -> #(Outside, "J")
          BottomEdge(from), "-" -> #(BottomEdge(from), "-")
          BottomEdge(from), "J" -> #(from, "J")
          BottomEdge(Outside), "7" -> #(Inside, "7")
          BottomEdge(Inside), "7" -> #(Outside, "7")
          Inside, "F" -> #(TopEdge(Inside), "F")
          Inside, "L" -> #(BottomEdge(Inside), "L")
          Inside, "|" -> #(Outside, "|")
          Inside, _ -> #(Inside, "#")
        }
      },
    )
    |> pair.second
  })
}

pub fn solve(input: String, part: ProblemPart) -> Result(Int, String) {
  let map =
    input
    |> string.trim
    |> string.split("\n")
    |> list.map(string.to_graphemes)

  let starting_moves = find_starting_moves(map)

  case part {
    PartOne -> {
      follow_loop(map, starting_moves)
      |> iterator.take_while(fn(moves) {
        let [a, b] = moves
        a != b
      })
      |> iterator.length
      |> int.add(1)
      |> Ok
    }
    PartTwo -> {
      let loop =
        follow_loop(map, starting_moves)
        |> iterator.fold_until(
          set.from_list([find_start(map)]),
          fn(loop, coords) {
            let in_loop =
              coords
              |> list.all(set.contains(loop, _))

            case in_loop {
              True -> Stop(loop)
              False ->
                Continue({
                  coords
                  |> list.fold(loop, fn(l, c) { set.insert(l, c) })
                })
            }
          },
        )

      map
      |> list.index_map(fn(y, row) {
        row
        |> list.index_map(fn(x, char) {
          case set.contains(loop, #(x, y)) {
            True -> char
            False -> "."
          }
        })
      })
      |> replace_start
      |> mark_internal
      |> list.flatten
      |> list.filter(fn(c) { c == "#" })
      |> list.length
      |> Ok
    }
  }
}
