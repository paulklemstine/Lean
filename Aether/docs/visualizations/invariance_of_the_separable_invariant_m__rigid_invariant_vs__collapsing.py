"""
visualize.py — The rigidity of m_f vs. the collapse of the raw degree.

Produces a grouped bar chart over a family of irreducible polynomials in
characteristic p, comparing for each example:
  * deg f over K            (the raw degree, before base change),
  * [N(theta):N] over N     (the degree after purely inseparable base change),
  * m_f = m_{f,N}           (the separable invariant, equal before and after).

The picture makes the theorem visible: the separable invariant (flat line of
markers) does not move, while the raw degree (tall bars) can collapse.
"""

from __future__ import annotations
from math import gcd
from functools import reduce
from typing import Dict, List, Tuple

Poly = Dict[int, Dict[int, int]]


def normalize(f: Poly, p: int) -> Poly:
    out: Poly = {}
    for xe, coeff in f.items():
        c = {be: v % p for be, v in coeff.items() if v % p != 0}
        if c:
            out[xe] = c
    return out


def x_degree(f: Poly) -> int:
    return max(f.keys()) if f else 0


def insep_exponent(f: Poly, p: int) -> int:
    exps = [xe for xe in f if xe != 0]
    if not exps:
        return 0
    g, e = reduce(gcd, exps), 0
    while g > 0 and g % p == 0:
        g //= p
        e += 1
    return e


def nat_sep_degree(f: Poly, p: int) -> int:
    return x_degree(f) // (p ** insep_exponent(f, p))


def is_pth_power(f: Poly, p: int) -> bool:
    return all(xe % p == 0 and all(be % p == 0 for be in c) for xe, c in f.items())


def pth_root(f: Poly, p: int) -> Poly:
    return normalize({xe // p: {be // p: v for be, v in c.items()}
                      for xe, c in f.items()}, p)


def minpoly_over_N(f: Poly, p: int, k: int) -> Poly:
    g = normalize({xe: {be * p ** k: v for be, v in c.items()}
                   for xe, c in f.items()}, p)
    while is_pth_power(g, p):
        g = pth_root(g, p)
    return g


def main() -> None:
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    import numpy as np

    examples: List[Tuple[str, int, Poly, int]] = [
        ("$X^2+t$\n(p=2)", 2, {2: {0: 1}, 0: {1: 1}}, 1),
        ("$X^4+tX^2+t$\n(p=2)", 2, {4: {0: 1}, 2: {1: 1}, 0: {1: 1}}, 1),
        ("$X^2+tX+t$\n(p=2)", 2, {2: {0: 1}, 1: {1: 1}, 0: {1: 1}}, 1),
        ("$X^9+tX^3+t$\n(p=3)", 3, {9: {0: 1}, 3: {1: 1}, 0: {1: 1}}, 1),
        ("$X^8+t$\n(p=2,k=2)", 2, {8: {0: 1}, 0: {1: 1}}, 2),
    ]

    labels, degK, degN, mvals = [], [], [], []
    for name, p, f, k in examples:
        f = normalize(f, p)
        labels.append(name)
        degK.append(x_degree(f))
        degN.append(x_degree(minpoly_over_N(f, p, k)))
        mvals.append(nat_sep_degree(f, p))

    x = np.arange(len(labels))
    w = 0.35
    fig, ax = plt.subplots(figsize=(11, 6))
    ax.bar(x - w / 2, degK, w, label=r"$\deg f$ over $K$", color="#4C72B0")
    ax.bar(x + w / 2, degN, w, label=r"$[N(\theta):N]$ over $N$", color="#C44E52")
    ax.plot(x, mvals, "o-", color="#000000", markersize=11, linewidth=2,
            label=r"$m_f = m_{f,N}$ (invariant)")
    for xi, m in zip(x, mvals):
        ax.annotate(f"{m}", (xi, m), textcoords="offset points", xytext=(0, 10),
                    ha="center", fontweight="bold")

    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.set_ylabel("degree")
    ax.set_title("Purely inseparable base change: the raw degree collapses,\n"
                 r"but the separable invariant $m_f$ is rigid")
    ax.legend()
    ax.grid(axis="y", alpha=0.3)
    fig.tight_layout()
    fig.savefig("m_f_invariance.png", dpi=150)
    print("wrote m_f_invariance.png")


if __name__ == "__main__":
    main()
