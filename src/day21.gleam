import gleam/bool
import gleam/int
import gleam/iterator.{Next}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import utils.{type ProblemPart, PartOne, PartTwo}

type Position =
  #(Int, Int)

pub type Farm {
  Farm(stones: Set(Position), width: Int, height: Int)
}

fn insert_stone(farm: Farm, position: Position) -> Farm {
  let Farm(stones, width, height) = farm
  Farm(set.insert(stones, position), width, height)
}

pub fn parse_map(input: String) -> #(Option(Position), Farm) {
  let chars =
    input
    |> string.trim
    |> string.split("\n")
    |> list.map(string.to_graphemes)

  let height = list.length(chars)
  let assert Ok(width) =
    chars
    |> list.first
    |> result.map(list.length)

  use state, row, y <- list.index_fold(
    chars,
    #(None, Farm(set.new(), width, height)),
  )
  use #(start, farm), char, x <- list.index_fold(row, state)

  case char {
    "#" -> #(start, insert_stone(farm, #(x, y)))
    "S" -> #(Some(#(x, y)), farm)
    _ -> #(start, farm)
  }
}

fn adjacent_positions(position: Position) -> List(Position) {
  let #(x, y) = position

  [#(x + 1, y), #(x - 1, y), #(x, y + 1), #(x, y - 1)]
}

fn unobstructed(obstacles: Set(Position), position: Position) -> Bool {
  set.contains(obstacles, position)
  |> bool.negate
}

pub fn take_steps(farm: Farm, start: Position, steps: Int) -> Set(Position) {
  iterator.unfold(
    set.from_list([start]),
    fn(open_set) {
      let next_open_set =
        set.fold(
          open_set,
          set.new(),
          fn(next_open_set, current_position) {
            adjacent_positions(current_position)
            |> list.filter(unobstructed(farm.stones, _))
            |> list.filter(fn(p) {
              let #(x, y) = p

              x >= 0 && x < farm.width && y >= 0 && y < farm.height
            })
            |> list.fold(next_open_set, set.insert)
          },
        )

      Next(next_open_set, next_open_set)
    },
  )
  |> iterator.at(steps - 1)
  |> result.unwrap(set.new())
}

pub fn solve_part_2(farm: Farm, start: Position, steps: Int) -> Int {
  let plots = steps / farm.width

  let even_grid = take_steps(farm, start, 130)
  let even_diamond = take_steps(farm, start, 64)
  let even_corners =
    even_grid
    |> set.filter(fn(p) { bool.negate(set.contains(even_diamond, p)) })

  let odd_grid = take_steps(farm, start, 131)
  let odd_diamond = take_steps(farm, start, 65)
  let odd_corners =
    odd_grid
    |> set.filter(fn(p) { bool.negate(set.contains(odd_diamond, p)) })

  int.sum([
    int.product([plots + 1, plots + 1, set.size(odd_grid)]),
    int.product([plots, plots, set.size(even_grid)]),
    -int.product([plots + 1, set.size(odd_corners)]),
    int.product([plots, set.size(even_corners)]),
  ])
}

pub fn solve(input: String, part: ProblemPart) -> Result(Int, String) {
  let assert #(Some(start), farm) = parse_map(input)

  case part {
    PartOne ->
      take_steps(farm, start, 64)
      |> set.size
      |> Ok
    PartTwo -> {
      solve_part_2(farm, start, 26_501_365)
      |> Ok
    }
  }
}
