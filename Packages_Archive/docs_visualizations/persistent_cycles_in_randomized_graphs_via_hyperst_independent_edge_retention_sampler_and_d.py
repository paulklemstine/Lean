from __future__ import annotations
import random

def retain_and_measure(n: int, edges: list[tuple[int, int]], p: float,
                       trials: int, seed: int = 0) -> tuple[float, float]:
    """Return (mean retained-edge count, mean minimum degree) of G_p over trials.
    The mean retained-edge count concentrates at p * |E|."""
    rng = random.Random(seed)
    tot_edges = 0
    tot_mindeg = 0
    for _ in range(trials):
        kept = [e for e in edges if rng.random() < p]
        tot_edges += len(kept)
        deg = [0] * n
        for a, b in kept:
            deg[a] += 1; deg[b] += 1
        tot_mindeg += min(deg) if deg else 0
    return tot_edges / trials, tot_mindeg / trials
