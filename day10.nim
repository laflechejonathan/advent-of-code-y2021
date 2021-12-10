import strutils
import std/sequtils
import std/sugar
import std/strformat
import std/tables
import std/sets
import std/algorithm
import std/deques
import std/options

const open_to_close = {
  '[': ']',
  '{': '}',
  '(': ')',
  '<': '>',
}.toTable

const scores = {
  ')': 3,
  ']': 57,
  '}': 1197,
  '>': 25137,
}.toTable

const scores_2 = {
  ')': 1,
  ']': 2,
  '}': 3,
  '>': 4,
}.toTable

proc parse_input(filename: string): seq[string] =
  let f = open(filename)
  defer: f.close()
  var line: string
  while f.readLine(line):
    result.add(line)

proc check_syntax(line: string): char =
  var stack = initDeque[char]()
  var bad_char = '?'
  for c in line:
    if c in ['[', '{', '<', '(']:
      stack.addFirst(c)
    elif c in [']', '}', '>', ')']:
      if (open_to_close[stack.popFirst()] != c):
        bad_char = c
        break
    else:
      assert false

  result = bad_char

proc autocomplete(line: string): seq[char]  =
  var stack = initDeque[char]()
  var is_valid = true
  for c in line:
    if c in ['[', '{', '<', '(']:
      stack.addFirst(c)
    elif c in [']', '}', '>', ')']:
      if (open_to_close[stack.popFirst()] != c):
        is_valid = false
        break
    else:
      assert false

  if is_valid:
    result = collect:
      for c in stack:
        open_to_close[c]

proc score_autocomplete(completion: seq[char]): int =
  result = 0
  for c in completion:
    result *= 5
    result += scores_2[c]

proc solve_1(filename: string): int =
  let lines = parse_input(filename)
  result = lines.map(check_syntax).mapIt(scores.getOrDefault(it, 0)).foldr(a + b)

proc solve_2(filename: string): int =
  let lines = parse_input(filename)
  let scores = sorted(lines.map(autocomplete).filterIt(it.len > 0).map(score_autocomplete))
  let index = (int) scores.len / 2
  result = scores[index]

echo solve_1("./inputs/day10/sample.txt")
echo solve_1("./inputs/day10/input.txt")
echo solve_2("./inputs/day10/sample.txt")
echo solve_2("./inputs/day10/input.txt")