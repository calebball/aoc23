import gleam/bool
import gleam/float
import gleam/function
import gleam/int
import gleam/list
import gleam/regex
import gleam/result
import gleam/string
import utils.{type ProblemPart, PartOne, PartTwo}

pub type Card {
  Card(id: Int, winning_numbers: List(Int), card_numbers: List(Int))
}

pub fn parse_card(input: String) {
  let assert Ok(is_int) = regex.from_string("\\d+")
  let assert ["Card " <> id_string, all_numbers] = string.split(input, ":")
  let assert [winning_numbers_string, card_numbers_string] =
    string.split(all_numbers, "|")

  let assert Ok(id) =
    id_string
    |> string.trim
    |> int.parse

  let assert Ok(winning_numbers) =
    regex.scan(is_int, winning_numbers_string)
    |> list.map(fn(match) { int.parse(match.content) })
    |> result.all

  let assert Ok(card_numbers) =
    regex.scan(is_int, card_numbers_string)
    |> list.map(fn(match) { int.parse(match.content) })
    |> result.all

  Card(id, winning_numbers, card_numbers)
}

pub fn matches(card: Card) {
  card.card_numbers
  |> list.filter(fn(n) { list.contains(card.winning_numbers, n) })
  |> list.length
}

pub fn score(card: Card) -> Int {
  case matches(card) {
    0 -> 0
    n -> {
      let assert Ok(result) =
        n - 1
        |> int.to_float
        |> int.power(2, _)
        |> result.map(float.truncate)

      result
    }
  }
}

type CollectionState {
  CollectionState(total: Int, next_counts: List(Int))
}

fn fold_next_card(state: CollectionState, card: Card) -> CollectionState {
  let [copies, ..next_counts] = state.next_counts

  let next_counts =
    list.index_map(
      next_counts,
      fn(idx, count) {
        case idx < matches(card) {
          True -> count + copies
          False -> count
        }
      },
    )

  CollectionState(state.total + copies, next_counts)
}

pub fn solve(input: String, part: ProblemPart) {
  case part {
    PartOne -> {
      input
      |> string.split("\n")
      |> list.filter(fn(s) { bool.negate(string.is_empty(s)) })
      |> list.map(function.compose(parse_card, score))
      |> int.sum
      |> Ok
    }

    PartTwo -> {
      let cards =
        input
        |> string.split("\n")
        |> list.filter(fn(s) { bool.negate(string.is_empty(s)) })
        |> list.map(parse_card)

      let initial_state = CollectionState(0, list.repeat(1, list.length(cards)))

      let final_state =
        cards
        |> list.fold(initial_state, fold_next_card)

      Ok(final_state.total)
    }
  }
}
