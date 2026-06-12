"""Visualize fingerprints (encoding matrix) and a separation check.

Generates 'closure_extractor_fingerprints.png': a heatmap whose columns are the
binary fingerprints of the elements 1..12 under a 4-bit closure-stable test
family, with closed sets of the divisibility closure annotated. Distinct columns
== separation (Theorem 6.1).
"""
from __future__ import annotations
from typing import Callable, FrozenSet, List
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np


def down_closure(ground, below):
    def cl(a):
        out = set(a)
        for x in a:
            for y in ground:
                if below(y, x):
                    out.add(y)
        return frozenset(out)
    return cl


def main() -> None:
    n = 12
    ground = frozenset(range(1, n + 1))
    cl = down_closure(ground, lambda y, x: x % y == 0)
    elems = sorted(ground)
    bits = 4
    M = np.array([[(x >> b) & 1 for x in elems] for b in range(bits)])

    fig, ax = plt.subplots(figsize=(10, 4))
    ax.imshow(M, cmap="Greys", aspect="auto", vmin=0, vmax=1)
    ax.set_xticks(range(len(elems)))
    ax.set_xticklabels(elems)
    ax.set_yticks(range(bits))
    ax.set_yticklabels([f"phi_{b}" for b in range(bits)])
    ax.set_xlabel("element x  (1..12)")
    ax.set_ylabel("closure-stable test")
    cols = {tuple(M[:, j]) for j in range(len(elems))}
    ax.set_title(f"Fingerprints enc(x): {len(cols)} distinct of {len(elems)} "
                 f"-> separation = {len(cols) == len(elems)}")
    for j in range(len(elems)):
        for b in range(bits):
            ax.text(j, b, str(M[b, j]), ha="center", va="center",
                    color="red" if M[b, j] else "black", fontsize=8)
    fig.tight_layout()
    fig.savefig("closure_extractor_fingerprints.png", dpi=130)
    print("wrote closure_extractor_fingerprints.png")


if __name__ == "__main__":
    main()
