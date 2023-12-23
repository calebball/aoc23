import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import utils.{type ProblemPart, PartOne, PartTwo}

type Position =
  #(Int, Int)

type Block {
  Block(id: Int, positions: Set(Position), bottom: Int, top: Int)
}

fn parse_blocks(input: String) -> List(Block) {
  use idx, line <- list.index_map(
    input
    |> string.trim()
    |> string.split("\n"),
  )

  let assert Ok([x1, y1, z1, x2, y2, z2]) =
    line
    |> string.split("~")
    |> list.flat_map(string.split(_, ","))
    |> list.map(int.parse)
    |> result.all

  let [x1, x2] = list.sort([x1, x2], int.compare)
  let [y1, y2] = list.sort([y1, y2], int.compare)
  let [z1, z2] = list.sort([z1, z2], int.compare)

  case x1 == x2, y1 == y2 {
    True, _ -> {
      Block(
        idx,
        list.range(y1, y2)
        |> list.map(fn(y) { #(x1, y) })
        |> set.from_list,
        z1,
        z2,
      )
    }
    _, True -> {
      Block(
        idx,
        list.range(x1, x2)
        |> list.map(fn(x) { #(x, y1) })
        |> set.from_list,
        z1,
        z2,
      )
    }
  }
}

fn is_stacked(a: Block, b: Block) -> Bool {
  use <- bool.guard(b.bottom != a.top + 1, False)

  set.intersection(a.positions, b.positions)
  |> set.size
  |> fn(size) { size > 0 }
}

fn is_underneath(a: Block, b: Block) -> Bool {
  use <- bool.guard(b.bottom <= a.top, False)

  set.intersection(a.positions, b.positions)
  |> set.size
  |> fn(size) { size > 0 }
}

fn drop(fallen: List(Block), block: Block) -> List(Block) {
  let Block(id, positions, bottom, top) = block

  let new_bottom =
    list.filter(fallen, is_underneath(_, block))
    |> list.map(fn(supported_by) { supported_by.top })
    |> list.reduce(int.max)
    |> result.unwrap(0)
    |> int.add(1)

  [Block(id, positions, new_bottom, top - bottom + new_bottom), ..fallen]
}

fn find_structural(blocks: List(Block)) -> Dict(Block, List(Block)) {
  use <- bool.guard(list.is_empty(blocks), dict.new())

  let [block, ..remaining] = blocks

  let supported_by =
    remaining
    |> list.filter(is_stacked(_, block))

  dict.insert(find_structural(remaining), block, supported_by)
}

fn above_ground(block: Block) -> Bool {
  block.bottom > 1
}

fn is_unstable(
  supported_by: Dict(Block, List(Block)),
  missing_blocks: Set(Block),
) -> Bool {
  use supported_by <- list.any(dict.values(supported_by))
  use support <- list.any(supported_by)

  set.contains(missing_blocks, support)
}

fn is_stable(
  supported_by: Dict(Block, List(Block)),
  missing_blocks: Set(Block),
) -> Bool {
  bool.negate(is_unstable(supported_by, missing_blocks))
}

fn topple(
  supported_by: Dict(Block, List(Block)),
  missing_blocks: Set(Block),
) -> Set(Block) {
  use <- bool.guard(is_stable(supported_by, missing_blocks), missing_blocks)

  let supported_by =
    dict.map_values(
      supported_by,
      fn(_, supports) {
        list.filter(
          supports,
          fn(block) { bool.negate(set.contains(missing_blocks, block)) },
        )
      },
    )

  let missing_blocks =
    dict.fold(
      supported_by,
      missing_blocks,
      fn(missing_blocks, block, supports) {
        case above_ground(block) && list.is_empty(supports) {
          True -> set.insert(missing_blocks, block)
          False -> missing_blocks
        }
      },
    )

  topple(supported_by, missing_blocks)
}

pub fn solve(input: String, part: ProblemPart) -> Result(Int, String) {
  let blocks =
    input
    |> parse_blocks

  let total_blocks = list.length(blocks)

  let collapsed =
    blocks
    |> list.sort(fn(a, b) { int.compare(a.bottom, b.bottom) })
    |> list.fold([], drop)

  let supported_by =
    collapsed
    |> find_structural

  case part {
    PartOne ->
      supported_by
      |> dict.fold(
        set.new(),
        fn(required, _, supported_by) {
          use <- bool.guard(list.length(supported_by) != 1, required)

          let [support] = supported_by
          set.insert(required, support)
        },
      )
      |> set.size
      |> int.subtract(total_blocks, _)
      |> Ok
    PartTwo -> {
      collapsed
      |> list.map(fn(block) {
        topple(supported_by, set.from_list([block]))
        |> set.size
        |> int.subtract(1)
      })
      |> int.sum
      |> Ok
    }
  }
}
