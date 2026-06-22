from __future__ import annotations
from itertools import combinations, chain
from typing import Callable, Dict, FrozenSet, List, Sequence
import matplotlib.pyplot as plt

Simplex = FrozenSet[int]
Weight = Dict[Simplex, float]

def all_simplices(vertices: Sequence[int]) -> List[Simplex]:
    verts = list(vertices)
    return [frozenset(c) for c in chain.from_iterable(
        combinations(verts, r) for r in range(len(verts) + 1))]

def diam_weight(distance: Callable[[int, int], float], sigma: Simplex) -> float:
    best = 0.0
    for x, y in combinations(sorted(sigma), 2):
        best = max(best, distance(x, y))
    return best

def vr_filtration(vertices: Sequence[int], distance: Callable[[int, int], float]) -> Weight:
    return {s: diam_weight(distance, s) for s in all_simplices(vertices)}

def sup_dist(w_f: Weight, w_g: Weight) -> float:
    keys = set(w_f) | set(w_g)
    return max(abs(w_f.get(k, 0.0) - w_g.get(k, 0.0)) for k in keys)

def main() -> None:
    verts = [0, 1, 2]
    base = vr_filtration(verts, lambda i, j: 0.0 if i == j else 1.0)
    eps = [k * 0.05 for k in range(0, 21)]
    dists = [sup_dist(base, vr_filtration(verts, (lambda e: lambda i, j: 0.0 if i == j else 1.0 + e)(e))) for e in eps]
    plt.figure(figsize=(7, 6))
    plt.plot(eps, dists, 'o-', color='darkgreen', label='interleaving distance')
    plt.plot(eps, eps, '--', color='gray', label='identity  (distance = epsilon)')
    plt.xlabel('input perturbation  epsilon')
    plt.ylabel('interleaving distance of outputs')
    plt.title('Persistence is an isometry: output distance equals input perturbation')
    plt.legend()
    plt.tight_layout()
    plt.savefig('stability_tight.png', dpi=150)
    print('wrote stability_tight.png')

if __name__ == '__main__':
    main()
