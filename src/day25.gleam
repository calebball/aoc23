import gleam/io
import gleam/bool
import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/iterator.{type Iterator, Done, Next}
import gleam/list
import gleam/option
import gleam/result
import gleam/set.{type Set}
import gleam/string
import utils.{type ProblemPart}

type Node =
  String

type Edges =
  Dict(Node, Dict(Node, Int))

type Vertices =
  Set(Node)

type Graph {
  Graph(vertices: Vertices, edges: Edges)
}

fn parse_edges(input: String) -> Edges {
  let lines =
    input
    |> string.trim
    |> string.split("\n")

  use edges, line <- list.fold(lines, dict.new())

  let [node, connections] = string.split(line, ": ")

  use edges, other <- list.fold(string.split(connections, " "), edges)

  edges
  |> dict.update(
    node,
    fn(others) {
      others
      |> option.unwrap(dict.new())
      |> dict.insert(other, 1)
    },
  )
  |> dict.update(
    other,
    fn(others) {
      others
      |> option.unwrap(dict.new())
      |> dict.insert(node, 1)
    },
  )
}

fn parse_vertices(edges: Edges) -> Vertices {
  use vertices, node, others <- dict.fold(edges, set.new())

  vertices
  |> set.insert(node)
  |> set.union(set.from_list(dict.keys(others)))
}

fn parse_graph(input: String) -> Graph {
  let edges = parse_edges(input)
  let vertices = parse_vertices(edges)
  Graph(vertices, edges)
}

fn min_cut_phase(
  graph: Graph,
  unvisited: Dict(Node, Int),
  visited: List(Node),
  last_weight: Int,
) -> #(Node, Node, Int) {
  use <- bool.lazy_guard(
    dict.size(unvisited) == 0,
    fn() {
      let [target, source, ..] = visited
      #(target, source, last_weight)
    },
  )

  let assert Ok(#(tightest, weight)) =
    dict.fold(
      unvisited,
      Error(Nil),
      fn(best, node, weight) {
        case best {
          Error(_) -> Ok(#(node, weight))
          Ok(#(_, best_weight)) if weight > best_weight -> Ok(#(node, weight))
          _ -> best
        }
      },
    )

  let assert Ok(tightest_connections) = dict.get(graph.edges, tightest)

  let unvisited =
    unvisited
    |> dict.delete(tightest)
    |> dict.map_values(fn(node, current_weight) {
      tightest_connections
      |> dict.get(node)
      |> result.unwrap(0)
      |> int.add(current_weight)
    })

  min_cut_phase(graph, unvisited, [tightest, ..visited], weight)
}

fn merge(graph: Graph, merging: Node, into: Node) -> Graph {
  let new_node = merging <> into

  let vertices =
    graph.vertices
    |> set.drop([merging, into])
    |> set.insert(new_node)

  let merging_edges =
    graph.edges
    |> dict.get(merging)
    |> result.lazy_unwrap(dict.new)
    |> dict.delete(into)

  let into_edges =
    graph.edges
    |> dict.get(into)
    |> result.lazy_unwrap(dict.new)
    |> dict.delete(merging)

  let new_edges =
    merging_edges
    |> dict.fold(
      into_edges,
      fn(all_edges, node, weight) {
        dict.update(
          all_edges,
          node,
          fn(current_weight) { option.unwrap(current_weight, 0) + weight },
        )
      },
    )

  let edges =
    graph.edges
    |> dict.drop([merging, into])
    |> dict.map_values(fn(_, edges) {
      use edges, other, weight <- dict.fold(edges, dict.new())

      case other == merging || other == into {
        True ->
          dict.update(edges, new_node, fn(w) { option.unwrap(w, 0) + weight })
        False -> dict.insert(edges, other, weight)
      }
    })
    |> dict.insert(new_node, new_edges)

  Graph(vertices, edges)
}

fn min_cut(graph: Graph, source: Node) -> Iterator(#(Node, Set(Node), Int)) {
  iterator.unfold(
    graph,
    fn(graph) {
      use <- bool.guard(set.size(graph.vertices) == 1, Done)
      io.println(string.inspect(set.size(graph.vertices)) <> " vertices left")

      let assert Ok(source_connections) = dict.get(graph.edges, source)
      let unvisited =
        graph.vertices
        |> set.delete(source)
        |> set.fold(
          dict.new(),
          fn(unvisited, node) {
            source_connections
            |> dict.get(node)
            |> result.unwrap(0)
            |> dict.insert(unvisited, node, _)
          },
        )
      let #(merging, into, weight) =
        min_cut_phase(graph, unvisited, [source], 0)

      let new_graph = merge(graph, merging, into)

      Next(#(merging, set.delete(graph.vertices, merging), weight), new_graph)
    },
  )
}

pub fn solve(input: String, _part: ProblemPart) -> Result(Int, String) {
  let graph = parse_graph(input)

  let [start, ..] = set.to_list(graph.vertices)

  min_cut(graph, start)
  |> iterator.find(fn(cut) {
    let #(_, _, weight) = cut
    weight == 3
  })
  |> result.map(fn(min_cut) {
    let #(left, right, _) = min_cut
    let right = set.fold(right, "", string.append)
    let left_size = string.length(left) / 3
    let right_size = string.length(right) / 3
    left_size * right_size
  })
  |> result.map_error(function.constant("oh noes!"))
}
