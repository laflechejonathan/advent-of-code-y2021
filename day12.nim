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

type CaveSize = enum
    small, big

type Cave = tuple
  value: string
  size: CaveSize

type Node = tuple
  cave: Cave
  reachable_caves: HashSet[Node]

proc parse_cave(cave_name: string): Cave =
  let size = if match(cave_name, re"[A-Z]+"): big else: small
  return (cave_name, size)

proc parse_line(line: string): (Cave, Cave) =
  let split = line.split("-", 1)
  return (parse_cave(split[0]), parse_cave(split[1]))

proc parse_graph(filename: string): Table[Cave, HashSet[Cave]] =
  let f = open(filename)
  defer: f.close()
  var line: string
  while f.readLine(line):
    let (a, b) = parse_line(line)
    var a_set: HashSet[Cave] = result.getOrDefault(a, initHashSet[Cave]())
    a_set.incl(b)
    result[a] = a_set
    var b_set: HashSet[Cave] = result.getOrDefault(b, initHashSet[Cave]())
    b_set.incl(a)
    result[b] = b_set

proc can_revisit_small(caves: seq[Cave], next_cave: Cave): bool =
  let smalls = caves.filterIt(it.size == small)
  let small_set = toHashSet(smalls)
  if not small_set.contains(next_cave):
    return true
  elif next_cave.value == "start":
    return false
  else:
    return smalls.len == small_set.len

proc is_legal_move(caves: seq[Cave], next_cave: Cave): bool =
  return
    next_cave.size == big or can_revisit_small(caves, next_cave)

proc to_string(caves: seq[Cave]): string = 
  return caves.mapIt(it.value).join(",")

proc explore_caves(map: Table[Cave, HashSet[Cave]]): seq[seq[Cave]] =
  let start_cave = parse_cave("start")
  let end_cave = parse_cave("end")
  var candidates = initDeque[seq[Cave]]()
  candidates.addFirst(@[start_cave])
  while candidates.len > 0:
    let current_path = candidates.popFirst()
    let current = current_path[^1]
    if current == end_cave:
      result.add(current_path)
    else:
      for next_cave in map[current]:
        if is_legal_move(current_path, next_cave):
          candidates.addLast(current_path & next_cave)

echo explore_caves(parse_graph("./inputs/day12/sample-1.txt")).len
echo explore_caves(parse_graph("./inputs/day12/sample-2.txt")).len
echo explore_caves(parse_graph("./inputs/day12/sample-3.txt")).len
echo explore_caves(parse_graph("./inputs/day12/input.txt")).len
