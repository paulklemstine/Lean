"""
Transseries: Asymptotic Expansions Beyond Power Series — Demo

Demonstrates the core concepts of transseries:
1. Growth level comparison and the depth hierarchy
2. Numerical verification of asymptotic separation theorems
3. Transmonomial evaluation and comparison
4. EML connection
"""

import math
from typing import NamedTuple


class GrowthLevel(NamedTuple):
    """A growth level (depth, exponent) in the transseries hierarchy."""
    depth: int
    exponent: float

    def __repr__(self):
        if self.depth == 0:
            return f"x^{self.exponent}"
        elif self.depth == 1:
            return f"exp({self.exponent}x)"
        elif self.depth == 2:
            return f"exp({self.exponent}·exp(x))"
        elif self.depth == -1:
            return f"log(x)^{self.exponent}"
        else:
            return f"depth{self.depth}(exp={self.exponent})"


class TransseriesTerm(NamedTuple):
    """A single term: coefficient × transmonomial."""
    coeff: float
    level: GrowthLevel

    def evaluate(self, x: float) -> float:
        """Evaluate the transmonomial at x."""
        d, alpha = self.level
        if d == -1:
            return self.coeff * math.log(x) ** alpha if x > 0 else 0.0
        elif d == 0:
            return self.coeff * x ** alpha if x > 0 else 0.0
        elif d == 1:
            return self.coeff * math.exp(alpha * x)
        elif d == 2:
            try:
                return self.coeff * math.exp(alpha * math.exp(x))
            except OverflowError:
                return float('inf') if self.coeff > 0 else float('-inf')
        return 0.0


class FormalTransseries:
    """A finite formal sum of transseries terms."""

    def __init__(self, terms: list[TransseriesTerm]):
        self.terms = sorted(terms, key=lambda t: t.level, reverse=True)

    def evaluate(self, x: float) -> float:
        return sum(t.evaluate(x) for t in self.terms)

    @property
    def leading_level(self) -> GrowthLevel:
        return self.terms[0].level if self.terms else GrowthLevel(0, 0)

    @property
    def leading_coeff(self) -> float:
        return self.terms[0].coeff if self.terms else 0.0

    def __repr__(self):
        parts = []
        for t in self.terms:
            sign = "+" if t.coeff > 0 else "-"
            parts.append(f"{sign} {abs(t.coeff):.2f}·{t.level}")
        return " ".join(parts).lstrip("+ ")


def demo_growth_hierarchy():
    """Demonstrate the growth level comparison."""
    print("=" * 60)
    print("1. GROWTH LEVEL HIERARCHY")
    print("=" * 60)

    levels = [
        GrowthLevel(-1, 1),  # log(x)
        GrowthLevel(0, 0.5), # sqrt(x)
        GrowthLevel(0, 1),   # x
        GrowthLevel(0, 2),   # x^2
        GrowthLevel(1, 0.1), # exp(0.1x)
        GrowthLevel(1, 1),   # exp(x)
        GrowthLevel(1, 3),   # exp(3x)
        GrowthLevel(2, 1),   # exp(exp(x))
    ]

    print("\nGrowth levels in ascending order:")
    for i, g in enumerate(levels):
        print(f"  {i+1}. {g}")

    print("\nComparison principle:")
    print("  - Higher depth always wins (exp beats poly beats log)")
    print("  - Same depth: larger exponent wins")

    print("\nNumerical verification at x = 10:")
    for g in levels:
        t = TransseriesTerm(1.0, g)
        val = t.evaluate(10.0)
        if val < 1e300:
            print(f"  {g}: {val:.4e}")
        else:
            print(f"  {g}: overflow (grows too fast!)")


def demo_depth_separation():
    """Demonstrate the depth separation theorem numerically."""
    print("\n" + "=" * 60)
    print("2. DEPTH SEPARATION THEOREM")
    print("=" * 60)

    print("\nexp(x) / x^n for various n:")
    for n in [1, 2, 5, 10]:
        ratios = []
        for x in [10, 50, 100, 500]:
            ratio = math.exp(x) / x**n if x**n > 0 else float('inf')
            ratios.append(ratio)
        print(f"  n={n:2d}: x=10: {ratios[0]:.2e}, x=50: {ratios[1]:.2e}, "
              f"x=100: {ratios[2]:.2e}, x=500: {ratios[3]:.2e}")

    print("\nlog(x) / x^ε for ε = 0.1:")
    for x in [10, 100, 1000, 10000, 100000]:
        ratio = math.log(x) / x**0.1
        print(f"  x={x:>6d}: log(x)/x^0.1 = {ratio:.6f}")
    print("  → Converges to 0 (logarithmic subordination)")


def demo_asymptotic_uniqueness():
    """Demonstrate the asymptotic uniqueness theorem."""
    print("\n" + "=" * 60)
    print("3. ASYMPTOTIC UNIQUENESS THEOREM")
    print("=" * 60)

    print("\n|exp(αx) - exp(βx)| for α=1, β=1.01:")
    for x in [1, 5, 10, 20, 50]:
        diff = abs(math.exp(1.0 * x) - math.exp(1.01 * x))
        print(f"  x={x:2d}: |exp(x) - exp(1.01x)| = {diff:.2e}")
    print("  → Diverges: α ≠ β implies unbounded difference")

    print("\nCounterexample with α=0, β=-1 (non-negative condition needed):")
    for x in [1, 10, 100, 1000]:
        diff = abs(math.exp(0) - math.exp(-x))
        print(f"  x={x:4d}: |1 - exp(-x)| = {diff:.6f}")
    print("  → Stays bounded! (α=0, β=-1 both satisfy |diff| ≤ 1)")


def demo_eml_connection():
    """Demonstrate the EML-transseries connection."""
    print("\n" + "=" * 60)
    print("4. EML CONNECTION")
    print("=" * 60)

    print("\neml(a, b) = exp(a) - log(b)")
    print("Transseries decomposition: depth-1 term + depth-(-1) term")
    print("\n(exp(a) - log(2)) / exp(a) → 1 as a → ∞:")
    b = 2.0
    for a in [1, 5, 10, 20, 50]:
        ratio = (math.exp(a) - math.log(b)) / math.exp(a)
        print(f"  a={a:2d}: ratio = {ratio:.10f}")
    print("  → The exponential part dominates")


def demo_transseries_algebra():
    """Demonstrate transseries construction and evaluation."""
    print("\n" + "=" * 60)
    print("5. TRANSSERIES ALGEBRA")
    print("=" * 60)

    # T = 3·exp(x) - 2·x^2 + log(x)
    T = FormalTransseries([
        TransseriesTerm(3.0, GrowthLevel(1, 1)),
        TransseriesTerm(-2.0, GrowthLevel(0, 2)),
        TransseriesTerm(1.0, GrowthLevel(-1, 1)),
    ])

    print(f"\nTransseries T = {T}")
    print(f"Leading level: {T.leading_level}")
    print(f"Leading coefficient: {T.leading_coeff}")

    print("\nEvaluation:")
    for x in [1.0, 2.0, 5.0, 10.0]:
        val = T.evaluate(x)
        print(f"  T({x}) = {val:.4f}")

    print("\nTerm-by-term breakdown at x=10:")
    for t in T.terms:
        print(f"  {t.coeff:+.0f}·{t.level} = {t.evaluate(10.0):.4e}")
    print(f"  Total: {T.evaluate(10.0):.4e}")
    print("  → The depth-1 term (exp) completely dominates")


if __name__ == "__main__":
    demo_growth_hierarchy()
    demo_depth_separation()
    demo_asymptotic_uniqueness()
    demo_eml_connection()
    demo_transseries_algebra()


"""
Visualization: EML-Transseries Connection

Shows how the EML operation eml(a,b) = exp(a) - log(b) decomposes
into depth-1 and depth-(-1) transseries components.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Figure 1: EML decomposition
ax = axes[0]
x = np.linspace(0.1, 8, 500)
b = 2.0

exp_part = np.exp(x)
log_part = -np.log(b) * np.ones_like(x)
eml_val = exp_part + log_part

ax.plot(x, eml_val, label='eml(a, 2) = exp(a) - log(2)', linewidth=2.5, color='#E91E63')
ax.plot(x, exp_part, label='exp(a) [depth 1]', linewidth=2, linestyle='--', color='#FF9800')
ax.fill_between(x, exp_part, eml_val, alpha=0.2, color='#2196F3',
                label='log(2) gap [depth -1]')
ax.set_xlabel('a', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.set_title('EML Transseries Decomposition', fontsize=14)
ax.legend(fontsize=10)
ax.set_ylim(-5, 100)
ax.grid(True, alpha=0.3)

# Figure 2: Ratio showing exp dominance
ax = axes[1]
x2 = np.linspace(0.5, 10, 500)

for b_val, color in [(0.5, '#2196F3'), (2.0, '#4CAF50'), (10.0, '#FF9800'), (100.0, '#9C27B0')]:
    ratio = (np.exp(x2) - np.log(b_val)) / np.exp(x2)
    ax.plot(x2, ratio, label=f'b={b_val}', linewidth=2, color=color)

ax.axhline(y=1, color='red', linestyle=':', alpha=0.7, linewidth=1.5, label='Limit = 1')
ax.set_xlabel('a', fontsize=12)
ax.set_ylabel('(exp(a) - log(b)) / exp(a)', fontsize=12)
ax.set_title('EML Asymptotic Dominance: Ratio → 1', fontsize=14)
ax.legend(fontsize=10)
ax.set_ylim(0.5, 1.5)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('eml_connection.png', dpi=150, bbox_inches='tight')
print("Saved eml_connection.png")


"""
Visualization: Growth Hierarchy of Transseries

Plots the growth rates of transmonomials at different depths,
illustrating the depth separation theorem.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def transmonomial_eval(depth: int, alpha: float, x: np.ndarray) -> np.ndarray:
    """Evaluate a transmonomial at depth d with exponent alpha."""
    if depth == -1:
        return np.where(x > 0, np.log(x) ** alpha, 0.0)
    elif depth == 0:
        return np.where(x > 0, x ** alpha, 0.0)
    elif depth == 1:
        return np.exp(np.clip(alpha * x, -700, 700))
    elif depth == 2:
        inner = np.clip(alpha * np.exp(np.clip(x, -700, 20)), -700, 700)
        return np.exp(inner)
    return np.zeros_like(x)

# Figure 1: Growth hierarchy (log scale)
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

x = np.linspace(0.1, 8, 500)

ax = axes[0]
ax.semilogy(x, transmonomial_eval(-1, 1, x), label='log(x) [depth -1]', linewidth=2, color='#2196F3')
ax.semilogy(x, transmonomial_eval(0, 1, x), label='x [depth 0]', linewidth=2, color='#4CAF50')
ax.semilogy(x, transmonomial_eval(0, 2, x), label='x² [depth 0]', linewidth=2, linestyle='--', color='#4CAF50')
ax.semilogy(x, transmonomial_eval(1, 0.5, x), label='exp(0.5x) [depth 1]', linewidth=2, linestyle='--', color='#FF9800')
ax.semilogy(x, transmonomial_eval(1, 1, x), label='exp(x) [depth 1]', linewidth=2, color='#FF9800')
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('Transmonomial value (log scale)', fontsize=12)
ax.set_title('Growth Hierarchy of Transmonomials', fontsize=14)
ax.legend(loc='upper left', fontsize=9)
ax.set_ylim(0.1, 1e4)
ax.grid(True, alpha=0.3)

# Figure 2: Ratios demonstrating separation
ax = axes[1]
x2 = np.linspace(1, 15, 500)
ratio1 = np.exp(x2) / x2**2
ratio2 = np.exp(x2) / x2**5
ratio3 = np.where(x2 > 1, np.log(x2) / x2**0.5, 0)

ax.semilogy(x2, ratio1, label='exp(x)/x² → ∞', linewidth=2, color='#E91E63')
ax.semilogy(x2, ratio2, label='exp(x)/x⁵ → ∞', linewidth=2, color='#9C27B0')
ax.plot(x2, ratio3, label='log(x)/√x → 0', linewidth=2, color='#00BCD4')
ax.axhline(y=1, color='gray', linestyle=':', alpha=0.5)
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('Ratio (log scale)', fontsize=12)
ax.set_title('Depth Separation Ratios', fontsize=14)
ax.legend(loc='upper left', fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('growth_hierarchy.png', dpi=150, bbox_inches='tight')
print("Saved growth_hierarchy.png")


# Figure 3: Asymptotic uniqueness visualization
fig2, ax = plt.subplots(figsize=(10, 6))

x3 = np.linspace(0, 5, 500)

# Same exponent: bounded difference
diff_same = np.abs(np.exp(1.0 * x3) - np.exp(1.0 * x3))
ax.plot(x3, diff_same, label='|exp(x) - exp(x)| = 0 (α=β=1)', linewidth=2, color='#4CAF50')

# Different exponents (both positive): unbounded
diff_diff = np.abs(np.exp(1.0 * x3) - np.exp(1.1 * x3))
ax.plot(x3, diff_diff, label='|exp(x) - exp(1.1x)| → ∞ (α=1, β=1.1)', linewidth=2, color='#F44336')

# Counterexample: α=0, β=-1 (bounded but α≠β)
diff_counter = np.abs(np.exp(0 * x3) - np.exp(-1 * x3))
ax.plot(x3, diff_counter, label='|1 - exp(-x)| ≤ 1 (α=0, β=-1)', linewidth=2, color='#FF9800', linestyle='--')

ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('|exp(αx) - exp(βx)|', fontsize=12)
ax.set_title('Asymptotic Uniqueness: Bounded Difference ⟹ Equal Exponents (for α,β ≥ 0)', fontsize=13)
ax.legend(fontsize=10)
ax.set_ylim(-0.5, 20)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('asymptotic_uniqueness.png', dpi=150, bbox_inches='tight')
print("Saved asymptotic_uniqueness.png")
