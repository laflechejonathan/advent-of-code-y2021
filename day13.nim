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

type FoldAxis = enum
  vertical = "fold along x",
  horizontal = "fold along y"

type Point = tuple
  x: int
  y: int

type FoldInstruction = tuple
  axis: FoldAxis
  value: int

type Paper = tuple
  points: HashSet[Point]
  folds: seq[FoldInstruction]

proc parse_paper(filename: string): Paper =
  let f = open(filename)
  defer: f.close()
  var line: string
  var points = initHashSet[Point]()
  while f.readLine(line):
    if not line.contains(','):
      break
    let parts = line.split(",", 1).map(parseInt)
    let x = parts[0]
    let y = parts[1]
    points.incl((x, y))
  
  var folds: seq[FoldInstruction] = @[]
  while f.readLine(line):
    let parts = line.split("=", 1)
    folds.add((parseEnum[FoldAxis](parts[0]), parseInt(parts[1])))
  
  return (points, folds)
  
proc fold_horizontal(fold_point_y: int, points: HashSet[Point]): HashSet[Point] =
  for pt in points:
    if pt.y < fold_point_y:
      result.incl(pt)
    else:
      let delta_from_fold_point = pt.y - fold_point_y
      let new_y = fold_point_y - delta_from_fold_point
      result.incl((pt.x, new_y))

proc fold_vertical(fold_point_x: int, points: HashSet[Point]): HashSet[Point] =
  for pt in points:
    if pt.x < fold_point_x:
      result.incl(pt)
    else:
      let delta_from_fold_point = pt.x - fold_point_x
      let new_x = fold_point_x - delta_from_fold_point
      result.incl((new_x, pt.y))

proc fold_one(paper: Paper): Paper =
  let fold = paper.folds[0]
  let new_points = case fold.axis:
    of vertical:
      fold_vertical(fold.value, paper.points)
    of horizontal:
      fold_horizontal(fold.value, paper.points)
  return (new_points, paper.folds[1..^1])

proc fold_all(paper: Paper): Paper =
  if paper.folds.len == 0:
    return paper
  else:
    fold_all(fold_one(paper))

proc print_paper(paper: Paper): void =
  let y_bound = max(toSeq(paper.points).mapIt(it.y))
  let x_bound = max(toSeq(paper.points).mapIt(it.x))
  for y in 0..y_bound:
    let line = collect:
      for x in 0..x_bound:
        if paper.points.contains((x, y)):
          "█"
        else:
          "."
    echo line.join
    

# Part 1
echo fold_one(parse_paper("./inputs/day13/sample.txt")).points.len
echo fold_one(parse_paper("./inputs/day13/input.txt")).points.len
# Part 2
echo "Sample:"
print_paper(fold_all(parse_paper("./inputs/day13/sample.txt")))
echo "Input:"
print_paper(fold_all(parse_paper("./inputs/day13/input.txt")))
