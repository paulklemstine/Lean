from itertools import chain, combinations
from typing import Callable, Dict, FrozenSet, Iterable, List

Simplex = FrozenSet[int]
Filtration = Dict[Simplex, float]


def all_nonempty_simplices(labels: Iterable[int]) -> List[Simplex]:
    items = list(labels)
    subs = chain.from_iterable(combinations(items, r) for r in range(1, len(items) + 1))
    return [frozenset(s) for s in subs]


def make_monotone_filtration(labels: Iterable[int], vertex_time: Dict[int, float]) -> Filtration:
    return {s: max(vertex_time[v] for v in s) for s in all_nonempty_simplices(labels)}


def shift(a: float, F: Filtration) -> Filtration:
    if a < 0:
        raise ValueError("shift amount must be non-negative")
    return {s: w - a for s, w in F.items()}


def comap(e: Callable[[int], int], F: Filtration) -> Filtration:
    return {s: F[frozenset(e(v) for v in s)] for s in F}


def interleaving_distance(F: Filtration, G: Filtration) -> float:
    return max(abs(F[s] - G[s]) for s in F)

import matplotlib.pyplot as plt

# Visualize that interleaving distance is invariant under random relabelings,
# while the underlying weight vectors are permuted.
import random

labels = [0, 1, 2, 3, 4]
F = make_monotone_filtration(labels, {i: float(i) for i in labels})
G = make_monotone_filtration(labels, {0: 0.4, 1: 0.7, 2: 2.5, 3: 3.2, 4: 4.6})
base = interleaving_distance(F, G)

dists = []
for _ in range(40):
    perm = labels[:]
    random.shuffle(perm)
    p = dict(zip(labels, perm))
    e = lambda v, p=p: p[v]
    dists.append(interleaving_distance(comap(e, F), comap(e, G)))

plt.figure(figsize=(8, 4))
plt.plot(dists, "o-", label="interleavingDist(comap e F, comap e G)")
plt.axhline(base, color="red", ls="--", label=f"invariant value = {base:.3f}")
plt.xlabel("random relabeling index")
plt.ylabel("interleaving distance")
plt.title("Relabeling invariance of the interleaving distance")
plt.legend()
plt.tight_layout()
plt.savefig("relabeling_invariance.png", dpi=150)
print("saved relabeling_invariance.png")
