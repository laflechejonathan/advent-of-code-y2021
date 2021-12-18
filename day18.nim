import strutils
import std/sequtils
import std/sugar
import std/strformat
import std/tables
import std/sets
import std/algorithm
import std/deques
import std/options
import std/re
import std/math

type
  NodeType = enum
    intNode, nodeNode
  SnailFishNode = ref SnailFishNodeObj
  SnailFishNodeObj = object
    case kind: NodeType
    of intNode: value: int
    of nodeNode: left, right: SnailFishNode

proc `$`(node: SnailFishNode): string =
  return case node.kind
    of intNode: fmt"{node.value}"
    of nodeNode: fmt"[{node.left},{node.right}]"

proc do_parse(s: string, idx: int): (SnailFishNode, int) =
  var i = idx
  var left, right: SnailFishNode
  var digits: seq[string] = @[]

  while s[i] in '0'..'9':
    digits.add($s[i])
    i += 1
  if digits.len > 0:
    return (SnailFishNode(kind: intNode, value: parseInt(digits.join)), i)

  while s[i] != ']':
    if s[i] == '[':
      (left, i) = do_parse(s, i + 1)
    elif s[i] == ',':
      (right, i) = do_parse(s, i + 1)

  assert left != nil and right != nil
  return (SnailFishNode(kind: nodeNode, left: left, right: right), i + 1)

proc split_rec(node: SnailFishNode): (SnailFishNode, bool) =
  case node.kind:
    of intNode:
      if node.value >= 10:
        # If any regular number is 10 or greater, the leftmost such regular number splits
        let left = SnailFishNode(kind: intNode, value: int(floor(node.value / 2)))
        let right = SnailFishNode(kind: intNode, value: int(ceil(node.value / 2)))
        return (SnailFishNode(kind: nodeNode, left: left, right: right), true)
    of nodeNode:
      let (new_l, l_changed) = split_rec(node.left)
      if l_changed:
        return (SnailFishNode(kind: nodeNode, left: new_l, right: node.right), true)
      let (new_r, r_changed) = split_rec(node.right)
      if r_changed:
        return (SnailFishNode(kind: nodeNode, left: node.left, right: new_r), true)

  return (node, false)
    
type Explosion = object
  old_node: SnailFishNode
  new_node: SnailFishNode
  left_applied: bool
  right_applied: bool

proc new_explosion(node: SnailFishNode): Explosion =
  return Explosion(
    old_node: node,
    new_node: SnailFishNode(kind: intNode, value: 0),
    left_applied: false,
    right_applied: false)

proc r_applied(explosion: Explosion): Explosion = 
  return Explosion(
    old_node: explosion.old_node,
    new_node: explosion.new_node,
    left_applied: explosion.left_applied,
    right_applied: true)

proc l_applied(explosion: Explosion): Explosion = 
  return Explosion(
    old_node: explosion.old_node,
    new_node: explosion.new_node,
    left_applied: true,
    right_applied: explosion.right_applied)

proc add_l(node: SnailFishNode, val: int): SnailFishNode =
  return case node.kind:
    of intNode:
      SnailFishNode(kind: intNode, value: node.value + val)
    of nodeNode:
      SnailFishNode(kind: nodeNode, left: add_l(node.left, val), right: node.right)

proc add_r(node: SnailFishNode, val: int): SnailFishNode =
  return case node.kind:
    of intNode:
      SnailFishNode(kind: intNode, value: node.value + val)
    of nodeNode:
      SnailFishNode(kind: nodeNode, left: node.left, right:add_r(node.right, val))
      
proc apply_explosion_l(
  node: SnailFishNode,
  left: SnailFishNode,
  explosion: Explosion): (SnailFishNode, Explosion) =
  if explosion.right_applied:
    return (
      SnailFishNode(kind: nodeNode, left: left, right: node.right),
      explosion)
  else:
    let new_right = add_l(node.right, explosion.old_node.right.value)
    return (
      SnailFishNode(kind: nodeNode, left: left, right: new_right),
      r_applied(explosion))

proc apply_explosion_r(
  node: SnailFishNode,
  right: SnailFishNode,
  explosion: Explosion): (SnailFishNode, Explosion) =
  if explosion.left_applied:
    return (
      SnailFishNode(kind: nodeNode, left: node.left, right: right),
      explosion)
  else:
    let new_left = add_r(node.left, explosion.old_node.left.value)
    return (
        SnailFishNode(kind: nodeNode, left: new_left, right: right),
      l_applied(explosion))

proc explode_rec(node: SnailFishNode, depth: int): (SnailFishNode, Option[Explosion]) =
  case node.kind:
    of intNode:
      return (node, none(Explosion))
    of nodeNode:
      if depth == 4:
        let explosion = new_explosion(node)
        return (explosion.new_node, some(explosion))
      else:
        let (l, maybe_l_explosion) = explode_rec(node.left, depth + 1)
        if maybe_l_explosion.isSome:
          let (new_node, explosion) = apply_explosion_l(node, l, maybe_l_explosion.get())
          return (new_node, some(explosion))

        let (r, maybe_r_explosion) = explode_rec(node.right, depth + 1)
        if maybe_r_explosion.isSome:
          let (new_node, explosion) = apply_explosion_r(node, r, maybe_r_explosion.get())
          return (new_node, some(explosion))

        return (node, none(Explosion))
        
proc reduce(node: SnailFishNode): SnailFishNode =
  var curr = node
  var maybe_explosion: Option[Explosion]
  var maybe_split = true
  while maybe_split or maybe_explosion.isSome:
    (curr, maybe_explosion) = explode_rec(curr, 0)
    if maybe_explosion.isNone:
      (curr, maybe_split) = split_rec(curr)
  return curr
  
proc magnitude(node: SnailFishNode): int =
  return case node.kind:
    of intNode: node.value
    of nodeNode: (magnitude(node.left) * 3) + (magnitude(node.right) * 2)

proc parse(s: string): SnailFishNode =
  return do_parse(s, 0)[0]

proc `+`(a: SnailFishNode, b: SnailFishNode): SnailFishNode =
  let node = SnailFishNode(kind: nodeNode, left: (a), right: (b))
  result = reduce(node)

proc read_lines(filename: string): seq[string] =
  let f = open(filename)
  defer: f.close()
  var line: string
  while f.readLine(line):
    result.add(line)

proc solve_1(filename: string): int =
  let sum = read_lines(filename).map(parse).foldl(a + b)
  return magnitude(sum)

type Result = tuple
  i: int
  j: int
  magnitude: int
  node: SnailFishNode

proc `<`(a, b: Result): bool = a.magnitude < b.magnitude

proc solve_2(filename: string): int =
  let nodes = toSeq(toHashSet(read_lines(filename))).map(parse)
  let tuples = collect:
    for i in 0..<nodes.len:
      for j in 0..<nodes.len:
        if i != j:
          let added = nodes[i] + nodes[j]
          (i: i, j: j, magnitude: magnitude(added), node: added)
  return max(tuples).magnitude

echo solve_1("./inputs/day18/input.txt")
echo solve_2("./inputs/day18/input.txt")