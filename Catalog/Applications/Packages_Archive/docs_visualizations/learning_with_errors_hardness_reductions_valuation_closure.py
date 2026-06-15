def valuation_closure(v, universe, s):
    if not s:
        sup_val = 0
    else:
        sup_val = max(v[x] for x in s)
    return frozenset(x for x in universe if v[x] <= sup_val)