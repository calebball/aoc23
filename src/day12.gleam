import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import utils.{type ProblemPart, PartOne, PartTwo}

type ArrangingState {
  Outside
  Inside
  Closing
}

type ArrangingContext {
  ArrangingContext(
    seen: List(String),
    unseen: List(String),
    groups: List(Int),
    state: ArrangingState,
  )
}

fn memoise_count_arrangements(
  context: ArrangingContext,
  cache: Dict(#(List(String), List(Int), ArrangingState), Int),
) {
  let ArrangingContext(seen, unseen, groups, state) = context

  case dict.get(cache, #(unseen, groups, state)) {
    Ok(n) -> #(n, cache)
    Error(_) -> {
      let [head, ..tail] = unseen

      let #(result, cache) = case state, head, tail, groups {
        _, ".", [], [] -> #(1, cache)
        Outside, "#", [], [1] -> #(1, cache)
        Inside, "#", [], [1] -> #(1, cache)
        Outside, "?", [], [1] -> #(1, cache)
        Inside, "?", [], [1] -> #(1, cache)
        _, "?", [], [] -> #(1, cache)
        _, _, [], _ -> #(0, cache)

        Outside, ".", _, _ ->
          memoise_count_arrangements(
            ArrangingContext([".", ..seen], tail, groups, Outside),
            cache,
          )
        Outside, "#", _, [1, ..remaining] ->
          memoise_count_arrangements(
            ArrangingContext(["#", ..seen], tail, remaining, Closing),
            cache,
          )
        Outside, "#", _, [n, ..remaining] ->
          memoise_count_arrangements(
            ArrangingContext(["#", ..seen], tail, [n - 1, ..remaining], Inside),
            cache,
          )
        Outside, "?", _, [1, ..remaining] -> {
          let #(damaged, cache) =
            memoise_count_arrangements(
              ArrangingContext(["#", ..seen], tail, remaining, Closing),
              cache,
            )
          let #(operational, cache) =
            memoise_count_arrangements(
              ArrangingContext([".", ..seen], tail, groups, Outside),
              cache,
            )
          #(damaged + operational, cache)
        }
        Outside, "?", _, [n, ..remaining] -> {
          let #(damaged, cache) =
            memoise_count_arrangements(
              ArrangingContext(
                ["#", ..seen],
                tail,
                [n - 1, ..remaining],
                Inside,
              ),
              cache,
            )
          let #(operational, cache) =
            memoise_count_arrangements(
              ArrangingContext([".", ..seen], tail, groups, Outside),
              cache,
            )
          #(damaged + operational, cache)
        }
        Outside, "?", _, [] -> {
          memoise_count_arrangements(
            ArrangingContext([".", ..seen], tail, groups, Outside),
            cache,
          )
        }

        Inside, "#", _, [1, ..remaining] ->
          memoise_count_arrangements(
            ArrangingContext(["#", ..seen], tail, remaining, Closing),
            cache,
          )
        Inside, "#", _, [n, ..remaining] ->
          memoise_count_arrangements(
            ArrangingContext(["#", ..seen], tail, [n - 1, ..remaining], Inside),
            cache,
          )
        Inside, "?", _, [1, ..remaining] ->
          memoise_count_arrangements(
            ArrangingContext(["#", ..seen], tail, remaining, Closing),
            cache,
          )
        Inside, "?", _, [n, ..remaining] ->
          memoise_count_arrangements(
            ArrangingContext(["#", ..seen], tail, [n - 1, ..remaining], Inside),
            cache,
          )

        Closing, ".", _, _ ->
          memoise_count_arrangements(
            ArrangingContext([".", ..seen], tail, groups, Outside),
            cache,
          )
        Closing, "?", _, _ ->
          memoise_count_arrangements(
            ArrangingContext([".", ..seen], tail, groups, Outside),
            cache,
          )

        _, _, _, _ -> #(0, cache)
      }

      #(result, dict.insert(cache, #(unseen, groups, state), result))
    }
  }
}

pub fn count_row_arrangements(row: String, groups: List(Int)) -> Int {
  let #(result, _) =
    memoise_count_arrangements(
      ArrangingContext([], string.to_graphemes(row), groups, Outside),
      dict.new(),
    )
  result
}

pub fn solve(input: String, part: ProblemPart) -> Result(Int, String) {
  let records =
    input
    |> string.trim
    |> string.split("\n")
    |> list.map(fn(s) {
      let assert [row, groups] = string.split(s, " ")

      let assert Ok(groups) =
        groups
        |> string.split(",")
        |> list.map(int.parse)
        |> result.all

      case part {
        PartOne -> #(row, groups)
        PartTwo -> {
          let row =
            row
            |> list.repeat(5)
            |> list.intersperse("?")
            |> string.concat

          let groups =
            groups
            |> list.repeat(5)
            |> list.flatten

          #(row, groups)
        }
      }
    })

  let counts =
    records
    |> list.map(fn(r) {
      let #(row, groups) = r

      count_row_arrangements(row, groups)
    })

  counts
  |> int.sum
  |> Ok
}
