"""
Visualization: Fractional Logarithm Cocycle

Plots the fractional parts frac(log_10(u_k)) for several sequences,
revealing the equidistribution (or lack thereof) that controls Benford
behavior. For irrational rotations, the points fill [0,1) uniformly.
For rational obstructions, they cluster on a finite set.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def frac_log(x, base=10):
    if x <= 0:
        return 0.0
    v = math.log(x) / math.log(base)
    return v - math.floor(v)


# Generate sequences
N = 500

# Powers of 2: frac(k * log10(2)) — irrational rotation
pow2_frac = [frac_log(2**k) for k in range(1, N+1)]

# Powers of 3: frac(k * log10(3)) — irrational rotation
pow3_frac = [frac_log(3**k) for k in range(1, N+1)]

# Powers of 10: frac(k * log10(10)) = frac(k) = 0 — rational obstruction
pow10_frac = [frac_log(10**k) for k in range(1, N+1)]

# Fibonacci: frac(log10(F_k)) ≈ frac(k*log10(φ) + const) — irrational
fib = [1, 1]
for _ in range(N + 10):
    fib.append(fib[-1] + fib[-2])
fib_frac = [frac_log(fib[k]) for k in range(10, N+10)]

# 3n+1 orbit from seed 7
x = 7
collatz_orbit = [x]
for _ in range(N):
    x = x // 2 if x % 2 == 0 else 3 * x + 1
    collatz_orbit.append(x)
collatz_frac = [frac_log(v) for v in collatz_orbit if v > 0]

fig, axes = plt.subplots(2, 3, figsize=(15, 9))

datasets = [
    ('Powers of 2: frac(k·log₁₀(2))', pow2_frac, '#27ae60'),
    ('Powers of 3: frac(k·log₁₀(3))', pow3_frac, '#2980b9'),
    ('Powers of 10 (OBSTRUCTED)', pow10_frac, '#c0392b'),
    ('Fibonacci: frac(log₁₀(Fₖ))', fib_frac, '#8e44ad'),
    ('Collatz orbit (seed=7)', collatz_frac[:N], '#e67e22'),
]

for idx, (title, data, color) in enumerate(datasets):
    row, col = divmod(idx, 3)
    ax = axes[row][col]

    # Scatter plot of fractional parts
    ax.scatter(range(len(data)), data, s=1.5, c=color, alpha=0.6)
    ax.set_title(title, fontsize=10, fontweight='bold')
    ax.set_xlabel('Index k')
    ax.set_ylabel('frac(log₁₀(uₖ))')
    ax.set_ylim(-0.05, 1.05)
    ax.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')
    ax.axhline(y=1, color='gray', linewidth=0.5, linestyle='--')

    # Add Benford digit boundaries
    for d in range(1, 10):
        boundary = math.log10(d)
        if 0 < boundary < 1:
            ax.axhline(y=boundary, color='lightgray', linewidth=0.3)

# Last panel: histogram comparison
ax = axes[1][2]
bins = np.linspace(0, 1, 51)
ax.hist(pow2_frac, bins=bins, alpha=0.6, density=True,
        label='2ᵏ', color='#27ae60')
ax.hist(pow10_frac, bins=bins, alpha=0.8, density=True,
        label='10ᵏ', color='#c0392b')
ax.axhline(y=1.0, color='black', linewidth=1.5, linestyle='--',
           label='Uniform')
ax.set_title('Histogram: Equidistributed vs Obstructed', fontsize=10,
             fontweight='bold')
ax.set_xlabel('frac(log₁₀(uₖ))')
ax.set_ylabel('Density')
ax.legend(fontsize=8)

fig.suptitle('The Logarithmic Cocycle: Equidistribution vs Rational Obstruction',
             fontsize=13, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_fractional_log.png', dpi=150, bbox_inches='tight')
print("Saved viz_fractional_log.png")
