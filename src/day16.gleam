import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string
import utils.{type ProblemPart, PartOne, PartTwo}

type Position =
  #(Int, Int)

type ContraptionPiece {
  SouthMirror
  NorthMirror
  VerticalSplitter
  HorizontalSplitter
}

type Bearing {
  North
  South
  East
  West
}

type Contraption {
  Contraption(height: Int, width: Int, pieces: Dict(Position, ContraptionPiece))
}

type Path =
  Dict(Position, Set(Bearing))

fn parse_contraption(input: String) -> Contraption {
  let lines =
    input
    |> string.trim
    |> string.split("\n")

  let height = list.length(lines)
  let assert Ok(width) =
    lines
    |> list.map(string.length)
    |> list.first

  let pieces =
    input
    |> string.trim
    |> string.to_graphemes
    |> list.fold(
      #(dict.new(), #(0, 0)),
      fn(state, char) {
        let #(pieces, #(x, y)) = state
        case char {
          "." -> #(pieces, #(x + 1, y))
          "\n" -> #(pieces, #(0, y + 1))
          "\\" -> #(dict.insert(pieces, #(x, y), SouthMirror), #(x + 1, y))
          "/" -> #(dict.insert(pieces, #(x, y), NorthMirror), #(x + 1, y))
          "|" -> #(dict.insert(pieces, #(x, y), VerticalSplitter), #(x + 1, y))
          "-" -> #(
            dict.insert(pieces, #(x, y), HorizontalSplitter),
            #(x + 1, y),
          )
        }
      },
    )
    |> pair.first

  Contraption(height, width, pieces)
}

fn off_board(contraption: Contraption, position: Position) -> Bool {
  let #(x, y) = position

  x < 0 || x >= contraption.width || y < 0 || y >= contraption.height
}

fn already_traced(path: Path, position: Position, bearing: Bearing) -> Bool {
  path
  |> dict.get(position)
  |> result.map(set.contains(_, bearing))
  |> result.unwrap(False)
}

fn add_to_path(path: Path, position: Position, bearing: Bearing) -> Path {
  dict.update(
    path,
    position,
    fn(s) {
      case s {
        None -> set.from_list([bearing])
        Some(others) -> set.insert(others, bearing)
      }
    },
  )
}

fn move(position: Position, bearing: Bearing) -> Position {
  let #(x, y) = position

  case bearing {
    North -> #(x, y - 1)
    South -> #(x, y + 1)
    East -> #(x + 1, y)
    West -> #(x - 1, y)
  }
}

fn trace_beam(
  contraption: Contraption,
  path: Path,
  position: Position,
  bearing: Bearing,
) -> Path {
  use <- bool.guard(off_board(contraption, position), path)
  use <- bool.guard(already_traced(path, position, bearing), path)

  let path = add_to_path(path, position, bearing)

  case dict.get(contraption.pieces, position) {
    Ok(SouthMirror) -> {
      let bearing = case bearing {
        North -> West
        South -> East
        East -> South
        West -> North
      }

      trace_beam(contraption, path, move(position, bearing), bearing)
    }
    Ok(NorthMirror) -> {
      let bearing = case bearing {
        North -> East
        South -> West
        East -> North
        West -> South
      }

      trace_beam(contraption, path, move(position, bearing), bearing)
    }
    Ok(VerticalSplitter) -> {
      case bearing {
        North -> trace_beam(contraption, path, move(position, bearing), bearing)
        South -> trace_beam(contraption, path, move(position, bearing), bearing)
        East -> {
          let path = trace_beam(contraption, path, move(position, North), North)
          trace_beam(contraption, path, move(position, South), South)
        }
        West -> {
          let path = trace_beam(contraption, path, move(position, North), North)
          trace_beam(contraption, path, move(position, South), South)
        }
      }
    }
    Ok(HorizontalSplitter) -> {
      case bearing {
        North -> {
          let path = trace_beam(contraption, path, move(position, East), East)
          trace_beam(contraption, path, move(position, West), West)
        }
        South -> {
          let path = trace_beam(contraption, path, move(position, East), East)
          trace_beam(contraption, path, move(position, West), West)
        }
        East -> trace_beam(contraption, path, move(position, bearing), bearing)
        West -> trace_beam(contraption, path, move(position, bearing), bearing)
      }
    }

    // There's an empty space here
    Error(_) -> trace_beam(contraption, path, move(position, bearing), bearing)
  }
}

pub fn solve(input: String, part: ProblemPart) -> Result(Int, String) {
  let contraption =
    input
    |> parse_contraption

  let initial_points = case part {
    PartOne -> [#(#(0, 0), East)]
    PartTwo -> {
      [
        list.map(
          list.range(0, contraption.width - 1),
          fn(x) { #(#(x, contraption.height - 1), North) },
        ),
        list.map(
          list.range(0, contraption.width - 1),
          fn(x) { #(#(x, 0), South) },
        ),
        list.map(
          list.range(0, contraption.height - 1),
          fn(y) { #(#(contraption.width - 1, y), West) },
        ),
        list.map(
          list.range(0, contraption.height - 1),
          fn(y) { #(#(0, y), East) },
        ),
      ]
      |> list.flatten
    }
  }

  initial_points
  |> list.fold(
    0,
    fn(best, p) {
      let #(position, bearing) = p

      trace_beam(contraption, dict.new(), position, bearing)
      |> dict.size
      |> int.max(best)
    },
  )
  |> Ok
}
