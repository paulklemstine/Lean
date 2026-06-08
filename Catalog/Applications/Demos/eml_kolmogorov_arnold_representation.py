#!/usr/bin/env python3
"""
EML Spectral Kolmogorov-Arnold Theory — Demonstrations

This script demonstrates the core results of the LogAffine Separation Algebra
and EML-KA decomposition theory with numerical examples.
"""

import numpy as np

def eml_ka_multiply(x, y):
    """1-term EML-KA decomposition for multiplication: exp(log(x) + log(y))"""
    return np.exp(np.log(x) + np.log(y))

def eml_ka_add(x, y):
    """2-term EML-KA decomposition for addition: exp(log(x) + 0) + exp(0 + log(y))"""
    return np.exp(np.log(x) + 0) + np.exp(0 + np.log(y))

def eml_ka_divide(x, y):
    """1-term EML-KA decomposition for division: exp(log(x) + (-log(y)))"""
    return np.exp(np.log(x) + (-np.log(y)))

def eml_ka_monomial(x, y, a, b):
    """1-term EML-KA for monomial x^a * y^b: exp(a*log(x) + b*log(y))"""
    return np.exp(a * np.log(x) + b * np.log(y))

def eml_ka_geom_mean(x, y):
    """1-term symmetric EML-KA for geometric mean: exp(0.5*log(x) + 0.5*log(y))"""
    return np.exp(0.5 * np.log(x) + 0.5 * np.log(y))

def eml_ka_sum_powers(x, y, r):
    """2-term EML-KA for x^r + y^r"""
    return np.exp(r * np.log(x) + 0) + np.exp(0 + r * np.log(y))

def fenchel_young_gap(x, s):
    """Fenchel-Young gap: exp(x) + s*log(s) - s - x*s ≥ 0"""
    return np.exp(x) + s * np.log(s) - s - x * s

def eml_ka_polynomial(x, y, coeffs, exps_a, exps_b):
    """M-term EML-KA for polynomial Σ c_i * x^a_i * y^b_i"""
    result = 0.0
    for c, a, b in zip(coeffs, exps_a, exps_b):
        result += np.exp(a * np.log(x) + b * np.log(y) + np.log(c))
    return result

# ============================================================
# Demo 1: Multiplication via EML-KA
# ============================================================
print("=" * 60)
print("Demo 1: Multiplication via 1-term EML-KA")
print("  x * y = exp(log(x) + log(y))")
print("=" * 60)

test_pairs = [(2.0, 3.0), (0.5, 4.0), (np.e, np.pi), (100.0, 0.01)]
for x, y in test_pairs:
    exact = x * y
    emlka = eml_ka_multiply(x, y)
    print(f"  x={x:8.4f}, y={y:8.4f}  |  exact={exact:12.6f}  |  EML-KA={emlka:12.6f}  |  error={abs(exact-emlka):.2e}")

# ============================================================
# Demo 2: Addition via 2-term EML-KA (Novel Result)
# ============================================================
print()
print("=" * 60)
print("Demo 2: Addition via 2-term EML-KA (Novel)")
print("  x + y = exp(log(x)) + exp(log(y))")
print("=" * 60)

for x, y in test_pairs:
    exact = x + y
    emlka = eml_ka_add(x, y)
    print(f"  x={x:8.4f}, y={y:8.4f}  |  exact={exact:12.6f}  |  EML-KA={emlka:12.6f}  |  error={abs(exact-emlka):.2e}")

# ============================================================
# Demo 3: Addition Incompressibility
# ============================================================
print()
print("=" * 60)
print("Demo 3: Addition Incompressibility")
print("  exp(α*log(x) + β*log(y)) = x^α * y^β ≠ x + y")
print("  Testing: x=1, y=1 gives x^α*y^β = 1 but x+y = 2")
print("=" * 60)

x, y = 1.0, 1.0
for alpha in [0.5, 1.0, 1.5, 2.0]:
    for beta in [0.5, 1.0, 1.5, 2.0]:
        monomial = np.exp(alpha * np.log(x) + beta * np.log(y))
        target = x + y
        print(f"  α={alpha}, β={beta}: monomial={monomial:.4f}, target={target:.4f}, match={abs(monomial-target) < 1e-10}")

# ============================================================
# Demo 4: Geometric Mean (Symmetric EML-KA)
# ============================================================
print()
print("=" * 60)
print("Demo 4: Geometric Mean — Symmetric 1-term EML-KA")
print("  √(xy) = exp(½ log(x) + ½ log(y))")
print("=" * 60)

for x, y in test_pairs:
    exact = np.sqrt(x * y)
    emlka = eml_ka_geom_mean(x, y)
    print(f"  x={x:8.4f}, y={y:8.4f}  |  √(xy)={exact:12.6f}  |  EML-KA={emlka:12.6f}  |  error={abs(exact-emlka):.2e}")

# ============================================================
# Demo 5: Fenchel-Young Gap
# ============================================================
print()
print("=" * 60)
print("Demo 5: Fenchel-Young Gap (non-negative, zero iff x = log(s))")
print("  gap(x,s) = exp(x) + s*log(s) - s - x*s ≥ 0")
print("=" * 60)

for s in [0.5, 1.0, 2.0, np.e]:
    for x in [np.log(s) - 1, np.log(s), np.log(s) + 1]:
        gap = fenchel_young_gap(x, s)
        is_zero = "ZERO" if abs(gap) < 1e-12 else f"{gap:.6f}"
        print(f"  s={s:.4f}, x={x:.4f} (log(s)={np.log(s):.4f}): gap={is_zero}")

# ============================================================
# Demo 6: Polynomial via EML-KA
# ============================================================
print()
print("=" * 60)
print("Demo 6: Polynomial 3x²y + 2xy³ + 5xy via 3-term EML-KA")
print("=" * 60)

coeffs = [3.0, 2.0, 5.0]
exps_a = [2, 1, 1]
exps_b = [1, 3, 1]

for x, y in [(2.0, 3.0), (1.5, 2.5), (0.7, 1.3)]:
    exact = 3*x**2*y + 2*x*y**3 + 5*x*y
    emlka = eml_ka_polynomial(x, y, coeffs, exps_a, exps_b)
    print(f"  x={x:.2f}, y={y:.2f}  |  exact={exact:12.4f}  |  EML-KA={emlka:12.4f}  |  error={abs(exact-emlka):.2e}")

# ============================================================
# Demo 7: Power Sums x^r + y^r
# ============================================================
print()
print("=" * 60)
print("Demo 7: Power Sums x^r + y^r via 2-term EML-KA")
print("=" * 60)

x, y = 2.0, 3.0
for r in [1, 2, 3, 4, 5]:
    exact = x**r + y**r
    emlka = eml_ka_sum_powers(x, y, r)
    print(f"  r={r}: x^r+y^r={exact:12.2f}  |  EML-KA={emlka:12.2f}  |  error={abs(exact-emlka):.2e}")

# ============================================================
# Summary
# ============================================================
print()
print("=" * 60)
print("SUMMARY: EML-KA Complexity Table")
print("=" * 60)
print(f"  {'Operation':<30} {'EML-KA Terms':>12} {'Depth':>6}")
print(f"  {'-'*30} {'-'*12} {'-'*6}")
print(f"  {'x * y':<30} {'1':>12} {'2':>6}")
print(f"  {'x / y':<30} {'1':>12} {'2':>6}")
print(f"  {'x + y':<30} {'2':>12} {'2':>6}")
print(f"  {'x^a * y^b (monomial)':<30} {'1':>12} {'2':>6}")
print(f"  {'√(xy) (geom. mean)':<30} {'1':>12} {'2':>6}")
print(f"  {'x^r + y^r (power sum)':<30} {'2':>12} {'2':>6}")
print(f"  {'M-term polynomial':<30} {'M':>12} {'2':>6}")
print(f"  {'constant c':<30} {'1':>12} {'0':>6}")


#!/usr/bin/env python3
"""
EML-KA Decomposition Visualization

Visualizes the LogAffine Separation Algebra and EML-KA decomposition
properties using matplotlib.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

def log_affine_eval(alpha, beta, x):
    """Evaluate LogAffine map α·log(x) + β"""
    return alpha * np.log(x) + beta

def eml_ka_multiply(x, y):
    return np.exp(np.log(x) + np.log(y))

def eml_ka_add(x, y):
    return np.exp(np.log(x)) + np.exp(np.log(y))

def fenchel_young_gap(x, s):
    return np.exp(x) + s * np.log(s) - s - x * s

# Create figure with 4 panels
fig = plt.figure(figsize=(16, 12))
gs = GridSpec(2, 2, figure=fig, hspace=0.3, wspace=0.3)

# ============================================================
# Panel 1: LogAffine Separation — different (α,β) pairs
# ============================================================
ax1 = fig.add_subplot(gs[0, 0])
x = np.linspace(0.1, 5, 200)

params = [(1, 0, 'log(x)'), (2, 0, '2·log(x)'), (0.5, 1, '½·log(x)+1'),
          (-1, 2, '-log(x)+2'), (1, -1, 'log(x)-1')]
colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd']

for (a, b, label), color in zip(params, colors):
    ax1.plot(x, log_affine_eval(a, b, x), label=label, color=color, linewidth=2)

ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.3)
ax1.axvline(x=1, color='gray', linestyle='--', alpha=0.3)
ax1.set_xlabel('x', fontsize=12)
ax1.set_ylabel('f(x)', fontsize=12)
ax1.set_title('LogAffine Separation Algebra\n{x ↦ α·log(x) + β}', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_ylim(-4, 5)
ax1.grid(True, alpha=0.2)

# ============================================================
# Panel 2: EML-KA Error Surface for Addition
# ============================================================
ax2 = fig.add_subplot(gs[0, 1])
x_grid = np.linspace(0.1, 5, 100)
y_grid = np.linspace(0.1, 5, 100)
X, Y = np.meshgrid(x_grid, y_grid)
Z_exact = X + Y
Z_emlka = eml_ka_add(X, Y)
Z_error = np.abs(Z_exact - Z_emlka)

im = ax2.pcolormesh(X, Y, np.log10(Z_error + 1e-16), cmap='viridis', shading='auto')
cb = plt.colorbar(im, ax=ax2, label='log₁₀(|error|)')
ax2.set_xlabel('x', fontsize=12)
ax2.set_ylabel('y', fontsize=12)
ax2.set_title('EML-KA Addition: Numerical Precision\n2-term decomposition error', fontsize=13, fontweight='bold')

# ============================================================
# Panel 3: Fenchel-Young Gap Surface
# ============================================================
ax3 = fig.add_subplot(gs[1, 0])
x_range = np.linspace(-3, 3, 200)
s_values = [0.5, 1.0, np.e, 3.0]
colors3 = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']

for s, color in zip(s_values, colors3):
    gap = fenchel_young_gap(x_range, s)
    ax3.plot(x_range, gap, label=f's={s:.2f} (min at x={np.log(s):.2f})',
             color=color, linewidth=2)
    ax3.plot(np.log(s), 0, 'o', color=color, markersize=8, zorder=5)

ax3.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax3.set_xlabel('x', fontsize=12)
ax3.set_ylabel('Gap(x, s)', fontsize=12)
ax3.set_title('Fenchel-Young Gap\nexp(x) + s·log(s) − s − x·s ≥ 0', fontsize=13, fontweight='bold')
ax3.legend(fontsize=9)
ax3.set_ylim(-0.5, 15)
ax3.grid(True, alpha=0.2)

# ============================================================
# Panel 4: EML-KA Complexity Comparison
# ============================================================
ax4 = fig.add_subplot(gs[1, 1])

operations = ['x·y', 'x/y', 'x^a·y^b', '√(xy)', 'x+y', 'x^r+y^r',
              'Σcᵢx^{aᵢ}y^{bᵢ}', 'c (const)']
terms = [1, 1, 1, 1, 2, 2, 3, 1]  # example M=3 for poly
depths = [2, 2, 2, 2, 2, 2, 2, 0]

y_pos = np.arange(len(operations))
bar_width = 0.35

bars1 = ax4.barh(y_pos - bar_width/2, terms, bar_width, label='Terms (Q)',
                  color='#2196F3', alpha=0.8)
bars2 = ax4.barh(y_pos + bar_width/2, depths, bar_width, label='Depth',
                  color='#FF9800', alpha=0.8)

ax4.set_yticks(y_pos)
ax4.set_yticklabels(operations, fontsize=10)
ax4.set_xlabel('Count', fontsize=12)
ax4.set_title('EML-KA Complexity Table\nTerms × Depth = Total Operations', fontsize=13, fontweight='bold')
ax4.legend(fontsize=10)
ax4.grid(True, axis='x', alpha=0.2)

# Add value labels
for bar in bars1:
    width = bar.get_width()
    ax4.text(width + 0.1, bar.get_y() + bar.get_height()/2, f'{int(width)}',
             ha='left', va='center', fontsize=9)
for bar in bars2:
    width = bar.get_width()
    ax4.text(width + 0.1, bar.get_y() + bar.get_height()/2, f'{int(width)}',
             ha='left', va='center', fontsize=9)

fig.suptitle('EML Spectral Kolmogorov-Arnold Theory', fontsize=16, fontweight='bold', y=0.98)
plt.savefig('emlka_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: emlka_visualization.png")
