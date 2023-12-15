import gleam/list.{Continue, Stop}
import gleam/option.{type Option, None, Some}

pub type ProblemPart {
  PartOne
  PartTwo
}

pub fn list_index(l: List(a), pred: fn(a) -> Bool) -> Option(Int) {
  let #(idx, found) =
    list.fold_until(
      l,
      #(0, True),
      fn(state, a) {
        let #(idx, _) = state
        case pred(a) {
          True -> Stop(#(idx, True))
          False -> Continue(#(idx + 1, False))
        }
      },
    )

  case found {
    True -> Some(idx)
    False -> None
  }
}
