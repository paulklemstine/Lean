from typing import Iterable, List, Tuple

def components(n: int, edges: Iterable[Tuple[int, int]]) -> List[List[int]]:
    parent = list(range(n))
    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    for a, b in edges:
        a, b = find(a), find(b)
        if a != b:
            parent[b] = a
    groups: dict[int, list[int]] = {}
    for x in range(n):
        groups.setdefault(find(x), []).append(x)
    return list(groups.values())
