def compute_tangling_degree(frame, world, memo=None):
    if memo is None: memo = {}
    if world in memo: return memo[world]
    succs = frame.successors(world)
    if not succs: memo[world] = 0; return 0
    result = max(compute_tangling_degree(frame, v, memo) for v in succs) + 1
    memo[world] = result
    return result