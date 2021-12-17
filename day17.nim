import strutils
import std/sequtils
import std/sugar
import std/strformat
import std/tables
import std/sets
import std/algorithm
import std/deques
import std/options
import std/re

type Point = tuple
  x: int
  y: int

type TargetArea = tuple
  min_x: int
  max_x: int
  min_y: int
  max_y:int

proc parse(input: string): TargetArea =
  var matches: array[4, string]
  assert match(input, re"target area: x=([-0-9]*)..([-0-9]*), y=([-0-9]*)..([-0-9]*)", matches)
  let numbers = matches.map(parseInt)
  return (numbers[0], numbers[1], numbers[2], numbers[3])

proc simulate_x(velocity: int, target: TargetArea): HashSet[int] =
  var sim_counter = 0
  var dx = velocity
  var x = 0
  while x < target.max_x and dx > 0:
    x += dx
    if x >= target.min_x and x <= target.max_x:
      result.incl(sim_counter)
    sim_counter += 1
    dx -= 1

  # Hack Hack
  if dx == 0 and x >= target.min_x and x <= target.max_x:
    for i in sim_counter..sim_counter + 500:
      result.incl(i)

proc simulate_y(velocity: int, target: TargetArea): (int, HashSet[int]) =
  var sim_counter = 0
  var dy = velocity
  var y = 0
  var apex = 0
  var hits = initHashSet[int]()
  while y >= target.min_y or dy > 0:
    y += dy
    apex = max(y, apex)
    if y >= target.min_y and y <= target.max_y:
      hits.incl(sim_counter)
    sim_counter += 1
    dy -= 1
  return (apex, hits)
  
proc find_best_apex(target: TargetArea): int =
  var best_apex = 0
  for dy in 0..1000:
    let (apex, possible) = simulate_y(dy, target)
    if possible.len > 0:
      best_apex = max(apex, best_apex)
    return best_apex

proc count_distinct_velocities(target: TargetArea): int =
  var counters_to_dx = initTable[int, HashSet[int]]()
  for dx in 0..target.max_x:
    let options = simulate_x(dx, target)
    for counter in options:
      var velocities = counters_to_dx.getOrDefault(counter, initHashSet[int]())
      velocities.incl(dx)
      counters_to_dx[counter] = velocities

  var velocities = initHashSet[Point]()
  for dy in target.min_y..1000:
    let (apex, options) = simulate_y(dy, target)
    for counter in options:
      for dx in counters_to_dx.getOrDefault(counter, initHashSet[int]()):
        velocities.incl((dx, dy))

  return velocities.len

echo "Part 1"
echo find_best_apex(parse("target area: x=20..30, y=-10..-5"))
echo find_best_apex(parse("target area: x=288..330, y=-96..-50"))
echo "Part 2"
echo count_distinct_velocities(parse("target area: x=20..30, y=-10..-5"))
echo count_distinct_velocities(parse("target area: x=288..330, y=-96..-50"))