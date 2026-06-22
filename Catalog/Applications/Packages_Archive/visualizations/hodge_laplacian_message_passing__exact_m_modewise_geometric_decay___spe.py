"""Visualize exact geometric decay of each spectral mode and the
spectral-gap-controlled oversmoothing rate. Saves 'oversmoothing_modes.png'."""
from __future__ import annotations
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

def path_laplacian(n: int) -> np.ndarray:
    L = np.zeros((n, n))
    for i in range(n - 1):
        L[i, i] += 1; L[i + 1, i + 1] += 1
        L[i, i + 1] -= 1; L[i + 1, i] -= 1
    return L

n = 12
L = path_laplacian(n)
w, V = np.linalg.eigh(L)
alpha = 1.0 / w[-1]
depths = np.arange(0, 60)

fig, ax = plt.subplots(1, 2, figsize=(13, 5))

# Left: energy of each mode vs depth (closed form (1-alpha nu)^(2k))
for idx in range(0, n, 2):
    nu = w[idx]
    energies = (1.0 - alpha * nu) ** (2 * depths)
    ax[0].semilogy(depths, np.maximum(energies, 1e-16),
                   label=f"nu={nu:.3f}")
ax[0].set_title("Exact modewise energy decay  (1 - alpha*nu)^(2k)")
ax[0].set_xlabel("depth k"); ax[0].set_ylabel("residual energy")
ax[0].legend(fontsize=8); ax[0].grid(True, which="both", alpha=0.3)

# Right: necessary depth vs spectral gap mu
mus = np.linspace(0.02, 1.0, 200)
eps = 1e-4
sigmas = (1.0 - alpha * mus) ** 2
ks = np.log(1.0 / eps) / np.log(1.0 / sigmas)
ax[1].plot(mus, ks, color="crimson")
ax[1].set_title("Necessary depth vs spectral gap (eps=1e-4)")
ax[1].set_xlabel("spectral gap mu"); ax[1].set_ylabel("required depth k*")
ax[1].grid(True, alpha=0.3)

fig.tight_layout()
fig.savefig("oversmoothing_modes.png", dpi=130)
print("saved oversmoothing_modes.png")
