import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import utils.{type ProblemPart, PartOne, PartTwo}

pub type Position =
  #(Int, Int, Int)

pub type FloatPosition =
  #(Float, Float, Float)

fn to_float(position: Position) -> FloatPosition {
  let #(x, y, z) = position
  #(int.to_float(x), int.to_float(y), int.to_float(z))
}

pub type Velocity =
  #(Int, Int, Int)

pub type Hailstone {
  Hailstone(position: Position, velocity: Velocity)
}

pub fn parse_hailstones(input: String) -> List(Hailstone) {
  let lines =
    input
    |> string.trim
    |> string.split("\n")

  use hailstones, line <- list.fold(lines, [])

  let [position, velocity] = string.split(line, "@")

  let assert Ok(position) =
    position
    |> string.trim
    |> string.split(", ")
    |> list.map(int.parse)
    |> result.all
    |> result.map(fn(p) {
      let [x, y, z] = p
      #(x, y, z)
    })

  let assert Ok(velocity) =
    velocity
    |> string.trim
    |> string.split(", ")
    |> list.map(string.trim)
    |> list.map(int.parse)
    |> result.all
    |> result.map(fn(p) {
      let [x, y, z] = p
      #(x, y, z)
    })

  [Hailstone(position, velocity), ..hailstones]
}

fn xy_gradient(hailstone: Hailstone) -> Float {
  let #(m_x, m_y, _) = hailstone.velocity
  int.to_float(m_y) /. int.to_float(m_x)
}

fn xy_intercept(hailstone: Hailstone) -> Float {
  let #(x, y, _) = hailstone.position
  let m = xy_gradient(hailstone)
  int.to_float(y) -. m *. int.to_float(x)
}

fn find_xy_intersection(
  a: Hailstone,
  b: Hailstone,
) -> Result(FloatPosition, Nil) {
  let a_gradient = xy_gradient(a)
  let a_intercept = xy_intercept(a)

  let b_gradient = xy_gradient(b)
  let b_intercept = xy_intercept(b)

  use <- bool.guard(a_gradient == b_gradient, Error(Nil))

  let x = { b_intercept -. a_intercept } /. { a_gradient -. b_gradient }

  Ok(#(x, a_gradient *. x +. a_intercept, 0.0))
}

fn is_in_xy_future(hailstone: Hailstone, position: FloatPosition) -> Bool {
  let #(ax, ay, _) = to_float(hailstone.position)
  let #(bx, by, _) = position

  let #(dx, dy, _) = to_float(hailstone.velocity)

  { bx -. ax } /. dx >. 0.0 && { by -. ay } /. dy >. 0.0
}

fn find_future_xy_intersection(
  a: Hailstone,
  b: Hailstone,
) -> Result(FloatPosition, Nil) {
  case find_xy_intersection(a, b) {
    Ok(intersection) -> {
      case
        is_in_xy_future(a, intersection) && is_in_xy_future(b, intersection)
      {
        True -> Ok(intersection)
        False -> Error(Nil)
      }
    }
    Error(_) -> Error(Nil)
  }
}

pub fn solve_part_1(
  hailstones: List(Hailstone),
  minimum_coordinate: Int,
  maximum_coordinate: Int,
) -> Int {
  let minimum_coordinate = int.to_float(minimum_coordinate)
  let maximum_coordinate = int.to_float(maximum_coordinate)

  list.combination_pairs(hailstones)
  |> list.filter_map(fn(hailstones) {
    let #(a, b) = hailstones
    find_future_xy_intersection(a, b)
  })
  |> list.filter(fn(intersection) {
    let #(x, y, _) = intersection
    x >=. minimum_coordinate && x <=. maximum_coordinate && y >=. minimum_coordinate && y <=. maximum_coordinate
  })
  |> list.length
}

fn add(a: Position, b: Position) -> Position {
  let #(a1, a2, a3) = a
  let #(b1, b2, b3) = b

  #(a1 + b1, a2 + b2, a3 + b3)
}

fn subtract(a: Position, b: Position) -> Position {
  let #(a1, a2, a3) = a
  let #(b1, b2, b3) = b

  #(a1 - b1, a2 - b2, a3 - b3)
}

fn scale(a: Position, b: Int) -> Position {
  let #(a1, a2, a3) = a

  #(a1 * b, a2 * b, a3 * b)
}

fn divide(a: Position, b: Int) -> Position {
  let #(a1, a2, a3) = a

  #(a1 / b, a2 / b, a3 / b)
}

fn dot_product(a: Position, b: Position) -> Int {
  let #(a1, a2, a3) = a
  let #(b1, b2, b3) = b

  a1 * b1 + a2 * b2 + a3 * b3
}

fn cross_product(a: Position, b: Position) -> Position {
  let #(a1, a2, a3) = a
  let #(b1, b2, b3) = b

  #(a2 * b3 - a3 * b2, a3 * b1 - a1 * b3, a1 * b2 - a2 * b1)
}

fn to_reference(reference: Hailstone, stone: Hailstone) -> Hailstone {
  Hailstone(
    subtract(stone.position, reference.position),
    subtract(stone.velocity, reference.velocity),
  )
}

fn plane_intersection(a: Hailstone, b: Hailstone) -> Int {
  let normal = cross_product(a.position, add(a.position, a.velocity))
  let time =
    int.negate(
      dot_product(normal, b.position) / dot_product(normal, b.velocity),
    )
  time
}

fn position_at_time(hailstone: Hailstone, time: Int) -> Position {
  add(hailstone.position, scale(hailstone.velocity, time))
}

pub fn solve(input: String, part: ProblemPart) -> Result(Int, String) {
  let hailstones = parse_hailstones(input)

  case part {
    PartOne -> {
      solve_part_1(hailstones, 200_000_000_000_000, 400_000_000_000_000)
      |> Ok
    }
    PartTwo -> {
      use <- bool.guard(
        list.length(hailstones) <= 4,
        Error("Not enough stones"),
      )

      let assert [first, second, third, fourth, ..] = hailstones

      let second_transformed = to_reference(first, second)
      let third_transformed = to_reference(first, third)
      let fourth_transformed = to_reference(first, fourth)

      let third_time = plane_intersection(second_transformed, third_transformed)
      let fourth_time =
        plane_intersection(second_transformed, fourth_transformed)

      let third_intersection = position_at_time(third, third_time)
      let fourth_intersection = position_at_time(fourth, fourth_time)

      let velocity =
        divide(
          subtract(fourth_intersection, third_intersection),
          fourth_time - third_time,
        )

      let #(x, y, z) = subtract(third_intersection, scale(velocity, third_time))

      x + y + z
      |> Ok
    }
  }
}
