import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/iterator.{Done, Next}
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
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

/// Represents a move across the cost map
type Move {
  Move(new_position: Position, direction: Direction, cost: Int)
}

/// Parses the map of movement costs.
///
/// Also returns a width and height of the map, because it requires a bit
/// more computation to determine that from the hashmap representation that
/// is returned.
fn parse_graph(input: String) -> #(Int, Int, Dict(Position, Int)) {
  let costs =
    input
    |> string.trim
    |> string.split("\n")

  let height = list.length(costs)
  let assert Ok(width) =
    costs
    |> list.first
    |> result.map(string.length)

  let costs =
    costs
    |> list.map(fn(s) {
      let assert Ok(row) =
        s
        |> string.to_graphemes
        |> list.map(int.parse)
        |> result.all
      row
    })
    |> list.index_fold(
      dict.new(),
      fn(costs, row, y) {
        list.index_fold(
          row,
          costs,
          fn(costs, cost, x) { dict.insert(costs, #(x, y), cost) },
        )
      },
    )

  #(width, height, costs)
}

/// Scans a list of positions being moved to over a cost map
fn scan_moves(
  new_positions: List(Position),
  costs: Dict(Position, Int),
  direction: Direction,
) -> List(Move) {
  new_positions
  |> list.fold(
    #([], 0),
    fn(state, new_position) {
      let #(moves, total_cost) = state
      let assert Ok(cost) = dict.get(costs, new_position)
      #(
        [Move(new_position, direction, total_cost + cost), ..moves],
        total_cost + cost,
      )
    },
  )
  |> pair.first
  |> list.reverse
}

/// Generate a function that will find neighbours to a given position in the
/// map.
///
/// Neighbours are all the positions that can be moved to, which includes moves
/// of multiple steps in one direction. So it refers to the graph of moves
/// rather than the map itself.
fn create_neighbour_fn(
  costs: Dict(Position, Int),
  width: Int,
  height: Int,
  min_distance: Int,
  max_distance: Int,
) -> fn(Position, Direction) -> List(Move) {
  fn(position, last_direction) {
    let #(x, y) = position

    case last_direction {
      Up | Down -> {
        let left_moves =
          list.range(x - 1, x - max_distance)
          |> list.filter(fn(new_x) { new_x >= 0 })
          |> list.map(fn(new_x) { #(new_x, y) })
          |> scan_moves(costs, Left)
          |> list.drop(min_distance - 1)

        let right_moves =
          list.range(x + 1, x + max_distance)
          |> list.filter(fn(new_x) { new_x < width })
          |> list.map(fn(new_x) { #(new_x, y) })
          |> scan_moves(costs, Right)
          |> list.drop(min_distance - 1)

        list.append(left_moves, right_moves)
      }
      Left | Right -> {
        let up_moves =
          list.range(y - 1, y - max_distance)
          |> list.filter(fn(new_y) { new_y >= 0 })
          |> list.map(fn(new_y) { #(x, new_y) })
          |> scan_moves(costs, Up)
          |> list.drop(min_distance - 1)

        let down_moves =
          list.range(y + 1, y + max_distance)
          |> list.filter(fn(new_y) { new_y < height })
          |> list.map(fn(new_y) { #(x, new_y) })
          |> scan_moves(costs, Down)
          |> list.drop(min_distance - 1)

        list.append(up_moves, down_moves)
      }
    }
  }
}

/// The head of a search path
type Search {
  Search(
    total_cost: Int,
    estimated_cost: Int,
    last_direction: Direction,
    position: Position,
    previous_steps: List(Position),
  )
}

type SearchState {
  SearchState(scores: Dict(#(Position, Direction), Int), open_set: List(Search))
}

fn manhattan_distance(a: Position, b: Position) -> Int {
  let #(ax, ay) = a
  let #(bx, by) = b
  int.absolute_value(ax - bx) + int.absolute_value(ay - by)
}

/// Applies a move to a search head, moving the head to the new position and
/// updating the rest of the search state.
fn apply_move(move: Move, search: Search, goal: Position) -> Search {
  let total_cost = search.total_cost + move.cost

  Search(
    total_cost,
    total_cost + manhattan_distance(move.new_position, goal),
    move.direction,
    move.new_position,
    [move.new_position, ..search.previous_steps],
  )
}

/// Evaluates a search head in the context of a given search state, returning
/// an updated state that includes the new search head if it is a beneficial
/// move.
fn evaluate_search(state: SearchState, search: Search) -> SearchState {
  let best_score =
    dict.get(state.scores, #(search.position, search.last_direction))
  let improved =
    best_score
    |> result.map(fn(s) { search.total_cost < s })
    |> result.unwrap(True)

  use <- bool.guard(bool.negate(improved), state)

  let #(better, worse) =
    state.open_set
    |> list.split_while(fn(open_search) {
      open_search.estimated_cost < search.estimated_cost
    })

  SearchState(
    dict.insert(
      state.scores,
      #(search.position, search.last_direction),
      search.total_cost,
    ),
    list.append(better, [search, ..worse]),
  )
}

/// Finds the shortest path between two points given a function that generates
/// valid moves from a given node.
/// Uses an A* algorithm to do the search.
fn find_path(
  neighbour_fn: fn(Position, Direction) -> List(Move),
  start: Position,
  goal: Position,
) {
  let #(gx, gy) = goal

  iterator.unfold(
    SearchState(
      dict.from_list([#(#(start, Right), 0)]),
      // To keep the typing simple we need to provide an initial direction that
      // we've reached the start node from. But the neighbour function will
      // turn us 90 degrees from the direction, so to go both right and down
      // we'll give it two starting directions.
      [
        Search(0, gx + gy, Left, start, [start]),
        Search(0, gx + gy, Down, start, [start]),
      ],
    ),
    fn(state) {
      use <- bool.guard(list.is_empty(state.open_set), Done)

      let [current, ..open_set] = state.open_set

      use <- bool.guard(
        current.position == goal,
        Next(Some(current.estimated_cost), SearchState(state.scores, open_set)),
      )

      let state =
        neighbour_fn(current.position, current.last_direction)
        |> list.map(apply_move(_, current, goal))
        |> list.fold(
          // We need to remove the search head that we're currently looking at
          // from the open set stored in the state
          SearchState(state.scores, open_set),
          evaluate_search,
        )

      Next(None, state)
    },
  )
}

pub fn solve(input: String, part: ProblemPart) -> Result(Int, String) {
  let #(width, height, costs) =
    input
    |> parse_graph

  case part {
    PartOne -> create_neighbour_fn(costs, width, height, 1, 3)
    PartTwo -> create_neighbour_fn(costs, width, height, 4, 10)
  }
  |> find_path(#(0, 0), #(width - 1, height - 1))
  |> iterator.drop_while(option.is_none)
  |> iterator.first
  |> result.map(option.to_result(_, Nil))
  |> result.flatten
  |> result.map_error(fn(_) { "oh noes!" })
}
