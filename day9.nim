import strutils
import std/sequtils
import std/sugar
import std/strformat
import std/tables
import std/sets
import std/algorithm
import std/deques

type Point = tuple
  x: int
  y: int

type HeightMap = tuple
  heights: Table[Point, int]
  max_x: int
  max_y: int


const neighbor_vectors: seq[Point] = @[
  (0, 1),
  (1, 0),
  (0, -1),
  (-1, 0),
]

proc add(a: Point, b: Point): Point =
  (a.x + b.x, a.y + b.y)

proc neighbors(point: Point): seq[Point] = 
  result = neighbor_vectors.mapIt(add(point, it))

proc is_low_point(point: Point, height_map: HeightMap): bool =
  let heights = height_map.heights
  let point_height = heights[point]
  let neighbors = neighbors(point).mapIt(heights.getOrDefault(it, high(int)))
  # echo point, neighbors, point_height
  result = all(neighbors, (n) => point_height < n)
  
proc parse_height_map(filename: string): HeightMap =
  let f = open(filename)
  defer: f.close()
  var line: string
  var y = 0
  var max_x = 0
  var heights = initTable[Point, int]()
  while (f.readLine(line)):
    let row = toSeq(line).mapIt(parseInt(fmt"{it}"))
    max_x = max(row.len - 1, max_x)
    for x in 0..<row.len:
      # echo fmt"{x}, {y}, {row[x]}"
      heights[(x, y)] = row[x]
    y += 1

  result = (
    heights: heights,
    max_x: max_x,
    max_y: y - 1,
  )

proc walk_basin(low_point: Point, height_map: HeightMap): int =
  let heights = height_map.heights
  var visited = initHashSet[Point]()
  visited.incl(low_point)
  var frontier = [low_point].toDeque
  while frontier.len > 0:
    let current = frontier.popFirst
    let current_height = heights[current]
    let neighbors = neighbors(current)
    for n in neighbors(current):
      if not visited.contains(n):
        let height = heights.getOrDefault(n, 9)
        if height > current_height and height < 9:
          frontier.addLast(n)
          visited.incl(n)
  
  result = visited.len
    

proc solve_1(filename: string): int =
  let height_map = parse_height_map(filename)
  let low_points = collect:
    for x in 0..height_map.max_x:
      for y in 0..height_map.max_y:
        if is_low_point((x, y), height_map):
          height_map.heights[(x, y)]
  echo low_points
  result = low_points.mapIt(it + 1).foldr(a + b)

proc solve_2(filename: string): int =
  let height_map = parse_height_map(filename)
  let low_points = collect:
    for x in 0..height_map.max_x:
      for y in 0..height_map.max_y:
        if is_low_point((x, y), height_map):
          (x, y)

  let basin_sizes = low_points.mapIt(walk_basin(it, height_map)).sorted
  echo basin_sizes
  result = basin_sizes[^3..^1].foldr(a * b)


echo solve_1("./inputs/day9/sample.txt")
echo solve_2("./inputs/day9/sample.txt")
echo solve_1("./inputs/day9/input.txt")
echo solve_2("./inputs/day9/input.txt")
