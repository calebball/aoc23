import gleam/erlang
import gleam/int
import gleam/io
import gleam/result
import simplifile
import glint
import day1
import day2
import day3
import day4
import day5
import day6
import day7
import day8
import day9
import day10
import day11
import day12
import day13
import day14
import day15
import day16
import day17
import day18
import day19
import day20
import utils.{PartOne, PartTwo}

pub fn run(cli: glint.CommandInput) {
  let solve = case cli.args {
    ["day1", ..] -> day1.solve
    ["day2", ..] -> day2.solve
    ["day3", ..] -> day3.solve
    ["day4", ..] -> day4.solve
    ["day5", ..] -> day5.solve
    ["day6", ..] -> day6.solve
    ["day7", ..] -> day7.solve
    ["day8", ..] -> day8.solve
    ["day9", ..] -> day9.solve
    ["day10", ..] -> day10.solve
    ["day11", ..] -> day11.solve
    ["day12", ..] -> day12.solve
    ["day13", ..] -> day13.solve
    ["day14", ..] -> day14.solve
    ["day15", ..] -> day15.solve
    ["day16", ..] -> day16.solve
    ["day17", ..] -> day17.solve
    ["day18", ..] -> day18.solve
    ["day19", ..] -> day19.solve
    ["day20", ..] -> day20.solve
  }
  let part = case cli.args {
    [_, "part1", ..] -> PartOne
    [_, "part2", ..] -> PartTwo
  }
  let path = case cli.args {
    [_, _, path] -> path
  }

  let assert Ok(input) = simplifile.read(path)

  solve(input, part)
  |> result.map(int.to_string)
  |> result.unwrap_both
  |> io.println
}

pub fn main() {
  glint.new()
  |> glint.with_name("aoc23")
  |> glint.with_pretty_help(glint.default_pretty_help())
  |> glint.add(at: [], do: glint.command(run))
  |> glint.run(erlang.start_arguments())
}
