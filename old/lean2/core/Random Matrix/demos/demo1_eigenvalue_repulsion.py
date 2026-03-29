#!/usr/bin/env python3
"""
Demo 1: Eigenvalue Repulsion — Visual Evidence
================================================
Compares the eigenvalue spacing of random matrices (GOE/GUE/GSE)
against independent random points, revealing the repulsion phenomenon.

Run: python demo1_eigenvalue_repulsion.py
Outputs: eigenvalue_repulsion.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

np.random.seed(42)

def sample_GOE(n):
    """Sample from Gaussian Orthogonal Ensemble (β=1)."""
    A = np.random.randn(n, n)
    H = (A + A.T) / np.sqrt(2)
    return np.linalg.eigvalsh(H)

def sample_GUE(n):
    """Sample from Gaussian Unitary Ensemble (β=2)."""
    A = (np.random.randn(n, n) + 1j * np.random.randn(n, n)) / np.sqrt(2)
    H = (A + A.conj().T) / np.sqrt(2)
    return np.linalg.eigvalsh(H)

def sample_GSE(n):
    """
    Sample from Gaussian Symplectic Ensemble (β=4).
    Uses the 2n×2n real representation of quaternionic self-dual matrices.
    """
    # Quaternionic structure: H = A + Bi + Cj + Dk
    A = np.random.randn(n, n)
    B = np.random.randn(n, n)
    C = np.random.randn(n, n)
    D = np.random.randn(n, n)
    # Symmetrize
    A = (A + A.T) / 2
    B = (B - B.T) / 2
    C = (C - C.T) / 2
    D = (D + D.T) / 2
    # Build 2n × 2n real matrix
    H = np.block([
        [A + D, -B - C],
        [B - C,  A - D]
    ]) / np.sqrt(2)
    H = (H + H.T) / 2
    eigs = np.linalg.eigvalsh(H)
    # GSE eigenvalues come in pairs; take every other one
    return eigs[::2]

# ─── Parameters ───
N = 100          # Matrix size
n_samples = 500  # Number of matrices to sample

# ─── Collect nearest-neighbor spacings ───
def normalized_spacings(eigenvalues_list):
    """Compute nearest-neighbor spacings, normalized to mean 1."""
    all_spacings = []
    for eigs in eigenvalues_list:
        eigs_sorted = np.sort(eigs)
        # Use bulk eigenvalues only (avoid edge effects)
        n = len(eigs_sorted)
        bulk = eigs_sorted[n//4 : 3*n//4]
        spacings = np.diff(bulk)
        # Normalize by local mean spacing
        mean_spacing = np.mean(spacings)
        if mean_spacing > 0:
            all_spacings.extend(spacings / mean_spacing)
    return np.array(all_spacings)

print("Sampling GOE matrices...")
goe_eigs = [sample_GOE(N) for _ in range(n_samples)]
goe_spacings = normalized_spacings(goe_eigs)

print("Sampling GUE matrices...")
gue_eigs = [sample_GUE(N) for _ in range(n_samples)]
gue_spacings = normalized_spacings(gue_eigs)

print("Sampling GSE matrices...")
gse_eigs = [sample_GSE(N) for _ in range(n_samples)]
gse_spacings = normalized_spacings(gse_eigs)

print("Generating Poisson (independent) spacings...")
poisson_spacings = np.random.exponential(1.0, size=len(goe_spacings))

# ─── Wigner surmise (exact for 2×2) ───
s = np.linspace(0, 4, 500)

def wigner_surmise(s, beta):
    """Wigner surmise for nearest-neighbor spacing."""
    if beta == 1:
        return (np.pi * s / 2) * np.exp(-np.pi * s**2 / 4)
    elif beta == 2:
        return (32 * s**2 / np.pi**2) * np.exp(-4 * s**2 / np.pi)
    elif beta == 4:
        return (2**18 * s**4 / (3**6 * np.pi**3)) * np.exp(-64 * s**2 / (9 * np.pi))

# ─── Plot ───
fig = plt.figure(figsize=(16, 12))
fig.suptitle("Eigenvalue Repulsion in Random Matrices\n"
             "Nearest-Neighbor Spacing Distributions",
             fontsize=16, fontweight='bold', y=0.98)

gs = GridSpec(2, 2, hspace=0.35, wspace=0.3)

configs = [
    (gs[0, 0], poisson_spacings, "Poisson (Independent Points)",
     lambda s: np.exp(-s), '#888888', 'No repulsion:\nP(s→0) → 1'),
    (gs[0, 1], goe_spacings, "GOE (β = 1, Real Symmetric)",
     lambda s: wigner_surmise(s, 1), '#e74c3c', 'Linear repulsion:\nP(s) ~ s'),
    (gs[1, 0], gue_spacings, "GUE (β = 2, Complex Hermitian)",
     lambda s: wigner_surmise(s, 2), '#3498db', 'Quadratic repulsion:\nP(s) ~ s²'),
    (gs[1, 1], gse_spacings, "GSE (β = 4, Quaternionic Self-Dual)",
     lambda s: wigner_surmise(s, 4), '#2ecc71', 'Quartic repulsion:\nP(s) ~ s⁴'),
]

for subplot, spacings, title, theory_fn, color, annotation in configs:
    ax = fig.add_subplot(subplot)
    ax.hist(spacings, bins=80, density=True, alpha=0.6, color=color,
            edgecolor='white', linewidth=0.5, label='Simulation')
    ax.plot(s, theory_fn(s), 'k-', linewidth=2.5, label='Theory')
    ax.set_xlabel('Normalized Spacing s', fontsize=12)
    ax.set_ylabel('P(s)', fontsize=12)
    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.set_xlim(0, 4)
    ax.set_ylim(0, 1.2)
    ax.legend(fontsize=10, loc='upper right')
    ax.text(2.8, 0.85, annotation, fontsize=10, color=color,
            fontweight='bold', ha='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='white', alpha=0.8))

fig.text(0.5, 0.01,
         "The key signature of repulsion: P(s→0) → 0 for random matrices, but P(s→0) → 1 for independent points.\n"
         "Stronger repulsion (higher β) means eigenvalues are more rigidly spaced.",
         ha='center', fontsize=11, style='italic',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', alpha=0.9))

plt.savefig('eigenvalue_repulsion.png', dpi=150, bbox_inches='tight')
print("Saved: eigenvalue_repulsion.png")
plt.close()
