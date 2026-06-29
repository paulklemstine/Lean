"""Visualize the flat single-peaked submanifold inside the curved profile space.

Renders, for all 3-voter / 3-alternative profiles, the fraction that are
single-peaked and the Condorcet curvature distribution, and draws single-peaked
utility curves (single summit) versus a non-single-peaked "valley" curve.
Requires matplotlib.
"""
from itertools import permutations, product
from typing import List, Tuple

import matplotlib.pyplot as plt

Ranking = Tuple[int, ...]
Profile = List[Ranking]


def prefers(r: Ranking, a: int, b: int) -> bool:
    return r.index(a) < r.index(b)


def majority_beats(P: Profile, a: int, b: int) -> bool:
    sa = sum(1 for r in P if prefers(r, a, b))
    return sa > sum(1 for r in P if prefers(r, b, a))


def curvature(P: Profile, n: int) -> int:
    return sum(
        1
        for a, b, c in product(range(n), repeat=3)
        if majority_beats(P, a, b) and majority_beats(P, b, c) and majority_beats(P, c, a)
    )


def is_sp_at(r: Ranking, p: int, n: int) -> bool:
    if any(not prefers(r, p, a) for a in range(n) if a != p):
        return False
    for b in range(n):
        for a in range(b):
            if b <= p and not prefers(r, b, a):
                return False
    for a in range(n):
        for b in range(a + 1, n):
            if p <= a and not prefers(r, a, b):
                return False
    return True


def is_sp(P: Profile, n: int) -> bool:
    return all(any(is_sp_at(r, p, n) for p in range(n)) for r in P)


def main() -> None:
    n, k = 3, 3
    rankings = list(permutations(range(n)))
    sp_curv, non_curv = [], []
    for prof in product(rankings, repeat=k):
        P = list(prof)
        (sp_curv if is_sp(P, n) else non_curv).append(curvature(P, n))

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    axes[0].hist([sp_curv, non_curv], bins=range(0, 6), align="left",
                 label=["single-peaked", "not single-peaked"],
                 color=["#2a9d8f", "#e76f51"], rwidth=0.8)
    axes[0].set_title("Condorcet curvature distribution (n=3, k=3)")
    axes[0].set_xlabel("Condorcet curvature (# majority 3-cycles)")
    axes[0].set_ylabel("number of profiles")
    axes[0].legend()
    axes[0].annotate("single-peaked => always 0 (flat)", xy=(0, max(1, len(sp_curv))),
                     xytext=(1.5, len(sp_curv) * 0.7),
                     arrowprops=dict(arrowstyle="->"))

    axis = list(range(n))
    axes[1].plot(axis, [3, 2, 1], "-o", color="#2a9d8f", label="single-peaked (peak at 0)")
    axes[1].plot(axis, [1, 3, 2], "-o", color="#264653", label="single-peaked (peak at 1)")
    axes[1].plot(axis, [2, 1, 3], "-o", color="#e76f51", label="NOT single-peaked (valley)")
    axes[1].set_title("Utility along the axis: single summit vs. valley")
    axes[1].set_xlabel("alternative (axis position)")
    axes[1].set_ylabel("preference height (higher = better)")
    axes[1].set_xticks(axis)
    axes[1].legend()

    fig.tight_layout()
    fig.savefig("single_peaked_flatness.png", dpi=130)
    print("saved single_peaked_flatness.png")


if __name__ == "__main__":
    main()
