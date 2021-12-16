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


type PacketType = enum
  sum = 0,
  product = 1,
  min = 2,
  max = 3,
  literal = 4,
  gt = 5,
  lt = 6,
  eq = 7,

type LengthType = enum
  total_len, num_packets
  
type SubPacketLength = tuple
  mode: LengthType
  value: int

proc to_bin(hex: string): string =
  let elements = collect:
    for c in hex:
      toBin(parseHexInt(fmt"{c}"), 4)
  result = elements.mapIt(fmt"{it}").join

proc version(code: string, idx: int): int =
  # Every packet begins with a standard header:
  # the first three bits encode the packet version,
  return parseBinInt(code[idx..<idx + 3])

proc packet_type(code: string, idx: int): PacketType =
  # and the next three bits encode the packet type ID.
  let packet_type = parseBinInt(code[idx + 3..<idx + 6])
  for t in sum..eq:
    if ord(t) == packet_type:
      return t


proc parse_literal(code: string, idx: int): (int, int) =
  # Literal value packets encode a single binary number.
  # The binary number is padded with leading zeroes until
  # its length is a multiple of four bits, and then it is
  # broken into groups of four bits.
  # Each group is prefixed by a 1 bit except the last group,
  # which is prefixed by a 0 bit. These groups of five bits
  # immediately follow the packet header.
  var chunks: seq[string] = @[]
  var cursor = idx + 6
  while true:
    let end_sentinel = code[cursor]
    chunks.add(code[cursor + 1..<cursor + 5])
    cursor += 5
    if end_sentinel == '0':
      break
  return (cursor, parseBinInt(chunks.join))

proc subpacket_length(code: string, idx: int): (int, SubPacketLength) =
  # to indicate which subsequent binary data represents its sub-packets,
  # an operator packet can use one of two modes indicated by the bit
  # immediately after the packet header; this is called the length type ID
  if code[idx + 6] == '0':
    # If the length type ID is 0, then the next 15 bits are a number
    # that represents the total length in bits of the sub-packets contained by this packet.
    let len_start = idx + 7
    let len_end = len_start + 15
    let value = parseBinInt(code[len_start..<len_end])
    return (len_end, (total_len, value))
  else:
    # If the length type ID is 1, then the next 11 bits are a number that
    # represents the number of sub-packets immediately contained by this packet.
    let len_start = idx + 7
    let len_end = len_start + 11
    let value = parseBinInt(code[len_start..<len_end])
    return (len_end, (num_packets, value))

type ParseResult = tuple
  cursor: int
  result: int

proc subpackets(code: string, cursor: int, subpackets: SubPacketLength, solve: (string, int) -> ParseResult): (int, seq[ParseResult]) =
  var next_cursor = cursor
  var results: seq[ParseResult] = @[]
  case subpackets.mode
    of total_len:
      let end_cursor = cursor + subpackets.value
      while next_cursor < end_cursor:
        results.add(solve(code, next_cursor))
        next_cursor = results[^1][0]
    of num_packets:
      for i in 1..subpackets.value:
        results.add(solve(code, next_cursor))
        next_cursor = results[^1][0]

  return (next_cursor, results)

proc solve_1(code: string, cursor: int): ParseResult =
  let version_num = version(code, cursor)
  let type_id = packet_type(code, cursor)
  if type_id == literal:
    var (next_cursor, value) = parse_literal(code, cursor)
    return (next_cursor, version_num)
  else:
    var sub_results: seq[ParseResult]
    var (next_cursor, subpackets) = subpacket_length(code, cursor)
    (next_cursor, subresults) = subpackets(code, next_cursor, subpackets, solve_1)
    let versions_sum = version_num + sub_results.mapIt(it[1]).foldl(a + b)
    return (next_cursor, versions_sum)

proc solve_2(code: string, cursor: int): ParseResult =
  let type_id = packet_type(code, cursor)
  if type_id == literal:
    return parse_literal(code, cursor)
  else:
    var sub_results: seq[ParseResult]
    var (next_cursor, subpackets) = subpacket_length(code, cursor)
    (next_cursor, subresults) = subpackets(code, next_cursor, subpackets, solve_2)
    let subvalues = subresults.mapIt(it[1])
    let value: int = case type_id:
      of sum:
        subvalues.foldl(a + b)
      of product:
        subvalues.foldl(a * b)
      of min:
        min(subvalues)
      of max:
        max(subvalues)
      of gt:
        if subvalues[0] > subvalues[1]: 1 else: 0
      of lt:
        if subvalues[0] < subvalues[1]: 1 else: 0
      of eq:
        if subvalues[0] == subvalues[1]: 1 else: 0
      else:
        raise newException(ValueError, "impossible")

    return (next_cursor, value)


echo "Part 1"
echo solve_1(to_bin("D2FE28"), 0)
echo solve_1(to_bin("8A004A801A8002F478"), 0)
echo solve_1(to_bin("C0015000016115A2E0802F182340"), 0)
echo solve_1(to_bin("A0016C880162017C3686B18A3D4780"), 0)
echo solve_1(to_bin(open("./inputs/day16/input.txt").readLine()), 0)

echo "Part 2"
echo solve_2(to_bin("C200B40A82"), 0)
echo solve_2(to_bin("CE00C43D881120"), 0)
echo solve_2(to_bin(open("./inputs/day16/input.txt").readLine()), 0)