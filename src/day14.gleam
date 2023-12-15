import gleam/iterator
import gleam/list.{Continue, Stop}
import gleam/string
import utils.{type ProblemPart, PartOne, PartTwo}

type Platform =
  List(List(String))

fn roll_row(row: List(String)) -> List(String) {
  row
  |> list.fold(
    #([], 0, 0),
    fn(state, char) {
      let #(current, rocks, spaces) = state

      case char {
        "O" -> #(current, rocks + 1, spaces)
        "." -> #(current, rocks, spaces + 1)
        "#" -> #(
          list.flatten([
            current,
            list.repeat("O", rocks),
            list.repeat(".", spaces),
            ["#"],
          ]),
          0,
          0,
        )
      }
    },
  )
  |> fn(state) {
    let #(current, rocks, spaces) = state
    list.flatten([current, list.repeat("O", rocks), list.repeat(".", spaces)])
  }
}

fn roll(platform: Platform) -> Platform {
  platform
  |> list.map(roll_row)
}

fn tilt_north(platform: Platform) -> Platform {
  platform
  |> list.transpose
  |> roll
  |> list.transpose
}

fn tilt_west(platform: Platform) -> Platform {
  platform
  |> roll
}

fn tilt_south(platform: Platform) -> Platform {
  platform
  |> list.transpose
  |> list.map(list.reverse)
  |> roll
  |> list.map(list.reverse)
  |> list.transpose
}

fn tilt_east(platform: Platform) -> Platform {
  platform
  |> list.map(list.reverse)
  |> roll
  |> list.map(list.reverse)
}

pub fn spin_cycle(platform: Platform) -> Platform {
  platform
  |> tilt_north
  |> tilt_west
  |> tilt_south
  |> tilt_east
}

fn total_load(platform: Platform) -> Int {
  let size = list.length(platform)

  platform
  |> list.map(fn(row) {
    row
    |> list.filter(fn(char) { char == "O" })
    |> list.length
  })
  |> list.index_fold(
    0,
    fn(total, count, idx) { total + count * { size - idx } },
  )
}

pub fn solve(input: String, part: ProblemPart) -> Result(Int, String) {
  let platform =
    input
    |> string.trim
    |> string.split("\n")
    |> list.map(string.to_graphemes)

  case part {
    PartOne -> tilt_north(platform)
    PartTwo -> {
      let #(_, loop, start) =
        iterator.range(1, 1_000_000_000)
        |> iterator.fold_until(
          #(platform, [], []),
          fn(state, _) {
            let #(platform, loop, _) = state
            let platform = spin_cycle(platform)
            let #(loop, start) =
              loop
              |> list.split_while(fn(p) { p != platform })

            let next_state = #(platform, [platform, ..loop], start)

            case start {
              [] -> Continue(next_state)
              _ -> Stop(next_state)
            }
          },
        )

      let idx = { 1_000_000_000 - list.length(start) } % list.length(loop)
      let assert Ok(platform) = list.at(loop, list.length(loop) - idx)

      platform
    }
  }
  |> total_load
  |> Ok
}
