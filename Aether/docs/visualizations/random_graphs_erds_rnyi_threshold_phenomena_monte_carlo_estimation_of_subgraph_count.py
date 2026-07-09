from __future__ import annotations
import random
from itertools import combinations
from typing import Dict, List, Tuple


def sample_graph(n: int, p: float, rng: random.Random) -> List[Tuple[int, int]]:
    return [(i, j) for i, j in combinations(range(n), 2) if rng.random() < p]


def count_isolated(n: int, edges: List[Tuple[int, int]]) -> int:
    touched = set()
    for i, j in edges:
        touched.add(i); touched.add(j)
    return n - len(touched)


def count_triangles(n: int, edges: List[Tuple[int, int]]) -> int:
    adj = {v: set() for v in range(n)}
    for i, j in edges:
        adj[i].add(j); adj[j].add(i)
    return sum(1 for a, b, c in combinations(range(n), 3)
               if b in adj[a] and c in adj[a] and c in adj[b])


def monte_carlo_means(n: int, p: float, trials: int, seed: int = 0) -> Dict[str, float]:
    rng = random.Random(seed)
    se = si = st = 0
    for _ in range(trials):
        edges = sample_graph(n, p, rng)
        se += len(edges); si += count_isolated(n, edges); st += count_triangles(n, edges)
    return {'edges': se / trials, 'isolated': si / trials, 'triangles': st / trials}
