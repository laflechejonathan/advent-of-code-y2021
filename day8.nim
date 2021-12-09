import strutils
import std/sequtils
import std/sugar
import std/strformat
import std/tables
import std/sets
import std/algorithm
import std/[strutils, math, threadpool]
{.experimental: "parallel".}

const numbers = {
  0: @['a', 'b', 'c', 'e', 'f', 'g'],
  1: @['c', 'f'],
  2: @['a', 'c', 'd', 'e', 'g'],
  3: @['a', 'c', 'd', 'f', 'g'],
  4: @['b', 'c', 'd', 'f'],
  5: @['a', 'b', 'd', 'f', 'g'],
  6: @['a', 'b', 'd', 'e', 'f', 'g'],
  7: @['a', 'c', 'f'],
  8: @['a', 'b', 'c', 'd', 'e', 'f', 'g'],
  9: @['a', 'b', 'c', 'd', 'f', 'g']
}.toTable
const number_sets = {
  toHashSet(@['a', 'b', 'c', 'e', 'f', 'g']): '0',
  toHashSet(@['c', 'f']): '1',
  toHashSet(@['a', 'c', 'd', 'e', 'g']): '2',
  toHashSet(@['a', 'c', 'd', 'f', 'g']): '3',
  toHashSet(@['b', 'c', 'd', 'f']): '4',
  toHashSet(@['a', 'b', 'd', 'f', 'g']): '5',
  toHashSet(@['a', 'b', 'd', 'e', 'f', 'g']): '6',
  toHashSet(@['a', 'c', 'f']): '7',
  toHashSet(@['a', 'b', 'c', 'd', 'e', 'f', 'g']): '8',
  toHashSet(@['a', 'b', 'c', 'd', 'f', 'g']): '9',
}.toTable

type InputLine = tuple
  unique_number_sets: seq[HashSet[char]]
  unique_numbers: seq[string]
  output: seq[string]

proc sorted_string(s: string): string = 
  let char_sequence = sorted(toSeq(s))
  result = char_sequence.join()

proc parse_input(line: string): InputLine =
  let parts = line.split(" | ", 1)
  let numbers = parts[0].split(" ").map(sorted_string)
  let number_sets = numbers.mapIt(toHashSet(it))
  let output = parts[1].split(" ").map(sorted_string)
  result = (number_sets, numbers, output)

proc parse(filename: string): seq[InputLine] = 
  let f = open(filename)
  defer: f.close()
  var line: string
  while f.readLine(line):
    result.add(parse_input(line))
  
proc solve_1(input: InputLine): int = 
  var candidates = initTable[int, seq[string]]()
  for i in 0..9:
    let possible: seq[string] = input.unique_numbers.filterIt(numbers[i].len == it.len)
    candidates[i] = possible
  
  let eight = candidates[8][0]
  let seven = candidates[7][0]
  let four = candidates[4][0]
  let one = candidates[1][0]
  let relevant = input.output.filterIt(it in [one, four, seven, eight])
  echo [seven, four, one], input.output, relevant
  result = relevant.len

proc decode_string(s: string, decoder: Table[char, char]): HashSet[char] =
  result = toHashSet(toSeq(s).mapIt(decoder[it]))

proc decode_number(s: string, decoder: Table[char, char]): char =
  result = number_sets[decode_string(s, decoder)]

proc test_decoding_table(input: InputLine, decoder: Table[char, char]): bool =
  let decoded = input.unique_numbers.mapIt(decode_string(it, decoder))
  let all_decoded = toHashSet(decoded)
  let canonical = toHashSet(toSeq(number_sets.keys))
  result = all_decoded == canonical

proc with_new_entry(decoder: Table[char, char], key: char, value: char): Table[char, char] =
  result = decoder
  result[key] = value

proc brute_force_decoding_table(input: InputLine, decoder: Table[char, char]): (bool, Table[char, char]) =
  result = (false, decoder)
  let remaining_values = toHashSet(toSeq('a'..'g')) - toHashSet(toSeq(decoder.values))
  var remaining_keys = toHashSet(toSeq('a'..'g')) - toHashSet(toSeq(decoder.keys))
  if remaining_keys.len == 0:
    result = (test_decoding_table(input, decoder), decoder)
  else:
    let k = remaining_keys.pop
    for v in remaining_values:
      let (works, new_decoder) = brute_force_decoding_table(input, with_new_entry(decoder, k, v))
      if works:
        result = (true, new_decoder)
        break


proc solve_line(line: InputLine): int = 
  let (works, decoder) = brute_force_decoding_table(line, initTable[char, char]())
  assert works
  result = parseInt(line.output.mapIt(decode_number(it, decoder)).mapIt(fmt"{it}").join)

proc solve_2(filename: string): int = 
  let lines = parse(filename)
  var solutions = newSeq[int](lines.len)
  parallel:
    for i in 0..<lines.len:
      solutions[i] = spawn solve_line(lines[i])

  echo solutions
  result = solutions.foldr(a + b)
  

echo solve_2("./inputs/day8/sample.txt")
echo solve_2("./inputs/day8/input.txt")