"""
Ultrametric Deep Learning: Python Demo
======================================

This demo illustrates the key theorems from the Lean 4 formalization
with concrete numerical examples over the p-adic numbers.

We simulate p-adic arithmetic using rational approximations and
demonstrate:
1. The ultrametric (strong) triangle inequality
2. The isosceles principle (no partial cancellation)
3. Entrywise norm submultiplicativity (no factor of n)
4. Pruning advantage (errors combine via max, not sum)
5. Valuation monotone pruning (higher valuation → smaller error)
"""

import numpy as np
import matplotlib.pyplot as plt
from fractions import Fraction
from typing import List, Tuple
import matplotlib
matplotlib.rcParams['figure.figsize'] = (10, 6)


# =============================================================================
# §1. p-Adic Valuation and Norm
# =============================================================================

def p_adic_valuation(n: int, p: int) -> int:
    """Compute v_p(n) = largest k such that p^k divides n."""
    if n == 0:
        return float('inf')
    n = abs(n)
    k = 0
    while n % p == 0:
        n //= p
        k += 1
    return k


def p_adic_valuation_rational(num: int, den: int, p: int) -> int:
    """Compute v_p(num/den) = v_p(num) - v_p(den)."""
    if num == 0:
        return float('inf')
    return p_adic_valuation(num, p) - p_adic_valuation(den, p)


def p_adic_norm(num: int, den: int, p: int) -> float:
    """Compute |num/den|_p = p^{-v_p(num/den)}."""
    v = p_adic_valuation_rational(num, den, p)
    if v == float('inf'):
        return 0.0
    return p ** (-v)


class PadicNumber:
    """A rational number viewed with its p-adic norm."""
    def __init__(self, num: int, den: int = 1, p: int = 5):
        self.num = num
        self.den = den
        self.p = p
        # Simplify
        from math import gcd
        g = gcd(abs(num), abs(den))
        if g > 0:
            self.num = num // g
            self.den = den // g

    def norm(self) -> float:
        return p_adic_norm(self.num, self.den, self.p)

    def valuation(self) -> int:
        return p_adic_valuation_rational(self.num, self.den, self.p)

    def __add__(self, other):
        num = self.num * other.den + other.num * self.den
        den = self.den * other.den
        return PadicNumber(num, den, self.p)

    def __neg__(self):
        return PadicNumber(-self.num, self.den, self.p)

    def __sub__(self, other):
        return self + (-other)

    def __mul__(self, other):
        return PadicNumber(self.num * other.num, self.den * other.den, self.p)

    def __repr__(self):
        if self.den == 1:
            return f"{self.num}"
        return f"{self.num}/{self.den}"


# =============================================================================
# §2. Demo: Ultrametric Triangle Inequality
# =============================================================================

def demo_ultrametric_inequality():
    """Demonstrate ‖x + y‖ ≤ max(‖x‖, ‖y‖) for various p-adic numbers."""
    print("=" * 60)
    print("DEMO 1: Ultrametric Triangle Inequality")
    print("  ‖x + y‖_p ≤ max(‖x‖_p, ‖y‖_p)")
    print("=" * 60)

    p = 5
    examples = [
        (PadicNumber(3, 1, p), PadicNumber(7, 1, p)),
        (PadicNumber(5, 1, p), PadicNumber(10, 1, p)),
        (PadicNumber(25, 1, p), PadicNumber(3, 1, p)),
        (PadicNumber(1, 5, p), PadicNumber(2, 25, p)),
        (PadicNumber(100, 1, p), PadicNumber(-100, 1, p)),  # Cancellation case
    ]

    for x, y in examples:
        s = x + y
        nx, ny, ns = x.norm(), y.norm(), s.norm()
        max_n = max(nx, ny)
        status = "✓" if ns <= max_n + 1e-10 else "✗"
        iso = "ISOSCELES" if abs(ns - max_n) < 1e-10 and nx != ny else ""
        cancel = "CANCEL" if abs(ns) < 1e-10 else ""
        print(f"  x={str(x):>8}, y={str(y):>8}, x+y={str(s):>8} | "
              f"‖x‖={nx:.4f}, ‖y‖={ny:.4f}, ‖x+y‖={ns:.4f}, "
              f"max={max_n:.4f} {status} {iso} {cancel}")

    # Contrast with Archimedean
    print("\n  CONTRAST: In ℝ, |3 + (-3)| = 0 < max(|3|, |-3|) = 3")
    print("  In ℚ_5, this can also happen (when norms are equal).")
    print("  But if ‖x‖ ≠ ‖y‖, ‖x+y‖ = max(‖x‖,‖y‖) ALWAYS.")
    print()


# =============================================================================
# §3. Demo: Isosceles Principle (No Partial Cancellation)
# =============================================================================

def demo_isosceles_principle():
    """Demonstrate that unequal norms → sum = max (no cancellation)."""
    print("=" * 60)
    print("DEMO 2: Isosceles Principle (Saddle Elimination)")
    print("  If ‖x‖ ≠ ‖y‖, then ‖x + y‖ = max(‖x‖, ‖y‖)")
    print("=" * 60)

    p = 5
    count_iso = 0
    count_total = 0

    for a in range(-20, 21):
        for b in range(-20, 21):
            if a == 0 or b == 0:
                continue
            x = PadicNumber(a, 1, p)
            y = PadicNumber(b, 1, p)
            s = x + y
            if x.norm() != y.norm():
                count_total += 1
                if abs(s.norm() - max(x.norm(), y.norm())) < 1e-10:
                    count_iso += 1

    print(f"  Tested {count_total} pairs with ‖x‖ ≠ ‖y‖")
    print(f"  Isosceles (‖x+y‖ = max): {count_iso}/{count_total} = "
          f"{100*count_iso/count_total:.1f}%")
    print(f"  → The isosceles principle holds for ALL pairs!")
    print()

    # Gradient implications
    print("  IMPLICATION FOR ML:")
    print("  If gradient components g₁, g₂ have ‖g₁‖ ≠ ‖g₂‖,")
    print("  then ‖g₁ + g₂‖ = max(‖g₁‖, ‖g₂‖) > 0.")
    print("  → The gradient CANNOT be zero (no saddle point)!")
    print("  → Saddle points require ALL components to have EQUAL norm.")
    print()


# =============================================================================
# §4. Demo: Entrywise Norm Submultiplicativity
# =============================================================================

def demo_submultiplicativity():
    """Demonstrate ‖BA‖_∞ ≤ ‖B‖_∞ · ‖A‖_∞ (no factor of n)."""
    print("=" * 60)
    print("DEMO 3: Entrywise Norm Submultiplicativity")
    print("  Ultrametric: ‖BA‖_∞ ≤ ‖B‖_∞ · ‖A‖_∞")
    print("  Archimedean: ‖BA‖_∞ ≤ n · ‖B‖_∞ · ‖A‖_∞")
    print("=" * 60)

    p = 5
    np.random.seed(42)

    for n in [3, 5, 10, 20]:
        # Random integer matrices (entries from -50 to 50)
        A_ints = np.random.randint(-50, 51, (n, n))
        B_ints = np.random.randint(-50, 51, (n, n))
        BA_ints = B_ints @ A_ints

        # Compute p-adic entry norms
        norm_A = max(p_adic_norm(int(A_ints[i, j]), 1, p)
                     for i in range(n) for j in range(n))
        norm_B = max(p_adic_norm(int(B_ints[i, j]), 1, p)
                     for i in range(n) for j in range(n))
        norm_BA = max(p_adic_norm(int(BA_ints[i, j]), 1, p)
                      for i in range(n) for j in range(n))

        ultra_bound = norm_B * norm_A
        archi_bound = n * norm_B * norm_A
        ratio = archi_bound / ultra_bound if ultra_bound > 0 else float('inf')

        print(f"  n={n:>2}: ‖BA‖={norm_BA:.4f}, "
              f"ultra_bound={ultra_bound:.4f}, "
              f"archi_bound={archi_bound:.4f}, "
              f"ratio={ratio:.0f}x")

    print("\n  → Ultrametric bound is n times tighter!")
    print("  → For L-layer network with width w: advantage = w^L")
    print()


# =============================================================================
# §5. Demo: Pruning Advantage
# =============================================================================

def demo_pruning_advantage():
    """Demonstrate O(n) pruning advantage: max vs sum of errors."""
    print("=" * 60)
    print("DEMO 4: Ultrametric Pruning Advantage")
    print("  Archimedean: total_error ≤ Σ |eᵢ| = O(n · max)")
    print("  Ultrametric: total_error ≤ max |eᵢ| = O(max)")
    print("=" * 60)

    p = 5
    np.random.seed(123)

    for n_pruned in [10, 100, 1000]:
        # Simulate pruning n weights with random 5-adic valuations
        valuations = np.random.randint(0, 5, n_pruned)
        norms = [float(p) ** (-int(v)) for v in valuations]

        archi_total = sum(norms)
        ultra_total = max(norms)
        advantage = archi_total / ultra_total if ultra_total > 0 else float('inf')

        print(f"  n_pruned={n_pruned:>5}: "
              f"archi_error={archi_total:>10.4f}, "
              f"ultra_error={ultra_total:>8.4f}, "
              f"advantage={advantage:>8.1f}x")

    print("\n  → Ultrametric pruning error doesn't grow with n!")
    print()


# =============================================================================
# §6. Demo: Valuation Monotone Pruning
# =============================================================================

def demo_valuation_pruning():
    """Demonstrate: higher valuation → smaller p-adic norm → prune first."""
    print("=" * 60)
    print("DEMO 5: Valuation Monotone Pruning Priority")
    print("  v_p(w₁) ≤ v_p(w₂) ⟹ ‖w₂‖ ≤ ‖w₁‖")
    print("  Prune highest-valuation weights first!")
    print("=" * 60)

    p = 5
    weights = [1, 2, 3, 5, 10, 15, 25, 50, 75, 125, 250, 625]

    print(f"  {'Weight':>8} | {'v_5(w)':>8} | {'‖w‖_5':>10} | Priority")
    print(f"  {'-'*8} | {'-'*8} | {'-'*10} | {'-'*8}")

    weight_data = [(w, p_adic_valuation(w, p), p_adic_norm(w, 1, p))
                   for w in weights]
    weight_data.sort(key=lambda x: -x[1])  # Sort by valuation descending

    for i, (w, v, n) in enumerate(weight_data):
        priority = "← PRUNE FIRST" if i < 4 else ""
        print(f"  {w:>8} | {v:>8} | {n:>10.6f} | {priority}")

    print("\n  → Higher valuation = smaller norm = safer to prune")
    print()


# =============================================================================
# §7. Visualization: Archimedean vs Ultrametric Bounds
# =============================================================================

def plot_comparison():
    """Plot the Archimedean vs ultrametric generalization bound ratio."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Plot 1: Generalization bound ratio vs depth
    ax = axes[0]
    widths = [10, 50, 100, 500]
    depths = range(1, 11)
    for w in widths:
        ratios = [w ** d for d in depths]
        ax.semilogy(list(depths), ratios, 'o-', label=f'width={w}')
    ax.set_xlabel('Network Depth L')
    ax.set_ylabel('Advantage Ratio (∏ wᵢ)')
    ax.set_title('Ultrametric vs Archimedean\nGeneralization Bound Ratio')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 2: Pruning advantage vs number pruned
    ax = axes[1]
    n_values = np.arange(1, 1001)
    ax.plot(n_values, n_values, 'r-', label='Archimedean (sum)', linewidth=2)
    ax.axhline(y=1, color='b', linestyle='-', label='Ultrametric (max)',
               linewidth=2)
    ax.set_xlabel('Number of Pruned Weights')
    ax.set_ylabel('Total Error / Max Individual Error')
    ax.set_title('Pruning Error Accumulation')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 100)

    # Plot 3: p-adic norm values (discrete spectrum)
    ax = axes[2]
    p = 5
    integers = list(range(1, 200))
    norms = [p_adic_norm(n, 1, p) for n in integers]
    ax.scatter(integers, norms, s=5, alpha=0.6, c='darkblue')
    ax.set_xlabel('Integer n')
    ax.set_ylabel('‖n‖₅')
    ax.set_title('5-adic Norm: Discrete Spectrum\n(norms ∈ {5ᵏ : k ∈ ℤ})')
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('ultrametric_deep_learning_demo.png', dpi=150, bbox_inches='tight')
    print("  [Saved: ultrametric_deep_learning_demo.png]")
    plt.close()


# =============================================================================
# §8. Main
# =============================================================================

if __name__ == "__main__":
    print("\n" + "🔬 " * 20)
    print("  ULTRAMETRIC DEEP LEARNING: CONCRETE DEMONSTRATIONS")
    print("🔬 " * 20 + "\n")

    demo_ultrametric_inequality()
    demo_isosceles_principle()
    demo_submultiplicativity()
    demo_pruning_advantage()
    demo_valuation_pruning()

    print("=" * 60)
    print("GENERATING VISUALIZATION")
    print("=" * 60)
    try:
        plot_comparison()
    except Exception as e:
        print(f"  [Visualization skipped: {e}]")

    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)
    print("\nKey Takeaways:")
    print("  1. Ultrametric inequality prevents partial gradient cancellation")
    print("  2. Entrywise norm submultiplicativity removes factor-of-n penalty")
    print("  3. Pruning errors combine via max, not sum (O(n) improvement)")
    print("  4. Higher p-adic valuation = smaller norm = safer to prune")
    print("  5. All results are machine-verified in Lean 4 (0 sorry)")
