#!/usr/bin/env python3
"""
Transseries Growth Scale: Numerical Demonstrations

Demonstrates the key results from the formalized transseries theory:
1. Asymptotic dominance hierarchy (exp >> poly >> log)
2. Growth level classification
3. EML growth operation
4. Non-equivalence of growth levels
"""

import math
from typing import Tuple

# Growth Level type
GrowthLevel = Tuple[int, float]  # (depth, exponent)


def growth_level_lt(a: GrowthLevel, b: GrowthLevel) -> bool:
    """Lexicographic order on growth levels."""
    if a[0] < b[0]:
        return True
    if a[0] == b[0] and a[1] < b[1]:
        return True
    return False


def exp_shift(g: GrowthLevel) -> GrowthLevel:
    """Exponential shift: raises depth by 1."""
    return (g[0] + 1, g[1])


def log_shift(g: GrowthLevel) -> GrowthLevel:
    """Logarithmic shift: lowers depth by 1."""
    return (g[0] - 1, g[1])


def eml_growth_op(g1: GrowthLevel, g2: GrowthLevel) -> GrowthLevel:
    """EML growth level operation."""
    e = exp_shift(g1)
    l = log_shift(g2)
    if e[0] > l[0]:
        return e
    elif l[0] > e[0]:
        return l
    elif e[1] >= l[1]:
        return e
    else:
        return l


def eval_transmonomial(g: GrowthLevel, x: float) -> float:
    """Evaluate the canonical transmonomial at growth level g."""
    depth, alpha = g
    if depth == 0:
        return x ** alpha
    elif depth == 1:
        return math.exp(x ** alpha) if x ** alpha < 700 else float('inf')
    elif depth == 2:
        inner = math.exp(x) if x < 700 else float('inf')
        return math.exp(inner) if inner < 700 else float('inf')
    elif depth == -1:
        return max(math.log(x), 1e-100) ** alpha if x > 0 else 0
    elif depth == -2:
        return max(math.log(max(math.log(x), 1e-100)), 1e-100) ** alpha if x > 1 else 0
    else:
        return float('nan')


# ============================================================
# Demo 1: Asymptotic Dominance Hierarchy
# ============================================================
print("=" * 60)
print("DEMO 1: Asymptotic Dominance Hierarchy")
print("=" * 60)
print()
print("Comparing growth rates at increasing x values:")
print(f"{'x':>10} {'log(x)':>12} {'x':>12} {'x^2':>12} {'exp(x)':>12}")
print("-" * 60)

for x in [10, 100, 1000, 10000]:
    log_x = math.log(x)
    x_val = x
    x2 = x ** 2
    exp_x = math.exp(min(x, 700))
    print(f"{x:10d} {log_x:12.2f} {x_val:12.0f} {x2:12.0f} {exp_x:12.2e}")

print()
print("Key insight: Each level dominates all lower levels.")
print("  log(x) << x << x^2 << exp(x)")

# ============================================================
# Demo 2: Dominance Ratios
# ============================================================
print()
print("=" * 60)
print("DEMO 2: Dominance Ratios (exp(x) / x^n)")
print("=" * 60)
print()
print("Theorem: exp(x)/x^n → ∞ for any n")
print(f"{'x':>10} {'exp(x)/x':>15} {'exp(x)/x^2':>15} {'exp(x)/x^5':>15}")
print("-" * 60)

for x in [5, 10, 20, 50, 100]:
    r1 = math.exp(x) / x
    r2 = math.exp(x) / x ** 2
    r5 = math.exp(x) / x ** 5
    print(f"{x:10d} {r1:15.2e} {r2:15.2e} {r5:15.2e}")

# ============================================================
# Demo 3: Poly Dominates Log
# ============================================================
print()
print("=" * 60)
print("DEMO 3: Polynomial Dominates Logarithm")
print("=" * 60)
print()
print("Theorem: x^α / (log x)^β → ∞ for α, β > 0")
print(f"{'x':>10} {'x/(log x)':>15} {'√x/(log x)^2':>15} {'x^0.1/log x':>15}")
print("-" * 60)

for x in [10, 100, 1000, 10000, 100000]:
    r1 = x / math.log(x)
    r2 = x ** 0.5 / math.log(x) ** 2
    r3 = x ** 0.1 / math.log(x)
    print(f"{x:10d} {r1:15.2f} {r2:15.2f} {r3:15.4f}")

# ============================================================
# Demo 4: EML Growth Operation
# ============================================================
print()
print("=" * 60)
print("DEMO 4: EML Growth Operation")
print("=" * 60)
print()
print("Theorem: EML of polynomial-level inputs gives exponential-level output")
print()

test_cases = [
    ((0, 1.0), (0, 1.0)),
    ((0, 2.0), (0, 3.0)),
    ((1, 1.0), (0, 1.0)),
    ((0, 1.0), (1, 1.0)),
    ((-1, 1.0), (0, 1.0)),
]

for g1, g2 in test_cases:
    result = eml_growth_op(g1, g2)
    print(f"  emlGrowthOp({g1}, {g2}) = {result}")
    print(f"    Input depth: {g1[0]}, Output depth: {result[0]} (raised: {result[0] > g1[0]})")

# ============================================================
# Demo 5: Growth Level Classification
# ============================================================
print()
print("=" * 60)
print("DEMO 5: Growth Level Classification")
print("=" * 60)
print()

levels = [
    ((-2, 1.0), "log(log(x))"),
    ((-1, 1.0), "log(x)"),
    ((-1, 2.0), "log(x)^2"),
    ((0, 0.5), "√x"),
    ((0, 1.0), "x"),
    ((0, 2.0), "x^2"),
    ((1, 0.5), "exp(√x)"),
    ((1, 1.0), "exp(x)"),
    ((1, 2.0), "exp(x^2)"),
    ((2, 1.0), "exp(exp(x))"),
]

print("Growth levels in increasing order:")
for i, (level, name) in enumerate(levels):
    x = 10.0
    val = eval_transmonomial(level, x)
    print(f"  {i+1:2d}. depth={level[0]:+d}, exp={level[1]:.1f}  →  {name:15s}  value at x=10: {val:.4e}")

print()
print("Verification of total order:")
for i in range(len(levels) - 1):
    a, na = levels[i]
    b, nb = levels[i + 1]
    assert growth_level_lt(a, b), f"{na} should be < {nb}"
    print(f"  {na} < {nb} ✓")

# ============================================================
# Demo 6: Exp-Log Cancellation
# ============================================================
print()
print("=" * 60)
print("DEMO 6: Exp-Log Shift Cancellation")
print("=" * 60)
print()

g = (3, 2.5)
print(f"Original: {g}")
print(f"exp_shift: {exp_shift(g)}")
print(f"log_shift: {log_shift(g)}")
print(f"exp_shift ∘ log_shift: {exp_shift(log_shift(g))} (= original ✓)")
print(f"log_shift ∘ exp_shift: {log_shift(exp_shift(g))} (= original ✓)")

# ============================================================
# Demo 7: Non-Equivalence Test
# ============================================================
print()
print("=" * 60)
print("DEMO 7: Exp-Poly Non-Equivalence")
print("=" * 60)
print()
print("Theorem: exp(x) and x^n are NEVER asymptotically equivalent")
print()
print("exp(x) / x^n diverges for all n:")
for n in [1, 2, 5, 10]:
    print(f"  n = {n}:")
    for x in [10, 50, 100]:
        ratio = math.exp(x) / x ** n
        print(f"    x={x:4d}: exp(x)/x^{n} = {ratio:.4e}")

print()
print("All ratios → ∞, confirming non-equivalence.")
print()
print("=" * 60)
print("All demonstrations complete.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: EML Growth Level Operation

Shows how the EML operation transforms growth levels,
always raising the depth (exponential wins over logarithm).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def exp_shift(depth, exp):
    return (depth + 1, exp)


def log_shift(depth, exp):
    return (depth - 1, exp)


def eml_growth_op(d1, a1, d2, a2):
    e_d, e_a = d1 + 1, a1
    l_d, l_a = d2 - 1, a2
    if e_d > l_d:
        return (e_d, e_a)
    elif l_d > e_d:
        return (l_d, l_a)
    elif e_a >= l_a:
        return (e_d, e_a)
    else:
        return (l_d, l_a)


fig, axes = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('EML Growth Level Operation', fontsize=14, fontweight='bold')

# Panel 1: EML as depth-raising operator
ax1 = axes[0]

# Show various input pairs and their EML results
inputs = [
    ((0, 1.0), (0, 1.0), 'poly, poly'),
    ((0, 2.0), (0, 0.5), 'x², √x'),
    ((1, 1.0), (0, 1.0), 'exp, poly'),
    ((0, 1.0), (1, 1.0), 'poly, exp'),
    ((-1, 1.0), (-1, 1.0), 'log, log'),
    ((1, 1.0), (1, 1.0), 'exp, exp'),
]

y_pos = np.arange(len(inputs))
input_depths = [i[0][0] for i in inputs]
output_depths = [eml_growth_op(i[0][0], i[0][1], i[1][0], i[1][1])[0] for i in inputs]
labels = [i[2] for i in inputs]

bars1 = ax1.barh(y_pos - 0.15, input_depths, 0.3, label='Input g₁ depth', color='steelblue', alpha=0.8)
bars2 = ax1.barh(y_pos + 0.15, output_depths, 0.3, label='Output depth', color='coral', alpha=0.8)

ax1.set_yticks(y_pos)
ax1.set_yticklabels(labels)
ax1.set_xlabel('Depth')
ax1.set_title('EML Always Raises Depth')
ax1.legend()
ax1.axvline(x=0, color='gray', linestyle='--', alpha=0.5)
ax1.grid(True, alpha=0.3, axis='x')

# Panel 2: EML operation on the growth level grid
ax2 = axes[1]

# Plot the growth level grid
for d in range(-2, 4):
    for a in np.arange(0.5, 3.5, 0.5):
        ax2.scatter(a, d, color='lightgray', s=30, zorder=1)

# Show specific EML operations with arrows
operations = [
    ((0, 1.0), (0, 1.0)),
    ((0, 2.0), (0, 1.0)),
    ((1, 1.0), (0, 2.0)),
    ((-1, 1.0), (0, 1.0)),
]

colors = ['red', 'blue', 'green', 'purple']
for (g1, g2), color in zip(operations, colors):
    result = eml_growth_op(g1[0], g1[1], g2[0], g2[1])
    
    # Draw g1 input
    ax2.scatter(g1[1], g1[0], color=color, s=100, marker='o', zorder=5,
               edgecolors='black', linewidth=1)
    # Draw g2 input
    ax2.scatter(g2[1], g2[0], color=color, s=100, marker='s', zorder=5,
               edgecolors='black', linewidth=1)
    # Draw result
    ax2.scatter(result[1], result[0], color=color, s=200, marker='*', zorder=5,
               edgecolors='black', linewidth=1)
    
    # Arrow from midpoint of inputs to result
    mid_a = (g1[1] + g2[1]) / 2
    mid_d = (g1[0] + g2[0]) / 2
    ax2.annotate('', xy=(result[1], result[0]),
                xytext=(mid_a, mid_d),
                arrowprops=dict(arrowstyle='->', color=color, lw=2, alpha=0.6))

ax2.set_xlabel('Exponent α')
ax2.set_ylabel('Depth d')
ax2.set_title('EML: Inputs (●,■) → Result (★)')
ax2.set_yticks(range(-2, 4))
ax2.grid(True, alpha=0.3)

# Legend
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], marker='o', color='w', markerfacecolor='gray', markersize=10, label='Input g₁'),
    Line2D([0], [0], marker='s', color='w', markerfacecolor='gray', markersize=10, label='Input g₂'),
    Line2D([0], [0], marker='*', color='w', markerfacecolor='gray', markersize=15, label='EML result'),
]
ax2.legend(handles=legend_elements, loc='upper left', fontsize=9)

plt.tight_layout()
plt.savefig('/workspace/request-project/Applications/eml_operation.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved: eml_operation.png")


#!/usr/bin/env python3
"""
Visualization: The Transseries Growth Hierarchy

Shows the asymptotic dominance relationships between functions
at different growth levels.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def safe_eval(func, x_array):
    """Safely evaluate a function, capping at large values."""
    result = np.zeros_like(x_array)
    for i, x in enumerate(x_array):
        try:
            val = func(x)
            result[i] = min(val, 1e15)
        except (OverflowError, ValueError):
            result[i] = 1e15
    return result


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Transseries Growth Hierarchy', fontsize=16, fontweight='bold')

# Panel 1: The basic hierarchy (log scale)
ax1 = axes[0, 0]
x = np.linspace(1.1, 20, 200)
ax1.semilogy(x, np.log(x), label='log(x) [depth -1]', linewidth=2, color='blue')
ax1.semilogy(x, x, label='x [depth 0]', linewidth=2, color='green')
ax1.semilogy(x, x**2, label='x² [depth 0]', linewidth=2, color='orange')
ax1.semilogy(x, np.exp(x), label='exp(x) [depth 1]', linewidth=2, color='red')
ax1.set_xlabel('x')
ax1.set_ylabel('f(x) [log scale]')
ax1.set_title('Growth Hierarchy: Depth Separation')
ax1.legend(fontsize=9)
ax1.set_ylim(0.1, 1e8)
ax1.grid(True, alpha=0.3)

# Panel 2: Dominance ratios
ax2 = axes[0, 1]
x = np.linspace(2, 30, 200)
ax2.plot(x, np.exp(x) / x, label='exp(x)/x', linewidth=2, color='red')
ax2.plot(x, np.exp(x) / x**2, label='exp(x)/x²', linewidth=2, color='orange')
ax2.plot(x, np.exp(x) / x**5, label='exp(x)/x⁵', linewidth=2, color='green')
ax2.set_xlabel('x')
ax2.set_ylabel('Ratio')
ax2.set_title('Exp Dominates Poly: Ratios → ∞')
ax2.legend(fontsize=9)
ax2.set_yscale('log')
ax2.grid(True, alpha=0.3)

# Panel 3: Depth filtration
ax3 = axes[1, 0]
depths = range(-2, 4)
exponents = [0.5, 1.0, 2.0]
colors = {-2: 'purple', -1: 'blue', 0: 'green', 1: 'orange', 2: 'red', 3: 'darkred'}
labels_done = set()

for d in depths:
    for alpha in exponents:
        label = f'depth {d}' if d not in labels_done else None
        labels_done.add(d)
        ax3.scatter(alpha, d, color=colors[d], s=100, zorder=5, label=label)

ax3.set_xlabel('Exponent α')
ax3.set_ylabel('Depth d')
ax3.set_title('Growth Level Grid: ℤ × ℝ')
ax3.legend(fontsize=8, loc='upper left')
ax3.set_yticks(list(depths))
ax3.set_yticklabels([f'{d}' for d in depths])
ax3.grid(True, alpha=0.3)

# Add arrows showing exp shift
for d in range(-2, 3):
    ax3.annotate('', xy=(1.0, d + 0.8), xytext=(1.0, d + 0.2),
                arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))

ax3.text(1.15, 0.5, 'exp↑', fontsize=9, color='gray')

# Panel 4: Poly vs Log dominance
ax4 = axes[1, 1]
x = np.linspace(2, 1000, 500)
ax4.plot(x, x / np.log(x), label='x / log(x)', linewidth=2, color='green')
ax4.plot(x, np.sqrt(x) / np.log(x)**2, label='√x / (log x)²', linewidth=2, color='blue')
ax4.plot(x, x**0.1 / np.log(x), label='x^0.1 / log(x)', linewidth=2, color='orange')
ax4.set_xlabel('x')
ax4.set_ylabel('Ratio')
ax4.set_title('Poly Dominates Log: Ratios → ∞')
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Applications/growth_hierarchy.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved: growth_hierarchy.png")
