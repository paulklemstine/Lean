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

def fmt(s: Simplex) -> str:
    return '{' + ','.join(map(str, sorted(s))) + '}' if s else 'empty'

def main() -> None:
    verts = [0, 1, 2, 3]
    base = {(0,1):1.0,(0,2):1.4,(0,3):1.0,(1,2):1.0,(1,3):1.4,(2,3):1.0}
    def mk(stretch: float) -> Callable[[int, int], float]:
        def d(i: int, j: int) -> float:
            if i == j: return 0.0
            key = (min(i, j), max(i, j))
            return base[key] + (stretch if key == (1, 3) else 0.0)
        return d
    F, G = vr_filtration(verts, mk(0.0)), vr_filtration(verts, mk(0.3))
    keys = sorted(set(F) | set(G), key=lambda s: (len(s), sorted(s)))
    gaps = [abs(F[k] - G[k]) for k in keys]
    labels = [fmt(k) for k in keys]
    dist = max(gaps)
    colors = ['crimson' if abs(g - dist) < 1e-9 else 'steelblue' for g in gaps]
    plt.figure(figsize=(8, 6))
    plt.barh(range(len(keys)), gaps, color=colors)
    plt.yticks(range(len(keys)), labels)
    plt.axvline(dist, color='crimson', ls='--', label=f'interleaving distance = {dist:.2f}')
    plt.xlabel('birth-time gap  |w_F(sigma) - w_G(sigma)|')
    plt.title('Per-simplex gaps; the supremum is the interleaving distance')
    plt.legend()
    plt.tight_layout()
    plt.savefig('gap_spectrum.png', dpi=150)
    print('wrote gap_spectrum.png   interleaving distance =', dist)

if __name__ == '__main__':
    main()
