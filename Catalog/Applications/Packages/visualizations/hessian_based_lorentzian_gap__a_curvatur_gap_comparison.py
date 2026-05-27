"""
Visualization 3: Hessian Gap vs Mass-Ratio Surrogate Comparison

Compares the Hessian Lorentzian gap with the traditional mass-ratio surrogate
across different TFIM parameter regimes. Shows that the Hessian gap provides
a more stable and informative certificate that remains well-defined even when
the mass ratio collapses to near-zero.
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


fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Panel 1: Hessian gap vs coupling J for different n
J_range = np.linspace(0.1, 3.0, 25)
for n in [4, 5, 6, 7]:
    gaps = []
    for J in J_range:
        coeffs = tfim_coeffs(n, J=J, h=1.0)
        L = _log_hessian(coeffs, n)
        M = _restrict_sum_zero(-L)
        gaps.append(float(np.linalg.eigvalsh(M)[0]))
    axes[0,0].plot(J_range, gaps, '-', linewidth=2, label=f'n={n}')
axes[0,0].set_xlabel('Coupling J', fontsize=11)
axes[0,0].set_ylabel('Hessian Gap κ', fontsize=11)
axes[0,0].set_title('Hessian Gap vs Coupling', fontsize=12)
axes[0,0].legend()
axes[0,0].grid(True, alpha=0.3)

# Panel 2: Mass ratio vs coupling J
for n in [4, 5, 6, 7]:
    ratios = []
    for J in J_range:
        coeffs = tfim_coeffs(n, J=J, h=1.0)
        vals = [v for v in coeffs.values() if v > 0]
        ratios.append(min(vals)/max(vals) if vals else 0)
    axes[0,1].semilogy(J_range, [max(r, 1e-20) for r in ratios], '-', linewidth=2, label=f'n={n}')
axes[0,1].set_xlabel('Coupling J', fontsize=11)
axes[0,1].set_ylabel('Mass Ratio (log scale)', fontsize=11)
axes[0,1].set_title('Mass Ratio vs Coupling', fontsize=12)
axes[0,1].legend()
axes[0,1].grid(True, alpha=0.3)

# Panel 3: Scatter plot — Hessian gap vs mass ratio
colors = plt.cm.viridis(np.linspace(0, 1, 4))
for idx, n in enumerate([4, 5, 6, 7]):
    h_gaps = []
    m_ratios = []
    for J in np.linspace(0.1, 2.5, 30):
        coeffs = tfim_coeffs(n, J=J, h=1.0)
        L = _log_hessian(coeffs, n)
        M = _restrict_sum_zero(-L)
        h_gaps.append(float(np.linalg.eigvalsh(M)[0]))
        vals = [v for v in coeffs.values() if v > 0]
        m_ratios.append(min(vals)/max(vals))
    axes[1,0].scatter(m_ratios, h_gaps, c=[colors[idx]], s=20, alpha=0.7, label=f'n={n}')
axes[1,0].set_xlabel('Mass Ratio', fontsize=11)
axes[1,0].set_ylabel('Hessian Gap κ', fontsize=11)
axes[1,0].set_title('Hessian Gap vs Mass Ratio', fontsize=12)
axes[1,0].legend()
axes[1,0].grid(True, alpha=0.3)

# Panel 4: Field sweep h for fixed J
h_range = np.linspace(0.1, 4.0, 30)
n = 5
gaps_h = []
ratios_h = []
for h in h_range:
    coeffs = tfim_coeffs(n, J=1.0, h=h)
    L = _log_hessian(coeffs, n)
    M = _restrict_sum_zero(-L)
    gaps_h.append(float(np.linalg.eigvalsh(M)[0]))
    vals = [v for v in coeffs.values() if v > 0]
    ratios_h.append(min(vals)/max(vals))

ax2 = axes[1,1].twinx()
l1 = axes[1,1].plot(h_range, gaps_h, '-', color='#2196F3', linewidth=2, label='Hessian Gap')
l2 = ax2.plot(h_range, ratios_h, '--', color='#FF5722', linewidth=2, label='Mass Ratio')
axes[1,1].set_xlabel('Field strength h', fontsize=11)
axes[1,1].set_ylabel('Hessian Gap κ', color='#2196F3', fontsize=11)
ax2.set_ylabel('Mass Ratio', color='#FF5722', fontsize=11)
axes[1,1].set_title(f'Both Gaps vs Field (n={n}, J=1)', fontsize=12)
lines = l1 + l2
labels = [l.get_label() for l in lines]
axes[1,1].legend(lines, labels, loc='center right')
axes[1,1].grid(True, alpha=0.3)

plt.suptitle('Hessian Gap vs Mass-Ratio Surrogate: A Comprehensive Comparison',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('gap_comparison.png', dpi=150, bbox_inches='tight')
print("Saved gap_comparison.png")
