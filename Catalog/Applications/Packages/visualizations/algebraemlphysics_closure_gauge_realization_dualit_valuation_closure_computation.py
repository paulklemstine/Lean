def valuation_closure(v, S, universe):
    sup_val = max((v[s] for s in S), default=0)
    return frozenset(x for x in universe if v[x] <= sup_val)