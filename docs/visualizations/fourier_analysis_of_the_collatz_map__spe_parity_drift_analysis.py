#!/usr/bin/env python3
"""
Visualization 2: Parity Drift and the Critical Threshold
=========================================================

Shows the random walk drift function μ(p) = p·log(3) - (1-p)·log(2) and
its unique zero p* ≈ 0.3869, the critical parity threshold that separates
contracting from expanding Collatz dynamics. Also shows the distribution
of observed parity ratios across many starting values.
"""

import numpy as np
import matplotlib.pyplot as plt


def collatz_step(n: int) -> int:
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_orbit(n: int, max_steps: int = 10000):
    orbit = [n]
    current = n
    for _ in range(max_steps):
        if current <= 1:
            break
        current = collatz_step(current)
        orbit.append(current)
    return orbit


def parity_ratio(n: int) -> float:
    orbit = collatz_orbit(n)
    total = len(orbit) - 1
    if total == 0:
        return 0.0
    odd_count = sum(1 for x in orbit[:-1] if x % 2 == 1)
    return odd_count / total


def drift_function(p):
    return p * np.log(3) - (1 - p) * np.log(2)


# Critical threshold
p_star = np.log(2) / (np.log(2) + np.log(3))

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: drift function
ax = axes[0]
p_vals = np.linspace(0, 1, 500)
drift_vals = drift_function(p_vals)

ax.fill_between(p_vals, drift_vals, 0, where=(drift_vals < 0),
                color='#2196F3', alpha=0.3, label='Contracting region')
ax.fill_between(p_vals, drift_vals, 0, where=(drift_vals > 0),
                color='#FF5722', alpha=0.3, label='Expanding region')
ax.plot(p_vals, drift_vals, 'k-', linewidth=2)
ax.axhline(y=0, color='gray', linestyle='-', linewidth=0.5)
ax.axvline(x=p_star, color='red', linestyle='--', linewidth=1.5,
           label=f'p* = {p_star:.4f}')
ax.plot(p_star, 0, 'ro', markersize=8, zorder=5)

ax.set_xlabel('Parity ratio p (fraction of odd steps)', fontsize=12)
ax.set_ylabel('Drift μ(p)', fontsize=12)
ax.set_title('Random Walk Drift Function', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 1)

# Right panel: distribution of observed parity ratios
ax2 = axes[1]
ratios = [parity_ratio(n) for n in range(3, 5001, 2)]  # odd numbers

ax2.hist(ratios, bins=60, color='#4CAF50', alpha=0.7, edgecolor='white',
         density=True, label='Observed distribution')
ax2.axvline(x=p_star, color='red', linestyle='--', linewidth=2,
            label=f'p* = {p_star:.4f}')
ax2.axvline(x=np.mean(ratios), color='blue', linestyle='-', linewidth=1.5,
            label=f'Mean = {np.mean(ratios):.4f}')

ax2.set_xlabel('Parity ratio (odd steps / total steps)', fontsize=12)
ax2.set_ylabel('Density', fontsize=12)
ax2.set_title('Parity Ratios of Collatz Orbits (n=3..5000)', fontsize=14,
              fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('parity_drift_analysis.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved parity_drift_analysis.png")
