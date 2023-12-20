import gleam/order.{Eq, Gt, Lt}
import gleam/int
import gleam/option.{type Option, None, Some}

pub type Interval {
  Closed(min: Int, max: Int)
}

pub fn shift(i: Interval, offset: Int) {
  Closed(i.min + offset, i.max + offset)
}

pub fn intersect(
  a: Interval,
  b: Interval,
) -> #(Option(Interval), List(Interval)) {
  case
    int.compare(a.min, b.min),
    int.compare(a.min, b.max),
    int.compare(a.max, b.min),
    int.compare(a.max, b.max)
  {
    // A is within B
    Gt, _, _, Lt -> #(Some(a), [])
    Gt, _, _, Eq -> #(Some(a), [])
    Eq, _, _, Lt -> #(Some(a), [])
    Eq, _, _, Eq -> #(Some(a), [])

    // B is within A
    Lt, _, _, Gt -> #(
      Some(b),
      [Closed(a.min, b.min - 1), Closed(b.max + 1, a.max)],
    )
    Eq, _, _, Gt -> #(Some(b), [Closed(b.max + 1, a.max)])
    Lt, _, _, Eq -> #(Some(b), [Closed(a.min, b.min - 1)])

    // B is less than A
    _, Gt, _, _ -> #(None, [a])

    // B overlaps A on the left
    _, Eq, _, _ -> #(Some(Closed(a.min, a.min)), [Closed(a.min + 1, a.max)])
    Gt, Lt, _, _ -> #(Some(Closed(a.min, b.max)), [Closed(b.max + 1, a.max)])

    // B overlaps A on the right
    _, _, Gt, Lt -> #(Some(Closed(b.min, a.max)), [Closed(a.min, b.min - 1)])
    _, _, Eq, _ -> #(Some(Closed(a.max, a.max)), [Closed(a.min, a.max - 1)])

    // B is greater than A
    _, _, Lt, _ -> #(None, [a])
  }
}
