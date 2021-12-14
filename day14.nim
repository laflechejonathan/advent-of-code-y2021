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

type Polymer = tuple
  current: seq[char]
  insertion_rules: Table[(char, char), char]

proc parse(filename: string): Polymer =
  let f = open(filename)
  defer: f.close()

  let initial = toSeq(f.readLine())
  let discarded = f.readLine()
  var line: string
  var insertion_rules = initTable[(char, char), char]()
  while f.readLine(line):
    let parts = line.split(" -> ", 1)
    insertion_rules[(parts[0][0], parts[0][1])] = parts[1][0]
  
  return (initial, insertion_rules)

proc add_all(t1: var Table[char, int], t2: Table[char, int]): void =
  for key, value in t2:
    t1[key] = t1.getOrDefault(key, 0) + value

proc transform_polymer(
  a: char,
  b: char,
  rules: Table[(char, char), char],
  steps: int,
  memoization: var Table[(char, char, int), Table[char, int]]): Table[char, int] =
  if memoization.contains((a, b, steps)):
    return memoization[(a, b, steps)]
  elif steps == 0 or not rules.contains((a, b)):
    result[a] = result.getOrDefault(a, 0) + 1
    result[b] = result.getOrDefault(b, 0) + 1
  else:
    let inserted = rules[(a, b)]
    let r_a = transform_polymer(a, inserted, rules, steps - 1, memoization)
    let r_b = transform_polymer(inserted, b, rules, steps - 1, memoization)
    # merge two subtrees, don't double count inserted
    add_all(result, r_a)
    add_all(result, r_b)
    result[inserted] -= 1

  memoization[(a, b, steps)] = result

proc score(counts: Table[char, int]): int =
  return max(toSeq(counts.values)) - min(toSeq(counts.values))

proc solve(polymer: Polymer, steps: int): int =
  var counts = initTable[char, int]()
  var memo = initTable[(char, char, int), Table[char, int]]()
  for i in 0..<polymer.current.len-1:
    let pair_counts = transform_polymer(polymer.current[i], polymer.current[i + 1], polymer.insertion_rules, steps, memo)
    add_all(counts, pair_counts)

  # decrement all but the last character, since they're double-counted
  for c in polymer.current[1..^2]:
    counts[c] -= 1
  return score(counts)

proc solve_1(polymer: Polymer): int =
  return solve(polymer, 10)

proc solve_2(polymer: Polymer): int =
  return solve(polymer, 40)

echo solve_1(parse("./inputs/day14/sample.txt"))
echo solve_1(parse("./inputs/day14/input.txt"))
echo solve_2(parse("./inputs/day14/sample.txt"))
echo solve_2(parse("./inputs/day14/input.txt"))