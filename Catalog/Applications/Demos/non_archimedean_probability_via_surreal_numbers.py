#!/usr/bin/env python3
"""
Non-Archimedean Probability Theory: Demonstrations

This script demonstrates the key ideas of non-Archimedean probability using
symbolic computation with infinitesimal elements represented as formal
polynomials in ε.
"""

from fractions import Fraction
from typing import Dict, Set, FrozenSet


class InfinitesimalNumber:
    """A number of the form a + b*ε + c*ε² (truncated formal power series).
    
    Represents elements of a non-Archimedean field where ε is a positive
    infinitesimal satisfying n*ε < 1 for all natural n.
    """
    
    def __init__(self, real: Fraction = Fraction(0), 
                 eps1: Fraction = Fraction(0),
                 eps2: Fraction = Fraction(0)):
        self.real = real  # standard part
        self.eps1 = eps1  # coefficient of ε
        self.eps2 = eps2  # coefficient of ε²
    
    def __add__(self, other):
        return InfinitesimalNumber(
            self.real + other.real,
            self.eps1 + other.eps1, 
            self.eps2 + other.eps2
        )
    
    def __sub__(self, other):
        return InfinitesimalNumber(
            self.real - other.real,
            self.eps1 - other.eps1,
            self.eps2 - other.eps2
        )
    
    def __mul__(self, other):
        # (a + bε + cε²)(d + eε + fε²) truncated to O(ε²)
        return InfinitesimalNumber(
            self.real * other.real,
            self.real * other.eps1 + self.eps1 * other.real,
            self.real * other.eps2 + self.eps1 * other.eps1 + self.eps2 * other.real
        )
    
    def __truediv__(self, other):
        if other.real != 0:
            # Division when standard part is nonzero
            inv_r = Fraction(1) / other.real
            # 1/(d + eε + fε²) ≈ (1/d)(1 - (eε+fε²)/d + (eε)²/d²)
            a = inv_r
            b = -other.eps1 * inv_r * inv_r
            c = (other.eps1 * other.eps1 * inv_r - other.eps2) * inv_r * inv_r
            inv = InfinitesimalNumber(a, b, c)
            return self * inv
        elif other.eps1 != 0:
            # Division by an infinitesimal (ε-level)
            inv_e = Fraction(1) / other.eps1
            # Dividing a + bε by eε = a/(eε) + b/e
            # This gives an infinite part - represent as special
            return InfinitesimalNumber(
                self.eps1 * inv_e,  # ε/ε part
                self.eps2 * inv_e,  # ε²/ε part
                Fraction(0)
            )
        else:
            raise ZeroDivisionError("Cannot divide by zero")
    
    def __eq__(self, other):
        if isinstance(other, (int, float, Fraction)):
            other = InfinitesimalNumber(Fraction(other))
        return self.real == other.real and self.eps1 == other.eps1 and self.eps2 == other.eps2
    
    def __repr__(self):
        parts = []
        if self.real != 0:
            parts.append(str(self.real))
        if self.eps1 != 0:
            parts.append(f"{self.eps1}·ε")
        if self.eps2 != 0:
            parts.append(f"{self.eps2}·ε²")
        return " + ".join(parts) if parts else "0"
    
    def is_infinitesimal(self) -> bool:
        """Check if this number is infinitesimal (standard part is zero)."""
        return self.real == 0
    
    def standard_part(self) -> Fraction:
        """Return the standard (real) part, discarding infinitesimals."""
        return self.real


# ============================================================
# Demo 1: Infinitesimal Arithmetic
# ============================================================

def demo_infinitesimal_arithmetic():
    print("=" * 60)
    print("DEMO 1: Infinitesimal Arithmetic")
    print("=" * 60)
    
    eps = InfinitesimalNumber(Fraction(0), Fraction(1))
    print(f"ε = {eps}")
    print(f"Is ε infinitesimal? {eps.is_infinitesimal()}")
    
    # Sum of infinitesimals
    two_eps = eps + eps
    print(f"\nε + ε = {two_eps}")
    print(f"Is 2ε infinitesimal? {two_eps.is_infinitesimal()}")
    
    # Product
    eps_sq = eps * eps
    print(f"\nε · ε = {eps_sq}")
    print(f"Is ε² infinitesimal? {eps_sq.is_infinitesimal()}")
    
    # Scaling
    n = 1000000
    n_eps = InfinitesimalNumber(Fraction(0), Fraction(n))
    print(f"\n{n}·ε = {n_eps}")
    print(f"Is {n}·ε infinitesimal? {n_eps.is_infinitesimal()}")
    print(f"Standard part of {n}·ε = {n_eps.standard_part()}")
    
    # Real + infinitesimal
    one_plus_eps = InfinitesimalNumber(Fraction(1)) + eps
    print(f"\n1 + ε = {one_plus_eps}")
    print(f"Standard part of (1 + ε) = {one_plus_eps.standard_part()}")


# ============================================================
# Demo 2: Uniform Infinitesimal Probability Measure
# ============================================================

def demo_uniform_infinitesimal_measure():
    print("\n" + "=" * 60)
    print("DEMO 2: Uniform Infinitesimal Probability Measure")
    print("=" * 60)
    
    eps = InfinitesimalNumber(Fraction(0), Fraction(1))
    
    # Create a probability space on {1, 2, 3, 4, 5}
    omega = {1, 2, 3, 4, 5}
    
    print(f"Sample space Ω = {omega}")
    print(f"Weight per point: ε = {eps}")
    
    # Singleton measures
    for x in sorted(omega):
        print(f"  μ({{{x}}}) = {eps}")
    
    # Finite set measures
    S = {1, 2, 3}
    measure_S = InfinitesimalNumber(Fraction(0), Fraction(len(S)))
    print(f"\nμ({S}) = {len(S)} · ε = {measure_S}")
    print(f"Is μ({S}) infinitesimal? {measure_S.is_infinitesimal()}")
    print(f"Is μ({S}) < 1? Yes (infinitesimal < 1)")
    
    # Complement
    S_comp = omega - S
    measure_S_comp = InfinitesimalNumber(Fraction(1)) - measure_S
    print(f"\nμ({S_comp}) = 1 - μ({S}) = {measure_S_comp}")
    print(f"Standard part of μ(Sᶜ) = {measure_S_comp.standard_part()}")
    
    # Full space - in this model, μ(Ω) should be 1
    # But 5ε ≠ 1 in general. This illustrates that the uniform
    # infinitesimal measure on an INFINITE set has μ(Ω) = 1,
    # while finite subsets have infinitesimal measure.
    measure_omega = InfinitesimalNumber(Fraction(0), Fraction(5))
    print(f"\nμ(Ω) for finite |Ω|=5: {measure_omega}")
    print("Note: For a finite space, this is NOT a valid probability measure")
    print("(since 5ε ≠ 1). The uniform infinitesimal measure requires an")
    print("INFINITE sample space where the 'sum' of all weights equals 1.")


# ============================================================  
# Demo 3: Conditional Probability on Singletons
# ============================================================

def demo_conditional_probability():
    print("\n" + "=" * 60)
    print("DEMO 3: Conditional Probability (Dirac Recovery)")
    print("=" * 60)
    
    eps = InfinitesimalNumber(Fraction(0), Fraction(1))
    
    # P(A | {x}) where A = {1, 3, 5} and we condition on various x
    A = {1, 3, 5}
    
    print(f"Event A = {A}")
    print(f"Weight ε = {eps}")
    
    for x in range(1, 6):
        if x in A:
            # A ∩ {x} = {x}, so P(A|{x}) = μ({x})/μ({x}) = 1
            p = eps / eps
            print(f"\nP(A | {{{x}}}) = μ(A ∩ {{{x}}})/μ({{{x}}}) = ε/ε = {p}")
        else:
            # A ∩ {x} = ∅, so P(A|{x}) = 0/μ({x}) = 0
            print(f"\nP(A | {{{x}}}) = μ(∅)/μ({{{x}}}) = 0/ε = 0")
    
    print("\n→ Conditioning on {x} recovers the Dirac delta:")
    print("  P(A | {x}) = 1 if x ∈ A, 0 if x ∉ A")
    print("  This is well-defined because μ({x}) = ε > 0!")


# ============================================================
# Demo 4: Inclusion-Exclusion with Infinitesimals  
# ============================================================

def demo_inclusion_exclusion():
    print("\n" + "=" * 60)
    print("DEMO 4: Inclusion-Exclusion with Infinitesimals")
    print("=" * 60)
    
    eps = InfinitesimalNumber(Fraction(0), Fraction(1))
    
    A = {1, 2, 3}
    B = {2, 3, 4, 5}
    
    mu_A = InfinitesimalNumber(Fraction(0), Fraction(len(A)))
    mu_B = InfinitesimalNumber(Fraction(0), Fraction(len(B)))
    mu_AB = InfinitesimalNumber(Fraction(0), Fraction(len(A & B)))
    mu_AuB = InfinitesimalNumber(Fraction(0), Fraction(len(A | B)))
    
    print(f"A = {A}, B = {B}")
    print(f"A ∩ B = {A & B}, A ∪ B = {A | B}")
    print(f"\nμ(A) = {mu_A}")
    print(f"μ(B) = {mu_B}")
    print(f"μ(A ∩ B) = {mu_AB}")
    print(f"μ(A ∪ B) = {mu_AuB}")
    
    # Verify inclusion-exclusion
    ie_result = mu_A + mu_B - mu_AB
    print(f"\nμ(A) + μ(B) - μ(A ∩ B) = {ie_result}")
    print(f"μ(A ∪ B) = {mu_AuB}")
    print(f"Inclusion-exclusion holds: {ie_result == mu_AuB}")


# ============================================================
# Demo 5: Anti-Concentration Theorem
# ============================================================

def demo_anti_concentration():
    print("\n" + "=" * 60)
    print("DEMO 5: Anti-Concentration Theorem")
    print("=" * 60)
    
    print("In a uniform infinitesimal probability space with weight ε:")
    print()
    
    for n in [1, 10, 100, 1000, 10**6, 10**9]:
        print(f"  |S| = {n:>12,} → μ(S) = {n}·ε (infinitesimal, < 1)")
    
    print()
    print("No matter how large the finite set, its measure is infinitesimal.")
    print("The 'bulk' of probability mass lives outside any finite set.")
    print()
    print("Proof: n·ε is infinitesimal because for any positive m,")
    print("  m · |n·ε| = (m·n) · ε < 1")
    print("since m·n is a natural number and ε is infinitesimal.")


if __name__ == "__main__":
    demo_infinitesimal_arithmetic()
    demo_uniform_infinitesimal_measure()
    demo_conditional_probability()
    demo_inclusion_exclusion()
    demo_anti_concentration()


#!/usr/bin/env python3
"""
Visualization: Anti-Concentration Theorem

Shows how the measure of finite subsets grows linearly with |S| but remains
infinitesimal (< 1) for all finite sets. Compares with standard uniform
probability where μ(S) = |S|/|Ω| approaches 1.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_anti_concentration():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Standard probability on finite Ω with |Ω| = 100
    ax1 = axes[0]
    N = 100
    sizes = np.arange(0, N + 1)
    standard_measure = sizes / N
    
    ax1.plot(sizes, standard_measure, 'b-', linewidth=2, label='μ(S) = |S|/|Ω|')
    ax1.axhline(y=1, color='r', linestyle='--', alpha=0.5, label='μ = 1')
    ax1.set_xlabel('|S| (size of finite subset)', fontsize=12)
    ax1.set_ylabel('μ(S)', fontsize=12)
    ax1.set_title('Standard Uniform Probability\n(|Ω| = 100)', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.set_ylim(-0.05, 1.15)
    ax1.grid(True, alpha=0.3)
    
    # Right: Infinitesimal probability (conceptual)
    ax2 = axes[1]
    
    # μ(S) = |S| · ε which is always infinitesimal
    # We represent this conceptually with a very small slope
    eps_values = [0.001, 0.01, 0.1]
    colors = ['green', 'orange', 'purple']
    labels = ['ε = 0.001', 'ε = 0.01', 'ε = 0.1']
    
    for eps, color, label in zip(eps_values, colors, labels):
        measure = sizes * eps
        ax2.plot(sizes, measure, color=color, linewidth=2, label=label, alpha=0.8)
    
    ax2.axhline(y=1, color='r', linestyle='--', alpha=0.5, label='μ = 1 (never reached)')
    ax2.set_xlabel('|S| (size of finite subset)', fontsize=12)
    ax2.set_ylabel('μ(S) = |S| · ε', fontsize=12)
    ax2.set_title('Infinitesimal Probability\n(μ(S) < 1 for all finite S)', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.set_ylim(-0.05, 1.15)
    ax2.grid(True, alpha=0.3)
    
    # Add annotation
    ax2.annotate('Anti-Concentration:\nNo finite set reaches μ = 1',
                xy=(70, 0.7), fontsize=11, color='darkred',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))
    
    plt.tight_layout()
    plt.savefig('anti_concentration.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved anti_concentration.png")


def plot_conditional_probability():
    """Visualize the Dirac Recovery Theorem."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Event A = {1, 3, 5, 7, 9} out of Ω = {1, ..., 10}
    omega = list(range(1, 11))
    A = {1, 3, 5, 7, 9}
    
    # Standard probability: P(A|{x}) is undefined (0/0)
    ax1 = axes[0]
    std_probs = [float('nan')] * len(omega)  # undefined
    ax1.bar(omega, [0.5] * len(omega), color='gray', alpha=0.3, label='P({x}) = 0 (undefined P(A|{x}))')
    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('P(A | {x})', fontsize=12)
    ax1.set_title('Standard Probability\nP(A|{x}) = 0/0 (undefined!)', fontsize=14)
    ax1.set_ylim(-0.1, 1.5)
    ax1.text(5.5, 1.2, 'UNDEFINED', fontsize=16, color='red', ha='center',
             bbox=dict(facecolor='lightyellow', alpha=0.8))
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Infinitesimal probability: P(A|{x}) = 1 if x ∈ A, 0 otherwise
    ax2 = axes[1]
    inf_probs = [1 if x in A else 0 for x in omega]
    colors = ['#2ecc71' if x in A else '#e74c3c' for x in omega]
    ax2.bar(omega, inf_probs, color=colors, alpha=0.8, edgecolor='black')
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('P(A | {x})', fontsize=12)
    ax2.set_title('Non-Archimedean Probability\nP(A|{x}) = Dirac delta (well-defined!)', fontsize=14)
    ax2.set_ylim(-0.1, 1.5)
    
    # Legend
    from matplotlib.patches import Patch
    legend_elements = [Patch(facecolor='#2ecc71', label='x ∈ A → P(A|{x}) = 1'),
                      Patch(facecolor='#e74c3c', label='x ∉ A → P(A|{x}) = 0')]
    ax2.legend(handles=legend_elements, fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('dirac_recovery.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved dirac_recovery.png")


def plot_infinitesimal_structure():
    """Visualize the additive structure of infinitesimals."""
    fig, ax = plt.subplots(figsize=(10, 8))
    
    # Number line with infinitesimal neighborhood of 0
    y_levels = np.linspace(0, 1, 6)
    
    # Standard reals
    reals = [-1, -0.5, 0, 0.5, 1]
    ax.scatter(reals, [0] * len(reals), s=100, c='blue', zorder=5)
    for r in reals:
        ax.annotate(str(r), (r, 0), textcoords="offset points", xytext=(0, 15),
                   ha='center', fontsize=12, color='blue')
    ax.plot([-1.5, 1.5], [0, 0], 'b-', alpha=0.3, linewidth=2)
    ax.text(-1.4, 0.05, 'Standard reals', fontsize=11, color='blue')
    
    # Zoom into neighborhood of 0
    zoom_center = 0
    zoom_width = 0.1
    
    # Draw zoom lines
    ax.plot([zoom_center - zoom_width, -1.2], [0, 0.3], 'k--', alpha=0.2)
    ax.plot([zoom_center + zoom_width, 1.2], [0, 0.3], 'k--', alpha=0.2)
    
    # Zoomed view
    eps_vals = [-3, -2, -1, 0, 1, 2, 3]
    x_positions = [v * 0.3 for v in eps_vals]
    
    ax.scatter(x_positions, [0.5] * len(eps_vals), s=80, c='green', zorder=5)
    for v, x in zip(eps_vals, x_positions):
        if v == 0:
            label = '0'
        elif v == 1:
            label = 'ε'
        elif v == -1:
            label = '-ε'
        else:
            label = f'{v}ε'
        ax.annotate(label, (x, 0.5), textcoords="offset points", xytext=(0, 15),
                   ha='center', fontsize=11, color='green')
    
    ax.plot([-1.2, 1.2], [0.5, 0.5], 'g-', alpha=0.3, linewidth=2)
    ax.text(-1.1, 0.55, 'Infinitesimal neighborhood of 0', fontsize=11, color='green')
    
    # Second-order infinitesimals
    eps2_vals = [-2, -1, 0, 1, 2]
    x_positions2 = [v * 0.2 for v in eps2_vals]
    
    ax.scatter(x_positions2, [0.85] * len(eps2_vals), s=60, c='purple', zorder=5)
    for v, x in zip(eps2_vals, x_positions2):
        if v == 0:
            label = '0'
        elif v == 1:
            label = 'ε²'
        elif v == -1:
            label = '-ε²'
        else:
            label = f'{v}ε²'
        ax.annotate(label, (x, 0.85), textcoords="offset points", xytext=(0, 15),
                   ha='center', fontsize=10, color='purple')
    
    ax.plot([-0.8, 0.8], [0.85, 0.85], 'purple', alpha=0.3, linewidth=2)
    ax.text(-0.75, 0.9, 'Second-order infinitesimals', fontsize=10, color='purple')
    
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-0.15, 1.15)
    ax.set_ylabel('Zoom level', fontsize=12)
    ax.set_title('Non-Archimedean Number Line\nInfinitely many "levels" of smallness', fontsize=14)
    ax.set_yticks([0, 0.5, 0.85])
    ax.set_yticklabels(['Reals', 'ε-level', 'ε²-level'])
    ax.grid(True, alpha=0.2)
    
    plt.tight_layout()
    plt.savefig('infinitesimal_structure.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved infinitesimal_structure.png")


if __name__ == "__main__":
    plot_anti_concentration()
    plot_conditional_probability()
    plot_infinitesimal_structure()
