"""Bar chart comparing direct Euler-characteristic counts against the
k-set inclusion-exclusion reconstruction for several covered complexes.
Requires matplotlib."""
from __future__ import annotations
import itertools
from typing import FrozenSet, List, Set
import matplotlib.pyplot as plt

Face = FrozenSet[int]
Collection = Set[Face]


def echi(c: Collection) -> int:
    return sum((-1) ** len(s) for s in c)


def closure(maximal: List[tuple]) -> Collection:
    out: Collection = set()
    for face in maximal:
        v = list(face)
        for r in range(1, len(v) + 1):
            for sub in itertools.combinations(v, r):
                out.add(frozenset(sub))
    return out


def echi_union_k(pieces: List[Collection]) -> int:
    n = len(pieces)
    tot = 0
    for r in range(1, n + 1):
        for combo in itertools.combinations(range(n), r):
            inter = set(pieces[combo[0]])
            for idx in combo[1:]:
                inter &= pieces[idx]
            tot += ((-1) ** (r - 1)) * echi(inter)
    return tot


sphere = closure([(0, 1, 2), (0, 1, 3), (0, 2, 3), (1, 2, 3)])
disk = closure([(0, 1, 2)])
interval = closure([(0, 1)])
examples = {
    "2-sphere": ([closure([(0, 1, 2), (0, 1, 3)]),
                  closure([(0, 2, 3), (1, 2, 3)])], sphere),
    "filled triangle": ([closure([(0, 1, 2)]), closure([(0, 1)])], disk),
    "edge": ([closure([(0, 1)]), closure([(1,)])], interval),
}

names, direct, recon = [], [], []
for name, (pieces, whole) in examples.items():
    names.append(name)
    direct.append(echi(whole))
    recon.append(echi_union_k(pieces))

x = range(len(names))
plt.figure(figsize=(8, 5))
plt.bar([i - 0.2 for i in x], direct, width=0.4, label="direct count")
plt.bar([i + 0.2 for i in x], recon, width=0.4, label="inclusion-exclusion")
plt.xticks(list(x), names)
plt.ylabel("signed Euler characteristic")
plt.title("Direct vs. nerve-reconstructed Euler characteristic")
plt.legend()
plt.tight_layout()
plt.savefig("euler_reconstruction.png", dpi=150)
print("saved euler_reconstruction.png")
