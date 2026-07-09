"""Bar chart: actual double-cover symmetry vs. the guaranteed bound 2|Aut(X)|.

Stable digraphs (the odd-order examples) sit exactly on 2|Aut(X)|; the
even-order witness Z/6 jumps above it, visibly unstable.  Requires matplotlib.
"""
from __future__ import annotations
from itertools import permutations
from typing import FrozenSet, List, Sequence, Tuple
import matplotlib.pyplot as plt


def count_aut(adj: List[List[bool]]) -> int:
    n = len(adj)
    image, used, count = [-1] * n, [False] * n, 0

    def ok(i: int, t: int) -> bool:
        return all(adj[t][image[j]] == adj[i][j] and adj[image[j]][t] == adj[j][i]
                   for j in range(i))

    def bt(i: int) -> None:
        nonlocal count
        if i == n:
            count += 1
            return
        for t in range(n):
            if not used[t] and ok(i, t):
                image[i], used[t] = t, True
                bt(i + 1)
                used[t] = False

    bt(0)
    return count


def aut_cayley(n: int, S: FrozenSet[int]) -> int:
    adj = [[(h - g) % n in S for h in range(n)] for g in range(n)]
    return count_aut(adj)


def aut_double(n: int, S: FrozenSet[int]) -> int:
    V = [(g, a) for g in range(n) for a in (0, 1)]
    adj = [[((q[0] - p[0]) % n in S and p[1] != q[1]) for q in V] for p in V]
    return count_aut(adj)


def main() -> None:
    cases: List[Tuple[str, int, FrozenSet[int]]] = [
        ("Z/3 dir.", 3, frozenset({1})),
        ("Z/5 dir.", 5, frozenset({1})),
        ("Z/5 cyc.", 5, frozenset({1, 4})),
        ("Z/7 cyc.", 7, frozenset({1, 6})),
        ("Z/6 cyc. (even!)", 6, frozenset({1, 5})),
    ]
    labels, autx, lower, autb = [], [], [], []
    for name, n, S in cases:
        a, b = aut_cayley(n, S), aut_double(n, S)
        labels.append(name); autx.append(a); lower.append(2 * a); autb.append(b)
    x = range(len(labels))
    plt.figure(figsize=(10, 6))
    plt.bar([i - 0.25 for i in x], autx, width=0.25, label="|Aut(X)|")
    plt.bar(list(x), lower, width=0.25, label="2|Aut(X)| (guaranteed bound)")
    plt.bar([i + 0.25 for i in x], autb, width=0.25, label="|Aut(X (x) K2)| (actual)")
    plt.yscale("log")
    plt.xticks(list(x), labels, rotation=20, ha="right")
    plt.ylabel("group order (log scale)")
    plt.title("Stability: actual double-cover symmetry vs. bound 2|Aut(X)|")
    plt.legend(); plt.tight_layout(); plt.savefig("stability_counts.png", dpi=150)
    print("wrote stability_counts.png")


if __name__ == "__main__":
    main()
