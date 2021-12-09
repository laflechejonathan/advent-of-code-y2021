import strutils
import std/sequtils
import std/sugar
import std/strformat
import std/tables
import std/sets
import std/algorithm
import nimprof

const canonical_strings_set = toHashSet(@[
  "abcefg",
  "cf",
  "acdeg",
  "acdfg",
  "bcdf",
  "abdfg",
  "abdefg",
  "acf",
  "abcdefg",
  "abcdfg",
])
const canonical_strings_table = {
  "abcefg": '0',
  "cf": '1',
  "acdeg": '2',
  "acdfg": '3',
  "bcdf": '4',
  "abdfg": '5',
  "abdefg": '6',
  "acf": '7',
  "abcdefg": '8',
  "abcdfg": '9',
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
  
proc decode_string(s: string, decoder: seq[char]): string =
  var decoding_table = initTable[char, char]()
  for (letter_k, letter_v) in zip(toSeq('a'..'g'), decoder):
    decoding_table[letter_k] = letter_v
  result = sorted(toSeq(s).mapIt(fmt"{decoding_table[it]}")).join

proc decode_number(s: string, decoder: seq[char]): char =
  let decoded = decode_string(s, decoder)
  result = canonical_strings_table[decoded]

proc is_valid(input: InputLine, decoder: seq[char]): bool =
  let decoded = input.unique_numbers.mapIt(decode_string(it, decoder))
  let all_decoded = toHashSet(decoded)
  result = all_decoded == canonical_strings_set

proc brute_force_decoding_key(input: InputLine): seq[char] =
  var decoding_key = @['a', 'b', 'c', 'd', 'e', 'f', 'g']
  result = @[]
  while decoding_key.nextPermutation():
    if is_valid(input, decoding_key):
      result = decoding_key
      break
  assert result.len > 0

proc solve_line(line: InputLine): int = 
  let decoder = brute_force_decoding_key(line)
  result = parseInt(line.output.mapIt(decode_number(it, decoder)).mapIt(fmt"{it}").join)

proc solve_2(filename: string): int = 
  let lines = parse(filename)
  var solutions = newSeq[int](lines.len)
  for i in 0..<lines.len:
    solutions[i] = solve_line(lines[i])

  echo solutions
  result = solutions.foldr(a + b)
  
echo solve_2("./inputs/day8/sample.txt")
echo solve_2("./inputs/day8/input.txt")