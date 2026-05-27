#!/usr/bin/env python3
"""
Visualization: Log-Concavity from Valuated Exchange

Shows the cross-domain bridge: how the four-point exchange inequality implies
local log-concavity along exchange rays. Visualizes coefficient sequences along
exchange directions in weighted uniform matroid polynomials.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
import math

# ─── Self-contained utility functions ────────────────────────────────────────

def multinomial_coeff(n, ks):
    """Compute multinomial coefficient n! / (k1! * k2! * ... * km!)."""
    result = math.factorial(n)
    for k in ks:
        result //= math.factorial(k)
    return result

def generate_homogeneous_coeffs(n_vars, degree):
    """Generate coefficients of (x1 + x2 + ... + xn)^d."""
    coeffs = {}
    def _gen(remaining_vars, remaining_degree, current_exp):
        if remaining_vars == 0:
            if remaining_degree == 0:
                exp = tuple(current_exp)
                coeffs[exp] = float(multinomial_coeff(degree, current_exp))
            return
        for k in range(remaining_degree + 1):
            _gen(remaining_vars - 1, remaining_degree - k, current_exp + [k])
    _gen(n_vars, degree, [])
    return coeffs

def compute_exchange_ray(coeffs, center, i, j, max_steps=10):
    """Extract coefficient values along the exchange ray m + t*(e_i - e_j)."""
    ray = []
    for t in range(-max_steps, max_steps + 1):
        pt = list(center)
        pt[i] += t
        pt[j] -= t
        if all(x >= 0 for x in pt):
            c = coeffs.get(tuple(pt), 0.0)
            ray.append((t, c))
    return ray

# ─── Main visualization ─────────────────────────────────────────────────────

fig, axes = plt.subplots(2, 3, figsize=(15, 9))
fig.suptitle('Log-Concavity from Valuated Exchange\n'
             'Coefficient sequences along exchange rays',
             fontsize=14, fontweight='bold')

# Test polynomials
test_cases = [
    ("(x+y+z)³", 3, 3, generate_homogeneous_coeffs(3, 3)),
    ("(x+y+z)⁴", 3, 4, generate_homogeneous_coeffs(3, 4)),
    ("(x+y+z+w)³", 4, 3, generate_homogeneous_coeffs(4, 3)),
]

for col, (title, n_vars, degree, coeffs) in enumerate(test_cases):
    # Top row: coefficients along ray (i=0, j=1) through center
    center = [degree // n_vars] * n_vars
    remainder = degree - sum(center)
    for r in range(remainder):
        center[r] += 1

    # Ray along (e_0 - e_1) direction
    ray = compute_exchange_ray(coeffs, center, 0, 1)
    ts = [r[0] for r in ray]
    cs = [r[1] for r in ray]

    ax = axes[0][col]
    ax.bar(ts, cs, color='#2196F3', edgecolor='black', linewidth=0.8, alpha=0.8)
    ax.set_xlabel('Step t along e₀ - e₁', fontsize=10)
    ax.set_ylabel('Coefficient', fontsize=10)
    ax.set_title(f'{title}\nRay through {tuple(center)}', fontsize=11, fontweight='bold')

    # Mark log-concavity: c(t)² ≥ c(t-1)·c(t+1) at each interior point
    for idx in range(1, len(cs) - 1):
        if cs[idx] > 0 and cs[idx-1] > 0 and cs[idx+1] > 0:
            lc = cs[idx]**2 >= cs[idx-1] * cs[idx+1] - 1e-10
            color = 'green' if lc else 'red'
            ax.plot(ts[idx], cs[idx] * 1.05, 'v', color=color, markersize=8)

    ax.legend(['✓ = log-concave'], fontsize=8, loc='upper right')

    # Bottom row: log of coefficients (should be concave)
    ax = axes[1][col]
    log_cs = [math.log(c) if c > 0 else None for c in cs]
    valid_t = [t for t, lc in zip(ts, log_cs) if lc is not None]
    valid_lc = [lc for lc in log_cs if lc is not None]

    ax.plot(valid_t, valid_lc, 'o-', color='#FF5722', linewidth=2, markersize=6)
    ax.set_xlabel('Step t along e₀ - e₁', fontsize=10)
    ax.set_ylabel('log(coefficient)', fontsize=10)
    ax.set_title(f'Log-scale (concavity = log-concavity)', fontsize=11)

    # Add concavity check
    is_concave = True
    for idx in range(1, len(valid_lc) - 1):
        if valid_lc[idx] < (valid_lc[idx-1] + valid_lc[idx+1]) / 2 - 1e-10:
            is_concave = False
    status = '✓ Concave' if is_concave else '✗ Not concave'
    status_color = 'green' if is_concave else 'red'
    ax.text(0.95, 0.05, status, transform=ax.transAxes,
            fontsize=12, fontweight='bold', color=status_color,
            ha='right', va='bottom',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('logconcavity_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: logconcavity_visualization.png")
