"""Visualization: the derivative tower of e^X, 1/(1-X), and the derangement EGF,
showing how Maclaurin extraction reads off the counting sequence at the origin."""
import numpy as np
import matplotlib.pyplot as plt
from math import factorial


def egf_coeffs(seq, n):
    return np.array([seq[k] / factorial(k) for k in range(n)], dtype=float)


N = 8
sets_seq = [1] * N                                   # E: e^X
orders_seq = [factorial(k) for k in range(N)]        # L: 1/(1-X)
derange = [1, 0, 1, 2, 9, 44, 265, 1854]             # D: e^{-X}/(1-X)

fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
data = [("E (sets), EGF = e^X", sets_seq),
        ("L (linear orders), EGF = 1/(1-X)", orders_seq),
        ("D (derangements)", derange)]

for ax, (title, seq) in zip(axes, data):
    ks = np.arange(N)
    # Maclaurin extraction reproduces the raw counts a_k = k-fold deriv at origin.
    ax.bar(ks - 0.2, seq, width=0.4, label="count F[k]", color="#2a6f97")
    ax.bar(ks + 0.2, [factorial(k) * egf_coeffs(seq, N)[k] for k in range(N)],
           width=0.4, label="k! * coeff_k(EGF)", color="#e29578")
    ax.set_yscale("symlog")
    ax.set_title(title)
    ax.set_xlabel("k")
    ax.legend(fontsize=8)

fig.suptitle("Species Maclaurin extraction: counts recovered from the derivative tower")
fig.tight_layout()
fig.savefig("species_taylor_tower.png", dpi=130)
print("wrote species_taylor_tower.png")
