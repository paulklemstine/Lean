"""
Transseries: Numerical Demonstrations

This demo illustrates the core results of the Graded Transseries Algebra:
1. Exponential Dominance: exp(x) / x^n → ∞
2. Three-Level Hierarchy: log ≪ polynomial ≪ exponential
3. Double-Exponential Dominance: exp(exp(x)) ≫ exp(αx)
4. Asymptotic Comparison for same-level transmonomials
5. Depth filtration and classification
"""

import math
from typing import List, Tuple

# ============================================================
# Growth Level and Transseries Data Structures
# ============================================================

class GrowthLevel:
    """A growth level (depth, exponent) representing a transmonomial's
    asymptotic growth rate."""
    
    def __init__(self, depth: int, exponent: float):
        self.depth = depth
        self.exponent = exponent
    
    def __repr__(self):
        if self.depth == 0:
            return f"x^{self.exponent}"
        elif self.depth == 1:
            return f"exp({self.exponent}x)"
        elif self.depth == -1:
            return f"log(x)^{self.exponent}"
        elif self.depth == 2:
            return f"exp({self.exponent}·exp(x))"
        else:
            return f"GL({self.depth}, {self.exponent})"
    
    def __lt__(self, other):
        """Lexicographic order: depth dominates."""
        if self.depth != other.depth:
            return self.depth < other.depth
        return self.exponent < other.exponent
    
    def exp_shift(self):
        return GrowthLevel(self.depth + 1, self.exponent)
    
    def log_shift(self):
        return GrowthLevel(self.depth - 1, self.exponent)
    
    def evaluate(self, x: float) -> float:
        """Evaluate the transmonomial at x."""
        try:
            if self.depth == 0:
                return x ** self.exponent
            elif self.depth == 1:
                return math.exp(self.exponent * x)
            elif self.depth == -1:
                return math.log(x) ** self.exponent if x > 0 else 0
            elif self.depth == 2:
                return math.exp(self.exponent * math.exp(x))
            elif self.depth == -2:
                return math.log(math.log(x)) ** self.exponent if x > math.e else 0
            else:
                return x ** self.exponent  # fallback
        except (OverflowError, ValueError):
            return float('inf')


class TransTerm:
    """A single term: coefficient × transmonomial."""
    def __init__(self, coeff: float, level: GrowthLevel):
        self.coeff = coeff
        self.level = level
    
    def __repr__(self):
        return f"{self.coeff}·{self.level}"
    
    def evaluate(self, x: float) -> float:
        return self.coeff * self.level.evaluate(x)


class Transseries:
    """A transseries: finite formal sum of transmonomial terms."""
    
    def __init__(self, terms: List[TransTerm]):
        self.terms = terms
    
    def __repr__(self):
        return " + ".join(str(t) for t in self.terms)
    
    def evaluate(self, x: float) -> float:
        return sum(t.evaluate(x) for t in self.terms)
    
    def depth_shift_up(self):
        return Transseries([TransTerm(t.coeff, t.level.exp_shift()) for t in self.terms])
    
    def depth_shift_down(self):
        return Transseries([TransTerm(t.coeff, t.level.log_shift()) for t in self.terms])
    
    def is_power_series(self):
        return all(t.level.depth == 0 for t in self.terms)
    
    def is_purely_exponential(self):
        return all(t.level.depth > 0 for t in self.terms)
    
    def classify(self) -> str:
        depths = set(t.level.depth for t in self.terms)
        if not depths:
            return "zero"
        if all(d == 0 for d in depths):
            return "power series"
        if all(d > 0 for d in depths):
            return "purely exponential"
        if all(d < 0 for d in depths):
            return "purely logarithmic"
        return "mixed"


# ============================================================
# Demo 1: Exponential Dominance
# ============================================================

def demo_exponential_dominance():
    print("=" * 60)
    print("DEMO 1: Exponential Dominance")
    print("exp(x) / x^n → ∞ as x → ∞")
    print("=" * 60)
    
    for n in [2, 5, 10]:
        print(f"\n  exp(x) / x^{n}:")
        for x in [10, 50, 100, 500, 1000]:
            try:
                ratio = math.exp(x) / (x ** n)
                print(f"    x = {x:>5}: {ratio:.2e}")
            except OverflowError:
                print(f"    x = {x:>5}: overflow (→ ∞)")


# ============================================================
# Demo 2: Three-Level Hierarchy
# ============================================================

def demo_three_level_hierarchy():
    print("\n" + "=" * 60)
    print("DEMO 2: Three-Level Hierarchy")
    print("log(x) ≪ x ≪ exp(x)")
    print("=" * 60)
    
    print("\n  x / log(x):")
    for x in [10, 100, 1000, 10000, 100000]:
        ratio = x / math.log(x)
        print(f"    x = {x:>7}: {ratio:.2f}")
    
    print("\n  exp(x) / x:")
    for x in [5, 10, 20, 50, 100]:
        try:
            ratio = math.exp(x) / x
            print(f"    x = {x:>5}: {ratio:.2e}")
        except OverflowError:
            print(f"    x = {x:>5}: overflow (→ ∞)")


# ============================================================
# Demo 3: Double-Exponential Dominance
# ============================================================

def demo_double_exponential():
    print("\n" + "=" * 60)
    print("DEMO 3: Double-Exponential Dominance")
    print("exp(exp(x)) / exp(αx) → ∞ for any α")
    print("=" * 60)
    
    for alpha in [1, 10, 100]:
        print(f"\n  exp(exp(x)) / exp({alpha}x):")
        for x in [3, 5, 7, 10]:
            try:
                # exp(exp(x) - αx) to avoid overflow
                exponent = math.exp(x) - alpha * x
                if exponent > 700:
                    print(f"    x = {x:>3}: > 10^300 (→ ∞)")
                else:
                    ratio = math.exp(exponent)
                    print(f"    x = {x:>3}: {ratio:.2e}")
            except OverflowError:
                print(f"    x = {x:>3}: overflow (→ ∞)")


# ============================================================
# Demo 4: Asymptotic Comparison at Same Level
# ============================================================

def demo_same_level_comparison():
    print("\n" + "=" * 60)
    print("DEMO 4: Asymptotic Comparison (Same Growth Level)")
    print("(c₁·m(x)) / (c₂·m(x)) → c₁/c₂")
    print("=" * 60)
    
    c1, c2 = 3.0, 5.0
    g = GrowthLevel(1, 1)  # exp(x)
    
    print(f"\n  T₁ = {c1}·exp(x), T₂ = {c2}·exp(x)")
    print(f"  Expected ratio: {c1}/{c2} = {c1/c2}")
    
    for x in [1, 5, 10, 50, 100]:
        t1 = c1 * g.evaluate(x)
        t2 = c2 * g.evaluate(x)
        ratio = t1 / t2 if t2 != 0 else float('inf')
        print(f"    x = {x:>5}: ratio = {ratio:.6f}")


# ============================================================
# Demo 5: Depth Filtration and Classification
# ============================================================

def demo_depth_filtration():
    print("\n" + "=" * 60)
    print("DEMO 5: Depth Filtration and Classification Shift")
    print("=" * 60)
    
    # A power series: 3x² + 5x
    T = Transseries([
        TransTerm(3, GrowthLevel(0, 2)),
        TransTerm(5, GrowthLevel(0, 1))
    ])
    print(f"\n  T = {T}")
    print(f"  Classification: {T.classify()}")
    
    # Shift up
    T_up = T.depth_shift_up()
    print(f"\n  depthShiftUp(T) = {T_up}")
    print(f"  Classification: {T_up.classify()}")
    
    # Shift down
    T_down = T.depth_shift_down()
    print(f"\n  depthShiftDown(T) = {T_down}")
    print(f"  Classification: {T_down.classify()}")
    
    # Verify involution
    T_round = T_up.depth_shift_down()
    print(f"\n  depthShiftDown(depthShiftUp(T)) = {T_round}")
    print(f"  Same as T? Levels match: "
          f"{all(a.level.depth == b.level.depth and a.level.exponent == b.level.exponent for a, b in zip(T.terms, T_round.terms))}")


# ============================================================
# Demo 6: Mixed Transseries Evaluation
# ============================================================

def demo_mixed_transseries():
    print("\n" + "=" * 60)
    print("DEMO 6: Mixed Transseries Evaluation")
    print("T = 2·exp(x) + 3·x² - log(x)")
    print("=" * 60)
    
    T = Transseries([
        TransTerm(2, GrowthLevel(1, 1)),
        TransTerm(3, GrowthLevel(0, 2)),
        TransTerm(-1, GrowthLevel(-1, 1))
    ])
    
    print(f"\n  Terms: {T}")
    for x in [2, 5, 10, 20, 50]:
        val = T.evaluate(x)
        exp_part = 2 * math.exp(x)
        poly_part = 3 * x**2
        log_part = -math.log(x)
        print(f"  x = {x:>3}: T(x) = {val:.2e}  "
              f"[exp: {exp_part:.2e}, poly: {poly_part:.2e}, log: {log_part:.2f}]")
        if exp_part > 0:
            print(f"           exp contribution: {100*exp_part/val:.1f}%")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("TRANSSERIES: Asymptotic Expansions Beyond Power Series")
    print("Numerical Demonstrations of Core Theorems")
    print()
    
    demo_exponential_dominance()
    demo_three_level_hierarchy()
    demo_double_exponential()
    demo_same_level_comparison()
    demo_depth_filtration()
    demo_mixed_transseries()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


"""
Visualization: The Transseries Growth Hierarchy

Plots the three-level hierarchy: log(x) ≪ x ≪ exp(x),
showing how each level dominates the previous one.
"""

import numpy as np

def create_growth_hierarchy_plot():
    """Create and save the growth hierarchy visualization."""
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available; skipping visualization.")
        return

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Panel 1: The three levels
    x = np.linspace(1.1, 20, 500)

    ax = axes[0]
    ax.plot(x, np.log(x), label=r'$\log(x)$', color='#2196F3', linewidth=2)
    ax.plot(x, x, label=r'$x$', color='#4CAF50', linewidth=2)
    ax.plot(x, np.exp(x/5), label=r'$e^{x/5}$', color='#F44336', linewidth=2)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('f(x)', fontsize=12)
    ax.set_title('Three Growth Levels', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_ylim(0, 30)
    ax.grid(True, alpha=0.3)

    # Panel 2: Dominance ratios
    x2 = np.linspace(2, 100, 500)

    ax = axes[1]
    ax.plot(x2, x2 / np.log(x2), label=r'$x / \log(x)$', color='#4CAF50', linewidth=2)
    ax.plot(x2, np.exp(x2/20) / x2, label=r'$e^{x/20} / x$', color='#F44336', linewidth=2)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('Ratio', fontsize=12)
    ax.set_title('Dominance Ratios → ∞', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_ylim(0, 50)
    ax.grid(True, alpha=0.3)

    # Panel 3: exp(x)/x^n for various n
    x3 = np.linspace(1, 30, 500)

    ax = axes[2]
    for n in [1, 2, 5, 10]:
        ratio = np.exp(x3) / (x3 ** n)
        ax.semilogy(x3, ratio, label=f'$e^x / x^{{{n}}}$', linewidth=2)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('Ratio (log scale)', fontsize=12)
    ax.set_title('Exponential Dominance', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('growth_hierarchy.png', dpi=150, bbox_inches='tight')
    print("Saved: growth_hierarchy.png")
    plt.close()


if __name__ == "__main__":
    create_growth_hierarchy_plot()
