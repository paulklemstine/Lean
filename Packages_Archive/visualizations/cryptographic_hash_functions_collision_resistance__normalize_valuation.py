def normalize_valuation(v, universe):
    counts = {}
    for x in universe:
        counts[x] = sum(1 for y in universe if v(y) < v(x))
    return lambda x: counts[x]