"""Visualize the deformation factors c_k = 1 - t^{2k+1} and the monomial scaling
of phi_t across the parameter t. Saves plethystic_triviality.png."""
from fractions import Fraction
from typing import List
import numpy as np
import matplotlib.pyplot as plt

def cc(t: float, k: int) -> float:
    return 1.0 - t ** (2 * k + 1)

ts = np.linspace(-0.99, 1.5, 400)
fig, axes = plt.subplots(1, 2, figsize=(13, 5))

# Left: the scalar factors c_k(t) for several k; all vanish simultaneously at t = 1.
for k in range(5):
    axes[0].plot(ts, [cc(t, k) for t in ts], label=f"c_{k} = 1 - t^{2*k+1}")
axes[0].axvline(1.0, color="red", ls="--", lw=1, label="t = 1 (total collapse)")
axes[0].axvline(0.0, color="green", ls=":", lw=1, label="t = 0 (identity)")
axes[0].axhline(0.0, color="black", lw=0.5)
axes[0].set_title("Diagonal deformation factors $c_k = 1 - t^{2k+1}$")
axes[0].set_xlabel("t"); axes[0].set_ylabel("$c_k$"); axes[0].legend(fontsize=8)

# Right: the scaling factor phi_t applies to a monomial p1^a p3^b p5^c = prod c_k^{e_k}.
monomials = {"$p_1^2$": [2, 0, 0], "$p_1 p_3$": [1, 1, 0],
             "$p_3^2$": [0, 2, 0], "$p_1 p_5$": [1, 0, 1]}
for label, exps in monomials.items():
    vals = []
    for t in ts:
        f = 1.0
        for k, e in enumerate(exps):
            f *= cc(t, k) ** e
        vals.append(f)
    axes[1].plot(ts, vals, label=label)
axes[1].axvline(1.0, color="red", ls="--", lw=1)
axes[1].axvline(0.0, color="green", ls=":", lw=1)
axes[1].axhline(1.0, color="black", lw=0.5)
axes[1].set_title(r"Monomial rescaling $\prod_k c_k^{e_k}$ applied by $\varphi_t$")
axes[1].set_xlabel("t"); axes[1].set_ylabel("scaling factor"); axes[1].legend(fontsize=8)

plt.tight_layout()
plt.savefig("plethystic_triviality.png", dpi=140)
print("saved plethystic_triviality.png")
