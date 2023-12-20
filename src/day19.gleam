import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/pair
import gleam/regex
import gleam/result
import gleam/set.{type Set}
import gleam/string
import utils.{type ProblemPart, PartOne, PartTwo}

type Rating =
  Dict(String, Int)

type RatingSet =
  Dict(String, Set(Int))

fn possible_ratings() -> RatingSet {
  dict.from_list([
    #("x", set.from_list(list.range(1, 4000))),
    #("m", set.from_list(list.range(1, 4000))),
    #("a", set.from_list(list.range(1, 4000))),
    #("s", set.from_list(list.range(1, 4000))),
  ])
}

fn size(ratings: RatingSet) -> Int {
  dict.values(ratings)
  |> list.map(set.size)
  |> list.reduce(int.multiply)
  |> result.unwrap(0)
}

fn is_empty(ratings: RatingSet) -> Bool {
  dict.values(ratings)
  |> list.any(fn(attribute) { set.size(attribute) == 0 })
}

fn intersect(a: RatingSet, b: RatingSet) -> Option(RatingSet) {
  let result =
    dict.map_values(
      a,
      fn(k, a_values) {
        let assert Ok(b_values) = dict.get(b, k)
        set.intersection(a_values, b_values)
      },
    )

  use <- bool.guard(is_empty(result), None)

  Some(result)
}

type Action {
  Accept
  Reject
  Propagate(target: String)
}

type Rule {
  BinaryRule(attribute: String, operator: String, target: Int, action: Action)
  DefaultRule(action: Action)
}

fn matching_set(rule: Rule) -> RatingSet {
  case rule {
    DefaultRule(_) -> possible_ratings()
    BinaryRule(attribute, ">", target, _) -> {
      possible_ratings()
      |> dict.insert(attribute, set.from_list(list.range(target + 1, 4000)))
    }
    BinaryRule(attribute, "<", target, _) -> {
      possible_ratings()
      |> dict.insert(attribute, set.from_list(list.range(1, target - 1)))
    }
  }
}

fn rejecting_set(rule: Rule) -> RatingSet {
  case rule {
    DefaultRule(_) -> possible_ratings()
    BinaryRule(attribute, ">", target, _) -> {
      possible_ratings()
      |> dict.insert(attribute, set.from_list(list.range(1, target)))
    }
    BinaryRule(attribute, "<", target, _) -> {
      possible_ratings()
      |> dict.insert(attribute, set.from_list(list.range(target, 4000)))
    }
  }
}

fn split_rating_set(
  rule: Rule,
  ratings: RatingSet,
) -> #(Option(RatingSet), Option(RatingSet)) {
  case rule {
    DefaultRule(_) -> #(Some(ratings), None)
    BinaryRule(_, _, _, _) -> {
      #(
        intersect(ratings, matching_set(rule)),
        intersect(ratings, rejecting_set(rule)),
      )
    }
  }
}

type Workflow {
  Workflow(name: String, rules: List(Rule))
}

fn parse_binary_rule(input: String, action: Action) -> Rule {
  let assert Ok(pattern) = regex.from_string("(\\w+)([<>])(\\d+)")

  let [match] = regex.scan(pattern, input)

  let [Some(attribute), Some(operator), Some(target)] = match.submatches
  let assert Ok(target) = int.parse(target)

  BinaryRule(attribute, operator, target, action)
}

fn parse_rule(input: String) -> Rule {
  let parts = string.split(input, ":")

  case parts {
    ["A"] -> DefaultRule(Accept)
    ["R"] -> DefaultRule(Reject)
    [target] -> DefaultRule(Propagate(target))
    [condition, "A"] -> parse_binary_rule(condition, Accept)
    [condition, "R"] -> parse_binary_rule(condition, Reject)
    [condition, target] -> parse_binary_rule(condition, Propagate(target))
  }
}

fn parse_workflows(input: String) -> Dict(String, Workflow) {
  let assert Ok(pattern) = regex.from_string("(\\w+)\\{(.*)\\}")

  input
  |> regex.scan(pattern, _)
  |> list.fold(
    dict.new(),
    fn(flows, match) {
      let [Some(name), Some(rules)] = match.submatches

      let rules =
        rules
        |> string.split(",")
        |> list.map(parse_rule)

      dict.insert(flows, name, Workflow(name, rules))
    },
  )
}

fn parse_ratings(input: String) -> List(RatingSet) {
  let assert Ok(pattern) =
    regex.from_string("\\{x=(\\d+),m=(\\d+),a=(\\d+),s=(\\d+)\\}")

  regex.scan(pattern, input)
  |> list.map(fn(match) {
    let [Some(x), Some(m), Some(a), Some(s)] = match.submatches
    let assert Ok(x) = int.parse(x)
    let assert Ok(m) = int.parse(m)
    let assert Ok(a) = int.parse(a)
    let assert Ok(s) = int.parse(s)
    dict.from_list([
      #("x", set.from_list([x])),
      #("m", set.from_list([m])),
      #("a", set.from_list([a])),
      #("s", set.from_list([s])),
    ])
  })
}

fn check_rating(
  workflows: Dict(String, Workflow),
  current_workflow: Workflow,
  rating: Rating,
) -> Action {
  let assert Ok(rule) =
    current_workflow.rules
    |> list.drop_while(fn(rule) {
      case rule {
        DefaultRule(_) -> False
        BinaryRule(attribute, operator, target, _) -> {
          case operator {
            "<" -> {
              let assert Ok(attribute) = dict.get(rating, attribute)
              attribute >= target
            }
            ">" -> {
              let assert Ok(attribute) = dict.get(rating, attribute)
              attribute <= target
            }
          }
        }
      }
    })
    |> list.first

  let action = case rule {
    DefaultRule(action) -> action
    BinaryRule(_, _, _, action) -> action
  }

  case action {
    Accept -> Accept
    Reject -> Reject
    Propagate(workflow_name) -> {
      let assert Ok(next_workflow) = dict.get(workflows, workflow_name)
      check_rating(workflows, next_workflow, rating)
    }
  }
}

fn check_rating_set(
  workflows: Dict(String, Workflow),
  current_workflow: Workflow,
  ratings: RatingSet,
) -> List(RatingSet) {
  let result =
    current_workflow.rules
    |> list.scan(
      #([], Some(ratings)),
      fn(state, rule) {
        let #(result, unmatched_orig) = state

        use <- bool.guard(option.is_none(unmatched_orig), #(result, None))

        let assert Some(unmatched_orig) = unmatched_orig

        let #(matched, unmatched) = split_rating_set(rule, unmatched_orig)
        let result = case matched, rule {
          None, _ -> result

          Some(m), DefaultRule(Accept) -> [m, ..result]

          Some(_), DefaultRule(Reject) -> result

          Some(m), DefaultRule(Propagate(next_workflow_name)) -> {
            let assert Ok(next_workflow) =
              dict.get(workflows, next_workflow_name)
            list.append(check_rating_set(workflows, next_workflow, m), result)
          }

          Some(m), BinaryRule(_, _, _, Accept) -> [m, ..result]

          Some(_), BinaryRule(_, _, _, Reject) -> result

          Some(m), BinaryRule(_, _, _, Propagate(next_workflow_name)) -> {
            let assert Ok(next_workflow) =
              dict.get(workflows, next_workflow_name)
            list.append(check_rating_set(workflows, next_workflow, m), result)
          }
        }

        #(result, unmatched)
      },
    )

  result
  |> list.map(pair.first)
  |> list.last
  |> result.unwrap([])
}

pub fn solve(input: String, part: ProblemPart) -> Result(Int, String) {
  let [workflows, ratings] = string.split(input, "\n\n")

  let workflows = parse_workflows(workflows)
  let ratings = parse_ratings(ratings)

  let assert Ok(initial_workflow) = dict.get(workflows, "in")

  case part {
    PartOne -> {
      ratings
      |> list.flat_map(fn(rating) {
        check_rating_set(workflows, initial_workflow, rating)
      })
      |> list.flat_map(dict.values)
      |> list.reduce(set.union)
      |> result.unwrap(set.new())
      |> set.fold(0, int.add)
      |> Ok
    }
    PartTwo -> {
      check_rating_set(workflows, initial_workflow, possible_ratings())
      |> list.map(size)
      |> int.sum
      |> Ok
    }
  }
}
