"""Plot the number of colours used by a proper colouring versus graph density,
comparing greedy colourings of random graphs to the maximum degree Delta."""
from __future__ import annotations
import random
from collections import defaultdict
from typing import Dict, FrozenSet, List, Set, Tuple
import matplotlib.pyplot as plt

Edge = FrozenSet[int]


def er(n: int, p: float, seed: int) -> Set[Edge]:
    rng = random.Random(seed)
    return {frozenset((u, v)) for u in range(n) for v in range(u + 1, n)
            if rng.random() < p}


def greedy(edges: Set[Edge]) -> Dict[Edge, int]:
    col: Dict[Edge, int] = {}
    inc: Dict[int, Set[int]] = defaultdict(set)
    for e in sorted(edges, key=lambda f: sorted(f)):
        a, b = tuple(e)
        c = 0
        while c in inc[a] | inc[b]:
            c += 1
        col[e] = c; inc[a].add(c); inc[b].add(c)
    return col


def max_degree(edges: Set[Edge]) -> int:
    deg: Dict[int, int] = defaultdict(int)
    for e in edges:
        a, b = tuple(e)
        deg[a] += 1; deg[b] += 1
    return max(deg.values()) if deg else 0


def main() -> None:
    n = 30
    ps: List[float] = [i / 20 for i in range(1, 20)]
    used: List[float] = []
    deltas: List[float] = []
    for p in ps:
        edges = er(n, p, seed=7)
        used.append(len(set(greedy(edges).values())))
        deltas.append(max_degree(edges))
    plt.plot(ps, used, "o-", label="colours used (greedy)")
    plt.plot(ps, deltas, "s--", label="max degree Delta")
    plt.xlabel("edge probability p"); plt.ylabel("count")
    plt.title(f"Proper colouring of G({n}, p): colours vs. Delta")
    plt.legend(); plt.tight_layout(); plt.savefig("colour_count.png", dpi=140)
    print("wrote colour_count.png")


if __name__ == "__main__":
    main()
