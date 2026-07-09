"""Visualize the obstruction lattice of a finite pairing datum.

Renders, for the Z/4 model <s,b>=(2s)b, the orthogonal of every subgroup of B
and highlights how the strictly nested class families {1} and {1,2} land on the
same obstruction set {0,2}.
"""
from itertools import chain, combinations
from typing import FrozenSet, List, Set

import matplotlib.pyplot as plt


def powerset(xs: List[int]):
    return chain.from_iterable(combinations(xs, k) for k in range(len(xs) + 1))


def left_orthogonal(S: List[int], H: Set[int], n: int) -> FrozenSet[int]:
    return frozenset(s for s in S if all((2 * s) * b % n == 0 for b in H))


def main() -> None:
    n = 4
    S = list(range(n))
    B = list(range(n))
    subsets = [frozenset(s) for s in powerset(B)]
    fig, ax = plt.subplots(figsize=(8, 5))
    for i, H in enumerate(subsets):
        obs = left_orthogonal(S, set(H), n)
        ax.scatter([i] * len(obs), sorted(obs), s=80)
        ax.annotate("{" + ",".join(map(str, sorted(H))) + "}",
                    (i, -0.6), ha="center", fontsize=7, rotation=45)
    ax.set_xlabel("family H of cohomology classes (subsets of Z/4)")
    ax.set_ylabel("obstruction set H^perp in S = Z/4")
    ax.set_title("Distinct class families collapse to the same obstruction")
    ax.set_yticks(range(n))
    plt.tight_layout()
    plt.savefig("obstruction_lattice.png", dpi=150)
    print("wrote obstruction_lattice.png")


if __name__ == "__main__":
    main()
