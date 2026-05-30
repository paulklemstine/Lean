"""
Visualization 2: Tropical Convexity Surface

Visualizes the tropicalization map -log(f) for a 2D matroid valuation,
showing how log-concavity in the original space becomes convexity
in the tropical (min-plus) semiring.

Left: Original valuation f(m1, m2) (log scale)
Right: Tropical valuation -log f(m1, m2) (should be convex)
"""

import numpy as np
import matplotlib.pyplot as plt
from math import factorial
from mpl_toolkits.mplot3d import Axes3D


def multinomial_2d(m1, m2, degree=6):
    """Binomial coefficient for 2 variables on degree slice."""
    if m1 < 0 or m2 < 0 or m1 + m2 != degree:
        return 0.0
    return factorial(degree) / (factorial(m1) * factorial(m2))


def weighted_valuation(m1, m2, degree=6, alpha=1.5, beta=0.8):
    """Weighted matroid valuation: multinomial * alpha^m1 * beta^m2."""
    c = multinomial_2d(m1, m2, degree)
    if c == 0:
        return 0.0
    return c * (alpha ** m1) * (beta ** m2)


# Generate data
degree = 8
x = np.arange(0, degree + 1)

# Function values along the degree slice
vals_uniform = np.array([multinomial_2d(m, degree - m, degree) for m in x])
vals_weighted = np.array([weighted_valuation(m, degree - m, degree) for m in x])

# Tropical values
trop_uniform = np.array([-np.log(v) if v > 0 else np.nan for v in vals_uniform])
trop_weighted = np.array([-np.log(v) if v > 0 else np.nan for v in vals_weighted])

# Ratio sequences
ratio_uniform = np.array([vals_uniform[i+1]/vals_uniform[i] 
                           if vals_uniform[i] > 0 else 0 
                           for i in range(len(vals_uniform)-1)])
ratio_weighted = np.array([vals_weighted[i+1]/vals_weighted[i] 
                            if vals_weighted[i] > 0 else 0 
                            for i in range(len(vals_weighted)-1)])

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# Row 1: Uniform matroid
ax = axes[0, 0]
ax.bar(x, vals_uniform, color='steelblue', alpha=0.8)
ax.set_title('Uniform Valuation\n$f(m) = \\binom{8}{m}$', fontsize=12)
ax.set_xlabel('$m_1$ (with $m_2 = 8 - m_1$)')
ax.set_ylabel('$f(m)$')

ax = axes[0, 1]
ax.plot(x, trop_uniform, 'o-', color='darkred', markersize=8)
ax.set_title('Tropical: $-\\log f(m)$\n(Convex = DLC holds)', fontsize=12)
ax.set_xlabel('$m_1$')
ax.set_ylabel('$-\\log f(m)$')
ax.grid(True, alpha=0.3)

# Check convexity visually: plot second differences
second_diff_u = np.array([trop_uniform[i+2] - 2*trop_uniform[i+1] + trop_uniform[i]
                           for i in range(len(trop_uniform)-2)
                           if not np.isnan(trop_uniform[i]) and 
                              not np.isnan(trop_uniform[i+1]) and
                              not np.isnan(trop_uniform[i+2])])

ax = axes[0, 2]
ax.bar(range(len(ratio_uniform)), ratio_uniform, color='forestgreen', alpha=0.8)
ax.set_title('Ratio Transform\n$R f(m) = f(m+1)/f(m)$', fontsize=12)
ax.set_xlabel('$m_1$')
ax.set_ylabel('$R f(m)$')
# Show that ratio is decreasing (log-concavity)
if len(ratio_uniform) > 1:
    is_decreasing = all(ratio_uniform[i] >= ratio_uniform[i+1] - 1e-10 
                        for i in range(len(ratio_uniform)-1))
    ax.set_title(f'Ratio Transform\nDecreasing = LC ✓' if is_decreasing 
                 else 'Ratio Transform\nNot decreasing ✗', fontsize=12)

# Row 2: Weighted matroid
ax = axes[1, 0]
ax.bar(x, vals_weighted, color='coral', alpha=0.8)
ax.set_title('Weighted Valuation\n$f(m) = \\binom{8}{m} \\cdot 1.5^{m_1} \\cdot 0.8^{m_2}$', fontsize=12)
ax.set_xlabel('$m_1$ (with $m_2 = 8 - m_1$)')
ax.set_ylabel('$f(m)$')

ax = axes[1, 1]
ax.plot(x, trop_weighted, 's-', color='darkred', markersize=8)
ax.set_title('Tropical: $-\\log f(m)$\n(Convex = DLC holds)', fontsize=12)
ax.set_xlabel('$m_1$')
ax.set_ylabel('$-\\log f(m)$')
ax.grid(True, alpha=0.3)

ax = axes[1, 2]
ax.bar(range(len(ratio_weighted)), ratio_weighted, color='mediumpurple', alpha=0.8)
is_decreasing_w = all(ratio_weighted[i] >= ratio_weighted[i+1] - 1e-10 
                      for i in range(len(ratio_weighted)-1))
ax.set_title(f'Ratio Transform\nDecreasing = LC ✓' if is_decreasing_w 
             else 'Ratio Transform\nNot decreasing ✗', fontsize=12)
ax.set_xlabel('$m_1$')
ax.set_ylabel('$R f(m)$')

plt.suptitle('Log-Concavity ↔ Tropical Convexity Bridge\n'
             'The ratio transform reveals curvature depth',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('tropical_surface.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved tropical_surface.png")
