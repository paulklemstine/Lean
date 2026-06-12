"""Visualization: the triangle-inequality defect across PTO triples.

For triples (p, q, r) with p the largest PTO and q sweeping between r and p,
we plot the "defect" = ordinal-rank(detour) - ordinal-rank(direct), where the
rank embeds small ordinals (finite + multiples/offsets of omega) into the reals
order-faithfully for plotting. The defect is <= 0 on monotone chains (exact
additivity) and becomes strictly negative -- the detour is *cheaper* than the
direct route -- exactly when a finite step is left-absorbed by a limit jump.

Requires matplotlib. Saves 'triangle_defect.png'.
"""
from __future__ import annotations
from typing import Tuple
import matplotlib.pyplot as plt

Term = Tuple[int, int]
CNF = Tuple[Term, ...]


def ord_lt(a: CNF, b: CNF) -> bool:
    return list(a) < list(b)


def ord_le(a: CNF, b: CNF) -> bool:
    return a == b or ord_lt(a, b)


def ord_add(a: CNF, b: CNF) -> CNF:
    if not b:
        return a
    lead = b[0][0]
    kept = [(e, c) for (e, c) in a if e > lead]
    same = [(e, c) for (e, c) in a if e == lead]
    rest = list(b)
    if same:
        rest = [(lead, same[0][1] + rest[0][1])] + rest[1:]
    return tuple(kept + rest)


def ord_sub(a: CNF, b: CNF) -> CNF:
    if ord_le(a, b):
        return ()
    al, bl = list(a), list(b)
    i = 0
    while i < len(bl):
        ea, ca = al[i]
        eb, cb = bl[i]
        if ea > eb:
            return tuple(al[i:])
        if ca > cb:
            return tuple([(ea, ca - cb)] + al[i + 1:])
        i += 1
    return tuple(al[i:])


def depth_dist(p: CNF, q: CNF) -> CNF:
    return ord_add(ord_sub(p, q), ord_sub(q, p))


def rank(a: CNF) -> float:
    """Order-faithful embedding of finite + omega*k + n ordinals into reals
    (for plotting only): omega -> 1000, finite n -> n."""
    val = 0.0
    for e, c in a:
        val += (1000.0 ** e) * c
    return val


def main() -> None:
    BIG = 1000  # stands in for omega in finite arithmetic of coefficients
    # Triple family: p = omega + 1, r = 0, q sweeps 0,1,...,n,...,omega
    p: CNF = ((1, 1), (0, 1))     # omega + 1
    r: CNF = ()                   # 0
    qs = [(), ((0, 1),), ((0, 2),), ((0, 5),), ((1, 1),)]  # 0,1,2,5,omega
    labels = ["0", "1", "2", "5", "w"]
    defects = []
    for q in qs:
        direct = rank(depth_dist(p, r))
        detour = rank(ord_add(depth_dist(p, q), depth_dist(q, r)))
        defects.append(detour - direct)   # negative => triangle violated

    fig, ax = plt.subplots(figsize=(7, 4.5))
    colors = ["#2a7" if d >= 0 else "#c33" for d in defects]
    ax.bar(labels, defects, color=colors)
    ax.axhline(0, color="black", linewidth=0.8)
    ax.set_xlabel("middle PTO q  (with p = w+1, r = 0)")
    ax.set_ylabel("rank(detour) - rank(direct)")
    ax.set_title("Triangle defect: negative bars = inequality VIOLATED\n"
                 "(q = w absorbs the +1 step:  1 + w = w)")
    fig.tight_layout()
    fig.savefig("triangle_defect.png", dpi=150)
    print("saved triangle_defect.png")


if __name__ == "__main__":
    main()
