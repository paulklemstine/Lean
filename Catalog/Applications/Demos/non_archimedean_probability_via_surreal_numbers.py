#!/usr/bin/env python3
"""
Non-Archimedean Probability Theory: Numerical Demonstrations

Demonstrates the key concepts using Python's Fraction type for exact arithmetic
and symbolic infinitesimal arithmetic.
"""

from fractions import Fraction
from typing import Dict, List, Set, Tuple
import itertools


class InfinitesimalField:
    """
    Represents elements of the form a + b*ε where a, b ∈ ℚ and ε is infinitesimal.
    Ordered lexicographically: (a₁, b₁) < (a₂, b₂) iff a₁ < a₂, or a₁ = a₂ and b₁ < b₂.
    This is a linearly ordered field (truncated at ε² = 0 for simplicity in demos,
    though the full theory works with ε² > 0 infinitesimal).
    """
    def __init__(self, std: Fraction, inf: Fraction = Fraction(0)):
        self.std = std  # standard part
        self.inf = inf  # infinitesimal coefficient

    def __repr__(self):
        if self.inf == 0:
            return f"{self.std}"
        elif self.std == 0:
            return f"{self.inf}ε"
        else:
            sign = "+" if self.inf > 0 else "-"
            return f"{self.std} {sign} {abs(self.inf)}ε"

    def __add__(self, other):
        return InfinitesimalField(self.std + other.std, self.inf + other.inf)

    def __sub__(self, other):
        return InfinitesimalField(self.std - other.std, self.inf - other.inf)

    def __mul__(self, other):
        # (a + bε)(c + dε) = ac + (ad + bc)ε  (dropping ε² terms)
        return InfinitesimalField(
            self.std * other.std,
            self.std * other.inf + self.inf * other.std
        )

    def __truediv__(self, other):
        if other.std == 0 and other.inf == 0:
            raise ZeroDivisionError
        if other.std != 0:
            # (a + bε) / (c + dε) = (a/c) + (b/c - ad/c²)ε
            return InfinitesimalField(
                self.std / other.std,
                (self.inf * other.std - self.std * other.inf) / (other.std ** 2)
            )
        raise ValueError("Division by pure infinitesimal not supported in dual numbers")

    def __lt__(self, other):
        if self.std != other.std:
            return self.std < other.std
        return self.inf < other.inf

    def __le__(self, other):
        return self == other or self < other

    def __eq__(self, other):
        if isinstance(other, InfinitesimalField):
            return self.std == other.std and self.inf == other.inf
        return False

    def __hash__(self):
        return hash((self.std, self.inf))

    def is_infinitesimal(self) -> bool:
        """Check if this element is infinitesimal (std part = 0, inf part > 0)."""
        return self.std == 0 and self.inf > 0


class NonArchProbSpace:
    """
    A finitely additive probability space valued in InfinitesimalField.
    """
    def __init__(self, outcomes: List[str], weights: Dict[str, InfinitesimalField]):
        self.outcomes = outcomes
        self.weights = weights

        # Verify normalization
        total = InfinitesimalField(Fraction(0))
        for w in weights.values():
            total = total + w
        assert total == InfinitesimalField(Fraction(1)), f"Weights sum to {total}, not 1"

    def prob(self, event: Set[str]) -> InfinitesimalField:
        result = InfinitesimalField(Fraction(0))
        for x in event:
            if x in self.weights:
                result = result + self.weights[x]
        return result

    def cond_prob(self, A: Set[str], B: Set[str]) -> InfinitesimalField:
        pB = self.prob(B)
        pAB = self.prob(A & B)
        return pAB / pB


def demo_1_uniform_finite():
    """Demo 1: Uniform probability on a finite set (standard case)."""
    print("=" * 60)
    print("DEMO 1: Uniform Probability on {a, b, c, d}")
    print("=" * 60)

    outcomes = ["a", "b", "c", "d"]
    w = Fraction(1, 4)
    weights = {x: InfinitesimalField(w) for x in outcomes}
    P = NonArchProbSpace(outcomes, weights)

    print(f"Weight of each outcome: {P.weights['a']}")
    print(f"P({{a}}) = {P.prob({'a'})}")
    print(f"P({{a, b}}) = {P.prob({'a', 'b'})}")
    print(f"P({{a, b, c, d}}) = {P.prob(set(outcomes))}")
    print(f"P(∅) = {P.prob(set())}")

    # Conditional probability
    A = {"a", "b"}
    B = {"b", "c"}
    print(f"\nP(A|B) where A={{a,b}}, B={{b,c}}: {P.cond_prob(A, B)}")
    print(f"P(B|A) where A={{a,b}}, B={{b,c}}: {P.cond_prob(B, A)}")

    # Verify Bayes: P(A|B)*P(B) = P(B|A)*P(A)
    lhs = P.cond_prob(A, B) * P.prob(B)
    rhs = P.cond_prob(B, A) * P.prob(A)
    print(f"\nBayes check: P(A|B)·P(B) = {lhs}, P(B|A)·P(A) = {rhs}")
    print(f"Equal? {lhs == rhs}")
    print()


def demo_2_infinitesimal_weights():
    """Demo 2: Probability with infinitesimal perturbation."""
    print("=" * 60)
    print("DEMO 2: Non-Uniform Probability with Infinitesimal Correction")
    print("=" * 60)

    # A 3-element space where one outcome has an infinitesimal correction
    # weights: 1/3 + ε, 1/3 - ε/2, 1/3 - ε/2
    # Sum = 1/3 + 1/3 + 1/3 + ε - ε/2 - ε/2 = 1
    third = Fraction(1, 3)
    half = Fraction(1, 2)
    outcomes = ["x", "y", "z"]
    weights = {
        "x": InfinitesimalField(third, Fraction(1)),       # 1/3 + ε
        "y": InfinitesimalField(third, -half),              # 1/3 - ε/2
        "z": InfinitesimalField(third, -half),              # 1/3 - ε/2
    }
    P = NonArchProbSpace(outcomes, weights)

    print("Weights:")
    for o in outcomes:
        print(f"  w({o}) = {P.weights[o]}")

    print(f"\nP({{x}}) = {P.prob({'x'})} (slightly MORE than 1/3)")
    print(f"P({{y}}) = {P.prob({'y'})} (slightly LESS than 1/3)")

    # Conditional probability
    A = {"x"}
    B = {"x", "y"}
    pAB = P.cond_prob(A, B)
    print(f"\nP({{x}} | {{x,y}}) = {pAB}")
    print("  (In standard probability this would be exactly 1/2)")
    print("  (Here the infinitesimal correction makes x slightly more likely)")
    print()


def demo_3_regularity():
    """Demo 3: Regular probability space — every point has positive weight."""
    print("=" * 60)
    print("DEMO 3: Regularity and Conditional Probability on Singletons")
    print("=" * 60)

    # A 5-element space with all positive (but non-uniform) weights
    outcomes = ["a", "b", "c", "d", "e"]
    raw = [Fraction(1), Fraction(2), Fraction(3), Fraction(4), Fraction(5)]
    total = sum(raw)
    weights = {outcomes[i]: InfinitesimalField(raw[i] / total) for i in range(5)}
    P = NonArchProbSpace(outcomes, weights)

    print("Regular probability space (all weights > 0):")
    for o in outcomes:
        print(f"  w({o}) = {P.weights[o]}")

    # Conditional probability on singletons
    for x in outcomes:
        B = {x}
        A = set(outcomes)
        print(f"  P(Ω | {{{x}}}) = {P.cond_prob(A, B)} (should be 1)")
    print()


def demo_4_bayes_verification():
    """Demo 4: Verify Bayes' theorem for all pairs of events."""
    print("=" * 60)
    print("DEMO 4: Systematic Bayes' Theorem Verification")
    print("=" * 60)

    outcomes = ["1", "2", "3"]
    weights = {
        "1": InfinitesimalField(Fraction(1, 6)),
        "2": InfinitesimalField(Fraction(1, 3)),
        "3": InfinitesimalField(Fraction(1, 2)),
    }
    P = NonArchProbSpace(outcomes, weights)

    # Check Bayes for all nonempty event pairs
    events = []
    for r in range(1, len(outcomes) + 1):
        for subset in itertools.combinations(outcomes, r):
            events.append(set(subset))

    violations = 0
    checks = 0
    for A in events:
        for B in events:
            pA = P.prob(A)
            pB = P.prob(B)
            if pA.std != 0 and pB.std != 0:  # both nonzero
                lhs = P.cond_prob(A, B) * pB
                rhs = P.cond_prob(B, A) * pA
                checks += 1
                if lhs != rhs:
                    violations += 1
                    print(f"  VIOLATION: A={A}, B={B}")

    print(f"Checked {checks} event pairs, {violations} violations")
    print(f"Bayes' theorem holds: {violations == 0}")
    print()


def demo_5_markov_inequality():
    """Demo 5: Non-Archimedean Markov inequality."""
    print("=" * 60)
    print("DEMO 5: Markov Inequality")
    print("=" * 60)

    outcomes = ["1", "2", "3", "4", "5"]
    # Uniform weights
    w = Fraction(1, 5)
    weights = {x: InfinitesimalField(w) for x in outcomes}
    P = NonArchProbSpace(outcomes, weights)

    # Random variable X(i) = i
    X = {str(i): InfinitesimalField(Fraction(i)) for i in range(1, 6)}

    # Expected value
    EX = InfinitesimalField(Fraction(0))
    for x in outcomes:
        EX = EX + P.weights[x] * X[x]
    print(f"E[X] = {EX}")

    # Markov for various thresholds
    for a_val in [2, 3, 4]:
        a = InfinitesimalField(Fraction(a_val))
        event = {x for x in outcomes if not (X[x] < a)}
        prob_event = P.prob(event)
        bound = EX / a
        print(f"  a={a_val}: P(X ≥ {a_val}) = {prob_event}, E[X]/{a_val} = {bound}, "
              f"holds: {prob_event <= bound}")
    print()


def demo_6_independence():
    """Demo 6: Independence characterization in uniform spaces."""
    print("=" * 60)
    print("DEMO 6: Independence in Uniform Probability Spaces")
    print("=" * 60)

    # Ω = {(i,j) : 0 ≤ i < 3, 0 ≤ j < 3} — 9 outcomes
    outcomes = [f"({i},{j})" for i in range(3) for j in range(3)]
    w = Fraction(1, 9)
    weights = {x: InfinitesimalField(w) for x in outcomes}
    P = NonArchProbSpace(outcomes, weights)

    # A = {first coordinate is 0}
    A = {f"(0,{j})" for j in range(3)}
    # B = {second coordinate is 0}
    B = {f"({i},0)" for i in range(3)}

    print(f"Ω has {len(outcomes)} outcomes")
    print(f"A = {{first coord = 0}} = {A}")
    print(f"B = {{second coord = 0}} = {B}")
    print(f"|A| = {len(A)}, |B| = {len(B)}, |A∩B| = {len(A & B)}, |Ω| = {len(outcomes)}")
    print(f"|A∩B| · |Ω| = {len(A & B) * len(outcomes)}")
    print(f"|A| · |B| = {len(A) * len(B)}")
    print(f"Independent? {len(A & B) * len(outcomes) == len(A) * len(B)}")

    print(f"\nP(A) = {P.prob(A)}")
    print(f"P(B) = {P.prob(B)}")
    print(f"P(A∩B) = {P.prob(A & B)}")
    print(f"P(A)·P(B) = {P.prob(A) * P.prob(B)}")
    print()


if __name__ == "__main__":
    demo_1_uniform_finite()
    demo_2_infinitesimal_weights()
    demo_3_regularity()
    demo_4_bayes_verification()
    demo_5_markov_inequality()
    demo_6_independence()

    print("=" * 60)
    print("All demonstrations completed successfully.")
    print("Key insight: Non-Archimedean probability allows conditioning")
    print("on events with infinitesimal probability — impossible in ℝ.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Non-Archimedean Probability Landscape

Shows how infinitesimal perturbations create a two-level structure in probability:
a "standard" level visible at macroscopic scale, and an "infinitesimal" level that
resolves ties between events with equal standard probability.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from fractions import Fraction

def create_probability_landscape():
    """Create the main probability landscape visualization."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Panel 1: Standard vs Non-Archimedean weights
    ax1 = axes[0, 0]
    outcomes = ['A', 'B', 'C', 'D', 'E', 'F']
    n = len(outcomes)
    std_weights = [1/n] * n
    # Non-Archimedean: base 1/6, with infinitesimal perturbations
    perturbations = [0.03, -0.01, 0.02, -0.02, 0.01, -0.03]  # visual stand-in for ε
    na_weights = [1/n + p for p in perturbations]

    x = np.arange(n)
    width = 0.35
    bars1 = ax1.bar(x - width/2, std_weights, width, label='Standard (ℝ)', color='#2196F3', alpha=0.8)
    bars2 = ax1.bar(x + width/2, na_weights, width, label='Non-Arch (F)', color='#FF5722', alpha=0.8)
    ax1.axhline(y=1/n, color='gray', linestyle='--', alpha=0.5)
    ax1.set_xticks(x)
    ax1.set_xticklabels(outcomes)
    ax1.set_ylabel('Weight')
    ax1.set_title('Standard vs Non-Archimedean Weights\n(infinitesimal differences resolve ties)')
    ax1.legend()
    ax1.set_ylim(0, 0.25)

    # Panel 2: Conditional probability P(A|{x}) for each singleton
    ax2 = axes[0, 1]
    # In a 6-element uniform space, P({x} | {x,y}) = 1/2 for all x,y (standard)
    # In non-Archimedean, P({x} | {x,y}) = w(x)/(w(x)+w(y)) which varies
    pairs = [('A','B'), ('B','C'), ('C','D'), ('D','E'), ('E','F'), ('A','F')]
    std_cond = [0.5] * len(pairs)
    na_cond = []
    for p in pairs:
        i, j = outcomes.index(p[0]), outcomes.index(p[1])
        wi, wj = na_weights[i], na_weights[j]
        na_cond.append(wi / (wi + wj))

    x2 = np.arange(len(pairs))
    pair_labels = [f'P({p[0]}|{{{p[0]},{p[1]}}})'  for p in pairs]
    ax2.bar(x2 - width/2, std_cond, width, label='Standard', color='#2196F3', alpha=0.8)
    ax2.bar(x2 + width/2, na_cond, width, label='Non-Archimedean', color='#FF5722', alpha=0.8)
    ax2.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5)
    ax2.set_xticks(x2)
    ax2.set_xticklabels(pair_labels, rotation=45, ha='right', fontsize=8)
    ax2.set_ylabel('Conditional Probability')
    ax2.set_title('Conditional Probability: Infinitesimals\nBreak Standard Degeneracies')
    ax2.legend()
    ax2.set_ylim(0.4, 0.6)

    # Panel 3: Markov inequality bound vs actual probability
    ax3 = axes[1, 0]
    n_pts = 10
    weights = np.ones(n_pts) / n_pts
    X_vals = np.arange(1, n_pts + 1, dtype=float)
    EX = np.sum(weights * X_vals)

    thresholds = np.linspace(1, n_pts, 50)
    actual_probs = []
    markov_bounds = []
    for a in thresholds:
        actual = np.sum(weights[X_vals >= a])
        bound = EX / a
        actual_probs.append(actual)
        markov_bounds.append(min(bound, 1.0))

    ax3.fill_between(thresholds, markov_bounds, alpha=0.3, color='#FF5722', label='Markov bound E[X]/a')
    ax3.step(thresholds, actual_probs, where='post', color='#2196F3', linewidth=2, label='Actual P(X ≥ a)')
    ax3.set_xlabel('Threshold a')
    ax3.set_ylabel('Probability')
    ax3.set_title('Non-Archimedean Markov Inequality\n(holds for any ordered field)')
    ax3.legend()
    ax3.set_ylim(0, 1.1)

    # Panel 4: The "regularity" advantage
    ax4 = axes[1, 1]
    # Show that in ℝ, as n→∞, singleton probability → 0
    # In non-Archimedean, singleton probability → ε (positive infinitesimal)
    ns = np.arange(2, 51)
    real_singleton = 1.0 / ns
    # Represent infinitesimal as a small positive constant for visualization
    eps_visual = 0.005

    ax4.plot(ns, real_singleton, 'b-', linewidth=2, label='ℝ: P({x}) = 1/n → 0')
    ax4.axhline(y=eps_visual, color='#FF5722', linestyle='-', linewidth=2,
                label='Non-Arch: P({x}) = ε > 0 (infinitesimal)')
    ax4.axhline(y=0, color='gray', linestyle='-', linewidth=0.5)
    ax4.fill_between(ns, 0, eps_visual, alpha=0.2, color='#FF5722')
    ax4.annotate('Infinitesimal gap\n(ε is positive but\nsmaller than any 1/n)',
                xy=(30, eps_visual/2), fontsize=9, ha='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))
    ax4.set_xlabel('Number of outcomes n')
    ax4.set_ylabel('Singleton probability')
    ax4.set_title('Regularity: Non-Archimedean Probability\nKeeps Every Point Positive')
    ax4.legend(loc='upper right')
    ax4.set_ylim(-0.02, 0.55)

    plt.tight_layout()
    plt.savefig('probability_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved probability_landscape.png")


if __name__ == "__main__":
    create_probability_landscape()
