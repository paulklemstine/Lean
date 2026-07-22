def valuation_closure(v, S, universe):
    threshold = max((v(x) for x in S), default=0)
    return frozenset(x for x in universe if v(x) <= threshold)