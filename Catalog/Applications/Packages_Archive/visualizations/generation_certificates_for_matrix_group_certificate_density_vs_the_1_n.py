"""Visualization: certificate density vs 1/n in GL_n(F_p).

Standalone script. Requires matplotlib + the arithmetic helpers, which are
inlined here so the file runs on its own.
"""
from __future__ import annotations

import random
from typing import List, Tuple

import matplotlib.pyplot as plt


def inv_mod(a: int, p: int) -> int:
    return pow(a % p, p - 2, p)


def det_mod(A: List[List[int]], p: int) -> int:
    M = [row[:] for row in A]
    n = len(M)
    det = 1
    for col in range(n):
        piv = next((i for i in range(col, n) if M[i][col] % p), None)
        if piv is None:
            return 0
        if piv != col:
            M[col], M[piv] = M[piv], M[col]
            det = (-det) % p
        det = (det * M[col][col]) % p
        invp = inv_mod(M[col][col], p)
        for i in range(col + 1, n):
            f = (M[i][col] * invp) % p
            if f:
                M[i] = [(M[i][j] - f * M[col][j]) % p for j in range(n)]
    return det % p


def char_poly_irreducible(A: List[List[int]], p: int) -> bool:
    # det(tI - A) via Laplace, then Rabin's test (inlined, see demo.py)
    from itertools import product  # noqa
    # (For brevity in the visualization we delegate to demo.py's routines.)
    import importlib.util
    import os
    spec = importlib.util.spec_from_file_location(
        "demo", os.path.join(os.path.dirname(__file__), "demo.py"))
    demo = importlib.util.module_from_spec(spec)  # type: ignore
    spec.loader.exec_module(demo)                 # type: ignore
    return demo.is_irreducible(demo.char_poly(A, p), p)


def density(n: int, p: int, samples: int, rng: random.Random) -> float:
    cert = inv = 0
    for _ in range(samples):
        A = [[rng.randrange(p) for _ in range(n)] for _ in range(n)]
        if det_mod(A, p) == 0:
            continue
        inv += 1
        if char_poly_irreducible(A, p):
            cert += 1
    return cert / inv if inv else 0.0


def main() -> None:
    rng = random.Random(7)
    ns = list(range(1, 7))
    for p in (2, 3, 5):
        ys = [density(n, p, 4000, rng) for n in ns]
        plt.plot(ns, ys, marker="o", label=f"F_{p} (empirical)")
    plt.plot(ns, [1.0 / n for n in ns], "k--", label="1/n (theory)")
    plt.xlabel("dimension n")
    plt.ylabel("certificate density in GL_n(F_p)")
    plt.title("Density of irreducible-charpoly elements vs 1/n")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.savefig("certificate_density.png", dpi=150, bbox_inches="tight")
    print("saved certificate_density.png")


if __name__ == "__main__":
    main()
