def is_realizable(cl, universe):
    closed = [s for s in powerset(universe) if cl(s) == s]
    for i, s in enumerate(closed):
        for t in closed[i+1:]:
            if not (s <= t or t <= s):
                return False
    return True