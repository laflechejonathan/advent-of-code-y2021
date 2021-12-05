import strutils
import std/sequtils
import std/sugar

type
  Instruction = enum
    forward = "forward", down = "down", up = "up"

type Command = tuple
  instruction: Instruction
  amount: int

type Position = tuple
  horizontal: int
  depth: int

type State = tuple
  horizontal: int
  depth: int
  aim: int

proc parse_instruction(line: string): Command =
  let words = line.split(' ', 2)
  result = (
    instruction: parseEnum[Instruction](words[0]),
    amount: parseInt(words[1]))

proc read_commands(filename: string): seq[Command] =
  let f = open(filename)
  defer: f.close()
  var line: string
  while f.readLine(line):
    result.add(parse_instruction(line))

proc chart_course_1(filename: string): Position =
  result = (0, 0)
  for command in read_commands(filename):
    case command.instruction
      of forward:
        result = (result.horizontal + command.amount, result.depth)
      of up:
        result = (result.horizontal, result.depth - command.amount)
      of down:
        result = (result.horizontal, result.depth + command.amount)

proc chart_course_2(filename: string): State =
  result = (0, 0, 0)
  for command in read_commands(filename):
    case command.instruction
      of forward:
        result = (result.horizontal + command.amount, result.depth + (result.aim * command.amount), result.aim)
      of up:
        result = (result.horizontal, result.depth, result.aim - command.amount)
      of down:
        result = (result.horizontal, result.depth, result.aim + command.amount)


proc solve_1(filename: string): int =
  let pos = chart_course_1(filename)
  result = pos.horizontal * pos.depth

proc solve_2(filename: string): int =
  let pos = chart_course_2(filename)
  result = pos.horizontal * pos.depth


echo "Part 1"
echo solve_1("./inputs/day2/sample.txt")
echo solve_1("./inputs/day2/input.txt")
echo "Part 2"
echo solve_2("./inputs/day2/sample.txt")
echo solve_2("./inputs/day2/input.txt")