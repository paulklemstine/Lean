#!/usr/bin/env python3
"""
Visualization: Coefficient profiles of symmetric power Euler polynomials.

Shows how the coefficient magnitudes of Sym^n Euler polynomials form
unimodal profiles for self-dual parameters (β = α⁻¹), illustrating
the palindromic symmetry proven in the Lean formalization.
"""

import numpy as np
import matplotlib.pyplot as plt


def symm_pow_roots(n, alpha, beta):
    return [alpha**(n - i) * beta**i for i in range(n + 1)]

def euler_poly_from_roots(roots):
    poly = np.array([1.0 + 0j])
    for r in roots:
        poly = np.convolve(poly, np.array([-r, 1.0]))
    return poly

def symm_pow_euler_coeffs(n, alpha, beta):
    return euler_poly_from_roots(symm_pow_roots(n, alpha, beta))


fig, axes = plt.subplots(2, 3, figsize=(14, 9))
fig.suptitle("Symmetric Power Euler Polynomial Coefficients\n"
             r"$\mathrm{Sym}^n(\alpha, \alpha^{-1})$: Self-Dual Case",
             fontsize=14, fontweight='bold')

alpha = 2.0
ns = [2, 4, 6, 8, 10, 12]

for ax, n in zip(axes.flat, ns):
    coeffs = symm_pow_euler_coeffs(n, alpha, 1.0/alpha)
    abs_coeffs = np.abs(coeffs.real)
    indices = np.arange(len(abs_coeffs))

    colors = plt.cm.viridis(abs_coeffs / max(abs_coeffs) if max(abs_coeffs) > 0 else abs_coeffs)
    ax.bar(indices, abs_coeffs, color=colors, edgecolor='black', linewidth=0.5)
    ax.set_title(f"$\\mathrm{{Sym}}^{{{n}}}$  (degree {n+1})", fontsize=11)
    ax.set_xlabel("Coefficient index $k$", fontsize=9)
    ax.set_ylabel("$|a_k|$", fontsize=9)

    # Mark the palindromic symmetry axis
    mid = len(abs_coeffs) / 2 - 0.5
    ax.axvline(mid, color='red', linestyle='--', alpha=0.5, label='Symmetry axis')
    ax.legend(fontsize=7, loc='upper right')

plt.tight_layout()
plt.savefig("coefficient_profiles.png", dpi=150, bbox_inches='tight')
print("Saved coefficient_profiles.png")
