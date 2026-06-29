from itertools import combinations

def euler_characteristic(vertices, edges):
    """Reduced Euler characteristic of the clique complex: sum_k (-1)^k * (#(k+1)-cliques)."""
    edges = {frozenset(e) for e in edges}
    def is_clique(c):
        return all(frozenset((a, b)) in edges for a, b in combinations(c, 2))
    chi = 0
    for k in range(1, len(vertices) + 1):
        count = sum(1 for c in combinations(vertices, k) if is_clique(c))
        chi += (-1) ** (k - 1) * count
    return chi
