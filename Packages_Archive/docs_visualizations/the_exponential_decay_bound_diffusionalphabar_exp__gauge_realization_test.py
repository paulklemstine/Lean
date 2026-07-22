def is_gauge_realizable(cl, universe):
    from itertools import combinations
    subsets = [frozenset()]
    for r in range(1, len(universe)+1):
        for c in combinations(universe, r):
            subsets.append(frozenset(c))
    closed = [s for s in subsets if cl(s) == s]
    for i, s in enumerate(closed):
        for t in closed[i+1:]:
            if not (s <= t or t <= s):
                return False
    return True