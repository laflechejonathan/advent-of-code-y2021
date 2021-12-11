import strutils
import std/sequtils
import std/sugar
import std/strformat
import std/tables
import std/sets
import std/algorithm
import std/deques
import std/options

type Point = tuple
  x: int
  y: int

const vectors: seq[Point] = @[
  (-1, -1),
  (-1, 0),
  (-1, 1),
  (0, -1),
  (0, 1),
  (1, 0),
  (1, -1),
  (1, 1),
]

proc parse_grid(filename: string): seq[seq[int]] =
  let f = open(filename)
  defer: f.close()
  var line: string
  while f.readLine(line):
    result.add(toSeq(line).mapIt(parseInt(fmt"{it}")))

proc flash_neighbors(pt: Point): seq[Point] =
  for v in vectors:
    let new_pt = (x: pt.x + v.x, y: pt.y + v.y)
    if new_pt.x >= 0 and new_pt.x < 10 and new_pt.y >= 0 and new_pt.y < 10:
      result.add(new_pt)

proc simulate_day(grid: seq[seq[int]]): (seq[seq[int]], int) =
  var new_grid = grid
  var to_visit = initDeque[Point]()
  for x in 0..9:
    for y in 0..9:
        new_grid[x][y] += 1
        to_visit.addLast((x, y))
  
  var flashed = initHashSet[Point]()
  while to_visit.len > 0:
    let pt = to_visit.popFirst()
    if new_grid[pt.x][pt.y] > 9:
      flashed.incl(pt)
      new_grid[pt.x][pt.y] = 0
      for n in flash_neighbors(pt):
        if not flashed.contains(n):
          new_grid[n.x][n.y] += 1
          to_visit.addLast(n)

  result = (new_grid, flashed.len)

proc print_grid(grid: seq[seq[int]]): void = 
  for row in grid:
    echo row.mapIt(fmt"{it}").join

proc solve_1(filename: string): int =
  var grid = parse_grid(filename)
  var flashes = 0
  for i in 1..100:
    (grid, flashes) = simulate_day(grid)
    result += flashes

proc solve_2(filename: string): int =
  var grid = parse_grid(filename)
  var flashes = 0
  for i in 1..10000:
    (grid, flashes) = simulate_day(grid)
    if flashes == 100:
      return i
  
echo solve_1("./inputs/day11/sample.txt")
echo solve_1("./inputs/day11/input.txt")
echo solve_2("./inputs/day11/sample.txt")
echo solve_2("./inputs/day11/input.txt")