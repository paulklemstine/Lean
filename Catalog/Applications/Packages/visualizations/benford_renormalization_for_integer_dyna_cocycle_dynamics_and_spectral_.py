#!/usr/bin/env python3
"""
Visualization 2: Cocycle Dynamics and Spectral Obstruction

Shows the fractional logarithm (oscillation component) of different orbits:
- Equidistributed cocycle (Benford) vs. concentrated cocycle (non-Benford)
- Spectral gap visualization showing the obstruction criterion
- Drift rate convergence
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def fractional_log(n, base=10):
    """Fractional part of log_base(n)."""
    if n <= 0:
        return 0.0
    val = math.log(n) / math.log(base)
    return val - math.floor(val)


def collatz_orbit(n, steps):
    """Generate Collatz orbit."""
    orbit = [n]
    for _ in range(steps):
        if n <= 1:
            n = 4
        n = n // 2 if n % 2 == 0 else 3 * n + 1
        orbit.append(n)
    return orbit


N = 3000

# Generate different orbit types
seq_2k = [2**k for k in range(1, N + 1)]
seq_10k = [10**k for k in range(1, N + 1)]
seq_3k = [3**k for k in range(1, N + 1)]
collatz_7 = collatz_orbit(7, N)

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# --- Row 1: Oscillation (fractional log) trajectories ---

# 2^k: irrational rotation by log_10(2)
ax = axes[0, 0]
osc = [fractional_log(x) for x in seq_2k[:500]]
ax.scatter(range(len(osc)), osc, s=1, alpha=0.5, c='steelblue')
ax.set_xlabel('Step k')
ax.set_ylabel('fract(log₁₀(2ᵏ))')
ax.set_title('$2^k$: Irrational Rotation\n(equidistributed → Benford)')
ax.set_ylim(0, 1)
ax.grid(True, alpha=0.3)

# 10^k: trivial rotation (always 0)
ax = axes[0, 1]
osc_10 = [fractional_log(x) for x in seq_10k[:500]]
ax.scatter(range(len(osc_10)), osc_10, s=3, alpha=0.7, c='red')
ax.set_xlabel('Step k')
ax.set_ylabel('fract(log₁₀(10ᵏ))')
ax.set_title('$10^k$: Rational Obstruction\n(concentrated at 0 → NOT Benford)')
ax.set_ylim(-0.1, 1.1)
ax.grid(True, alpha=0.3)

# Collatz: chaotic but equidistributed
ax = axes[0, 2]
osc_c = [fractional_log(x) for x in collatz_7[:500] if x > 0]
ax.scatter(range(len(osc_c)), osc_c, s=1, alpha=0.5, c='green')
ax.set_xlabel('Step k')
ax.set_ylabel('fract(log₁₀(T^k(7)))')
ax.set_title('Collatz(7): Chaotic Cocycle\n(equidistributed → Benford)')
ax.set_ylim(0, 1)
ax.grid(True, alpha=0.3)

# --- Row 2: Histograms of oscillation + spectral analysis ---

# 2^k histogram
ax = axes[1, 0]
osc_full = [fractional_log(x) for x in seq_2k]
ax.hist(osc_full, bins=50, density=True, alpha=0.7, color='steelblue', edgecolor='navy')
ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.7, label='Uniform density')
ax.set_xlabel('fract(log₁₀(n))')
ax.set_ylabel('Density')
ax.set_title('Distribution of Oscillation ($2^k$)')
ax.legend()
ax.grid(True, alpha=0.3)

# 10^k histogram
ax = axes[1, 1]
osc_10_full = [fractional_log(x) for x in seq_10k]
ax.hist(osc_10_full, bins=50, density=True, alpha=0.7, color='red', edgecolor='darkred')
ax.set_xlabel('fract(log₁₀(n))')
ax.set_ylabel('Density')
ax.set_title('Distribution of Oscillation ($10^k$)\nDirac mass at 0')
ax.grid(True, alpha=0.3)

# Spectral analysis: for each q, compute max residual of q*log_b(u(k)) from integers
ax = axes[1, 2]
max_q = 30

for name, seq, color in [('$2^k$', seq_2k[:1000], 'steelblue'), 
                           ('$3^k$', seq_3k[:1000], 'green'),
                           ('$10^k$', seq_10k[:100], 'red')]:
    residuals = []
    for q in range(1, max_q + 1):
        max_res = 0
        for x in seq[-min(200, len(seq)):]:
            if x > 0:
                val = q * math.log(x) / math.log(10)
                res = abs(val - round(val))
                max_res = max(max_res, res)
        residuals.append(max_res)
    ax.plot(range(1, max_q + 1), residuals, 'o-', markersize=3, label=name, color=color, alpha=0.8)

ax.axhline(y=0, color='black', linestyle='-', alpha=0.3)
ax.axhline(y=0.01, color='gray', linestyle=':', alpha=0.5, label='Detection threshold')
ax.set_xlabel('Candidate obstruction order q')
ax.set_ylabel('Max residual (distance to ℤ)')
ax.set_title('Spectral Obstruction Detection\n(low residual = obstruction)')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)
ax.set_yscale('log')
ax.set_ylim(1e-16, 1)

plt.suptitle('Cocycle Dynamics and Spectral Obstructions', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_cocycle_dynamics.png', dpi=150, bbox_inches='tight')
print("Saved viz_cocycle_dynamics.png")
