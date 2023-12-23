import gleam/bool
import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import utils.{type ProblemPart, PartOne, PartTwo}

type Direction {
  Up
  Down
  Left
  Right
}

type Position =
  #(Int, Int)

type Trail {
  Flat
  Slope(direction: Direction)
}

type Map =
  Dict(Position, Trail)

type IntersectionMap =
  Dict(Position, List(#(Position, Int)))

type Path {
  Path(walk: List(Position), distance: Int)
}

fn parse_dimensions(input: String) -> #(Int, Int) {
  let lines =
    input
    |> string.trim
    |> string.split("\n")

  let [row, ..] = lines

  #(string.length(row), list.length(lines))
}

fn parse_map(input: String) -> Map {
  let lines =
    input
    |> string.trim
    |> string.split("\n")

  use map, row, y <- list.index_fold(lines, dict.new())
  use map, char, x <- list.index_fold(string.to_graphemes(row), map)

  case char {
    "." -> dict.insert(map, #(x, y), Flat)
    ">" -> dict.insert(map, #(x, y), Slope(Right))
    "v" -> dict.insert(map, #(x, y), Slope(Down))
    "<" -> dict.insert(map, #(x, y), Slope(Left))
    "^" -> dict.insert(map, #(x, y), Slope(Up))
    _ -> map
  }
}

fn build_neighbour_fn(map: Map) -> fn(Path) -> List(Path) {
  fn(path: Path) {
    let [#(x, y), ..previous] = path.walk
    let assert Ok(trail) = dict.get(map, #(x, y))

    let next_positions = case trail {
      Slope(Up) -> [#(x, y - 1)]
      Slope(Right) -> [#(x + 1, y)]
      Slope(Down) -> [#(x, y + 1)]
      Slope(Left) -> [#(x - 1, y)]
      Flat -> [#(x + 1, y), #(x, y + 1), #(x - 1, y), #(x, y - 1)]
    }

    next_positions
    |> list.filter(fn(position) {
      list.contains(previous, position)
      |> bool.negate
      |> bool.and(dict.has_key(map, position))
    })
    |> list.map(fn(p) { Path([p, ..path.walk], path.distance + 1) })
  }
}

fn neighbours(map: Map, position: Position) -> List(Position) {
  let #(x, y) = position
  [#(x + 1, y), #(x, y + 1), #(x - 1, y), #(x, y - 1)]
  |> list.filter(dict.has_key(map, _))
}

fn is_intersection(map: Map, position: Position) -> Bool {
  neighbours(map, position)
  |> list.length
  |> fn(num_paths) { num_paths > 2 }
}

fn walk_to_intersection(map: Map, path: Path) -> Path {
  let [#(x, y), ..previous] = path.walk

  let next_positions =
    [#(x + 1, y), #(x, y + 1), #(x - 1, y), #(x, y - 1)]
    |> list.filter(fn(position) {
      list.contains(previous, position)
      |> bool.negate
      |> bool.and(dict.has_key(map, position))
    })

  use <- bool.guard(list.is_empty(next_positions), path)

  let [next_position] = next_positions

  case is_intersection(map, next_position) {
    True -> Path([next_position, ..path.walk], path.distance + 1)
    False ->
      walk_to_intersection(
        map,
        Path([next_position, ..path.walk], path.distance + 1),
      )
  }
}

fn find_intersections(
  map: Map,
  intersections: IntersectionMap,
  open_set: List(Position),
) -> IntersectionMap {
  use <- bool.guard(list.is_empty(open_set), intersections)

  let [intersection, ..open_set] = open_set

  let paths =
    neighbours(map, intersection)
    |> list.map(fn(first_step) {
      walk_to_intersection(map, Path([first_step, intersection], 1))
    })

  let open_set =
    paths
    |> list.filter_map(fn(path) {
      let [next_intersection, ..] = path.walk

      let in_queue = list.contains(open_set, next_intersection)
      let already_visited = dict.has_key(intersections, next_intersection)

      case in_queue || already_visited {
        True -> Error(Nil)
        False -> Ok(next_intersection)
      }
    })
    |> list.append(open_set)

  let intersections =
    dict.insert(
      intersections,
      intersection,
      paths
      |> list.map(fn(path) {
        let [next_intersection, ..] = path.walk
        #(next_intersection, path.distance)
      }),
    )

  find_intersections(map, intersections, open_set)
}

fn build_neighbour_fn2(map: Map) -> fn(Path) -> List(Path) {
  let intersection_map = find_intersections(map, dict.new(), [#(1, 0)])

  fn(path: Path) {
    let [position, ..previous] = path.walk

    let assert Ok(next_intersections) = dict.get(intersection_map, position)

    next_intersections
    |> list.filter(fn(next_intersection) {
      let #(intersection, _) = next_intersection
      list.contains(previous, intersection)
      |> bool.negate
      |> bool.and(dict.has_key(map, position))
    })
    |> list.map(fn(next_intersection) {
      let #(intersection, distance) = next_intersection
      Path([intersection, ..path.walk], path.distance + distance)
    })
  }
}

fn dijkstra(
  neighbour_fn: fn(Path) -> List(Path),
  open_paths: List(Path),
) -> Dict(Position, List(Path)) {
  use <- bool.guard(list.is_empty(open_paths), dict.new())

  let neighbours =
    open_paths
    |> list.flat_map(neighbour_fn)

  open_paths
  |> list.fold(
    dijkstra(neighbour_fn, neighbours),
    fn(distances, path) {
      let assert Ok(position) = list.first(path.walk)
      use known_distances <- dict.update(distances, position)

      [path, ..option.unwrap(known_distances, [])]
    },
  )
}

pub fn solve(input: String, part: ProblemPart) -> Result(Int, String) {
  let #(width, height) =
    input
    |> parse_dimensions

  let map =
    input
    |> parse_map

  case part {
    PartOne -> build_neighbour_fn(map)
    PartTwo -> build_neighbour_fn2(map)
  }
  |> dijkstra([Path([#(1, 0)], 0)])
  |> dict.get(#(width - 2, height - 1))
  |> result.map(fn(paths) {
    paths
    |> list.map(fn(path) { path.distance })
    |> list.reduce(int.max)
  })
  |> result.flatten
  |> result.map_error(function.constant("oh noes!"))
}
