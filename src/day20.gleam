import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/iterator.{type Iterator, Next}
import gleam/list
import gleam/option.{None, Some}
import gleam/queue.{type Queue}
import gleam/string
import utils.{type ProblemPart, PartOne, PartTwo}

type FlipFlopState {
  On
  Off
}

type Pulse {
  High
  Low
}

type ConnectionPulse {
  ConnectionPulse(from: String, to: String, pulse: Pulse)
}

type PulseQueue =
  Queue(ConnectionPulse)

type Module {
  FlipFlop(name: String, outputs: List(String), state: FlipFlopState)
  Conjunction(name: String, outputs: List(String), state: Dict(String, Pulse))
  Broadcaster(name: String, outputs: List(String))
}

fn parse_modules(input: String) -> Dict(String, Module) {
  let #(modules, inputs) =
    input
    |> string.trim
    |> string.split("\n")
    |> list.fold(
      #(dict.new(), dict.new()),
      fn(state, s) {
        let #(all_modules, inputs) = state

        let [module_string, all_outputs] = string.split(s, " -> ")
        let outputs = string.split(all_outputs, ", ")

        let module = case module_string {
          "broadcaster" -> Broadcaster("broadcaster", outputs)
          "%" <> name -> FlipFlop(name, outputs, Off)
          "&" <> name -> Conjunction(name, outputs, dict.new())
        }

        #(
          dict.insert(all_modules, module.name, module),
          list.fold(
            outputs,
            inputs,
            fn(ins, out) {
              dict.update(
                ins,
                out,
                fn(current_inputs) {
                  case current_inputs {
                    Some(l) -> [module.name, ..l]
                    None -> [module.name]
                  }
                },
              )
            },
          ),
        )
      },
    )

  dict.fold(
    inputs,
    modules,
    fn(ms, name, inputs) {
      case dict.get(ms, name) {
        Ok(Conjunction(_, outputs, _)) -> {
          let state =
            inputs
            |> list.map(fn(i) { #(i, Low) })
            |> dict.from_list

          dict.insert(ms, name, Conjunction(name, outputs, state))
        }
        _ -> ms
      }
    },
  )
}

fn output_pulses(
  outputs: List(String),
  from: String,
  pulse: Pulse,
) -> List(ConnectionPulse) {
  use to <- list.map(outputs)
  ConnectionPulse(from, to, pulse)
}

fn pulse_module(
  module: Module,
  from: String,
  pulse: Pulse,
) -> #(Module, List(ConnectionPulse)) {
  case module {
    FlipFlop(name, outputs, Off) -> {
      use <- bool.guard(pulse == High, #(module, []))
      #(FlipFlop(name, outputs, On), output_pulses(outputs, name, High))
    }
    FlipFlop(name, outputs, On) -> {
      use <- bool.guard(pulse == High, #(module, []))
      #(FlipFlop(name, outputs, Off), output_pulses(outputs, name, Low))
    }
    Conjunction(name, outputs, state) -> {
      let next_state = dict.insert(state, from, pulse)

      // case name {
      //   "ns" -> {
      //     next_state
      //     |> dict.values
      //     |> list.fold(
      //       #(0, 0),
      //       fn(t, pulse) {
      //         let #(l, h) = t
      //         case pulse {
      //           High -> #(l, h + 1)
      //           Low -> #(l + 1, h)
      //         }
      //       },
      //     )
      //     |> fn(x) { "ns state is " <> string.inspect(x) }
      //     |> io.println
      //     Nil
      //   }
      //   _ -> Nil
      // }

      let next_pulse =
        next_state
        |> dict.values
        |> list.all(fn(p) { p == High })
        |> fn(b) {
          case b {
            True -> Low
            False -> High
          }
        }

      #(
        Conjunction(name, outputs, next_state),
        output_pulses(outputs, name, next_pulse),
      )
    }
    Broadcaster(name, outputs) -> {
      #(module, output_pulses(outputs, name, pulse))
    }
  }
}

fn push_back_list(q: Queue(a), items: List(a)) -> Queue(a) {
  use current_queue, item <- list.fold(items, q)
  queue.push_back(current_queue, item)
}

fn send_all_pulses(
  modules: Dict(String, Module),
  inputs: Dict(String, List(Pulse)),
  pulses: PulseQueue,
) -> #(Dict(String, Module), Dict(String, List(Pulse)), PulseQueue) {
  use <- bool.guard(queue.is_empty(pulses), #(modules, inputs, pulses))
  let assert Ok(#(pulse, remaining_pulses)) = queue.pop_front(pulses)
  let ConnectionPulse(from, to, pulse) = pulse
  let inputs =
    dict.update(
      inputs,
      to,
      fn(received) {
        case received {
          Some(received) -> [pulse, ..received]
          None -> [pulse]
        }
      },
    )

  use <- bool.lazy_guard(
    dict.has_key(modules, to)
    |> bool.negate,
    fn() { send_all_pulses(modules, inputs, remaining_pulses) },
  )
  let assert Ok(module) = dict.get(modules, to)

  let #(updated_module, new_pulses) = pulse_module(module, from, pulse)

  let updated_modules = dict.insert(modules, module.name, updated_module)
  let updated_pulses = push_back_list(remaining_pulses, new_pulses)

  send_all_pulses(updated_modules, inputs, updated_pulses)
}

fn press_button_continually(
  modules: Dict(String, Module),
) -> Iterator(Dict(String, List(Pulse))) {
  iterator.unfold(
    modules,
    fn(modules) {
      let #(modules, inputs, _) =
        send_all_pulses(
          modules,
          dict.new(),
          queue.from_list([ConnectionPulse("button", "broadcaster", Low)]),
        )
      Next(inputs, modules)
    },
  )
}

pub fn solve(input: String, part: ProblemPart) -> Result(Int, String) {
  case part {
    PartOne -> {
      parse_modules(input)
      |> press_button_continually()
      |> iterator.take(1000)
      |> iterator.fold(
        [],
        fn(all_inputs, inputs) {
          list.append(
            all_inputs,
            inputs
            |> dict.values
            |> list.flatten,
          )
        },
      )
      |> list.partition(fn(p) { p == Low })
      |> fn(p) {
        let #(lows, highs) = p
        list.length(lows) * list.length(highs)
      }
      |> Ok
    }

    PartTwo -> {
      let modules = parse_modules(input)

      let assert [rx_input] =
        modules
        |> dict.filter(fn(_, module) {
          case module {
            Conjunction(_, outputs, _) -> list.contains(outputs, "rx")
            _ -> False
          }
        })
        |> dict.keys

      let required_inputs =
        modules
        |> dict.filter(fn(_, module) {
          case module {
            FlipFlop(_, outputs, _) -> list.contains(outputs, rx_input)
            Conjunction(_, outputs, _) -> list.contains(outputs, rx_input)
            Broadcaster(_, outputs) -> list.contains(outputs, rx_input)
          }
        })
        |> dict.keys()

      required_inputs
      |> list.map(fn(name) {
        press_button_continually(modules)
        |> iterator.take_while(fn(inputs) {
          let assert Ok(inputs) = dict.get(inputs, name)

          list.all(inputs, fn(p) { p == High })
        })
        |> iterator.length
        |> int.add(1)
      })
      |> int.product
      |> Ok
    }
  }
}
