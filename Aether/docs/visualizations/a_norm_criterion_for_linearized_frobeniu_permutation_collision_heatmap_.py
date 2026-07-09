"""
visualization.py — Visualize the permutation/collision structure of
x -> a*x^p + c*x over F_{p^2}, and the exact exceptional count p+1.

Produces two panels:
  (left)  a heatmap over all (a, c) pairs showing where the norm criterion
          N(a) != N(c) holds (permutation) vs fails (collision), for F_{p^2}.
  (right) the exceptional count p+1 vs p^2, illustrating the vanishing
          fraction (p+1)/p^2 -> 0.

Self-contained except for matplotlib/numpy.
"""

from __future__ import annotations

from itertools import product

import matplotlib.pyplot as plt
import numpy as np


def nonresidue(p: int) -> int:
    squares = {(x * x) % p for x in range(p)}
    for g in range(2, p):
        if g not in squares:
            return g
    raise ValueError("no non-residue")


def norm(u: int, v: int, p: int, g: int) -> int:
    # N(u + v t) = u^2 - g v^2  in F_p  (since t^p = -t, t^2 = g)
    return (u * u - g * v * v) % p


def make_panels(p: int = 7) -> None:
    g = nonresidue(p)
    elems = list(product(range(p), repeat=2))          # F_{p^2} as pairs
    n = len(elems)
    norms = [norm(u, v, p, g) for (u, v) in elems]

    # Permutation matrix: 1 where N(a) != N(c) (permutation), 0 where collision.
    M = np.zeros((n, n), dtype=int)
    for i, na in enumerate(norms):
        for j, nc in enumerate(norms):
            M[i, j] = 1 if na != nc else 0

    fig, axes = plt.subplots(1, 2, figsize=(13, 5.5))

    ax = axes[0]
    ax.imshow(M, cmap="RdYlGn", origin="lower", aspect="equal")
    ax.set_title(f"$L(x)=a x^p + c x$ over $\\mathbb{{F}}_{{{p**2}}}$\n"
                 f"green: permutation $N(a)\\neq N(c)$, red: collision")
    ax.set_xlabel("index of coefficient $c$")
    ax.set_ylabel("index of coefficient $a$")

    ax = axes[1]
    ps = [3, 5, 7, 11, 13, 17, 19, 23]
    exc = [pp + 1 for pp in ps]
    tot = [pp * pp for pp in ps]
    ax.plot(ps, tot, "o-", label="$p^2$ total coefficients")
    ax.plot(ps, exc, "s-", label="$p+1$ exceptional")
    ax.set_title("Exceptional coefficients are a vanishing fraction")
    ax.set_xlabel("prime $p$")
    ax.set_ylabel("count")
    ax.legend()
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig("permutation_polynomial_structure.png", dpi=150)
    print("saved permutation_polynomial_structure.png")


if __name__ == "__main__":
    make_panels(7)
