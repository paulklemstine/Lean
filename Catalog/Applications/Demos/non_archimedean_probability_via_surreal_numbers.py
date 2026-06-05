#!/usr/bin/env python3
"""
Non-Archimedean Probability: Numerical Demonstrations

Demonstrates the key concepts of infinitesimal probability theory using
symbolic representations of surreal numbers.
"""

from fractions import Fraction
from typing import List, Set, Tuple


class SurrealApprox:
    """
    A simplified representation of surreal numbers as pairs (real_part, infinitesimal_order).
    Represents numbers of the form a + b/ω where a is the real part and b is the
    coefficient of 1/ω (the infinitesimal part).

    This is a truncated Hahn series representation sufficient for demonstrating
    the key phenomena.
    """

    def __init__(self, real: Fraction = Fraction(0), infinitesimal: Fraction = Fraction(0)):
        self.real = real  # coefficient of ω^0
        self.inf = infinitesimal  # coefficient of ω^(-1), i.e., 1/ω

    def __add__(self, other: 'SurrealApprox') -> 'SurrealApprox':
        return SurrealApprox(self.real + other.real, self.inf + other.inf)

    def __sub__(self, other: 'SurrealApprox') -> 'SurrealApprox':
        return SurrealApprox(self.real - other.real, self.inf - other.inf)

    def __mul__(self, n: int) -> 'SurrealApprox':
        """Scalar multiplication by a natural number."""
        return SurrealApprox(self.real * n, self.inf * n)

    def __rmul__(self, n: int) -> 'SurrealApprox':
        return self.__mul__(n)

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, SurrealApprox):
            return NotImplemented
        return self.real == other.real and self.inf == other.inf

    def __lt__(self, other: 'SurrealApprox') -> bool:
        if self.real != other.real:
            return self.real < other.real
        return self.inf < other.inf

    def __le__(self, other: 'SurrealApprox') -> bool:
        return self == other or self < other

    def __gt__(self, other: 'SurrealApprox') -> bool:
        return other < self

    def __repr__(self) -> str:
        parts = []
        if self.real != 0:
            parts.append(str(self.real))
        if self.inf != 0:
            if self.inf == 1:
                parts.append("ε")
            elif self.inf == -1:
                parts.append("-ε")
            else:
                parts.append(f"{self.inf}ε")
        if not parts:
            return "0"
        return " + ".join(parts)

    def is_infinitesimal(self) -> bool:
        """Check if this number is infinitesimal (real part is zero, inf part positive)."""
        return self.real == 0 and self.inf > 0

    def is_positive(self) -> bool:
        """Check if strictly positive."""
        return self > SurrealApprox()


# Convenience constructors
ZERO = SurrealApprox()
ONE = SurrealApprox(Fraction(1))
EPSILON = SurrealApprox(Fraction(0), Fraction(1))  # 1/ω


def demo_archimedean_obstruction():
    """Demonstrate that ℝ has no infinitesimals (Theorem 1)."""
    print("=" * 60)
    print("DEMO 1: Archimedean Obstruction")
    print("=" * 60)
    print()
    print("In ℝ, every positive number eventually exceeds 1 when")
    print("multiplied by a large enough integer:")
    print()

    for eps_val in [0.1, 0.01, 0.001, 0.0001]:
        n = int(1.0 / eps_val) + 1
        print(f"  ε = {eps_val}: {n} × ε = {n * eps_val:.4f} > 1  ✓")

    print()
    print("No real number is infinitesimal. (Theorem 1: archimedean_no_infinitesimal)")
    print()


def demo_surreal_infinitesimal():
    """Demonstrate infinitesimal behavior in surreal-like numbers (Theorem 2-4)."""
    print("=" * 60)
    print("DEMO 2: Surreal Infinitesimals")
    print("=" * 60)
    print()

    eps = EPSILON
    print(f"  ε = {eps}")
    print(f"  ε is positive: {eps.is_positive()}")
    print(f"  ε is infinitesimal: {eps.is_infinitesimal()}")
    print()

    # Demonstrate that finite multiples stay infinitesimal
    print("Finite multiples of ε remain infinitesimal (Theorem 4):")
    for n in [1, 10, 100, 1000, 1000000]:
        result = n * eps
        print(f"  {n} × ε = {result}, infinitesimal: {result.is_infinitesimal()}")

    print()
    print("But n × ε < 1 for ALL finite n. (Non-Archimedean!)")
    print()

    # Convexity
    half_eps = SurrealApprox(Fraction(0), Fraction(1, 2))
    print(f"Convexity (Theorem 2): ε/2 = {half_eps}")
    print(f"  0 < ε/2 ≤ ε: {ZERO < half_eps and half_eps <= eps}")
    print(f"  ε/2 is infinitesimal: {half_eps.is_infinitesimal()}")
    print()


def demo_finite_measure():
    """Demonstrate finitely additive infinitesimal measure (Theorems 5-7)."""
    print("=" * 60)
    print("DEMO 3: Infinitesimal Probability Measure on Fin(n)")
    print("=" * 60)
    print()

    for n in [3, 5, 10, 100]:
        eps = EPSILON
        points = list(range(n))
        total = n * eps

        print(f"  Fin({n}): each point gets mass ε = {eps}")
        print(f"    Total mass = {n} × ε = {total}")
        print(f"    Total ≤ 1: {total <= ONE}")
        print(f"    Total is infinitesimal: {total.is_infinitesimal()}")
        print()

    # Finite additivity
    print("Finite additivity (Theorem 5):")
    S = {0, 1}
    T = {2, 3, 4}
    eps = EPSILON
    mu_S = len(S) * eps
    mu_T = len(T) * eps
    mu_union = len(S | T) * eps
    print(f"  S = {S}, μ(S) = {mu_S}")
    print(f"  T = {T}, μ(T) = {mu_T}")
    print(f"  S ∪ T = {S | T}, μ(S ∪ T) = {mu_union}")
    print(f"  μ(S) + μ(T) = {mu_S + mu_T}")
    print(f"  Additivity: μ(S ∪ T) = μ(S) + μ(T)? {mu_union == mu_S + mu_T}")
    print()


def demo_discrimination():
    """Demonstrate that infinitesimal measures discriminate sets (Theorem 14)."""
    print("=" * 60)
    print("DEMO 4: Discrimination Theorem")
    print("=" * 60)
    print()
    print("Classical probability on [0,1]: all finite sets have measure 0.")
    print("Infinitesimal probability discriminates by cardinality:")
    print()

    n = 6
    eps = EPSILON

    # Show all possible measures
    for k in range(n + 1):
        measure = k * eps
        print(f"  |S| = {k}: μ(S) = {measure}")

    print()
    print("Every cardinality gives a DISTINCT measure value!")
    print("Sets {0,1} and {0,1,2} are distinguishable: 2ε ≠ 3ε")
    print()


def demo_anti_cancellation():
    """Demonstrate the anti-cancellation bridge (Theorem 11)."""
    print("=" * 60)
    print("DEMO 5: Anti-Cancellation Bridge")
    print("=" * 60)
    print()
    print("If all point masses are positive, total mass is positive.")
    print("(Analog of sum_ne_zero_of_same_sign_and_exists_ne_zero)")
    print()

    # Various positive measures
    measures = [
        [EPSILON, EPSILON, EPSILON],
        [SurrealApprox(Fraction(0), Fraction(1, 3)),
         SurrealApprox(Fraction(0), Fraction(2, 3)),
         EPSILON],
        [SurrealApprox(Fraction(1, 2)), EPSILON,
         SurrealApprox(Fraction(0), Fraction(7))],
    ]

    for i, mu in enumerate(measures):
        total = ZERO
        for m in mu:
            total = total + m
        all_pos = all(m.is_positive() for m in mu)
        print(f"  Measure {i + 1}: masses = [{', '.join(str(m) for m in mu)}]")
        print(f"    All positive: {all_pos}")
        print(f"    Total = {total}")
        print(f"    Total > 0: {total.is_positive()}")
        print()


def demo_complementation():
    """Demonstrate the complementation identity (Theorem 12)."""
    print("=" * 60)
    print("DEMO 6: Complementation Identity")
    print("=" * 60)
    print()

    n = 5
    eps = EPSILON
    total = n * eps

    for k in range(n + 1):
        mu_S = k * eps
        mu_comp = (n - k) * eps
        sum_val = mu_S + mu_comp
        print(f"  |S| = {k}: μ(S) = {mu_S}, μ(Sᶜ) = {mu_comp}, "
              f"sum = {sum_val} = total? {sum_val == total}")

    print()


if __name__ == "__main__":
    demo_archimedean_obstruction()
    demo_surreal_infinitesimal()
    demo_finite_measure()
    demo_discrimination()
    demo_anti_cancellation()
    demo_complementation()

    print("=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Infinitesimal vs Standard Probability Measures

Compares standard (ℝ-valued) and infinitesimal (surreal-valued) probability
measures on finite sets, illustrating the discrimination theorem.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_measure_comparison():
    """Compare standard and infinitesimal measures on subsets of Fin(6)."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    n = 6
    cardinalities = list(range(n + 1))

    # Standard uniform measure on Fin(6): each point has mass 1/6
    standard_measures = [k / n for k in cardinalities]

    # Infinitesimal measure: each point has mass ε
    # We represent ε as a small visual value but label correctly
    inf_measures = list(range(n + 1))  # k * ε

    # Plot 1: Standard measure
    ax1 = axes[0]
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, n + 1))
    bars1 = ax1.bar(cardinalities, standard_measures, color=colors, edgecolor='black', linewidth=0.5)
    ax1.set_xlabel('Cardinality |S|', fontsize=12)
    ax1.set_ylabel('μ(S)', fontsize=12)
    ax1.set_title('Standard Uniform Measure on Fin(6)\n(ℝ-valued, Archimedean)', fontsize=13)
    ax1.set_xticks(cardinalities)
    ax1.set_ylim(0, 1.15)

    for bar, val in zip(bars1, standard_measures):
        ax1.text(bar.get_x() + bar.get_width() / 2., bar.get_height() + 0.02,
                f'{val:.3f}', ha='center', va='bottom', fontsize=9)

    # Plot 2: Infinitesimal measure
    ax2 = axes[1]
    bars2 = ax2.bar(cardinalities, inf_measures, color=colors, edgecolor='black', linewidth=0.5)
    ax2.set_xlabel('Cardinality |S|', fontsize=12)
    ax2.set_ylabel('μ(S) / ε', fontsize=12)
    ax2.set_title('Infinitesimal Uniform Measure on Fin(6)\n(Surreal-valued, Non-Archimedean)', fontsize=13)
    ax2.set_xticks(cardinalities)

    for bar, val in zip(bars2, inf_measures):
        ax2.text(bar.get_x() + bar.get_width() / 2., bar.get_height() + 0.1,
                f'{val}ε', ha='center', va='bottom', fontsize=9)

    # Add annotation about discrimination
    ax2.annotate('All values distinct!\n(Discrimination Theorem)',
                xy=(3, 3), fontsize=10,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow',
                         edgecolor='orange', alpha=0.8),
                ha='center')

    plt.tight_layout()
    plt.savefig('measure_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: measure_comparison.png")


def plot_archimedean_obstruction():
    """Visualize the Archimedean obstruction: n*ε eventually exceeds u."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Archimedean case (ℝ)
    ax1 = axes[0]
    epsilon = 0.15
    u = 1.0
    ns = np.arange(0, 12)
    values = ns * epsilon

    colors_arch = ['green' if v <= u else 'red' for v in values]
    ax1.bar(ns, values, color=colors_arch, edgecolor='black', linewidth=0.5)
    ax1.axhline(y=u, color='blue', linestyle='--', linewidth=2, label=f'u = {u}')
    ax1.set_xlabel('n (number of copies)', fontsize=12)
    ax1.set_ylabel('n · ε', fontsize=12)
    ax1.set_title(f'Archimedean (ℝ): ε = {epsilon}\nn·ε eventually exceeds u', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.set_xticks(ns)

    n_exceed = int(np.ceil(u / epsilon))
    ax1.annotate(f'Exceeds u at n={n_exceed}!',
                xy=(n_exceed, n_exceed * epsilon),
                xytext=(n_exceed + 1, n_exceed * epsilon + 0.3),
                arrowprops=dict(arrowstyle='->', color='red'),
                fontsize=10, color='red', fontweight='bold')

    # Non-Archimedean case (Surreal)
    ax2 = axes[1]
    ns2 = np.arange(0, 12)
    # In non-Archimedean: n·ε is always infinitesimal, never reaches u=1
    # Visually: show all bars at a very small height
    inf_values = ns2 * 0.05  # Visual representation of n·ε

    ax2.bar(ns2, inf_values, color='green', edgecolor='black', linewidth=0.5)
    ax2.axhline(y=u, color='blue', linestyle='--', linewidth=2, label='u = 1')
    ax2.set_xlabel('n (number of copies)', fontsize=12)
    ax2.set_ylabel('n · ε (relative to u)', fontsize=12)
    ax2.set_title('Non-Archimedean (Surreal): ε = 1/ω\nn·ε NEVER reaches u', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.set_xticks(ns2)
    ax2.set_ylim(0, 1.5)

    ax2.annotate('Gap is infinite!\nNo finite n bridges it.',
                xy=(6, 0.3), xytext=(6, 0.7),
                arrowprops=dict(arrowstyle='->', color='green'),
                fontsize=10, color='green', fontweight='bold',
                ha='center')

    plt.tight_layout()
    plt.savefig('archimedean_obstruction.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: archimedean_obstruction.png")


def plot_infinitesimal_structure():
    """Visualize the structure of infinitesimals: convexity and additive closure."""
    fig, ax = plt.subplots(figsize=(10, 6))

    # Number line with infinitesimal region
    ax.set_xlim(-0.5, 3.5)
    ax.set_ylim(-0.3, 1.5)

    # Draw number line
    ax.axhline(y=0, color='black', linewidth=1.5)

    # Mark key points
    points = {
        0: ('0', 'black'),
        0.3: ('ε/2', 'blue'),
        0.6: ('ε', 'blue'),
        0.9: ('3ε/2', 'blue'),
        1.2: ('2ε', 'blue'),
        3.0: ('1', 'red'),
    }

    for x, (label, color) in points.items():
        ax.plot(x, 0, 'o', markersize=8, color=color)
        ax.annotate(label, xy=(x, 0), xytext=(x, -0.15),
                   ha='center', fontsize=11, color=color)

    # Infinitesimal region
    inf_patch = mpatches.FancyBboxPatch((-0.1, 0.1), 1.5, 0.3,
                                         boxstyle="round,pad=0.05",
                                         facecolor='lightblue', alpha=0.5,
                                         edgecolor='blue', linewidth=2)
    ax.add_patch(inf_patch)
    ax.text(0.65, 0.25, 'Infinitesimal Region', ha='center', fontsize=12,
           color='blue', fontweight='bold')

    # Standard region
    std_patch = mpatches.FancyBboxPatch((2.5, 0.1), 1.0, 0.3,
                                        boxstyle="round,pad=0.05",
                                        facecolor='lightyellow', alpha=0.5,
                                        edgecolor='red', linewidth=2)
    ax.add_patch(std_patch)
    ax.text(3.0, 0.25, 'Standard Region', ha='center', fontsize=12,
           color='red', fontweight='bold')

    # Gap annotation
    ax.annotate('', xy=(1.4, 0.6), xytext=(2.5, 0.6),
               arrowprops=dict(arrowstyle='<->', color='purple', lw=2))
    ax.text(1.95, 0.7, 'Infinite gap\n(no finite n bridges this)',
           ha='center', fontsize=10, color='purple')

    # Convexity annotation
    ax.annotate('Convex: if x ≤ ε\nthen x is infinitesimal',
               xy=(0.3, 0.05), xytext=(-0.3, 0.8),
               arrowprops=dict(arrowstyle='->', color='green'),
               fontsize=10, color='green',
               bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.5))

    # Additive closure annotation
    ax.annotate('Closed under +:\nε + ε = 2ε ∈ Inf',
               xy=(1.2, 0.05), xytext=(1.5, 0.8),
               arrowprops=dict(arrowstyle='->', color='orange'),
               fontsize=10, color='orange',
               bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.5))

    ax.set_title('Structure of Infinitesimals in Non-Archimedean Groups', fontsize=14)
    ax.set_xlabel('Value', fontsize=12)
    ax.get_yaxis().set_visible(False)

    plt.tight_layout()
    plt.savefig('infinitesimal_structure.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: infinitesimal_structure.png")


if __name__ == "__main__":
    plot_measure_comparison()
    plot_archimedean_obstruction()
    plot_infinitesimal_structure()
    print("\nAll visualizations generated.")
