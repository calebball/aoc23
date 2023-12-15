import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option
import gleam/pair
import gleam/result
import gleam/string
import utils.{type ProblemPart, PartOne, PartTwo}

type Step {
  Insert(label: String, length: Int)
  Remove(label: String)
}

type Lens =
  #(String, Int)

type Box =
  List(Lens)

type Boxes =
  Dict(Int, Box)

fn do_step(boxes: Boxes, step: Step) -> Boxes {
  dict.update(
    boxes,
    hash(step.label),
    fn(lenses) {
      let lenses = option.unwrap(lenses, [])

      case step {
        Insert(label, length) ->
          lenses
          |> list.key_set(label, length)
        Remove(label) ->
          lenses
          |> list.key_pop(label)
          |> result.map(pair.second)
          |> result.unwrap(lenses)
      }
    },
  )
}

fn focusing_power(box: Box) -> Int {
  box
  |> list.index_map(fn(idx, lens) {
    let #(_, length) = lens
    length * { idx + 1 }
  })
  |> int.sum
}

fn hash(s: String) -> Int {
  list.fold(
    string.to_utf_codepoints(s),
    0,
    fn(value, code) {
      { 17 * { value + string.utf_codepoint_to_int(code) } } % 256
    },
  )
}

fn parse_steps(input: String) -> List(Step) {
  input
  |> string.replace("\n", "")
  |> string.split(",")
  |> list.map(fn(step) {
    case string.ends_with(step, "-") {
      True -> {
        let label = string.drop_right(step, 1)
        Remove(label)
      }
      False -> {
        let assert [label, length] = string.split(step, "=")
        let assert Ok(length) = int.parse(length)
        Insert(label, length)
      }
    }
  })
}

pub fn solve(input: String, part: ProblemPart) -> Result(Int, String) {
  case part {
    PartOne ->
      input
      |> string.replace("\n", "")
      |> string.split(",")
      |> list.map(hash)
      |> int.sum
      |> Ok
    PartTwo -> {
      input
      |> parse_steps
      |> list.fold(dict.new(), do_step)
      |> dict.map_values(fn(box_idx, box) {
        box
        |> focusing_power
        |> int.multiply(box_idx + 1)
      })
      |> dict.values
      |> int.sum
      |> Ok
    }
  }
}
