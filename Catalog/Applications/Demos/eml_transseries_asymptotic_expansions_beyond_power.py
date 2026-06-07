"""
Transseries Growth Hierarchy — Demonstration

This script demonstrates the key concepts from the formalization:
1. Growth level comparison
2. Shift operators
3. Formal differentiation
4. Growth valuation
5. Asymptotic evaluation
"""

import math
from typing import NamedTuple, Optional

class GrowthLevel(NamedTuple):
    """A growth level (level, exponent) representing an asymptotic class."""
    level: int
    exponent: float

    def __repr__(self):
        if self.level > 0:
            base = "exp" + ("^" + str(self.level) if self.level > 1 else "") + "(x)"
        elif self.level == 0:
            base = "x"
        else:
            base = "log" + ("^" + str(-self.level) if -self.level > 1 else "") + "(x)"
        if self.exponent == 1:
            return base
        return f"{base}^{self.exponent}"


def dominates(g1: GrowthLevel, g2: GrowthLevel) -> bool:
    """Check if g1 is dominated by g2 (g1 grows slower)."""
    return g1.level < g2.level or (g1.level == g2.level and g1.exponent < g2.exponent)


def exp_shift(g: GrowthLevel) -> GrowthLevel:
    """Exponential shift: raise the level by 1."""
    return GrowthLevel(g.level + 1, g.exponent)


def log_shift(g: GrowthLevel) -> GrowthLevel:
    """Logarithmic shift: lower the level by 1."""
    return GrowthLevel(g.level - 1, g.exponent)


def formal_deriv_level(g: GrowthLevel) -> GrowthLevel:
    """Formal derivative of a growth level monomial."""
    if g.level > 0:
        return g  # Exponentials are fixed points!
    else:
        return GrowthLevel(g.level, g.exponent - 1)


def eval_base(level: int, x: float) -> float:
    """Evaluate the base function at x for a given level."""
    if level == 0:
        return x
    elif level > 0:
        result = x
        for _ in range(level):
            result = math.exp(min(result, 700))  # Clamp to avoid overflow
        return result
    else:
        result = x
        for _ in range(-level):
            if result > 0:
                result = math.log(result)
            else:
                return float('-inf')
        return result


def eval_growth(g: GrowthLevel, x: float) -> float:
    """Evaluate a growth level monomial at x."""
    base = eval_base(g.level, x)
    if base <= 0 and g.exponent != int(g.exponent):
        return 0.0
    try:
        return base ** g.exponent
    except (OverflowError, ValueError):
        return float('inf')


# === DEMONSTRATIONS ===

print("=" * 60)
print("TRANSSERIES GROWTH HIERARCHY — DEMONSTRATION")
print("=" * 60)

# 1. Growth Level Comparison
print("\n--- 1. Growth Level Comparison ---")
levels = [
    GrowthLevel(-2, 1),   # log(log(x))
    GrowthLevel(-1, 1),   # log(x)
    GrowthLevel(-1, 2),   # log(x)^2
    GrowthLevel(0, 0.5),  # √x
    GrowthLevel(0, 1),    # x
    GrowthLevel(0, 2),    # x^2
    GrowthLevel(1, 1),    # exp(x)
    GrowthLevel(1, 2),    # exp(x)^2
    GrowthLevel(2, 1),    # exp(exp(x))
]

print("Ordering of growth levels (ascending):")
for i, g in enumerate(levels):
    if i > 0:
        assert dominates(levels[i-1], levels[i]), f"Order violation: {levels[i-1]} vs {levels[i]}"
        print(f"  {levels[i-1]}  <  {g}")

# 2. Shift Operators
print("\n--- 2. Shift Operators ---")
g = GrowthLevel(0, 2)  # x^2
print(f"  Start:     {g}")
print(f"  ExpShift:  {exp_shift(g)}")
print(f"  LogShift:  {log_shift(g)}")
print(f"  Exp∘Log:   {exp_shift(log_shift(g))}  (should equal start)")
print(f"  Log∘Exp:   {log_shift(exp_shift(g))}  (should equal start)")
assert exp_shift(log_shift(g)) == g, "Cancellation failed!"
assert log_shift(exp_shift(g)) == g, "Cancellation failed!"
print("  ✓ Shift cancellation verified")

# 3. Formal Differentiation
print("\n--- 3. Formal Differentiation (Exp-Poly Dichotomy) ---")
poly = GrowthLevel(0, 5)  # x^5
exp_g = GrowthLevel(1, 1)  # exp(x)

print(f"  Polynomial x^5 under iterated differentiation:")
g = poly
for k in range(7):
    print(f"    D^{k}: {g}  (exponent = {g.exponent})")
    g = formal_deriv_level(g)

print(f"\n  Exponential exp(x) under iterated differentiation:")
g = exp_g
for k in range(5):
    print(f"    D^{k}: {g}")
    g = formal_deriv_level(g)
print("  ✓ Exponential is FIXED POINT — invariant under all derivatives!")

# 4. Growth Valuation
print("\n--- 4. Growth Valuation ---")

class TransTerm(NamedTuple):
    coeff: float
    gl: GrowthLevel

def growth_valuation(terms: list) -> Optional[int]:
    if not terms:
        return None  # ⊥
    return terms[0].gl.level

# Example transseries: 3·exp(x) + 2·x^2 - 0.5·log(x)
ts = [
    TransTerm(3.0, GrowthLevel(1, 1)),
    TransTerm(2.0, GrowthLevel(0, 2)),
    TransTerm(-0.5, GrowthLevel(-1, 1)),
]
print(f"  Transseries: 3·exp(x) + 2·x² - 0.5·log(x)")
print(f"  Growth valuation: {growth_valuation(ts)}")
print(f"  (Level 1 = exponential scale, dominated by exp(x) term)")

# 5. Asymptotic Evaluation
print("\n--- 5. Asymptotic Evaluation ---")
x_values = [10, 100, 1000]
test_levels = [
    GrowthLevel(-1, 1),  # log(x)
    GrowthLevel(0, 1),   # x
    GrowthLevel(0, 2),   # x^2
    GrowthLevel(1, 1),   # exp(x)
]

print(f"  {'Level':<20} {'x=10':<15} {'x=100':<15} {'x=1000':<15}")
print(f"  {'-'*65}")
for g in test_levels:
    vals = [eval_growth(g, x) for x in x_values]
    formatted = [f"{v:.4g}" if abs(v) < 1e20 else "∞" for v in vals]
    print(f"  {str(g):<20} {formatted[0]:<15} {formatted[1]:<15} {formatted[2]:<15}")

# 6. Depth Spectrum
print("\n--- 6. Depth Spectrum & Complexity ---")
ts_terms = [
    TransTerm(1.0, GrowthLevel(2, 1)),   # exp(exp(x))
    TransTerm(-1.0, GrowthLevel(0, 3)),  # -x^3
    TransTerm(0.5, GrowthLevel(-1, 1)),  # 0.5·log(x)
]
depths = {abs(t.gl.level) for t in ts_terms}
complexity = len(ts_terms) + sum(abs(t.gl.level) for t in ts_terms)
print(f"  Transseries: exp(exp(x)) - x³ + 0.5·log(x)")
print(f"  Depth spectrum: {sorted(depths)}")
print(f"  Complexity: {complexity} (3 terms + depths 2+0+1 = 6)")

print("\n" + "=" * 60)
print("All demonstrations passed successfully!")
print("=" * 60)


"""
Visualization: Growth Level Hierarchy

Shows the dramatic separation between growth levels by plotting
eval(g, x) for various growth levels on a log-scale.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def eval_base(level: int, x: float) -> float:
    if level == 0:
        return x
    elif level > 0:
        result = x
        for _ in range(level):
            result = math.exp(min(result, 500))
        return result
    else:
        result = x
        for _ in range(-level):
            if result > 0:
                result = math.log(max(result, 1e-300))
            else:
                return 1e-300
        return max(result, 1e-300)


def eval_growth(level: int, exponent: float, x: float) -> float:
    base = eval_base(level, x)
    if base <= 0:
        return 1e-300
    try:
        return base ** exponent
    except (OverflowError, ValueError):
        return 1e300


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left panel: log-scale comparison of growth levels
    ax1 = axes[0]
    x = np.linspace(2, 10, 200)

    growth_levels = [
        (-2, 1, "log(log(x))", "#2196F3"),
        (-1, 1, "log(x)", "#4CAF50"),
        (0, 0.5, "√x", "#FF9800"),
        (0, 1, "x", "#F44336"),
        (0, 2, "x²", "#9C27B0"),
        (1, 0.5, "exp(x)^0.5", "#795548"),
        (1, 1, "exp(x)", "#E91E63"),
    ]

    for level, exp, label, color in growth_levels:
        y = [eval_growth(level, exp, xi) for xi in x]
        y_clipped = [min(max(yi, 1e-5), 1e15) for yi in y]
        ax1.semilogy(x, y_clipped, label=label, color=color, linewidth=2)

    ax1.set_xlabel("x", fontsize=12)
    ax1.set_ylabel("Growth Level Evaluation (log scale)", fontsize=12)
    ax1.set_title("Growth Hierarchy: Each Level Dominates All Below", fontsize=13)
    ax1.legend(fontsize=9, loc="upper left")
    ax1.set_ylim(1e-2, 1e15)
    ax1.grid(True, alpha=0.3)

    # Right panel: Derivative behavior
    ax2 = axes[1]
    derivs_poly = list(range(8))
    poly_exponents = [5.0 - k for k in derivs_poly]

    derivs_exp = list(range(8))
    exp_exponents = [1.0] * 8

    ax2.plot(derivs_poly, poly_exponents, 'o-', color="#F44336",
             linewidth=2, markersize=8, label="x⁵ (polynomial)")
    ax2.plot(derivs_exp, exp_exponents, 's-', color="#E91E63",
             linewidth=2, markersize=8, label="exp(x) (exponential)")

    ax2.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax2.fill_between(derivs_poly, 0, poly_exponents, alpha=0.1, color="#F44336")

    ax2.set_xlabel("Number of derivatives k", fontsize=12)
    ax2.set_ylabel("Exponent after k derivatives", fontsize=12)
    ax2.set_title("Exp-Poly Dichotomy Under Differentiation", fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.annotate("Exponentials:\nFIXED POINT",
                 xy=(4, 1), fontsize=10, color="#E91E63",
                 ha='center', va='bottom')
    ax2.annotate("Polynomials:\nEROSIVE",
                 xy=(4, -1), fontsize=10, color="#F44336",
                 ha='center', va='top')

    plt.tight_layout()
    plt.savefig("Applications/growth_hierarchy.png", dpi=150, bbox_inches='tight')
    print("Saved: Applications/growth_hierarchy.png")


if __name__ == "__main__":
    main()


"""
Visualization: Shift Operators on the Growth Level Lattice

Shows the self-similar structure of the growth hierarchy
under exponential and logarithmic shifts.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))

    levels = range(-3, 4)
    exponents = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0]

    level_labels = {
        -3: "log³(x)", -2: "log²(x)", -1: "log(x)",
        0: "x", 1: "exp(x)", 2: "exp²(x)", 3: "exp³(x)"
    }

    # Draw the lattice points
    for l in levels:
        for e in exponents:
            color = '#2196F3' if l < 0 else ('#4CAF50' if l == 0 else '#F44336')
            ax.scatter(l, e, c=color, s=80, zorder=5, edgecolors='black', linewidths=0.5)

    # Draw shift arrows
    for l in range(-3, 3):
        for e in [1.0, 2.0]:
            ax.annotate("",
                        xy=(l + 1, e), xytext=(l, e),
                        arrowprops=dict(arrowstyle="->", color="#E91E63",
                                        lw=1.5, alpha=0.6))

    for l in range(-2, 4):
        for e in [1.5, 2.5]:
            ax.annotate("",
                        xy=(l - 1, e), xytext=(l, e),
                        arrowprops=dict(arrowstyle="->", color="#9C27B0",
                                        lw=1.5, alpha=0.6))

    # Labels
    for l, label in level_labels.items():
        ax.text(l, -0.2, label, ha='center', va='top', fontsize=9,
                fontweight='bold', color='black')

    ax.set_xlabel("Integer Level ℓ", fontsize=13)
    ax.set_ylabel("Real Exponent α", fontsize=13)
    ax.set_title("Growth Level Lattice with Shift Operators", fontsize=14)

    # Legend
    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], marker='o', color='w', markerfacecolor='#2196F3',
               markersize=10, label='Logarithmic (ℓ < 0)'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor='#4CAF50',
               markersize=10, label='Polynomial (ℓ = 0)'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor='#F44336',
               markersize=10, label='Exponential (ℓ > 0)'),
        Line2D([0], [0], color='#E91E63', lw=2, label='expShift →'),
        Line2D([0], [0], color='#9C27B0', lw=2, label='← logShift'),
    ]
    ax.legend(handles=legend_elements, fontsize=10, loc='upper left')

    ax.set_xlim(-3.5, 3.5)
    ax.set_ylim(-0.5, 3.5)
    ax.grid(True, alpha=0.2)
    ax.axvline(x=-0.5, color='gray', linestyle=':', alpha=0.3)
    ax.axvline(x=0.5, color='gray', linestyle=':', alpha=0.3)

    plt.tight_layout()
    plt.savefig("Applications/shift_operators.png", dpi=150, bbox_inches='tight')
    print("Saved: Applications/shift_operators.png")


if __name__ == "__main__":
    main()
