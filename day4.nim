import strutils
import std/sequtils
import std/sugar
import std/strformat
import std/tables

type Turns = tuple
  numbers: seq[int]
  number_to_turn: Table[int, int]

type BingoCell = tuple
  value: int
  turn_marked: int

type
  BingoTable* = seq[seq[BingoCell]]

type Input = tuple
  turns: Turns
  bingoTables: seq[BingoTable]

proc print_table(table: BingoTable): void =
  for row in table:
    echo row.mapIt(fmt"{it.value}/{it.turn_marked}").join("\t")

proc parse_turns(line: string): Turns =
  let numbers = line.split(',').mapIt(parseInt(it))
  var turn_map = initTable[int, int]()
  for turn in 0 ..< numbers.len:
    let number: int = numbers[turn]
    turn_map[number] = turn
  result = (numbers, turn_map)

proc parse_bingo_row(line: string, turns: Turns): seq[BingoCell] = 
  # echo fmt"bingo row: {line.splitWhitespace()}"
  let numbers = line.splitWhitespace().mapIt(parseInt(it))
  assert(numbers.len == 5, fmt"{numbers}")
  result = numbers.mapIt((
    value: it,
    turn_marked: turns.number_to_turn.getOrDefault(it, low(int)))
  )

proc parse_bingo_table(lines: seq[string], turns: Turns): BingoTable =
  assert(lines.len == 5)
  result = lines.mapIt(parse_bingo_row(it, turns))

proc winning_turn(numbers: seq[BingoCell]): int =
  result = foldl(numbers, max(a, b.turn_marked), low(int))

proc get_winning_turn(table: BingoTable): int =
  result = high(int)
  for i in 0..4:
    let row_i = table[i]
    let col_i = collect(for j in 0..4: table[j][i])
    result = min(@[result, winning_turn(row_i), winning_turn(col_i)])

proc filter_unmarked(table: BingoTable, winning_turn: int): seq[BingoCell] =
  const empty: seq[BingoCell] = @[]
  let all_cells = foldl(table, a & b, empty)
  result = all_cells.filterIt(it.turn_marked > winning_turn)

proc read_input(filename: string): Input =
  let f = open(filename)
  defer: f.close()
  let turns = parse_turns(f.readLine())
  var line: string
  var bingo_tables: seq[BingoTable]
  var lines: seq[string]
  while f.readLine(line):
    if not line.isEmptyOrWhitespace():
      lines.add(line)
    if lines.len == 5:
      bingo_tables.add(parse_bingo_table(lines, turns))
      lines = @[]
  result = (turns, bingo_tables)


# build map of number -> turn count
# mark bingo numbers with turn count or -1
# find minimum turn count for filled row or column 
# find minimum board
# filter board to unmarked numbers, take sum, multiply with last called
proc solve_all(filename: string): void =
  let input = read_input(filename)
  var min_win = high(int)
  var min_win_table: BingoTable 
  var max_win = low(int)
  var max_win_table: BingoTable 
  for table in input.bingoTables:
    let win = get_winning_turn(table)
    if win < min_win:
      min_win = win
      min_win_table = table
    if win > max_win:
      max_win = win
      max_win_table = table

  let min_unmarked = filter_unmarked(min_win_table, min_win)
  let min_sum = foldl(min_unmarked, a + b.value, 0)
  let min_last_called = input.turns.numbers[min_win]
  echo "Part 1"
  echo fmt"winning bingo table at turn {min_win}, drawing {min_last_called}."
  echo fmt"{min_sum} * {min_last_called} = {min_sum * min_last_called}"
  echo "Part 2"
  let max_unmarked = filter_unmarked(max_win_table, max_win)
  let max_sum = foldl(max_unmarked, a + b.value, 0)
  let max_last_called = input.turns.numbers[max_win]
  echo fmt"winning bingo table at turn {max_win}, drawing {max_last_called}."
  echo fmt"{max_sum} * {max_last_called} = {max_sum * max_last_called}"



solve_all("./inputs/day4/sample.txt")
solve_all("./inputs/day4/input.txt")