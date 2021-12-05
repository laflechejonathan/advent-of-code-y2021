import strutils
import std/sequtils
import std/sugar
import std/strformat

type Counts = tuple
  zeroes: int
  ones: int

type Rates = tuple
  gamma: int
  epsilon: int

proc get_epsilon(counts: Counts): char =
  result = if counts.zeroes > counts.ones: '0' else: '1'

proc get_gamma(counts: Counts): char =
  result = if counts.zeroes > counts.ones: '1' else: '0'

proc get_oxygen_rating(counts: Counts): char =
  result =  if counts.ones >= counts.zeroes: '1' else: '0'

proc get_co2_rating(counts: Counts): char =
  result =  if counts.zeroes <= counts.ones: '0' else: '1'

proc str(chars: seq[char]): string =
  result = chars.mapIt($it).join

proc get_bin_counts(i: int, binary_strings: seq[string]): Counts =
  let zeroes = binary_strings.filterIt(it[i] == '0').len
  let ones = binary_strings.filterIt(it[i] == '1').len
  result = (zeroes, ones)

proc get_rates(binary_strings: seq[string]): Rates =
  assert(binary_strings.len > 0)
  let length = binary_strings[0].len
  let counts = collect(for i in 0 ..< length: get_bin_counts(i, binary_strings))
  let gamma = parseBinInt(str(counts.map(get_gamma)))
  let epsilon = parseBinInt(str(counts.map(get_epsilon)))
  result = (gamma, epsilon)
  
proc filter_ratings(binary_strings: seq[string], rating_calculation: (Counts) -> char, index: int): int =
  # echo fmt"index: {index}, {binary_strings}"
  assert(binary_strings.len > 0)
  if binary_strings.len == 1:
    result = parseBinInt(binary_strings[0])
  else:
    assert(index < binary_strings[0].len)
    let counts = get_bin_counts(index, binary_strings)
    let rating = rating_calculation(counts)
    let filtered_strings = binary_strings.filterIt(it[index] == rating)
    result = filter_ratings(filtered_strings, rating_calculation, index + 1)

proc read_bin_strings(filename: string): seq[string] =
  let f = open(filename)
  defer: f.close()
  var line: string
  while f.readLine(line):
    result.add(line)

proc solve_1(filename: string): void =
  let rates = get_rates(read_bin_strings(filename))
  echo fmt"gamma: {rates.gamma} epsilon: {rates.epsilon} power: {rates.gamma * rates.epsilon}"

proc solve_2(filename: string): void =
  let binaries = read_bin_strings(filename)
  # echo "oxygen"
  let oxygen = filter_ratings(binaries, get_oxygen_rating, 0)
  # echo "co2"
  let co2 = filter_ratings(binaries, get_co2_rating, 0)
  echo fmt"oxygen: {oxygen} co2: {co2} life support: {oxygen * co2}"

echo "Part 1"
solve_1("./inputs/day3/sample.txt")
solve_1("./inputs/day3/input.txt")
echo "Part 2"
solve_2("./inputs/day3/sample.txt")
solve_2("./inputs/day3/input.txt")