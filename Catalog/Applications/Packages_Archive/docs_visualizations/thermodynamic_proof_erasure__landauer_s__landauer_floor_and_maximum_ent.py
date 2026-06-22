"""
Visualization: the Landauer floor and the maximum-entropy ceiling.

Generates two panels:
  (A) Erased information (n - m) * ln 2 and the corresponding heat k*T*(n-m)*ln2
      as a function of the number of removed proof steps (n - m), with the residue
      map sitting exactly on the floor and random compressors hovering just above it.
  (B) The Gibbs ceiling: entropy of a perturbed distribution on N points stays below
      ln N, touching it only at the uniform distribution.

Requires: numpy, matplotlib.
"""

from __future__ import annotations

import math
import numpy as np
import matplotlib.pyplot as plt

BOLTZMANN_K: float = 1.380649e-23
ROOM_T: float = 300.0
LN2: float = math.log(2.0)


def shannon_entropy(p: np.ndarray) -> float:
    p = p[p > 0]
    return float(-np.sum(p * np.log(p)))


def random_compressor_erased(n: int, m: int, rng: np.random.Generator) -> float:
    src = np.full(1 << n, 1.0 / (1 << n))
    table = rng.integers(0, 1 << m, size=1 << n)
    img = np.bincount(table, weights=src, minlength=1 << m)
    return shannon_entropy(src) - shannon_entropy(img)


def main() -> None:
    rng = np.random.default_rng(0)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # Panel A: floor vs removed steps (small n so 2^n is enumerable).
    n = 10
    removed = list(range(0, n + 1))
    floor_nats = [(r) * LN2 for r in removed]
    ax1.plot(removed, floor_nats, "k-", lw=2, label="floor (n-m)·ln2  [residue map]")
    # Random compressors for each m.
    for r in removed:
        m = n - r
        vals = [random_compressor_erased(n, m, rng) for _ in range(8)]
        ax1.scatter([r] * len(vals), vals, c="crimson", s=14, alpha=0.5,
                    label="random compressors" if r == removed[1] else None)
    ax1.set_xlabel("proof steps removed  (n − m)")
    ax1.set_ylabel("erased information (nats)")
    ax1.set_title(f"Landauer floor for proof compression (n = {n})")
    ax1.legend()
    ax1.grid(alpha=0.3)
    secax = ax1.secondary_yaxis(
        "right", functions=(lambda x: x * BOLTZMANN_K * ROOM_T,
                            lambda y: y / (BOLTZMANN_K * ROOM_T)))
    secax.set_ylabel("minimum heat at 300 K (J)")

    # Panel B: Gibbs ceiling.
    N = 8
    ceiling = math.log(N)
    strengths = np.linspace(0.0, 1.0, 60)
    base = np.full(N, 1.0 / N)
    spike = np.zeros(N); spike[0] = 1.0
    ents = []
    for s in strengths:
        p = (1 - s) * base + s * spike
        ents.append(shannon_entropy(p))
    ax2.plot(strengths, ents, "b-", lw=2, label="H(p)")
    ax2.axhline(ceiling, color="k", ls="--", label="ceiling ln N")
    ax2.set_xlabel("distance from uniform (perturbation strength)")
    ax2.set_ylabel("entropy (nats)")
    ax2.set_title(f"Gibbs maximum-entropy ceiling (N = {N})")
    ax2.legend()
    ax2.grid(alpha=0.3)

    fig.tight_layout()
    fig.savefig("landauer_proof_compression.png", dpi=150)
    print("wrote landauer_proof_compression.png")


if __name__ == "__main__":
    main()
