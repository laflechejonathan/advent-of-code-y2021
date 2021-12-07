import strutils
import std/sequtils
import std/sugar
import std/strformat
import std/tables

proc parse_crabs(filename: string) : seq[int] = 
  let f = open(filename)
  defer: f.close()
  result = f.readLine().split(",").map(parseInt)

proc cost(a: int, b: int): int =
  let steps = abs(a - b)
  result = (int) (steps * (steps + 1)) / 2

proc evaluate_alignment_candidate(crabs: seq[int], position: int): int =
  result = crabs.mapIt(cost(position, it)).foldl(a + b)

proc find_best_alignment(crabs: seq[int]): int =
  let full_range = toSeq(min(crabs)..max(crabs))
  result = min(full_range.mapIt(evaluate_alignment_candidate(crabs, it)))
    
echo find_best_alignment(parse_crabs("./inputs/day7/sample.txt"))
echo find_best_alignment(parse_crabs("./inputs/day7/input.txt"))