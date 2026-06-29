from typing import Callable, Dict, List, Tuple

Dissimilarity = Callable[[int, int], float]


class UnionFind:
    def __init__(self, n: int) -> None:
        self.parent: List[int] = list(range(n))
        self.rank: List[int] = [0] * n

    def find(self, a: int) -> int:
        while self.parent[a] != a:
            self.parent[a] = self.parent[self.parent[a]]
            a = self.parent[a]
        return a

    def union(self, a: int, b: int) -> bool:
        ra, rb = self.find(a), self.find(b)
        if ra == rb:
            return False
        if self.rank[ra] < self.rank[rb]:
            ra, rb = rb, ra
        self.parent[rb] = ra
        if self.rank[ra] == self.rank[rb]:
            self.rank[ra] += 1
        return True


def single_linkage_mst(n: int, d: Dissimilarity) -> Dict[Tuple[int, int], float]:
    """Full merge-scale table via Kruskal on the symmetrized dissimilarity."""
    edges: List[Tuple[float, int, int]] = []
    for a in range(n):
        for b in range(a + 1, n):
            w = min(float(d(a, b)), float(d(b, a)))
            edges.append((w, a, b))
    edges.sort()

    uf = UnionFind(n)
    members: Dict[int, List[int]] = {i: [i] for i in range(n)}
    thr: Dict[Tuple[int, int], float] = {}
    for w, a, b in edges:
        ra, rb = uf.find(a), uf.find(b)
        if ra == rb:
            continue
        for u in members[ra]:
            for v in members[rb]:
                key = (u, v) if u < v else (v, u)
                thr[key] = w
        uf.union(a, b)
        root = uf.find(a)
        members[root] = members[ra] + members[rb]
    return thr
