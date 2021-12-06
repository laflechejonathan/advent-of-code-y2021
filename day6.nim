import strutils
import std/sequtils
import std/sugar
import std/strformat
import std/tables

proc parse_initial_fish(line: string): Table[int, int] = 
  let split = line.split(",").map(parseInt)
  for fish_timer in split:
    let current = result.getOrDefault(fish_timer, 0)
    result[fish_timer] = current + 1

proc parse_fish(filename: string) : Table[int, int] = 
  let f = open(filename)
  defer: f.close()
  parse_initial_fish(f.readLine())

proc simulate_day(fish: Table[int, int]): Table[int, int] =
  for i in 0..8:
    result[i] = fish.getOrDefault(i + 1, 0)
  result[6] = result[6] + fish.getOrDefault(0, 0)
  result[8] = fish.getOrDefault(0, 0)

proc simulate(fish: Table[int, int], day_countdown: int): Table[int, int] =
  if day_countdown == 0:
    result = fish
  else:
    result = simulate(simulate_day(fish), day_countdown - 1)

proc count_fish(fish: Table[int, int]): int =
  let values = collect:
    for ct in fish.values: ct
  result = values.foldl(a + b)


echo count_fish(simulate(parse_fish("./inputs/day6/sample.txt"), 256))
echo count_fish(simulate(parse_fish("./inputs/day6/input.txt"), 256))