"""Visualize the tight logarithmic depth clock: residual energy vs depth."""
import math
import numpy as np
import matplotlib.pyplot as plt

rho, E, eps = 0.6, 100.0, 1e-3
N = max(0, math.ceil(math.log(eps / E) / math.log(rho)))   # hodgeDepth
ks = np.arange(0, N + 6)
residual = rho ** ks * E

fig, ax = plt.subplots(figsize=(8, 5))
ax.semilogy(ks, residual, "o-", label=r"residual $\rho^k E$ (worst case)")
ax.axhline(eps, color="crimson", ls="--", label=r"tolerance $\varepsilon$")
ax.axvline(N, color="seagreen", ls=":", label=fr"hodgeDepth $N={N}$")
ax.fill_between(ks[ks < N], eps, residual[ks < N], where=residual[ks < N] > eps,
                color="orange", alpha=0.25, label="overshoot (tightness)")
ax.set_xlabel("depth k (layers)"); ax.set_ylabel("residual Dirichlet energy")
ax.set_title("Tight logarithmic depth clock: every depth < N overshoots")
ax.legend(); fig.tight_layout(); plt.savefig("depth_clock.png", dpi=150)
print("wrote depth_clock.png")
