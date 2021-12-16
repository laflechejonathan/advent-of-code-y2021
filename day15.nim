import strutils
# import nimprof 
import std/sequtils
import std/sugar
import std/strformat
import std/tables
import std/sets
import std/algorithm
import std/deques
import std/options
import std/re
import sorta

type Point = tuple
  x: int
  y: int

type Cave = tuple
  points: Table[Point, int]
  max_x: int
  max_y: int

const vectors: seq[Point] = @[
  (0, 1),
  (1, 0),
  (-1, 0),
  (0, -1),
]

proc sequence(num: int, steps: int): int =
  result = num
  for i in 0..steps:
    result += 1
    if result == 10:
      result = 1

proc parse(filename: string): Cave =
  let f = open(filename)
  defer: f.close()

  var line: string
  var y = 0
  var max_x = 0
  var max_y = 0
  var points = initTable[Point, int]()
  while f.readLine(line):
    for x in 0..<line.len:
      points[(x, y)] = parseInt($line[x])
      max_x = x
      max_y = y
    y += 1

  return (points, max_x, max_y)
  
proc tile_cave(cave: Cave, copies: int): Cave =
  var points = cave.points
  let tile_width = cave.max_x + 1
  let tile_height = cave.max_y + 1
  var max_x = 0
  var max_y = 0
  for x in 0..<tile_width:
    for y in 0..<tile_height:
      for i in 0..<copies:
        for j in 0..<copies:
          if i > 0 or j > 0:
            let new_pt = (x: i * tile_width + x, y: j * tile_height + y)
            let steps_from_origin = i + j - 1
            let new_value = sequence(points[(x, y)], steps_from_origin)
            points[new_pt] = new_value
            max_x = new_pt.x
            max_y = new_pt.y
  
  return (points, max_x, max_y)
  
proc next_key(table: SortedTable[Point, int]): Point =
  for k in table.keys:
    return k

proc neighbors(pt: Point, cave: Cave): seq[Point] =
  return vectors
    .mapIt((x: pt.x + it.x, y: pt.y + it.y))
    .filterIt(it.x >= 0 and it.x <= cave.max_x and it.y >= 0 and it.y <= cave.max_y)

proc shortest_path(curr: Point, cave: Cave): int =
  let start_pt = (0, 0)
  let end_pt = (cave.max_x, cave.max_y)
  var unvisited = initSortedTable[Point, int]()
  var costs = initTable[Point, int]()
  for pt in cave.points.keys:
    unvisited[pt] = high(int)
    costs[pt] = high(int)

  unvisited[start_pt] = 0
  costs[(start_pt)] = 0

  while unvisited.contains(end_pt):
    var current = next_key(unvisited)
    let curr_cost = costs[current]
    for n in neighbors(current, cave):
      let new_cost = curr_cost + cave.points[n]
      if new_cost < costs[n]:
        costs[n] = new_cost
        unvisited[n] = new_cost
    unvisited.del(current)
  
  return costs[end_pt]

echo "Part 1"
echo shortest_path((0, 0), parse("./inputs/day15/sample.txt"))
echo shortest_path((0, 0), parse("./inputs/day15/input.txt"))
echo "Part 2"
echo shortest_path((0, 0), tile_cave(parse("./inputs/day15/sample.txt"), 5))
echo shortest_path((0, 0), tile_cave(parse("./inputs/day15/input.txt"), 5))