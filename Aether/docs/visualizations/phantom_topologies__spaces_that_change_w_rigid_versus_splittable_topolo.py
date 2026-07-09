"""Bar chart of rigid vs. splittable topology counts on n-point sets.

Requires: matplotlib.
"""
from __future__ import annotations
from itertools import combinations
import matplotlib.pyplot as plt


def powerset(xs):
    items = list(xs)
    return [frozenset(c) for r in range(len(items) + 1)
            for c in combinations(items, r)]


def is_topology(opens, U):
    if frozenset() not in opens or U not in opens:
        return False
    for a in opens:
        for b in opens:
            if (a & b) not in opens or (a | b) not in opens:
                return False
    return True


def all_topologies(U):
    middle = [s for s in powerset(U) if s not in (frozenset(), U)]
    out = []
    for r in range(len(middle) + 1):
        for c in combinations(middle, r):
            o = set(c) | {frozenset(), U}
            if is_topology(o, U):
                out.append(frozenset(o))
    return out


def splittable(tau, tops):
    finer = [t for t in tops if tau <= t and t != tau]
    for a, b in combinations(finer, 2):
        if frozenset(a & b) == tau:
            return True
    return False


def main():
    ns, rig, spl = [], [], []
    for n in (1, 2, 3):
        U = frozenset(range(n))
        tops = all_topologies(U)
        r = sum(1 for t in tops if not splittable(t, tops))
        ns.append(n)
        rig.append(r)
        spl.append(len(tops) - r)
    plt.bar(ns, rig, label="rigid", color="#e74c3c")
    plt.bar(ns, spl, bottom=rig, label="splittable", color="#2ecc71")
    plt.xlabel("number of points")
    plt.ylabel("number of topologies")
    plt.legend()
    plt.title("Rigid vs. splittable topologies")
    plt.savefig("rigid_count.png", dpi=150, bbox_inches="tight")
    print("saved rigid_count.png")


if __name__ == "__main__":
    main()
