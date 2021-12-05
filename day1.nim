import strutils
import std/sequtils
import std/sugar


proc window_sum(numbers: seq[int], i: int): int =
    result = foldl(numbers[i..min(i+2, numbers.len - 1)], a + b, 0)

proc read_sequence(filename: string): seq[int] =
  let f = open(filename)
  defer: f.close()
  var line: string
  while f.readLine(line):
    result.add(parseInt(line))


proc count_increases(numbers: seq[int]): int =
    for i in 0 ..< numbers.len:
        if i > 0 and numbers[i] > numbers[i - 1]:
            result += 1


proc solve_1(filename: string): int =
  let sequence = read_sequence(filename)
  result = count_increases(sequence)

proc solve_2(filename: string): int =
    let sequence = read_sequence(filename)
    let windowed = collect(for i in 0 ..< sequence.len: window_sum(sequence, i))
    result = count_increases(windowed)
    

echo "Part 1"
echo solve_1("./inputs/day1/sample.txt")
echo solve_1("./inputs/day1/input.txt")
echo "Part 2"
echo solve_2("./inputs/day1/sample.txt")
echo solve_2("./inputs/day1/input.txt")



