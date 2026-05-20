import math
from itertools import product

def graph_colorings_count(n_vertices, edges, q):
    count = 0
    for coloring in product(range(q), repeat=n_vertices):
        proper = all(coloring[u] != coloring[v] for u, v in edges)
        if proper:
            count += 1
    return count

# Path graph example
for n in range(2, 10):
    edges = [(i, i+1) for i in range(n-1)]
    c = graph_colorings_count(n, edges, 3)
    exact = 3 * 2**(n-1)
    print(f"P_{n}: {c} colorings (formula: {exact}), H={math.log2(c):.2f}")