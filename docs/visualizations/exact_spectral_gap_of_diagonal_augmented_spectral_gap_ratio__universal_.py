#!/usr/bin/env python3
"""
Visualization 1: Spectral Gap Ratio γ_hyb / γ_loc vs n for various dimensions d.

Demonstrates that the ratio is EXACTLY 2 for all n and d, disproving
the conjecture (d+1)/d for d ≥ 2. Plots the conjectured values as
dashed lines for comparison.
"""
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def compute_spectral_gaps_bruteforce(n, d):
    """Brute force spectral gap computation for small n, d."""
    from itertools import product as iprod
    gamma_loc = float('inf')
    gamma_hyb = float('inf')
    for freq in iprod(range(n), repeat=d):
        if all(k == 0 for k in freq):
            continue
        lam_loc = sum(2 - 2*math.cos(2*math.pi*k/n) for k in freq)
        lam_hyb = lam_loc + (2 - 2*math.cos(2*math.pi*sum(freq)/n))
        gamma_loc = min(gamma_loc, lam_loc)
        gamma_hyb = min(gamma_hyb, lam_hyb)
    return gamma_loc, gamma_hyb


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: ratio vs n for different d
ax1 = axes[0]
colors = ['#e74c3c', '#2ecc71', '#3498db', '#9b59b6']
dims = [1, 2, 3, 4]

for idx, d in enumerate(dims):
    n_values = list(range(3, 25)) if d <= 3 else list(range(3, 12))
    ratios = []
    for n in n_values:
        gl, gh = compute_spectral_gaps_bruteforce(n, d)
        ratios.append(gh / gl)

    ax1.plot(n_values, ratios, 'o-', color=colors[idx],
             label=f'd = {d} (actual)', markersize=6, linewidth=2)

    # Conjectured (d+1)/d
    conj = (d + 1) / d
    ax1.axhline(y=conj, color=colors[idx], linestyle='--', alpha=0.4,
                label=f'd = {d} (conjecture {conj:.2f})')

ax1.axhline(y=2.0, color='black', linestyle='-', linewidth=2, alpha=0.3,
            label='True ratio = 2')
ax1.set_xlabel('Modulus n', fontsize=13)
ax1.set_ylabel('γ_hyb / γ_loc', fontsize=13)
ax1.set_title('Spectral Gap Ratio: Universal Doubling', fontsize=14)
ax1.legend(fontsize=8, loc='center right')
ax1.set_ylim(0.8, 2.5)
ax1.grid(True, alpha=0.3)

# Right panel: spectral gaps themselves
ax2 = axes[1]
n_range = np.arange(3, 51)
gl_formula = 4 * np.sin(np.pi / n_range) ** 2
gh_formula = 2 * gl_formula

ax2.plot(n_range, gl_formula, 'b-', linewidth=2.5, label='γ_loc = 4sin²(π/n)')
ax2.plot(n_range, gh_formula, 'r-', linewidth=2.5, label='γ_hyb = 8sin²(π/n)')
ax2.fill_between(n_range, gl_formula, gh_formula, alpha=0.15, color='green',
                  label='Speedup region')

# Mark some brute-force computed points
for d in [1, 2, 3]:
    marker = ['s', '^', 'D'][d-1]
    n_pts = list(range(3, 20))
    gl_pts = [compute_spectral_gaps_bruteforce(n, d)[0] for n in n_pts]
    gh_pts = [compute_spectral_gaps_bruteforce(n, d)[1] for n in n_pts]
    ax2.scatter(n_pts, gl_pts, marker=marker, s=30, alpha=0.6, color='blue')
    ax2.scatter(n_pts, gh_pts, marker=marker, s=30, alpha=0.6, color='red',
               label=f'd={d} (computed)' if d == 1 else f'd={d}')

ax2.set_xlabel('Modulus n', fontsize=13)
ax2.set_ylabel('Spectral Gap', fontsize=13)
ax2.set_title('Spectral Gaps: Local vs Hybrid', fontsize=14)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_yscale('log')

plt.tight_layout()
plt.savefig('spectral_ratio.png', dpi=150, bbox_inches='tight')
print("Saved spectral_ratio.png")
