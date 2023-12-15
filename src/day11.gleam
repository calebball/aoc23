import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/pair
import gleam/string
import utils.{type ProblemPart, PartOne, PartTwo}

pub type Map =
  List(List(String))

pub type Position =
  #(Int, Int)

pub fn expand_rows(map: Map, by: Int) -> Map {
  map
  |> list.fold(
    [],
    fn(new_map, row) {
      case list.all(row, fn(c) { c == "." }) {
        True -> list.append(new_map, list.repeat(row, by))
        False -> list.append(new_map, [row])
      }
    },
  )
}

pub fn expand(map: Map, by: Int) -> Map {
  map
  |> expand_rows(by)
  |> list.transpose
  |> expand_rows(by)
  |> list.transpose
}

pub fn find_galaxies(map: Map) -> List(Position) {
  map
  |> list.index_fold(
    [],
    fn(positions, row, y) {
      list.index_fold(
        row,
        positions,
        fn(positions, c, x) {
          case c {
            "#" -> [#(x, y), ..positions]
            _ -> positions
          }
        },
      )
    },
  )
}

pub fn make_row_expander(map: Map, expansion: Int) -> Dict(Int, Int) {
  list.index_fold(
    map,
    #(dict.new(), 0),
    fn(state, row, idx) {
      let #(expander, current) = state

      case list.all(row, fn(c) { c == "." }) {
        True -> #(dict.insert(expander, idx, current), current + expansion)
        False -> #(dict.insert(expander, idx, current), current + 1)
      }
    },
  )
  |> pair.first
}

pub fn solve(input: String, part: ProblemPart) -> Result(Int, String) {
  let map =
    input
    |> string.trim
    |> string.split("\n")
    |> list.map(string.to_graphemes)

  let expand_by = case part {
    PartOne -> 2
    PartTwo -> 1_000_000
  }

  let x_expander =
    map
    |> list.transpose
    |> make_row_expander(expand_by)

  let y_expander =
    map
    |> make_row_expander(expand_by)

  map
  |> find_galaxies
  |> list.map(fn(p) {
    let #(x, y) = p

    let assert Ok(x) = dict.get(x_expander, x)
    let assert Ok(y) = dict.get(y_expander, y)

    #(x, y)
  })
  |> list.combination_pairs
  |> list.map(fn(p) {
    let #(#(x1, y1), #(x2, y2)) = p
    int.absolute_value(x1 - x2) + int.absolute_value(y1 - y2)
  })
  |> int.sum
  |> Ok
}
