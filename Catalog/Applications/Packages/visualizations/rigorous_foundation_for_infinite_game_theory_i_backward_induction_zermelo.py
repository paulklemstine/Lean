def solve(node):
  if node.is_leaf: return node.value
  results = [solve(c) for c in node.children]
  return any(results) if node.player == 0 else all(results)