"""Visualization: growth ladders on a log-log-style axis.
Generates 'ladders.png' contrasting the collapsing ladder 2^(k*n) with the
separating power ladder 2^(n^k). Requires matplotlib (pip install matplotlib)."""
from __future__ import annotations
import math
import matplotlib.pyplot as plt

ns = list(range(1, 9))

fig, axes = plt.subplots(1, 2, figsize=(12, 5))

# Left: collapsing exponential ladder 2^(k*n)  (plot exponent k*n)
for k in (1, 2, 3):
    axes[0].plot(ns, [k * n for n in ns], marker="o", label=f"k={k}")
axes[0].set_title("Collapsing ladder: exponent of 2^(k*n) = k*n\n"
                  "(all rungs polynomially comparable -> one p-degree)")
axes[0].set_xlabel("n"); axes[0].set_ylabel("log2(size) = k*n"); axes[0].legend()

# Right: separating power ladder 2^(n^k)  (plot exponent n^k, log scale)
for k in (1, 2, 3):
    axes[1].plot(ns, [n ** k for n in ns], marker="s", label=f"k={k}")
axes[1].set_yscale("log")
axes[1].set_title("Power ladder: exponent of 2^(n^k) = n^k\n"
                  "(super-polynomial gaps -> infinite height)")
axes[1].set_xlabel("n"); axes[1].set_ylabel("log2(size) = n^k (log scale)")
axes[1].legend()

plt.tight_layout()
plt.savefig("ladders.png", dpi=130)
print("wrote ladders.png")
