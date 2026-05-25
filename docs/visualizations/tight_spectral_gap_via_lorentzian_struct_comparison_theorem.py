#!/usr/bin/env python3
"""
Visualization 2: Comparison Theorem and Dirichlet Form Domination

Shows how the comparison theorem transfers spectral gap bounds:
if E₁(f) ≥ c·E₂(f) for all f, then γ₁ ≥ c·γ₂.

Visualizes the Dirichlet form ratio for different test functions
and the resulting spectral gap transfer.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

def build_chain(pi):
    n = len(pi) - 1
    P = np.zeros((n + 1, n + 1))
    for i in range(n + 1):
        if pi[i] == 0:
            P[i, i] = 1.0
            continue
        if i > 0 and pi[i - 1] > 0:
            P[i, i - 1] = 0.5 * min(1.0, pi[i - 1] / pi[i])
        if i < n and pi[i + 1] > 0:
            P[i, i + 1] = 0.5 * min(1.0, pi[i + 1] / pi[i])
        P[i, i] = 1.0 - np.sum(P[i, :])
    return P

def dirichlet_form(pi, P, f):
    n = len(pi)
    result = 0.0
    for x in range(n):
        for y in range(n):
            result += pi[x] * P[x, y] * (f[x] - f[y]) ** 2
    return 0.5 * result

def variance(pi, f):
    mean = np.sum(pi * f)
    return np.sum(pi * (f - mean) ** 2)

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

n = 50
coeffs = np.array([comb(n, k) for k in range(n + 1)], dtype=float)
pi = coeffs / np.sum(coeffs)
P1 = build_chain(pi)

# Create chains with different laziness parameters
lazy_params = [0.0, 0.2, 0.4, 0.6, 0.8]
chains = [(1 - lam) * P1 + lam * np.eye(n + 1) for lam in lazy_params]

# Panel 1: Eigenvalue spectra
for lam, P in zip(lazy_params, chains):
    eigs = np.sort(np.real(np.linalg.eigvals(P)))[::-1]
    axes[0, 0].plot(range(min(20, len(eigs))), eigs[:20], 'o-',
                    label=f'λ={lam:.1f}', markersize=3, linewidth=1)

axes[0, 0].set_xlabel('Eigenvalue index', fontsize=11)
axes[0, 0].set_ylabel('Eigenvalue', fontsize=11)
axes[0, 0].set_title('Eigenvalue Spectra of Compared Chains', fontsize=13)
axes[0, 0].legend(fontsize=9)
axes[0, 0].grid(True, alpha=0.3)

# Panel 2: Dirichlet form ratios
states = np.arange(n + 1, dtype=float)
np.random.seed(42)
test_fns = [states / n, (states / n) ** 2, np.sin(np.pi * states / n)]
test_names = ['f(k)=k/n', 'f(k)=(k/n)²', 'f(k)=sin(πk/n)']

for fname, f in zip(test_names, test_fns):
    E1 = dirichlet_form(pi, P1, f)
    ratios = []
    for lam, P in zip(lazy_params, chains):
        E = dirichlet_form(pi, P, f)
        ratios.append(E1 / E if E > 1e-15 else float('inf'))
    axes[0, 1].plot(lazy_params, ratios, 'o-', label=fname, markersize=5)

theoretical = [1.0 / (1.0 - lam) for lam in lazy_params]
axes[0, 1].plot(lazy_params, theoretical, 'k--', label='Theoretical: 1/(1-λ)',
                linewidth=2, alpha=0.5)

axes[0, 1].set_xlabel('Laziness parameter λ', fontsize=11)
axes[0, 1].set_ylabel('E₁(f)/E_λ(f)', fontsize=11)
axes[0, 1].set_title('Dirichlet Form Domination Ratios', fontsize=13)
axes[0, 1].legend(fontsize=9)
axes[0, 1].grid(True, alpha=0.3)

# Panel 3: Poincaré inequality verification
P = P1
f_range = np.linspace(0, 1, 200)
poincare_ratios = []
for freq in range(1, 15):
    f = np.sin(freq * np.pi * states / n)
    v = variance(pi, f)
    e = dirichlet_form(pi, P, f)
    poincare_ratios.append((freq, v / e if e > 1e-15 else 0))

freqs, ratios = zip(*poincare_ratios)
gap = 1.0 - np.sort(np.abs(np.real(np.linalg.eigvals(P))))[::-1][1]
poincare_const = 1.0 / gap

axes[1, 0].bar(freqs, ratios, color='#2196F3', alpha=0.7, label='Var(f)/E(f,f)')
axes[1, 0].axhline(y=poincare_const, color='red', linestyle='--',
                    label=f'C_P = 1/λ₁ = {poincare_const:.1f}', linewidth=2)
axes[1, 0].set_xlabel('Frequency (sin modes)', fontsize=11)
axes[1, 0].set_ylabel('Var(f) / E(f,f)', fontsize=11)
axes[1, 0].set_title('Poincaré Inequality: All Ratios ≤ C_P', fontsize=13)
axes[1, 0].legend(fontsize=10)
axes[1, 0].grid(True, alpha=0.3)

# Panel 4: Spectral gap transfer via comparison
n_values = [10, 20, 30, 50, 75, 100]
for c_factor, color, label in [(1.0, '#2196F3', 'c=1 (original)'),
                                 (0.5, '#FF5722', 'c=0.5 (half speed)'),
                                 (0.25, '#4CAF50', 'c=0.25 (quarter speed)')]:
    gaps = []
    for n in n_values:
        coeffs = np.array([comb(n, k) for k in range(n + 1)], dtype=float)
        pi = coeffs / np.sum(coeffs)
        P = build_chain(pi)
        eigs = np.sort(np.abs(np.real(np.linalg.eigvals(P))))[::-1]
        gap = c_factor * (1.0 - eigs[1])
        gaps.append(gap)

    axes[1, 1].loglog(n_values, gaps, 'o-', color=color, label=label,
                      markersize=6, linewidth=1.5)

# Reference lines
axes[1, 1].loglog(n_values, [1/(2*n) for n in n_values], 'k--', alpha=0.3,
                  label='Θ(1/n)')
axes[1, 1].loglog(n_values, [1/(8*(n+1)**2) for n in n_values], 'k:', alpha=0.3,
                  label='Θ(1/n²)')

axes[1, 1].set_xlabel('n', fontsize=11)
axes[1, 1].set_ylabel('Spectral gap', fontsize=11)
axes[1, 1].set_title('Gap Transfer via Comparison Theorem', fontsize=13)
axes[1, 1].legend(fontsize=9, loc='lower left')
axes[1, 1].grid(True, alpha=0.3)

plt.suptitle('Comparison Theorem for Spectral Gaps', fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('comparison_theorem.png', dpi=150, bbox_inches='tight')
print("Saved comparison_theorem.png")
