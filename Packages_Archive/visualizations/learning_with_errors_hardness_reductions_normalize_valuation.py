def normalize_valuation(v):
    keys = list(v.keys())
    return {x: sum(1 for y in keys if v[y] < v[x]) for x in keys}