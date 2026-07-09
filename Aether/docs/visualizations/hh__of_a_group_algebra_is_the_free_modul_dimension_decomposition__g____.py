"""Visualization: conjugacy-class structure and the rank of HH_0(R[G]).

For a selection of finite groups, this script draws a bar chart comparing
|G|, the dimension of the commutator submodule [R[G],R[G]], and the dimension
of HH_0(R[G]) (= number of conjugacy classes), illustrating the identity

    dim HH_0(R[G]) = #Conj(G)    and    |G| = dim[R[G],R[G]] + #Conj(G).
"""

from __future__ import annotations

from fractions import Fraction
from itertools import permutations, product

import matplotlib.pyplot as plt


def mul_table_symmetric(k: int) -> tuple[int, list[list[int]], int]:
    perms = list(permutations(range(k)))
    index = {p: i for i, p in enumerate(perms)}
    n = len(perms)

    def comp(p, q):
        return tuple(p[q[i]] for i in range(k))

    mul = [[index[comp(perms[a], perms[b])] for b in range(n)] for a in range(n)]
    return n, mul, index[tuple(range(k))]


def mul_table_cyclic(nn: int) -> tuple[int, list[list[int]], int]:
    return nn, [[(a + b) % nn for b in range(nn)] for a in range(nn)], 0


def num_classes(n: int, mul: list[list[int]]) -> int:
    inv = [next(b for b in range(n) if mul[a][b] == mul[b][a] == 0) for a in range(n)]
    seen: set[int] = set()
    count = 0
    for u in range(n):
        if u in seen:
            continue
        orbit = {mul[mul[c][u]][inv[c]] for c in range(n)}
        seen |= orbit
        count += 1
    return count


def commutator_rank(n: int, mul: list[list[int]]) -> int:
    rows: list[list[Fraction]] = []
    for a, b in product(range(n), repeat=2):
        v = [Fraction(0)] * n
        v[mul[a][b]] += 1
        v[mul[b][a]] -= 1
        rows.append(v)
    r = 0
    for col in range(n):
        piv = next((i for i in range(r, len(rows)) if rows[i][col] != 0), None)
        if piv is None:
            continue
        rows[r], rows[piv] = rows[piv], rows[r]
        inv = Fraction(1) / rows[r][col]
        rows[r] = [x * inv for x in rows[r]]
        for i in range(len(rows)):
            if i != r and rows[i][col] != 0:
                f = rows[i][col]
                rows[i] = [x - f * y for x, y in zip(rows[i], rows[r])]
        r += 1
    return r


def main() -> None:
    groups = [
        ("C_6", *mul_table_cyclic(6)),
        ("S_3", *mul_table_symmetric(3)),
        ("S_4", *mul_table_symmetric(4)),
    ]
    labels, orders, comm, classes = [], [], [], []
    for name, n, mul, _e in groups:
        labels.append(name)
        orders.append(n)
        cr = commutator_rank(n, mul)
        comm.append(cr)
        classes.append(n - cr)

    x = range(len(labels))
    w = 0.27
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.bar([i - w for i in x], orders, w, label="|G|")
    ax.bar(list(x), comm, w, label="dim [R[G],R[G]]")
    ax.bar([i + w for i in x], classes, w, label="dim HH_0 = #Conj(G)")
    ax.set_xticks(list(x))
    ax.set_xticklabels(labels)
    ax.set_ylabel("dimension over Q")
    ax.set_title("HH_0(R[G]) is free on conjugacy classes:  |G| = dim[R[G],R[G]] + #Conj(G)")
    ax.legend()
    for i, c in zip(x, classes):
        ax.text(i + w, c + 0.2, str(c), ha="center")
    fig.tight_layout()
    fig.savefig("hh0_dimensions.png", dpi=150)
    print("Saved hh0_dimensions.png")


if __name__ == "__main__":
    main()
