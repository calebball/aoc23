import gleam/dict.{type Dict}
import gleam/iterator
import gleam/list.{Continue, Stop}
import gleam/option.{Some}
import gleam/pair
import gleam/regex
import gleam/result
import gleam/string
import utils.{type ProblemPart, PartOne, PartTwo}

pub fn gcd(a: Int, b: Int) -> Int {
  case b {
    0 -> a
    _ -> gcd(b, a % b)
  }
}

pub fn lcm(a: Int, b: Int) -> Int {
  { a * b } / gcd(a, b)
}

pub type Node {
  Node(left: String, right: String)
}

pub fn parse_graph(input: String) -> Dict(String, Node) {
  let assert Ok(pattern) =
    regex.from_string("(\\w{3}) = \\((\\w{3}), (\\w{3})\\)")

  regex.scan(pattern, input)
  |> list.fold(
    dict.new(),
    fn(nodes, match) {
      let assert [Some(key), Some(left), Some(right)] = match.submatches

      dict.insert(nodes, key, Node(left, right))
    },
  )
}

pub fn solve(input: String, part: ProblemPart) -> Result(Int, String) {
  let assert [directions, graph_spec] = string.split(input, "\n\n")

  let graph = parse_graph(graph_spec)

  let starting_nodes = case part {
    PartOne -> ["AAA"]
    PartTwo -> {
      let assert Ok(pattern) = regex.from_string("(\\w{2}A) =")
      regex.scan(pattern, graph_spec)
      |> list.map(fn(m) {
        let [Some(node)] = m.submatches
        node
      })
    }
  }

  case part {
    PartOne -> {
      let at_end = case part {
        PartOne -> fn(nodes: List(String)) {
          let assert [node] = nodes
          node == "ZZZ"
        }
        PartTwo -> fn(nodes: List(String)) {
          nodes
          |> list.all(string.ends_with(_, "Z"))
        }
      }

      let directions =
        directions
        |> string.to_graphemes
        |> iterator.from_list
        |> iterator.cycle

      directions
      |> iterator.fold_until(
        #(starting_nodes, 0),
        fn(state, d) {
          let #(current, count) = state

          case at_end(current) {
            True -> Stop(#(current, count))
            False -> {
              let next =
                current
                |> list.map(fn(n) {
                  let assert Ok(node) = dict.get(graph, n)
                  case d {
                    "L" -> node.left
                    "R" -> node.right
                  }
                })

              Continue(#(next, count + 1))
            }
          }
        },
      )
      |> pair.second
      |> Ok
    }

    PartTwo -> {
      let directions =
        directions
        |> string.to_graphemes
        |> list.index_map(fn(idx, d) { #(idx, d) })
        |> iterator.from_list
        |> iterator.cycle

      starting_nodes
      |> list.map(fn(node) {
        directions
        |> iterator.scan(
          node,
          fn(n, d) {
            let #(_, d) = d
            let assert Ok(n) = dict.get(graph, n)
            case d {
              "L" -> n.left
              "R" -> n.right
            }
          },
        )
        |> iterator.zip(directions)
        |> iterator.map(fn(p) {
          let #(n, #(idx, _)) = p
          #(idx, n)
        })
        |> iterator.fold_until(
          #([], []),
          fn(lp, p) {
            let #(_, l) = lp

            case list.contains(l, p) {
              True ->
                Stop({
                  let l = list.reverse(l)
                  #(
                    list.take_while(l, fn(x) { x != p }),
                    list.drop_while(l, fn(x) { x != p }),
                  )
                })
              False -> Continue(#([], [p, ..l]))
            }
          },
        )
      })
      |> list.map(fn(p) {
        let #(_, loop) = p
        list.length(loop)
      })
      |> list.reduce(lcm)
      |> result.map_error(fn(_) { "oh noes!" })
    }
  }
}
