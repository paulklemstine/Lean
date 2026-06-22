"""
Visualization: the inclusion lattice of Zariski-closed sets of Spec_proof(Z/nZ).

For Z/nZ the prime congruences correspond to the prime divisors of n. We draw
the proof spectrum as points, and the Hasse diagram of Zariski-closed sets V(S)
ordered by inclusion -- a finite picture of the Zariski topology. Saving to a PNG
requires matplotlib; no other dependencies.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, List, Set, Tuple

import matplotlib.pyplot as plt


def prime_factors(n: int) -> List[int]:
    fs, d = [], 2
    while d * d <= n:
        if n % d == 0:
            fs.append(d)
            while n % d == 0:
                n //= d
        d += 1
    if n > 1:
        fs.append(n)
    return fs


def closed_sets(n: int) -> List[FrozenSet[int]]:
    """All Zariski-closed subsets of Spec_proof(Z/nZ).

    Points = prime divisors of n. V(S) = { p : p divides every s in S }.
    The closed sets are exactly the subsets of points closed under this rule;
    for the squarefree spectrum they are all subsets, which we enumerate."""
    pts = prime_factors(n)
    seen: Set[FrozenSet[int]] = set()
    for r in range(len(pts) + 1):
        for combo in combinations(pts, r):
            seen.add(frozenset(combo))
    return sorted(seen, key=lambda s: (len(s), sorted(s)))


def draw(n: int, path: str = "spectrum_lattice.png") -> None:
    sets = closed_sets(n)
    levels: Dict[int, List[FrozenSet[int]]] = {}
    for s in sets:
        levels.setdefault(len(s), []).append(s)

    pos: Dict[FrozenSet[int], Tuple[float, float]] = {}
    for lvl, members in levels.items():
        for i, s in enumerate(members):
            x = i - (len(members) - 1) / 2.0
            pos[s] = (x, lvl)

    fig, ax = plt.subplots(figsize=(8, 6))
    for s in sets:
        for t in sets:
            if s < t and len(t) == len(s) + 1 and s <= t:
                (x0, y0), (x1, y1) = pos[s], pos[t]
                ax.plot([x0, x1], [y0, y1], color="#bbbbbb", zorder=1)
    for s in sets:
        x, y = pos[s]
        label = "{" + ",".join(map(str, sorted(s))) + "}" if s else "∅"
        ax.scatter([x], [y], s=900, color="#4C72B0", zorder=2)
        ax.text(x, y, label, ha="center", va="center", color="white", fontsize=9)

    ax.set_title(f"Zariski-closed sets of Spec_proof(Z/{n}Z)  (by inclusion)")
    ax.set_xlabel("closed sets V(S) of prime points")
    ax.set_ylabel("number of points")
    ax.set_yticks(sorted(levels))
    ax.set_xticks([])
    fig.tight_layout()
    fig.savefig(path, dpi=130)
    print(f"wrote {path}")


if __name__ == "__main__":
    draw(30)  # primes 2, 3, 5 -> an 8-vertex Boolean lattice of closed sets
