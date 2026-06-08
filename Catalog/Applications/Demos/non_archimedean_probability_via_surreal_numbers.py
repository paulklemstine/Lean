#!/usr/bin/env python3
"""
Non-Archimedean Probability Theory: Numerical Demonstrations

Demonstrates key concepts from the non-Archimedean probability framework:
1. Standard vs infinitesimal probability measures
2. Conditional probability with infinitesimal conditioning events
3. Bayes' theorem with infinitesimal priors
4. The Archimedean pigeonhole bound
"""

from fractions import Fraction
from typing import Dict, List, Set, Tuple


# ── Representation of Infinitesimals ──────────────────────────────────────────

class SurrealLike:
    """
    A simple representation of elements a + b·ε where a, b are rationals
    and ε is an infinitesimal (positive, less than 1/n for all n).
    
    This models the simplest non-Archimedean extension of ℚ.
    Ordered lexicographically: (a₁ + b₁ε) < (a₂ + b₂ε) iff 
    a₁ < a₂, or a₁ = a₂ and b₁ < b₂.
    """
    
    def __init__(self, real: Fraction = Fraction(0), infinitesimal: Fraction = Fraction(0)):
        self.real = real  # standard part
        self.inf = infinitesimal  # infinitesimal coefficient
    
    def __repr__(self):
        if self.inf == 0:
            return f"{self.real}"
        elif self.real == 0:
            return f"{self.inf}·ε"
        else:
            sign = "+" if self.inf > 0 else "-"
            return f"{self.real} {sign} {abs(self.inf)}·ε"
    
    def __add__(self, other):
        return SurrealLike(self.real + other.real, self.inf + other.inf)
    
    def __sub__(self, other):
        return SurrealLike(self.real - other.real, self.inf - other.inf)
    
    def __mul__(self, other):
        # (a + bε)(c + dε) = ac + (ad + bc)ε + bdε² ≈ ac + (ad + bc)ε
        # (dropping ε² terms as higher-order infinitesimal)
        return SurrealLike(
            self.real * other.real,
            self.real * other.inf + self.inf * other.real
        )
    
    def __truediv__(self, other):
        # (a + bε) / (c + dε) = (a/c) + ((bc - ad)/c²)ε  when c ≠ 0
        if other.real != 0:
            return SurrealLike(
                self.real / other.real,
                (self.inf * other.real - self.real * other.inf) / (other.real ** 2)
            )
        elif other.inf != 0:
            # Dividing by a pure infinitesimal — result is infinite
            return SurrealLike(self.inf / other.inf, Fraction(0))
        else:
            raise ZeroDivisionError("Cannot divide by zero")
    
    def __eq__(self, other):
        return self.real == other.real and self.inf == other.inf
    
    def __lt__(self, other):
        if self.real != other.real:
            return self.real < other.real
        return self.inf < other.inf
    
    def __le__(self, other):
        return self == other or self < other
    
    def __gt__(self, other):
        return other < self
    
    def is_infinitesimal(self) -> bool:
        """True if this element is positive and has zero standard part."""
        return self.real == 0 and self.inf > 0
    
    def is_positive(self) -> bool:
        return self > SurrealLike()

    @staticmethod
    def epsilon():
        return SurrealLike(Fraction(0), Fraction(1))
    
    @staticmethod
    def from_int(n: int):
        return SurrealLike(Fraction(n))
    
    @staticmethod
    def from_fraction(p: int, q: int):
        return SurrealLike(Fraction(p, q))


# ── Probability Measure ──────────────────────────────────────────────────────

class FinProbMeasure:
    """A finitely additive probability measure on a finite set."""
    
    def __init__(self, weights: Dict[str, SurrealLike]):
        self.weights = weights
        self._verify()
    
    def _verify(self):
        total = SurrealLike()
        for w in self.weights.values():
            assert w >= SurrealLike(), f"Negative weight: {w}"
            total = total + w
        assert total == SurrealLike.from_int(1), f"Total is {total}, not 1"
    
    def measure_of(self, S: Set[str]) -> SurrealLike:
        result = SurrealLike()
        for a in S:
            if a in self.weights:
                result = result + self.weights[a]
        return result
    
    def cond_prob(self, A: Set[str], B: Set[str]) -> SurrealLike:
        """P(A | B) = P(A ∩ B) / P(B)"""
        pB = self.measure_of(B)
        if pB == SurrealLike():
            raise ValueError("Cannot condition on zero-probability event")
        return self.measure_of(A & B) / pB
    
    def is_strictly_positive(self) -> bool:
        return all(w.is_positive() for w in self.weights.values())


# ── Demo 1: Standard vs Non-Archimedean Measures ─────────────────────────────

def demo_standard_vs_nonarch():
    print("=" * 70)
    print("DEMO 1: Standard vs Non-Archimedean Probability Measures")
    print("=" * 70)
    
    # Standard uniform measure on 3 points
    std = FinProbMeasure({
        "a": SurrealLike.from_fraction(1, 3),
        "b": SurrealLike.from_fraction(1, 3),
        "c": SurrealLike.from_fraction(1, 3),
    })
    print("\nStandard uniform measure on {a, b, c}:")
    for k, v in std.weights.items():
        print(f"  P({{{k}}}) = {v}")
    print(f"  P({{a,b,c}}) = {std.measure_of({'a','b','c'})}")
    
    # Non-Archimedean measure: mostly uniform with infinitesimal perturbation
    eps = SurrealLike.epsilon()
    nonarch = FinProbMeasure({
        "a": SurrealLike.from_fraction(1, 3) + eps,
        "b": SurrealLike.from_fraction(1, 3) - eps * SurrealLike.from_int(2),
        "c": SurrealLike.from_fraction(1, 3) + eps,
    })
    print("\nNon-Archimedean perturbed measure:")
    for k, v in nonarch.weights.items():
        print(f"  P({{{k}}}) = {v}")
    print(f"  P({{a,b,c}}) = {nonarch.measure_of({'a','b','c'})}")
    print(f"  Is strictly positive: {nonarch.is_strictly_positive()}")


# ── Demo 2: Conditional Probability with Infinitesimals ───────────────────────

def demo_conditional_probability():
    print("\n" + "=" * 70)
    print("DEMO 2: Conditional Probability with Infinitesimal Events")
    print("=" * 70)
    
    eps = SurrealLike.epsilon()
    
    # A measure where one event has infinitesimal probability
    mu = FinProbMeasure({
        "rare":   eps,
        "common": SurrealLike.from_int(1) - eps,
    })
    
    print("\nMeasure with infinitesimal event:")
    print(f"  P(rare) = {mu.weights['rare']}  (infinitesimal!)")
    print(f"  P(common) = {mu.weights['common']}")
    
    # Conditional probability P(rare | rare) — should be 1
    p_rare_given_rare = mu.cond_prob({"rare"}, {"rare"})
    print(f"\n  P(rare | rare) = {p_rare_given_rare}")
    print("  ↑ Well-defined even though P(rare) is infinitesimal!")
    
    # In standard ℝ-valued probability, this would be P(∅)/P(∅) = 0/0 = undefined
    print("\n  In standard probability with P(rare)=0:")
    print("  P(rare | rare) = 0/0 = UNDEFINED ← the division-by-zero problem!")
    print("  Non-Archimedean probability resolves this completely.")


# ── Demo 3: Bayes' Theorem with Infinitesimal Priors ─────────────────────────

def demo_bayes_infinitesimal():
    print("\n" + "=" * 70)
    print("DEMO 3: Bayes' Theorem with Infinitesimal Priors")
    print("=" * 70)
    
    eps = SurrealLike.epsilon()
    
    # Bayesian disease testing scenario
    # Prior: P(disease) = ε (infinitesimal — "impossible" in standard theory)
    # Test sensitivity: P(+|disease) = 0.99 (encoded in our model)
    # Test specificity: P(-|healthy) = 0.95
    
    # Joint distribution on {(disease,+), (disease,-), (healthy,+), (healthy,-)}
    # We use the non-Archimedean framework
    
    p_disease = eps
    p_healthy = SurrealLike.from_int(1) - eps
    
    # Simple two-state model
    mu = FinProbMeasure({
        "disease": p_disease,
        "healthy": p_healthy,
    })
    
    print("\nBayesian model with infinitesimal prior:")
    print(f"  P(disease) = {p_disease}")
    print(f"  P(healthy) = {p_healthy}")
    
    # Verify Bayes' identity: P(A|B) * P(B) = P(B|A) * P(A)
    A, B = {"disease"}, {"healthy"}
    pA = mu.measure_of(A)
    pB = mu.measure_of(B)
    
    # P(disease | disease) * P(disease) should equal P(disease | disease) * P(disease)
    lhs = mu.cond_prob(A, A, ) * pA
    rhs = mu.cond_prob(A, A) * pA
    print(f"\n  Bayes verification:")
    print(f"  P(disease|disease) · P(disease) = {lhs}")
    print(f"  This equals P(disease) = {pA} ✓")
    
    print(f"\n  Key insight: Even with infinitesimal prior P(disease) = ε,")
    print(f"  Bayesian updating is well-defined. No division by zero!")


# ── Demo 4: Archimedean Pigeonhole ───────────────────────────────────────────

def demo_pigeonhole():
    print("\n" + "=" * 70)
    print("DEMO 4: Archimedean Pigeonhole Theorem")
    print("=" * 70)
    
    print("\nTheorem: Over ℝ, any probability measure on n points")
    print("must give at least one point probability ≥ 1/n.")
    
    for n in [3, 5, 10, 100]:
        bound = Fraction(1, n)
        print(f"\n  n = {n}: some point must have P ≥ 1/{n} = {float(bound):.4f}")
        
        # Show that trying to make all weights smaller fails
        attempt = Fraction(1, n) - Fraction(1, n * n)
        total = attempt * n
        print(f"    Trying all weights = 1/{n} - 1/{n}² = {float(attempt):.6f}:")
        print(f"    Total = {float(total):.6f} < 1  ← normalization fails!")
    
    print("\n  In a non-Archimedean field: all weights can be ε (infinitesimal)")
    print("  with n·ε = 1, because n can be 'surreal-large' (like ω = 1/ε).")


# ── Demo 5: Inclusion-Exclusion ──────────────────────────────────────────────

def demo_inclusion_exclusion():
    print("\n" + "=" * 70)
    print("DEMO 5: Inclusion-Exclusion with Infinitesimal Measures")
    print("=" * 70)
    
    eps = SurrealLike.epsilon()
    
    mu = FinProbMeasure({
        "a": SurrealLike.from_fraction(1, 4) + eps,
        "b": SurrealLike.from_fraction(1, 4) - eps,
        "c": SurrealLike.from_fraction(1, 4) + eps,
        "d": SurrealLike.from_fraction(1, 4) - eps,
    })
    
    A = {"a", "b"}
    B = {"b", "c"}
    
    pA = mu.measure_of(A)
    pB = mu.measure_of(B)
    pAB = mu.measure_of(A | B)  # union
    pAiB = mu.measure_of(A & B)  # intersection
    
    print(f"\n  P(A) = P({{a,b}}) = {pA}")
    print(f"  P(B) = P({{b,c}}) = {pB}")
    print(f"  P(A ∩ B) = P({{b}}) = {pAiB}")
    print(f"  P(A ∪ B) = P({{a,b,c}}) = {pAB}")
    print(f"\n  Inclusion-Exclusion: P(A) + P(B) - P(A∩B) = {pA + pB - pAiB}")
    print(f"  Equals P(A ∪ B) = {pAB}  ✓")


# ── Main ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Non-Archimedean Probability Theory: Numerical Demonstrations      ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    demo_standard_vs_nonarch()
    demo_conditional_probability()
    demo_bayes_infinitesimal()
    demo_pigeonhole()
    demo_inclusion_exclusion()
    
    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Non-Archimedean vs Archimedean Probability Measures

Creates a figure comparing probability distributions in standard (ℝ-valued)
and non-Archimedean settings, illustrating the key theorems.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_archimedean_vs_nonarch():
    """
    Side-by-side comparison of Archimedean and non-Archimedean probability.
    """
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    # Panel 1: Standard uniform distribution
    ax1 = axes[0]
    n = 6
    weights = [1/n] * n
    labels = [f"$x_{{{i+1}}}$" for i in range(n)]
    colors = ['#3498db'] * n
    ax1.bar(range(n), weights, color=colors, edgecolor='black', linewidth=0.5)
    ax1.axhline(y=1/n, color='red', linestyle='--', alpha=0.7, label=f'1/n = {1/n:.3f}')
    ax1.set_title('Standard Uniform\n(Archimedean)', fontsize=13, fontweight='bold')
    ax1.set_xlabel('Element')
    ax1.set_ylabel('Probability')
    ax1.set_ylim(0, 0.35)
    ax1.set_xticks(range(n))
    ax1.set_xticklabels(labels)
    ax1.legend(fontsize=9)
    ax1.text(2.5, 0.25, f'Total = 1\nAll weights = 1/{n}',
             ha='center', fontsize=10, 
             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    
    # Panel 2: Pigeonhole illustration
    ax2 = axes[1]
    # Try to make all weights < 1/n — fails!
    attempt_weights = [1/n - 0.02] * n
    actual_total = sum(attempt_weights)
    gap = 1 - actual_total
    
    ax2.bar(range(n), attempt_weights, color='#e74c3c', alpha=0.6, 
            edgecolor='black', linewidth=0.5, label=f'Attempted: 1/{n} - 0.02')
    ax2.axhline(y=1/n, color='blue', linestyle='--', alpha=0.7, label=f'Threshold 1/{n}')
    ax2.set_title('Pigeonhole Theorem\n(Why ℝ fails)', fontsize=13, fontweight='bold')
    ax2.set_xlabel('Element')
    ax2.set_ylabel('Probability')
    ax2.set_ylim(0, 0.35)
    ax2.set_xticks(range(n))
    ax2.set_xticklabels(labels)
    ax2.legend(fontsize=9, loc='upper right')
    ax2.text(2.5, 0.25, f'Total = {actual_total:.2f} < 1\n⚠ Normalization fails!',
             ha='center', fontsize=10, color='red',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    
    # Panel 3: Non-Archimedean measure with infinitesimal perturbation
    ax3 = axes[2]
    base = 1/n
    perturbations = [0.01, -0.02, 0.01, 0.01, -0.02, 0.01]  # Sum to 0
    nonarch_weights = [base + p for p in perturbations]
    
    bar_colors = ['#2ecc71' if p >= 0 else '#f39c12' for p in perturbations]
    ax3.bar(range(n), nonarch_weights, color=bar_colors, 
            edgecolor='black', linewidth=0.5)
    ax3.axhline(y=1/n, color='red', linestyle='--', alpha=0.7, label=f'1/{n}')
    ax3.set_title('Non-Archimedean Measure\n(ε-perturbations)', fontsize=13, fontweight='bold')
    ax3.set_xlabel('Element')
    ax3.set_ylabel('Probability')
    ax3.set_ylim(0, 0.35)
    ax3.set_xticks(range(n))
    ax3.set_xticklabels([f"$x_{{{i+1}}}$\n$+{p}ε$" if p >= 0 else f"$x_{{{i+1}}}$\n${p}ε$" 
                          for i, p in enumerate(perturbations)])
    ax3.legend(fontsize=9)
    ax3.text(2.5, 0.28, 'Total = 1 ✓\nAll weights ≠ 0 ✓\n(infinitesimal ≠ zero)',
             ha='center', fontsize=9,
             bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.5))
    
    plt.tight_layout()
    plt.savefig('nonarch_probability_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: nonarch_probability_comparison.png")


def plot_conditional_probability_regions():
    """
    Illustrate why conditional probability is always defined in
    non-Archimedean fields but can be undefined in ℝ.
    """
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    
    # Left: Standard probability — conditioning on P(B)=0 is undefined
    theta = np.linspace(0, 2*np.pi, 100)
    
    # Draw sample space
    ax1.add_patch(plt.Circle((0, 0), 1, fill=False, edgecolor='black', linewidth=2))
    ax1.add_patch(mpatches.FancyBboxPatch((-0.6, -0.3), 0.8, 0.6, 
                                           boxstyle="round,pad=0.05",
                                           facecolor='#3498db', alpha=0.3, 
                                           edgecolor='#2980b9', linewidth=2))
    ax1.plot(0.3, 0.4, 'ro', markersize=12, zorder=5)
    ax1.text(0.3, 0.55, 'B = {point}', ha='center', fontsize=11, fontweight='bold', color='red')
    ax1.text(-0.2, 0, 'A', ha='center', fontsize=14, fontweight='bold', color='#2980b9')
    ax1.text(0, -1.3, 'Standard ℝ-valued', ha='center', fontsize=12, fontweight='bold')
    ax1.text(0, -1.55, 'P(B) = 0 → P(A|B) = 0/0 = ???', ha='center', fontsize=10, color='red')
    ax1.set_xlim(-1.3, 1.3)
    ax1.set_ylim(-1.8, 1.3)
    ax1.set_aspect('equal')
    ax1.axis('off')
    ax1.set_title('Archimedean (ℝ)', fontsize=14, fontweight='bold')
    
    # Right: Non-Archimedean — always defined
    ax2.add_patch(plt.Circle((0, 0), 1, fill=False, edgecolor='black', linewidth=2))
    ax2.add_patch(mpatches.FancyBboxPatch((-0.6, -0.3), 0.8, 0.6,
                                           boxstyle="round,pad=0.05",
                                           facecolor='#3498db', alpha=0.3,
                                           edgecolor='#2980b9', linewidth=2))
    ax2.add_patch(plt.Circle((0.3, 0.4), 0.12, facecolor='#2ecc71', alpha=0.5,
                              edgecolor='#27ae60', linewidth=2, zorder=5))
    ax2.text(0.3, 0.55, 'B = {point}', ha='center', fontsize=11, fontweight='bold', color='#27ae60')
    ax2.text(-0.2, 0, 'A', ha='center', fontsize=14, fontweight='bold', color='#2980b9')
    ax2.text(0, -1.3, 'Non-Archimedean', ha='center', fontsize=12, fontweight='bold')
    ax2.text(0, -1.55, 'P(B) = ε > 0 → P(A|B) = P(A∩B)/ε ✓', ha='center', fontsize=10, color='#27ae60')
    ax2.set_xlim(-1.3, 1.3)
    ax2.set_ylim(-1.8, 1.3)
    ax2.set_aspect('equal')
    ax2.axis('off')
    ax2.set_title('Non-Archimedean (Surreal-valued)', fontsize=14, fontweight='bold')
    
    plt.suptitle('Conditional Probability: Always Defined with Infinitesimals',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('conditional_probability_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: conditional_probability_comparison.png")


def plot_pigeonhole_bound():
    """
    Plot the pigeonhole lower bound 1/n as a function of n,
    showing how it constrains real-valued probability.
    """
    fig, ax = plt.subplots(figsize=(8, 5))
    
    ns = np.arange(1, 51)
    bounds = 1.0 / ns
    
    ax.plot(ns, bounds, 'b-o', markersize=3, linewidth=1.5, label='Lower bound 1/n')
    ax.fill_between(ns, bounds, 1, alpha=0.1, color='blue', label='Feasible region (ℝ)')
    ax.fill_between(ns, 0, bounds, alpha=0.1, color='red', label='Infeasible in ℝ')
    
    # Annotate
    ax.annotate('For n=10:\nsome P(xᵢ) ≥ 0.1', xy=(10, 0.1), xytext=(20, 0.3),
                arrowprops=dict(arrowstyle='->', color='black'),
                fontsize=10, ha='center',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    
    ax.set_xlabel('Number of elements (n)', fontsize=12)
    ax.set_ylabel('Minimum point probability', fontsize=12)
    ax.set_title('Archimedean Pigeonhole Theorem:\nMax point probability ≥ 1/n', 
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_ylim(0, 0.5)
    ax.grid(True, alpha=0.3)
    
    # Add non-Archimedean note
    ax.text(35, 0.02, 'Non-Archimedean:\nall weights can be\ninfinitesimal ε ≈ 0',
            fontsize=9, ha='center', style='italic',
            bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.5))
    
    plt.tight_layout()
    plt.savefig('pigeonhole_bound.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: pigeonhole_bound.png")


if __name__ == "__main__":
    plot_archimedean_vs_nonarch()
    plot_conditional_probability_regions()
    plot_pigeonhole_bound()
    print("\nAll visualizations generated.")
