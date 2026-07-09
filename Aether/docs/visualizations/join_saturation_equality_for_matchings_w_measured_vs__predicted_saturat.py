"""Visualization: saturation number sat(n, K_1 v (tK_2 u qK_1)) vs n, with the
Cameron-Puleo recurrence prediction overlaid.  Requires matplotlib.  Self-contained."""
from __future__ import annotations
from itertools import combinations, permutations
from typing import FrozenSet, Iterator, Tuple
import matplotlib.pyplot as plt

Edge = FrozenSet[int]
Graph = Tuple[int, FrozenSet[Edge]]


def all_pairs(n: int) -> Iterator[Edge]:
    for i, j in combinations(range(n), 2):
        yield frozenset((i, j))


def contains_copy(host: Graph, pattern: Graph) -> bool:
    hn, _ = host
    pn, pedges = pattern
    if pn > hn:
        return False
    adj = {(min(e), max(e)) for e in host[1]}
    for perm in permutations(range(hn), pn):
        if all((min(perm[a], perm[b]), max(perm[a], perm[b])) in adj
               for e in pedges for a, b in [tuple(e)]):
            return True
    return False


def is_saturated(host: Graph, pattern: Graph) -> bool:
    if contains_copy(host, pattern):
        return False
    n, existing = host
    for e in all_pairs(n):
        if e in existing:
            continue
        if not contains_copy((n, existing | {e}), pattern):
            return False
    return True


def sat_number(n: int, pattern: Graph) -> int:
    pairs = list(all_pairs(n))
    best = -1
    for mask in range(1 << len(pairs)):
        edges = frozenset(pairs[k] for k in range(len(pairs)) if (mask >> k) & 1)
        if is_saturated((n, edges), pattern):
            ec = len(edges)
            best = ec if best == -1 or ec < best else best
    return best


def cone(h: Graph) -> Graph:
    n, edges = h
    return (n + 1, frozenset(set(edges) | {frozenset((n, v)) for v in range(n)}))


def matching_plus_isolated(t: int, q: int) -> Graph:
    n = 2 * t + q
    return (n, frozenset(frozenset((2 * k, 2 * k + 1)) for k in range(t)))


def main() -> None:
    t, q = 1, 1
    F = matching_plus_isolated(t, q)
    coneF = cone(F)
    ns = list(range(4, 7))
    measured = [sat_number(n, coneF) for n in ns]
    predicted = [(n - 1) + sat_number(n - 1, F) for n in ns]
    plt.figure(figsize=(7, 5))
    plt.plot(ns, measured, "o-", label="measured sat(n, K_1 v F)")
    plt.plot(ns, predicted, "s--", label="(n-1) + sat(n-1, F)")
    plt.xlabel("n (number of vertices)")
    plt.ylabel("saturation number")
    plt.title("Cameron-Puleo recurrence for F = K_2 u K_1")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("recurrence.png", dpi=150)
    print("saved recurrence.png")


if __name__ == "__main__":
    main()
