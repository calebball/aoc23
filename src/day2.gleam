import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regex
import gleam/result
import gleam/string
import utils.{type ProblemPart, PartOne, PartTwo}

pub type Bag {
  Bag(red: Int, green: Int, blue: Int)
}

pub type BallSet {
  BallSet(red: Int, green: Int, blue: Int)
}

pub type Game {
  Game(id: Int, sets: List(BallSet))
}

pub fn parse_int_from_match(m: regex.Match) -> Result(Int, _) {
  let assert [Some(submatch)] = m.submatches
  int.parse(submatch)
}

pub fn parse_game_id(s: String) -> Int {
  let assert Ok(id_pattern) = regex.from_string("Game (\\d+)")

  let assert Ok(output) =
    regex.scan(id_pattern, s)
    |> list.first
    |> result.map(parse_int_from_match)
    |> result.flatten

  output
}

pub fn parse_colour(input: String, colour_name: String) -> Int {
  let assert Ok(pattern) = regex.from_string("(\\d+) " <> colour_name)

  regex.scan(pattern, input)
  |> list.first
  |> result.map(parse_int_from_match)
  |> result.flatten
  |> result.unwrap(0)
}

pub fn parse_set(s: String) -> BallSet {
  BallSet(
    red: parse_colour(s, "red"),
    green: parse_colour(s, "green"),
    blue: parse_colour(s, "blue"),
  )
}

pub fn parse_game(line: String) {
  case string.split(line, ":") {
    [game_string, sets_string] -> {
      Game(
        id: parse_game_id(game_string),
        sets: string.split(sets_string, ";")
        |> list.map(parse_set),
      )
    }
  }
}

pub fn is_possible(game: Game) {
  list.all(game.sets, fn(s) { s.red <= 12 && s.green <= 13 && s.blue <= 14 })
}

pub fn smallest_bag(game: Game) {
  let assert Ok(red) =
    game.sets
    |> list.map(fn(s) { s.red })
    |> list.reduce(int.max)

  let assert Ok(green) =
    game.sets
    |> list.map(fn(s) { s.green })
    |> list.reduce(int.max)

  let assert Ok(blue) =
    game.sets
    |> list.map(fn(s) { s.blue })
    |> list.reduce(int.max)

  Bag(red, green, blue)
}

pub fn power(bag: Bag) -> Int {
  let red = int.max(1, bag.red)
  let green = int.max(1, bag.green)
  let blue = int.max(1, bag.blue)
  red * green * blue
}

pub fn solve(input: String, part: ProblemPart) {
  let games =
    string.split(input, "\n")
    |> list.filter(fn(s) { bool.negate(string.is_empty(s)) })
    |> list.map(parse_game)

  let result = case part {
    PartOne ->
      games
      |> list.filter(is_possible)
      |> list.map(fn(g) { g.id })
      |> int.sum
    PartTwo -> {
      games
      |> list.map(smallest_bag)
      |> list.map(power)
      |> int.sum
    }
  }

  Ok(result)
}
