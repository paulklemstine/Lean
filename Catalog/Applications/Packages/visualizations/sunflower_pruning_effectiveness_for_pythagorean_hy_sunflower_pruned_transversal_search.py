import math
from itertools import combinations

def pythagorean_edges(n):
    edges = set()
    for a in range(1, n + 1):
        for b in range(a + 1, n + 1):
            c_sq = a * a + b * b
            c = int(math.isqrt(c_sq))
            if c * c == c_sq and c <= n and c > b:
                edges.add(frozenset({a, b, c}))
    return edges

def vertex_degree(edges, v):
    return sum(1 for e in edges if v in e)

def find_sunflower(edges, min_petals):
    edge_list = list(edges)
    for v in sorted(set().union(*edges), key=lambda x: -vertex_degree(edges, x)):
        incident = [e for e in edge_list if v in e]
        if len(incident) < min_petals:
            continue
        sunflower = []
        used = set()
        for e in incident:
            petal = e - {v}
            if not petal & used:
                sunflower.append(e)
                used |= petal
                if len(sunflower) >= min_petals:
                    return sunflower, frozenset({v})
    return None

calls = 0

def sunflower_search(edges, current, k):
    global calls
    calls += 1
    remaining = [e for e in edges if not (e & current)]
    if not remaining:
        return set(current)
    if k == 0:
        return None
    sf = find_sunflower(set(frozenset(e) for e in remaining), k + 1)
    if sf:
        sf_edges, kernel = sf
        for v in sorted(kernel):
            current.add(v)
            result = sunflower_search(remaining, current, k - 1)
            if result is not None:
                return result
            current.discard(v)
        return None
    else:
        uncovered = remaining[0]
        for v in sorted(uncovered):
            current.add(v)
            result = sunflower_search(remaining, current, k - 1)
            if result is not None:
                return result
            current.discard(v)
        return None

# Example
edges = pythagorean_edges(50)
calls = 0
result = sunflower_search(list(edges), set(), 10)
print(f"Hitting set: {sorted(result) if result else None}")
print(f"Recursive calls: {calls}")
