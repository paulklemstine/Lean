def normalize_valuation(v):
    elements = list(v.keys())
    return {x: sum(1 for y in elements if v[y] < v[x]) for x in elements}