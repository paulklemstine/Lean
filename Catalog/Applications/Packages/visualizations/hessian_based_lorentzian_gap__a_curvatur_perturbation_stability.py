"""
Visualization 2: Perturbation Stability of the Hessian Gap

Shows how the Hessian gap degrades under coefficient perturbation,
confirming the formal stability theorem: if the entrywise log-Hessian
difference is bounded by delta, the gap decreases by at most n^2 * delta.
The actual gap typically stays well above the theoretical lower bound.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as cartesian_product


def _eval_poly(coeffs, point):
    val = 0.0
    for alpha, c in coeffs.items():
        val += c * np.prod([point[i] ** alpha[i] for i in range(len(alpha))])
    return val

def _grad(coeffs, n):
    grad = np.zeros(n)
    for alpha, c in coeffs.items():
        for i in range(n):
            if alpha[i] > 0:
                grad[i] += c * alpha[i]
    return grad

def _hessian(coeffs, n):
    H = np.zeros((n, n))
    for alpha, c in coeffs.items():
        for i in range(n):
            for j in range(n):
                if i == j:
                    if alpha[i] >= 2:
                        H[i][j] += c * alpha[i] * (alpha[i] - 1)
                else:
                    if alpha[i] >= 1 and alpha[j] >= 1:
                        H[i][j] += c * alpha[i] * alpha[j]
    return H

def _log_hessian(coeffs, n):
    ones = np.ones(n)
    p1 = _eval_poly(coeffs, ones)
    g = _grad(coeffs, n)
    H = _hessian(coeffs, n)
    return H / p1 - np.outer(g, g) / p1**2

def _restrict_sum_zero(M):
    n = M.shape[0]
    ones = np.ones(n) / np.sqrt(n)
    basis = []
    for k in range(n):
        e = np.zeros(n)
        e[k] = 1.0
        e -= np.dot(e, ones) * ones
        for b in basis:
            e -= np.dot(e, b) * b
        norm = np.linalg.norm(e)
        if norm > 1e-10:
            basis.append(e / norm)
    return np.array(basis) @ M @ np.array(basis).T

def tfim_coeffs(n, J=1.0, h=1.0):
    configs = list(cartesian_product([0, 1], repeat=n))
    energies = []
    for config in configs:
        spins = [2*s - 1 for s in config]
        E = sum(-J * spins[i] * spins[(i+1)%n] for i in range(n))
        E -= h * sum(spins)
        energies.append(E)
    energies = np.array(energies, dtype=float)
    weights = np.exp(-energies)
    Z = weights.sum()
    return {c: float(weights[i]/Z) for i, c in enumerate(configs)}


fig, axes = plt.subplots(1, 2, figsize=(13, 5))

# Panel 1: Gap vs noise level for different n
rng = np.random.RandomState(42)
for n in [4, 5, 6]:
    base = tfim_coeffs(n)
    L_base = _log_hessian(base, n)
    M_base = _restrict_sum_zero(-L_base)
    base_gap = float(np.linalg.eigvalsh(M_base)[0])

    noise_levels = np.linspace(0, 0.3, 30)
    actual_gaps = []
    predicted_gaps = []

    for noise in noise_levels:
        if noise == 0:
            actual_gaps.append(base_gap)
            predicted_gaps.append(base_gap)
            continue
        noisy = {k: max(v + rng.normal(0, noise * v), 1e-15) for k, v in base.items()}
        total = sum(noisy.values())
        noisy = {k: v/total for k, v in noisy.items()}
        L_noisy = _log_hessian(noisy, n)
        M_noisy = _restrict_sum_zero(-L_noisy)
        actual_gap = float(np.linalg.eigvalsh(M_noisy)[0])
        actual_gaps.append(actual_gap)
        delta = np.max(np.abs(L_base - L_noisy))
        predicted_gaps.append(base_gap - n**2 * delta)

    axes[0].plot(noise_levels, actual_gaps, '-', linewidth=2, label=f'Actual (n={n})')
    axes[0].plot(noise_levels, predicted_gaps, '--', linewidth=1, alpha=0.6,
                 label=f'Bound (n={n})')

axes[0].axhline(y=0, color='red', linestyle=':', alpha=0.5)
axes[0].set_xlabel('Noise level (relative)', fontsize=12)
axes[0].set_ylabel('Hessian Gap', fontsize=12)
axes[0].set_title('Gap Stability Under Perturbation', fontsize=13)
axes[0].legend(fontsize=9)
axes[0].grid(True, alpha=0.3)

# Panel 2: Heatmap of log-Hessian
n = 6
coeffs = tfim_coeffs(n)
L = _log_hessian(coeffs, n)
im = axes[1].imshow(-L, cmap='RdBu_r', aspect='equal')
axes[1].set_title(f'$-\\nabla^2 \\log P$ at 1 (n={n})', fontsize=13)
axes[1].set_xlabel('Variable index j', fontsize=12)
axes[1].set_ylabel('Variable index i', fontsize=12)
plt.colorbar(im, ax=axes[1], shrink=0.8)

plt.suptitle('Perturbation Stability & Log-Hessian Structure',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('perturbation_stability.png', dpi=150, bbox_inches='tight')
print("Saved perturbation_stability.png")
