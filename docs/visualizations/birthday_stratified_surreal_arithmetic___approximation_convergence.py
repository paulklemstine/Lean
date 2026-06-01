#!/usr/bin/env python3
"""
Visualization: Dyadic Approximation Convergence

Shows how dyadic approximations converge to target values,
illustrating the density theorem and approximation bounds.
"""

import matplotlib.pyplot as plt
import numpy as np
from fractions import Fraction


def dyadic_approx(q: Fraction, n: int) -> Fraction:
    power = 2 ** n
    scaled = q * power
    floored = int(scaled)
    if Fraction(floored) > scaled:
        floored -= 1
    return Fraction(floored, power)


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Approximation convergence for multiple targets
ax1 = axes[0]
targets = [
    (Fraction(1, 3), '1/3', 'steelblue'),
    (Fraction(1, 7), '1/7', 'coral'),
    (Fraction(22, 7), 'π ≈ 22/7', 'forestgreen'),
    (Fraction(17, 12), '√2 ≈ 17/12', 'purple'),
]

ns = list(range(1, 13))
for q, label, color in targets:
    errors = []
    for n in ns:
        d = dyadic_approx(q, n)
        err = abs(float(q) - float(d))
        errors.append(max(err, 1e-15))  # Avoid log(0)
    ax1.semilogy(ns, errors, 'o-', color=color, label=label, markersize=4)

# Plot the bound 1/2^n
bounds = [1.0 / 2 ** n for n in ns]
ax1.semilogy(ns, bounds, 'k--', linewidth=2, label='Bound: 1/2ⁿ', alpha=0.7)

ax1.set_xlabel('Precision level n', fontsize=12)
ax1.set_ylabel('Approximation error |q - d|', fontsize=12)
ax1.set_title('Dyadic Approximation: Exponential Convergence',
              fontsize=14, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Right: Density — filling in the interval [0, 1]
ax2 = axes[1]
colors_bday = plt.cm.Set1(np.linspace(0, 0.8, 8))

for n in range(7):
    denom = 2 ** n
    points = []
    for num in range(denom + 1):
        q = Fraction(num, denom)
        from fractions import Fraction as F
        d = q.denominator
        v = 0
        while d % 2 == 0:
            v += 1
            d //= 2
        if v == n:
            points.append(float(q))

    if points:
        y_vals = [n] * len(points)
        ax2.scatter(points, y_vals, c=[colors_bday[n]], s=max(5, 60 - n * 8),
                   zorder=7 - n, alpha=0.8)

ax2.set_xlabel('Position in [0, 1]', fontsize=12)
ax2.set_ylabel('Birthday (day born)', fontsize=12)
ax2.set_title('Dyadic Density: Filling [0,1] by Birthday',
              fontsize=14, fontweight='bold')
ax2.set_yticks(range(7))
ax2.set_yticklabels([f'Day {i}' for i in range(7)])
ax2.set_xlim(-0.05, 1.05)
ax2.grid(True, alpha=0.3, axis='x')

plt.tight_layout()
plt.savefig('approximation_convergence.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: approximation_convergence.png")
