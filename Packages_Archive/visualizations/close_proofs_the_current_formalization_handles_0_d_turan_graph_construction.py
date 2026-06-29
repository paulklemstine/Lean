from itertools import combinations

def turan_graph(n: int, p: int) -> set[frozenset[int]]:
    assert p >= 1
    return {frozenset((u, v)) for u, v in combinations(range(n), 2)
            if u % p != v % p}
