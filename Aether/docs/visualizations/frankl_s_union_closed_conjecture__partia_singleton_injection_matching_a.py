"""Visualize the singleton injection as a bipartite matching and the Reimer
identity as a bar chart.  Requires matplotlib."""
from itertools import combinations
from typing import FrozenSet, List, Set

import matplotlib.pyplot as plt

Family = Set[FrozenSet[int]]


def reimer_data(max_n: int):
    ns, lhs, rhs = [], [], []
    for n in range(max_n + 1):
        total = sum(len(c) for r in range(n + 1) for c in combinations(range(n), r))
        ns.append(n); lhs.append(2 * total); rhs.append(n * 2 ** n)
    return ns, lhs, rhs


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: singleton injection matching
    F: Family = {frozenset(), frozenset({2}), frozenset({2, 3}),
                 frozenset({1}), frozenset({1, 2}), frozenset({1, 2, 3}),
                 frozenset({1, 3})}
    avoid = sorted([A for A in F if 1 not in A], key=lambda s: (len(s), sorted(s)))
    contain = sorted([A for A in F if 1 in A], key=lambda s: (len(s), sorted(s)))
    for i, A in enumerate(avoid):
        ax1.text(0, -i, "{" + ",".join(map(str, sorted(A))) + "}", ha="center",
                 va="center", bbox=dict(boxstyle="round", fc="#ffd8a8"))
        img = A | {1}
        j = contain.index(img)
        ax1.annotate("", xy=(1, -j), xytext=(0.18, -i),
                     arrowprops=dict(arrowstyle="->", color="#1971c2"))
    for j, A in enumerate(contain):
        ax1.text(1, -j, "{" + ",".join(map(str, sorted(A))) + "}", ha="center",
                 va="center", bbox=dict(boxstyle="round", fc="#b2f2bb"))
    ax1.set_title("Singleton injection  A -> A u {1}")
    ax1.axis("off")

    # Right: Reimer identity
    ns, lhs, rhs = reimer_data(7)
    ax2.plot(ns, lhs, "o-", label="2 * sum |A|")
    ax2.plot(ns, rhs, "x--", label="n * 2^n")
    ax2.set_xlabel("n"); ax2.set_ylabel("value")
    ax2.set_title("Reimer tightness on the Boolean cube")
    ax2.legend()

    plt.tight_layout()
    plt.savefig("frankl_visualization.png", dpi=150)
    print("Saved frankl_visualization.png")


if __name__ == "__main__":
    main()
