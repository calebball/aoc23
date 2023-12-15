import gleam/io
import gleam/bool
import gleam/dict
import gleam/function
import gleam/int
import gleam/list
import gleam/order.{type Order, Eq, Gt, Lt}
import gleam/regex
import gleam/result
import gleam/string
import utils.{type ProblemPart, PartOne, PartTwo}

pub fn parse_card(card: String, part: ProblemPart) -> Int {
  case card {
    "A" -> 14
    "K" -> 13
    "Q" -> 12
    "J" ->
      case part {
        PartOne -> 11
        PartTwo -> 1
      }
    "T" -> 10
    "9" -> 9
    "8" -> 8
    "7" -> 7
    "6" -> 6
    "5" -> 5
    "4" -> 4
    "3" -> 3
    "2" -> 2
  }
}

pub type Hand {
  FiveOfAKind(cards: List(Int))
  FourOfAKind(cards: List(Int))
  FullHouse(cards: List(Int))
  ThreeOfAKind(cards: List(Int))
  TwoPair(cards: List(Int))
  OnePair(cards: List(Int))
  HighCard(cards: List(Int))
}

pub fn parse_hand(input: String, part: ProblemPart) -> Hand {
  let cards =
    input
    |> string.to_graphemes
    |> list.map(parse_card(_, part))

  let counts =
    cards
    |> list.group(function.identity)
    |> dict.map_values(fn(_, v) { list.length(v) })

  let num_jokers =
    dict.get(counts, 1)
    |> result.unwrap(0)

  case num_jokers {
    5 -> FiveOfAKind(cards)
    _ -> {
      let [highest_count, ..other_counts] =
        counts
        |> dict.delete(1)
        |> dict.values
        |> list.sort(int.compare)
        |> list.reverse

      let counts = [highest_count + num_jokers, ..other_counts]

      case counts {
        [5] -> FiveOfAKind(cards)
        [4, 1] -> FourOfAKind(cards)
        [3, 2] -> FullHouse(cards)
        [3, 1, 1] -> ThreeOfAKind(cards)
        [2, 2, 1] -> TwoPair(cards)
        [2, 1, 1, 1] -> OnePair(cards)
        [1, 1, 1, 1, 1] -> HighCard(cards)
      }
    }
  }
}

pub fn compare_cards(a: List(Int), b: List(Int)) -> Order {
  list.zip(a, b)
  |> list.fold_until(
    Eq,
    fn(_, cards) {
      let #(a, b) = cards
      case int.compare(a, b) {
        Eq -> list.Continue(Eq)
        Lt -> list.Stop(Lt)
        Gt -> list.Stop(Gt)
      }
    },
  )
}

pub fn compare_hands(a: Hand, b: Hand) -> Order {
  case a, b {
    FiveOfAKind(a), FiveOfAKind(b) -> compare_cards(a, b)
    FiveOfAKind(_), _ -> Gt
    _, FiveOfAKind(_) -> Lt

    FourOfAKind(a), FourOfAKind(b) -> compare_cards(a, b)
    FourOfAKind(_), _ -> Gt
    _, FourOfAKind(_) -> Lt

    FullHouse(a), FullHouse(b) -> compare_cards(a, b)
    FullHouse(_), _ -> Gt
    _, FullHouse(_) -> Lt

    ThreeOfAKind(a), ThreeOfAKind(b) -> compare_cards(a, b)
    ThreeOfAKind(_), _ -> Gt
    _, ThreeOfAKind(_) -> Lt

    TwoPair(a), TwoPair(b) -> compare_cards(a, b)
    TwoPair(_), _ -> Gt
    _, TwoPair(_) -> Lt

    OnePair(a), OnePair(b) -> compare_cards(a, b)
    OnePair(_), _ -> Gt
    _, OnePair(_) -> Lt

    HighCard(a), HighCard(b) -> compare_cards(a, b)
  }
}

pub type Bid {
  Bid(hand: Hand, amount: Int)
}

pub fn compare_bids(a: Bid, b: Bid) -> Order {
  compare_hands(a.hand, b.hand)
}

pub fn parse_bid(input: String, part: ProblemPart) -> Bid {
  let assert Ok(is_space) = regex.from_string("\\s+")
  let assert [hand, amount] = regex.split(is_space, input)
  let assert Ok(amount) = int.parse(amount)
  Bid(hand: parse_hand(hand, part), amount: amount)
}

pub fn solve(input: String, part: ProblemPart) -> Result(Int, String) {
  let bids =
    string.split(input, "\n")
    |> list.filter(fn(s) { bool.negate(string.is_empty(s)) })
    |> list.map(parse_bid(_, part))

  bids
  |> list.sort(compare_bids)
  |> list.index_map(fn(idx, bid) { bid.amount * { idx + 1 } })
  |> int.sum
  |> Ok
}
