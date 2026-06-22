"""Visualize the provability-rank spectrum box^k(BOT) = {0,...,k-1} as a staircase."""
from typing import FrozenSet, List
import matplotlib.pyplot as plt

Prop = FrozenSet[int]


def box(s: Prop, n: int) -> Prop:
    return frozenset(k for k in range(n) if all(m in s for m in range(k)))


def main() -> None:
    n, kmax = 12, 12
    cur: Prop = frozenset()
    fig, ax = plt.subplots(figsize=(8, 5))
    for k in range(kmax + 1):
        for stage in cur:
            ax.add_patch(plt.Rectangle((stage, k), 1, 1, color="#3b6fb6"))
        cur = box(cur, n)
    ax.set_xlim(0, n)
    ax.set_ylim(0, kmax + 1)
    ax.set_xlabel("stage n (truth at time n)")
    ax.set_ylabel("number of boxes k")
    ax.set_title(r"Provability rank: $\Box^k\bot = \{0,\dots,k-1\}$")
    ax.set_aspect("equal")
    plt.tight_layout()
    plt.savefig("provability_rank.png", dpi=150)
    print("wrote provability_rank.png")


if __name__ == "__main__":
    main()
