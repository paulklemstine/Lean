def realize_from_chain(cl_fn, universe):
    """Construct a gauge valuation realizing a closure with chain closed sets.
    v(x) = |cl({x})| - |cl(empty)|
    """
    baseline = len(cl_fn(frozenset()))
    v = {x: len(cl_fn(frozenset([x]))) - baseline for x in universe}
    return v

def verify_realization(v, cl_fn, universe):
    """Verify that cl_v matches cl_fn on all subsets."""
    from itertools import combinations
    for r in range(len(universe) + 1):
        for combo in combinations(universe, r):
            s = frozenset(combo)
            threshold = max((v[x] for x in s), default=0)
            cl_v_s = frozenset(x for x in universe if v[x] <= threshold)
            if cl_v_s != cl_fn(s):
                return False
    return True
