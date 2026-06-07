#!/usr/bin/env python3
"""
Non-Archimedean Probability Demo

Demonstrates infinitesimal probability spaces using symbolic computation.
We use a simple model where elements of the non-Archimedean field are
represented as formal Laurent series in ε (epsilon), i.e., elements of
the form a₀ + a₁ε + a₂ε² + ... where aᵢ ∈ ℝ and ε is infinitesimal.
"""

from fractions import Fraction
from typing import Dict, List, Tuple


class InfinitesimalNumber:
    """A number of the form a + b*ε where ε is infinitesimal.

    We represent elements of a simple non-Archimedean extension of ℚ:
    ℚ(ε) where ε is positive and smaller than any positive rational.
    """

    def __init__(self, standard: Fraction = Fraction(0),
                 infinitesimal: Fraction = Fraction(0)):
        self.standard = standard  # The "standard part"
        self.infinitesimal = infinitesimal  # Coefficient of ε

    def __repr__(self):
        parts = []
        if self.standard != 0:
            parts.append(str(self.standard))
        if self.infinitesimal != 0:
            if self.infinitesimal == 1:
                parts.append("ε")
            elif self.infinitesimal == -1:
                parts.append("-ε")
            else:
                parts.append(f"{self.infinitesimal}·ε")
        return " + ".join(parts) if parts else "0"

    def __add__(self, other):
        return InfinitesimalNumber(
            self.standard + other.standard,
            self.infinitesimal + other.infinitesimal
        )

    def __sub__(self, other):
        return InfinitesimalNumber(
            self.standard - other.standard,
            self.infinitesimal - other.infinitesimal
        )

    def __mul__(self, other):
        # (a + bε)(c + dε) = ac + (ad+bc)ε + bdε² ≈ ac + (ad+bc)ε
        return InfinitesimalNumber(
            self.standard * other.standard,
            self.standard * other.infinitesimal + self.infinitesimal * other.standard
        )

    def __truediv__(self, other):
        if other.standard == 0:
            raise ZeroDivisionError("Division by infinitesimal not supported in this model")
        # (a + bε) / (c + dε) ≈ a/c + (bc - ad)/(c²) · ε
        inv_std = Fraction(1, 1) / other.standard
        return InfinitesimalNumber(
            self.standard * inv_std,
            (self.infinitesimal * other.standard - self.standard * other.infinitesimal)
            * inv_std * inv_std
        )

    def is_infinitesimal(self) -> bool:
        return self.standard == 0 and self.infinitesimal != 0

    def is_positive(self) -> bool:
        if self.standard > 0:
            return True
        if self.standard == 0:
            return self.infinitesimal > 0
        return False

    def __eq__(self, other):
        if isinstance(other, (int, float, Fraction)):
            return self.standard == Fraction(other) and self.infinitesimal == 0
        return self.standard == other.standard and self.infinitesimal == other.infinitesimal


# Shortcuts
def eps(coeff=1):
    return InfinitesimalNumber(Fraction(0), Fraction(coeff))

def real(val):
    return InfinitesimalNumber(Fraction(val), Fraction(0))


class InfProbSpace:
    """An infinitesimal probability space on a finite set."""

    def __init__(self, elements: list, weights: Dict):
        self.elements = elements
        self.weights = weights  # element -> InfinitesimalNumber

        # Verify normalization
        total = real(0)
        for e in elements:
            total = total + weights[e]
        assert total == 1, f"Total mass is {total}, not 1"

        # Verify regularity
        for e in elements:
            assert weights[e].is_positive(), f"Weight of {e} is not positive: {weights[e]}"

    def prob(self, subset: set) -> InfinitesimalNumber:
        result = real(0)
        for e in subset:
            result = result + self.weights[e]
        return result

    def cond_prob(self, A: set, B: set) -> InfinitesimalNumber:
        return self.prob(A & B) / self.prob(B)


def demo_basic():
    """Demo 1: Basic infinitesimal probability space."""
    print("=" * 60)
    print("DEMO 1: Uniform Probability on {0, 1, 2}")
    print("=" * 60)

    space = InfProbSpace(
        [0, 1, 2],
        {0: real(Fraction(1, 3)),
         1: real(Fraction(1, 3)),
         2: real(Fraction(1, 3))}
    )

    print(f"P({{0}}) = {space.prob({0})}")
    print(f"P({{0,1}}) = {space.prob({0, 1})}")
    print(f"P({{0,1,2}}) = {space.prob({0, 1, 2})}")
    print(f"P({{0}} | {{0,1}}) = {space.cond_prob({0}, {0, 1})}")
    print()


def demo_infinitesimal_loading():
    """Demo 2: Infinitesimally loaded die."""
    print("=" * 60)
    print("DEMO 2: Infinitesimally Loaded Die")
    print("=" * 60)

    # A die where face 0 has an infinitesimal advantage
    space = InfProbSpace(
        [0, 1, 2],
        {0: real(Fraction(1, 3)) + eps(1),
         1: real(Fraction(1, 3)),
         2: real(Fraction(1, 3)) + eps(-1)}
    )

    print(f"P({{0}}) = {space.prob({0})} (infinitesimally favored)")
    print(f"P({{1}}) = {space.prob({1})} (neutral)")
    print(f"P({{2}}) = {space.prob({2})} (infinitesimally disfavored)")
    print(f"Total = {space.prob({0, 1, 2})}")
    print()
    print("Conditional probabilities:")
    print(f"P({{0}} | {{0,1}}) = {space.cond_prob({0}, {0, 1})}")
    print(f"P({{1}} | {{0,1}}) = {space.cond_prob({1}, {0, 1})}")
    print()
    print("Note: The loading is infinitesimal — undetectable by finite sampling")
    print("but formally present in the mathematics.")
    print()


def demo_bayes():
    """Demo 3: Bayes' theorem with infinitesimal events."""
    print("=" * 60)
    print("DEMO 3: Bayes' Theorem with Infinitesimal Probabilities")
    print("=" * 60)

    space = InfProbSpace(
        [0, 1, 2, 3],
        {0: real(Fraction(1, 4)) + eps(1),
         1: real(Fraction(1, 4)) + eps(-1),
         2: real(Fraction(1, 4)) + eps(1),
         3: real(Fraction(1, 4)) + eps(-1)}
    )

    A = {0, 1}
    B = {0, 2}

    pAB = space.cond_prob(A, B) * space.prob(B)
    pBA = space.cond_prob(B, A) * space.prob(A)

    print(f"A = {A}, B = {B}")
    print(f"P(A) = {space.prob(A)}")
    print(f"P(B) = {space.prob(B)}")
    print(f"P(A|B) · P(B) = {pAB}")
    print(f"P(B|A) · P(A) = {pBA}")
    print(f"Equal? {pAB == pBA}  (Bayes' theorem verified)")
    print()


def demo_archimedean_impossibility():
    """Demo 4: Archimedean impossibility."""
    print("=" * 60)
    print("DEMO 4: Archimedean Impossibility")
    print("=" * 60)

    c = Fraction(1, 1000)
    print(f"Suppose we try to assign weight c = {c} to each natural number.")
    print(f"We need N·c > 1, i.e., N > {1/c}")

    N = int(1 / c) + 1
    print(f"Taking N = {N}: N·c = {N * c} > 1 ✓")
    print()
    print("With just the first 1001 natural numbers, the total mass exceeds 1.")
    print("This proves no Archimedean field can support uniform positive weights")
    print("on an infinite set. Non-Archimedean fields are NECESSARY.")
    print()


def demo_product_space():
    """Demo 5: Product probability space."""
    print("=" * 60)
    print("DEMO 5: Product Infinitesimal Probability Space")
    print("=" * 60)

    # Two independent spaces
    space1 = InfProbSpace(
        [0, 1],
        {0: real(Fraction(1, 2)) + eps(1),
         1: real(Fraction(1, 2)) + eps(-1)}
    )

    space2 = InfProbSpace(
        ['H', 'T'],
        {'H': real(Fraction(1, 2)),
         'T': real(Fraction(1, 2))}
    )

    # Build product space
    product_elements = [(a, b) for a in [0, 1] for b in ['H', 'T']]
    product_weights = {}
    for a, b in product_elements:
        product_weights[(a, b)] = space1.weights[a] * space2.weights[b]

    product_space = InfProbSpace(product_elements, product_weights)

    print("Space 1: {0, 1} with P(0) = 1/2 + ε, P(1) = 1/2 - ε")
    print("Space 2: {H, T} with P(H) = P(T) = 1/2")
    print()
    print("Product space probabilities:")
    for e in product_elements:
        print(f"  P({e}) = {product_space.weights[e]}")
    print(f"\nTotal = {product_space.prob(set(product_elements))}")
    print()
    print("Independence check:")
    A = {(0, 'H'), (0, 'T')}
    B = {(0, 'H'), (1, 'H')}
    pA = product_space.prob(A)
    pB = product_space.prob(B)
    pAB = product_space.prob(A & B)
    print(f"P(first=0) = {pA}")
    print(f"P(second=H) = {pB}")
    print(f"P(first=0 ∩ second=H) = {pAB}")
    print(f"P(first=0) · P(second=H) = {pA * pB}")
    print(f"Independent? {pAB == pA * pB}")
    print()


if __name__ == "__main__":
    demo_basic()
    demo_infinitesimal_loading()
    demo_bayes()
    demo_archimedean_impossibility()
    demo_product_space()

    print("=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Non-Archimedean Probability Landscape

Creates a visualization comparing classical vs infinitesimal probability
assignments on a discrete space, showing the hierarchy of improbability.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_probability_landscape():
    """Compare classical vs infinitesimal probability on a space of 6 elements."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    elements = ['A', 'B', 'C', 'D', 'E', 'F']
    n = len(elements)

    # Panel 1: Classical uniform distribution
    ax = axes[0]
    classical_probs = [1/n] * n
    colors = ['#2196F3'] * n
    bars = ax.bar(elements, classical_probs, color=colors, edgecolor='black', linewidth=1.5)
    ax.set_ylim(0, 0.35)
    ax.set_title('Classical Probability\n(Archimedean: ℝ-valued)', fontsize=13, fontweight='bold')
    ax.set_ylabel('P(x)', fontsize=12)
    ax.axhline(y=1/n, color='red', linestyle='--', alpha=0.5, label=f'P = 1/{n}')
    ax.legend(fontsize=10)
    ax.set_xlabel('Events', fontsize=12)

    # Panel 2: Infinitesimal uniform distribution (conceptual)
    ax = axes[1]
    # Show that in non-Archimedean field, 1/ω is infinitesimal
    # We represent ε as a very small bar with annotation
    eps_height = 0.02  # Visual representation
    bars = ax.bar(elements, [eps_height] * n, color='#FF9800', edgecolor='black', linewidth=1.5)
    ax.set_ylim(0, 0.35)
    ax.set_title('Infinitesimal Probability\n(Non-Archimedean: F-valued)', fontsize=13, fontweight='bold')
    ax.set_ylabel('P(x)', fontsize=12)

    # Add ε labels
    for bar, elem in zip(bars, elements):
        ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.008,
                'ε', ha='center', va='bottom', fontsize=14, fontweight='bold',
                color='#E65100')

    # Add annotation
    ax.annotate('Each P(x) = ε > 0\n(infinitesimal but positive!)',
                xy=(2.5, 0.05), fontsize=11,
                ha='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))

    # Add line showing 1/n for comparison
    ax.axhline(y=1/n, color='blue', linestyle=':', alpha=0.3, label=f'Classical 1/{n}')
    ax.legend(fontsize=10)
    ax.set_xlabel('Events', fontsize=12)

    # Panel 3: Loaded infinitesimal die
    ax = axes[2]
    # Probabilities: 1/6 + ε, 1/6, 1/6 - ε/2, 1/6, 1/6, 1/6 + ε/2 - ε
    # Simplified: show different infinitesimal perturbations
    base = 1/n
    perturbations = [0.03, 0.01, -0.02, 0.015, -0.015, 0]
    loaded_probs = [base + p for p in perturbations]
    colors_loaded = ['#4CAF50' if p > 0 else '#F44336' if p < 0 else '#2196F3'
                     for p in perturbations]
    bars = ax.bar(elements, loaded_probs, color=colors_loaded, edgecolor='black', linewidth=1.5)
    ax.set_ylim(0, 0.35)
    ax.set_title('Infinitesimally Loaded Die\n(Perturbations ∈ O(ε))', fontsize=13, fontweight='bold')
    ax.set_ylabel('P(x)', fontsize=12)

    # Add perturbation labels
    for bar, elem, p in zip(bars, elements, perturbations):
        label = '+ε' if p > 0 else '-ε' if p < 0 else '0'
        color = '#2E7D32' if p > 0 else '#C62828' if p < 0 else '#1565C0'
        ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.008,
                f'1/{n} {label}', ha='center', va='bottom', fontsize=9,
                color=color, fontweight='bold')

    ax.axhline(y=base, color='red', linestyle='--', alpha=0.5, label=f'1/{n}')

    green_patch = mpatches.Patch(color='#4CAF50', label='Favored (+ε)')
    red_patch = mpatches.Patch(color='#F44336', label='Disfavored (-ε)')
    blue_patch = mpatches.Patch(color='#2196F3', label='Neutral')
    ax.legend(handles=[green_patch, red_patch, blue_patch], fontsize=9)
    ax.set_xlabel('Events', fontsize=12)

    plt.suptitle('Non-Archimedean Probability: From Classical to Infinitesimal',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('/workspace/request-project/Novelty/SurrealProbability/probability_landscape.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved probability_landscape.png")


def plot_archimedean_impossibility():
    """Visualize why Archimedean fields can't support uniform infinite weights."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    c_values = [0.1, 0.05, 0.01, 0.005, 0.001]

    for c in c_values:
        N_values = range(1, int(2/c) + 1)
        cumulative = [n * c for n in N_values]
        ax.plot(list(N_values), cumulative, label=f'c = {c}', linewidth=2)

    ax.axhline(y=1, color='red', linestyle='--', linewidth=2, label='Budget = 1')
    ax.set_xlabel('Number of elements N', fontsize=13)
    ax.set_ylabel('Cumulative mass N·c', fontsize=13)
    ax.set_title('Archimedean Impossibility:\nAny positive weight eventually exceeds budget',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_ylim(0, 2.5)
    ax.grid(True, alpha=0.3)

    # Annotate the key insight
    ax.annotate('No matter how small c > 0,\nN·c eventually exceeds 1',
                xy=(500, 1.5), fontsize=12,
                ha='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.9))

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Novelty/SurrealProbability/archimedean_impossibility.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved archimedean_impossibility.png")


def plot_infinitesimal_hierarchy():
    """Visualize the hierarchy of infinitesimal probabilities."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 7))

    categories = ['Certain\nP = 1', 'Likely\nP = 1/2', 'Unlikely\nP = 1/100',
                   '1st-order\ninfinitesimal\nP = ε',
                   '2nd-order\ninfinitesimal\nP = ε²',
                   'Impossible\nP = 0']

    # Use log-like scale for visualization
    heights = [1.0, 0.5, 0.1, 0.03, 0.01, 0]
    colors = ['#4CAF50', '#8BC34A', '#FFC107', '#FF9800', '#FF5722', '#9E9E9E']

    bars = ax.barh(range(len(categories)), heights, color=colors,
                   edgecolor='black', linewidth=1.5, height=0.6)
    ax.set_yticks(range(len(categories)))
    ax.set_yticklabels(categories, fontsize=11)
    ax.set_xlabel('Probability (schematic scale)', fontsize=13)
    ax.set_title('Infinitesimal Probability Hierarchy\nClassical theory collapses levels 3-5 to "impossible"',
                 fontsize=14, fontweight='bold')

    # Add bracket showing classical collapse
    ax.annotate('', xy=(0.04, 2.7), xytext=(0.04, 5.3),
                arrowprops=dict(arrowstyle='<->', color='red', lw=2))
    ax.text(0.06, 4, 'Classical probability\nsees all of these\nas P = 0',
            fontsize=11, color='red', va='center',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    ax.invert_yaxis()
    plt.tight_layout()
    plt.savefig('/workspace/request-project/Novelty/SurrealProbability/infinitesimal_hierarchy.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved infinitesimal_hierarchy.png")


if __name__ == "__main__":
    plot_probability_landscape()
    plot_archimedean_impossibility()
    plot_infinitesimal_hierarchy()
    print("\nAll visualizations generated.")
