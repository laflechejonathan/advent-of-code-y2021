import strutils
import std/sequtils
import std/sugar
import std/strformat
import std/tables

type Point = tuple
  x: int
  y: int

type Line = tuple
  start: Point
  endpoint: Point

proc parse_point(point: string): Point = 
  let split = point.split(",", 1).map(parseInt)
  assert split.len == 2
  result = (split[0], split[1])

proc parse_line(line: string): Line =
  let split = line.split(" -> ", 1).map(parse_point)
  assert split.len == 2
  result = (split[0], split[1])

proc is_horizontal(line: Line): bool =
  result = line.start.y == line.endpoint.y

proc is_vertical(line: Line): bool =
  result = line.start.x == line.endpoint.x

proc is_diagonal(line: Line): bool =
  result = abs(line.start.x - line.endpoint.x) == abs(line.start.y - line.endpoint.y)

proc is_straight_line(line: Line): bool =
  result = is_horizontal(line) or is_vertical(line) or is_diagonal(line)

proc range(a: int, b: int): seq[int] =
  result = collect:
    if a < b:
      for i in countup(a, b):
        i
    elif a > b:
      for i in countdown(a, b):
        i
  
proc point_span(line: Line): seq[Point] =
  if is_horizontal(line):
    result = collect(for i in range(line.start.x, line.endpoint.x): (i, line.start.y))
  elif is_vertical(line):
    result = collect(for i in range(line.start.y, line.endpoint.y): (line.start.x, i))
  elif is_diagonal(line):
    result = collect:
      for pt in zip(range(line.start.x, line.endpoint.x), range(line.start.y, line.endpoint.y)):
        (pt[0], pt[1])
  else:
    assert false

proc read_lines(filename: string): seq[Line] =
  let f = open(filename)
  defer: f.close()
  var line: string
  while f.readLine(line):
    result.add(parse_line(line))

proc print_table(table: Table[Point, int]): void =
  for y in 0..10:
    let line = collect:
      for x in 0..10:
        if table.contains((x, y)): intToStr(table[(x, y)]) else: "."
    echo line.join
        
proc solve_2(filename: string): int =
  let all_points = read_lines(filename)
    .filter(is_straight_line)
    .map(point_span)
    .foldl(a & b)

  var table = initTable[Point, int]()
  for pt in all_points:
    let current = table.getOrDefault(pt, 0)
    table[pt] = current + 1

  let dangerous_points = collect:
    for pt, count in table.pairs:
      if count >= 2: pt

  # print_table(table)
  result = dangerous_points.len


echo solve_2("./inputs/day5/sample.txt")
echo solve_2("./inputs/day5/input.txt")