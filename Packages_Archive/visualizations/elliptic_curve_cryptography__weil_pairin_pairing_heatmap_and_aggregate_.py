"""
viz.py — Visualizations for the bilinear pairing / BLS package.

Generates two figures:
  1. A heatmap of the pairing values e(a,b) = GEN^(a*b mod R) mod P over a
     small grid, exposing the multiplicative (rank-1 in the exponent) structure
     that makes the map bilinear.
  2. A comparison of total signature size as the number of signers grows:
     naive (one signature per signer) vs. BLS aggregate (constant size).

Requires: matplotlib, numpy.  Run:  python3 viz.py
"""

from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt

P: int = 2039
R: int = 1019
GEN: int = pow(3, (P - 1) // R, P)


def e(a: int, b: int) -> int:
    return pow(GEN, (a * b) % R, P)


def heatmap(n: int = 40) -> None:
    grid = np.array([[e(a, b) for b in range(n)] for a in range(n)])
    plt.figure(figsize=(6, 5))
    plt.imshow(grid, origin="lower", cmap="twilight")
    plt.colorbar(label="e(a, b)  in Z/P")
    plt.xlabel("b  (second argument in G)")
    plt.ylabel("a  (first argument in G)")
    plt.title("Bilinear pairing values e(a,b) = GEN^(a*b mod R)")
    plt.tight_layout()
    plt.savefig("pairing_heatmap.png", dpi=150)
    print("wrote pairing_heatmap.png")


def aggregate_size(max_signers: int = 200, sig_bytes: int = 48) -> None:
    n = np.arange(1, max_signers + 1)
    naive = n * sig_bytes              # one signature per signer
    bls = np.full_like(n, sig_bytes)   # one aggregate element, constant
    plt.figure(figsize=(6, 5))
    plt.plot(n, naive, label="naive (n separate signatures)")
    plt.plot(n, bls, label="BLS aggregate (one element)")
    plt.xlabel("number of signers n")
    plt.ylabel("total signature size (bytes)")
    plt.title("Signature size: naive vs. BLS aggregation")
    plt.legend()
    plt.tight_layout()
    plt.savefig("aggregate_size.png", dpi=150)
    print("wrote aggregate_size.png")


if __name__ == "__main__":
    heatmap()
    aggregate_size()
