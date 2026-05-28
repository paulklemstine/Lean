#!/usr/bin/env python3
"""
Visualization: GFF Covariance Kernel and Partition Function

Top row: Covariance kernels K(i,j) for cycle graphs with different pinned vertices.
Bottom left: Partition function prefactor Z vs graph size n.
Bottom right: GFF energy landscape showing gauge invariance (energy vs shift constant).

This visualization demonstrates the statistical mechanics ↔ spectral graph theory bridge:
the covariance structure is entirely determined by the Laplacian pseudoinverse.
"""

import numpy as np
import matplotlib.pyplot as plt


def cycle_laplacian(n):
    L = np.zeros((n, n))
    for k in range(n):
        i, j = k, (k + 1) % n
        L[i, i] += 1; L[j, j] += 1
        L[i, j] -= 1; L[j, i] -= 1
    return L


def effective_resistance_matrix(L):
    Lp = np.linalg.pinv(L)
    diag = np.diag(Lp)
    return diag[:, None] + diag[None, :] - 2 * Lp


def covariance_kernel(R, base=0):
    Rb = R[:, base]
    return (Rb[:, None] + Rb[None, :] - R) / 2


def reduced_laplacian(L, pin=0):
    idx = [i for i in range(L.shape[0]) if i != pin]
    return L[np.ix_(idx, idx)]


fig = plt.figure(figsize=(14, 10))
fig.suptitle("Gaussian Free Field: Covariance Structure and Partition Function",
             fontsize=14, fontweight='bold')

# Top row: Covariance kernels for C_8 with different base vertices
n = 8
L = cycle_laplacian(n)
R = effective_resistance_matrix(L)

for idx, base in enumerate([0, 2, 4]):
    ax = fig.add_subplot(2, 3, idx + 1)
    K = covariance_kernel(R, base=base)
    im = ax.imshow(K, cmap='RdBu_r', interpolation='nearest',
                   vmin=-K.max(), vmax=K.max())
    ax.set_title(f"$C_8$ Covariance\n(base = {base})", fontsize=11)
    ax.set_xlabel("$j$")
    if idx == 0:
        ax.set_ylabel("$i$")
    plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)

# Bottom left: Partition function vs n
ax_z = fig.add_subplot(2, 3, 4)
ns = np.arange(3, 25)
Zs = [(2 * np.pi) ** ((n-1) / 2) / np.sqrt(n) for n in ns]
ax_z.semilogy(ns, Zs, 'b-o', markersize=4, linewidth=1.5)
ax_z.set_xlabel("Graph size $n$", fontsize=11)
ax_z.set_ylabel("Partition prefactor $Z$", fontsize=11)
ax_z.set_title("$Z(C_n) = (2\\pi)^{(n-1)/2} / \\sqrt{n}$", fontsize=11)
ax_z.grid(True, alpha=0.3)

# Bottom center: det(L_red) vs n
ax_det = fig.add_subplot(2, 3, 5)
dets = [np.linalg.det(reduced_laplacian(cycle_laplacian(n))) for n in ns]
ax_det.plot(ns, dets, 'r-s', markersize=4, linewidth=1.5, label='Numerical')
ax_det.plot(ns, ns, 'k--', linewidth=1, alpha=0.5, label='$\\det = n$ (exact)')
ax_det.set_xlabel("Graph size $n$", fontsize=11)
ax_det.set_ylabel("$\\det(L_{\\mathrm{red}})$", fontsize=11)
ax_det.set_title("Reduced Laplacian Determinant", fontsize=11)
ax_det.legend(fontsize=9)
ax_det.grid(True, alpha=0.3)

# Bottom right: Gauge invariance demonstration
ax_gauge = fig.add_subplot(2, 3, 6)
n_gauge = 6
L_gauge = cycle_laplacian(n_gauge)
np.random.seed(42)
x = np.random.randn(n_gauge)
cs = np.linspace(-5, 5, 100)
energies = [((x + c) @ L_gauge @ (x + c)) for c in cs]
ax_gauge.plot(cs, energies, 'g-', linewidth=2)
ax_gauge.axhline(y=x @ L_gauge @ x, color='k', linestyle='--', alpha=0.5,
                 label=f'$E(x) = {x @ L_gauge @ x:.3f}$')
ax_gauge.set_xlabel("Constant shift $c$", fontsize=11)
ax_gauge.set_ylabel("Energy $E(x + c \\cdot \\mathbf{1})$", fontsize=11)
ax_gauge.set_title("Gauge Invariance: $E$ constant in $c$", fontsize=11)
ax_gauge.legend(fontsize=9)
ax_gauge.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("viz_covariance_kernel.png", dpi=150, bbox_inches='tight')
print("Saved viz_covariance_kernel.png")
