def link_coloring(coloring, vertex, n, r):
    from itertools import combinations
    link = {}
    others = [i for i in range(n) if i != vertex]
    for subset in combinations(others, r):
        key = frozenset(subset)
        key_orig = frozenset(subset) | {vertex}
        link[key] = coloring.get(key_orig, 0)
    return link