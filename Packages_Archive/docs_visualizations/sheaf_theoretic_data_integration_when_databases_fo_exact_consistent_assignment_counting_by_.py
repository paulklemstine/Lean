from typing import Iterable, Tuple

def consistency_count(n: int, edges: Iterable[Tuple[int, int]], q: int) -> tuple[int, float]:
    parent = list(range(n))
    def find(x: int) -> int:
        if parent[x] != x:
            parent[x] = find(parent[x])
        return parent[x]
    for a, b in edges:
        a, b = find(a), find(b)
        if a != b:
            parent[b] = a
    c = len({find(i) for i in range(n)})
    count = q ** c
    return count, count / (q ** n)
