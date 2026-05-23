import math

def pythagorean_edges(n):
    """Construct Pythagorean triple hypergraph on {1,...,n}."""
    edges = set()
    for a in range(1, n + 1):
        for b in range(a + 1, n + 1):
            c_sq = a * a + b * b
            c = int(math.isqrt(c_sq))
            if c * c == c_sq and c <= n and c > b:
                edges.add(frozenset({a, b, c}))
    return edges

# Example
edges = pythagorean_edges(50)
print(f"H_50 has {len(edges)} edges")
for e in sorted(sorted(x) for x in edges):
    print(f"  {e}")
