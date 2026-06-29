#!/usr/bin/env python3
"""
Numerical demonstrations of non-Archimedean probability theory.

This script illustrates the key theorems from the formalization in
Algebra/NonArchimedeanProbability.lean using concrete numerical examples.
Since Python's floats are real (Archimedean) numbers, we simulate
non-Archimedean fields using symbolic representations and the
`fractions.Fraction` type for exact rational arithmetic.

Key demonstrations:
1. The Archimedean property in Q and its failure in extended fields
2. Finitely additive measures and the faithfulness-monotonicity equivalence
3. Conditional probability on singletons
4. Uniform measures and the infinitesimal probability concept
"""

from __future__ import annotations
from fractions import Fraction
from itertools import combinations
from typing import FrozenSet, Callable


# ===========================================================================
# Section 1: The Archimedean Property
# ===========================================================================

def is_archimedean_witness(x: Fraction, y: Fraction, max_n: int = 10_000) -> int | None:
    """
    Find n such that x <= n * y, or None if no such n exists up to max_n.

    Demonstrates Theorem 3.1: in an Archimedean field, such n always exists.
    """
    if y <= 0:
        raise ValueError("y must be positive")
    for n in range(max_n + 1):
        if x <= n * y:
            return n
    return None


def demo_archimedean_property() -> None:
    """Demonstrate that Q is Archimedean (Corollary 3.2)."""
    print("=" * 70)
    print("DEMO 1: The Archimedean Property in Q")
    print("=" * 70)
    print()
    print("Theorem (no_infinitesimal_prob_rationals):")
    print("  No rational number is an infinitesimal probability.")
    print()

    test_cases: list[tuple[Fraction, Fraction]] = [
        (Fraction(1), Fraction(1, 1000000)),
        (Fraction(999999, 1), Fraction(1, 7)),
        (Fraction(1, 1), Fraction(1, 10**12)),
    ]

    for x, y in test_cases:
        n = is_archimedean_witness(x, y)
        print(f"  x = {x}, y = {y}")
        print(f"    Archimedean witness: n = {n}  (since {x} <= {n} * {y} = {n * y})")
        print()

    # Show that any candidate "infinitesimal" in Q fails
    print("  Attempting infinitesimal probabilities in Q:")
    candidates = [Fraction(1, 10**k) for k in range(1, 8)]
    for eps in candidates:
        # Find n such that n * eps >= 1
        n_witness = int(1 / eps)
        print(f"    ε = {eps}: {n_witness} * ε = {n_witness * eps} >= 1  ✗ (not infinitesimal)")
    print()
    print("  Conclusion: Q is Archimedean — no infinitesimal probabilities exist.\n")


# ===========================================================================
# Section 2: Symbolic Non-Archimedean Field
# ===========================================================================

class LaurentElement:
    """
    An element of the Laurent series field Q((ε)), representing a + b*ε + ...

    This is a non-Archimedean ordered field where ε is a positive infinitesimal.
    We represent elements as (standard_part, infinitesimal_coefficient) for
    simplicity, i.e., a + b*ε.
    """

    def __init__(self, standard: Fraction, infinitesimal: Fraction = Fraction(0)):
        self.standard = standard
        self.infinitesimal = infinitesimal

    def __repr__(self) -> str:
        parts: list[str] = []
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

    def __add__(self, other: LaurentElement) -> LaurentElement:
        return LaurentElement(
            self.standard + other.standard,
            self.infinitesimal + other.infinitesimal,
        )

    def __mul__(self, other: LaurentElement) -> LaurentElement:
        # (a + bε)(c + dε) ≈ ac + (ad + bc)ε  (ignoring ε² terms)
        return LaurentElement(
            self.standard * other.standard,
            self.standard * other.infinitesimal + self.infinitesimal * other.standard,
        )

    def __lt__(self, other: LaurentElement) -> bool:
        """Lexicographic order: compare standard parts first, then infinitesimal."""
        if self.standard != other.standard:
            return self.standard < other.standard
        return self.infinitesimal < other.infinitesimal

    def __le__(self, other: LaurentElement) -> bool:
        return self == other or self < other

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, LaurentElement):
            return NotImplemented
        return self.standard == other.standard and self.infinitesimal == other.infinitesimal

    def __hash__(self) -> int:
        return hash((self.standard, self.infinitesimal))

    def is_positive(self) -> bool:
        return LaurentElement(Fraction(0)) < self

    def is_infinitesimal_prob(self) -> bool:
        """Check if this is an infinitesimal probability: 0 < ε and n·ε < 1 for all n."""
        if not self.is_positive():
            return False
        # In our representation, a + bε is infinitesimal iff a == 0 and b > 0
        return self.standard == Fraction(0) and self.infinitesimal > 0


def demo_non_archimedean_field() -> None:
    """Demonstrate infinitesimal probabilities in a non-Archimedean field."""
    print("=" * 70)
    print("DEMO 2: Infinitesimal Probabilities in Q((ε))")
    print("=" * 70)
    print()
    print("Theorem (non_archimedean_iff_infinitesimal_exists):")
    print("  A linearly ordered field admits infinitesimal probabilities")
    print("  if and only if it is non-Archimedean.")
    print()

    eps = LaurentElement(Fraction(0), Fraction(1))
    one = LaurentElement(Fraction(1))
    zero = LaurentElement(Fraction(0))

    print(f"  Let ε = {eps} in Q((ε)).")
    print(f"  ε > 0? {eps.is_positive()}  ✓")
    print(f"  ε is infinitesimal probability? {eps.is_infinitesimal_prob()}  ✓")
    print()

    # Show n·ε < 1 for various n
    print("  Verification: n·ε < 1 for all n ∈ ℕ:")
    for n in [1, 10, 100, 1000, 10**6, 10**9]:
        n_eps = LaurentElement(Fraction(0), Fraction(n))
        print(f"    {n} · ε = {n_eps} < 1? {n_eps < one}  ✓")

    print()
    print("  Q((ε)) is non-Archimedean: ε is positive but n·ε < 1 for all n.")
    print("  This confirms Theorem 3.1 (⇐ direction).\n")


# ===========================================================================
# Section 3: Finitely Additive Measures
# ===========================================================================

class FinAddMeasure:
    """
    A finitely additive measure on a finite set, valued in Q.

    Demonstrates the FinAddMeasure structure from the formalization.
    """

    def __init__(self, universe: frozenset[str], weights: dict[str, Fraction]):
        self.universe = universe
        self.weights = {x: weights.get(x, Fraction(0)) for x in universe}

        # Verify nonnegativity
        for x, w in self.weights.items():
            assert w >= 0, f"Weight of {x} is negative: {w}"

    def mass(self, s: frozenset[str]) -> Fraction:
        """Compute μ(s) = Σ_{x ∈ s} μ({x})  (Theorem 4.2: mass_eq_sum)."""
        return sum(self.weights[x] for x in s if x in self.weights)

    def is_faithful(self) -> bool:
        """Check if μ({x}) > 0 for all x (faithfulness)."""
        return all(w > 0 for w in self.weights.values())

    def is_strictly_monotone(self) -> bool:
        """Check if s ⊂ t implies μ(s) < μ(t) (strict monotonicity)."""
        elements = list(self.universe)
        for size_s in range(len(elements)):
            for s_tuple in combinations(elements, size_s):
                s = frozenset(s_tuple)
                for size_t in range(size_s + 1, len(elements) + 1):
                    for t_tuple in combinations(elements, size_t):
                        t = frozenset(t_tuple)
                        if s < t:  # proper subset
                            if not (self.mass(s) < self.mass(t)):
                                return False
        return True

    def cond_prob(self, a: frozenset[str], b: frozenset[str]) -> Fraction | None:
        """Conditional probability P(A|B) = μ(A ∩ B) / μ(B)."""
        mass_b = self.mass(b)
        if mass_b == 0:
            return None  # undefined
        return self.mass(a & b) / mass_b


def demo_faithfulness_equivalence() -> None:
    """Demonstrate Theorem 5.3: faithful ⟺ strictly monotone."""
    print("=" * 70)
    print("DEMO 3: Faithfulness ⟺ Strict Monotonicity")
    print("=" * 70)
    print()
    print("Theorem (faithful_iff_strict_mono):")
    print("  μ is faithful (∀x, μ({x}) > 0) ⟺ μ is strictly monotone (s ⊂ t ⟹ μ(s) < μ(t))")
    print()

    universe = frozenset({"a", "b", "c"})

    # Example 1: Faithful measure
    mu1 = FinAddMeasure(universe, {
        "a": Fraction(1, 3),
        "b": Fraction(1, 4),
        "c": Fraction(5, 12),
    })
    print("  Example 1: μ({a}) = 1/3, μ({b}) = 1/4, μ({c}) = 5/12")
    print(f"    Faithful? {mu1.is_faithful()}")
    print(f"    Strictly monotone? {mu1.is_strictly_monotone()}")
    print(f"    Total mass: {mu1.mass(universe)}")
    print()

    # Verify strict monotonicity explicitly
    s1 = frozenset({"a"})
    s2 = frozenset({"a", "b"})
    print(f"    {{a}} ⊂ {{a,b}}: μ({{a}}) = {mu1.mass(s1)} < μ({{a,b}}) = {mu1.mass(s2)}  ✓")
    print(f"    ∅ ⊂ {{c}}:    μ(∅) = {mu1.mass(frozenset())} < μ({{c}}) = {mu1.mass(frozenset({'c'}))}  ✓")
    print()

    # Example 2: Non-faithful measure (one zero weight)
    mu2 = FinAddMeasure(universe, {
        "a": Fraction(1, 2),
        "b": Fraction(0),
        "c": Fraction(1, 2),
    })
    print("  Example 2: μ({a}) = 1/2, μ({b}) = 0, μ({c}) = 1/2")
    print(f"    Faithful? {mu2.is_faithful()}")
    print(f"    Strictly monotone? {mu2.is_strictly_monotone()}")

    # Show the failure of strict monotonicity
    s3 = frozenset({"a"})
    s4 = frozenset({"a", "b"})
    print(f"    {{a}} ⊂ {{a,b}}: μ({{a}}) = {mu2.mass(s3)}, μ({{a,b}}) = {mu2.mass(s4)}  — NOT strictly greater!")
    print()
    print("  Equivalence confirmed: faithful ⟺ strictly monotone.\n")


def demo_conditional_probability() -> None:
    """Demonstrate conditional probability on singletons (Section 6)."""
    print("=" * 70)
    print("DEMO 4: Conditional Probability on Singletons")
    print("=" * 70)
    print()
    print("Theorems (condProb_singleton_mem, condProb_singleton_not_mem):")
    print("  P(A | {x}) = 1 if x ∈ A,  P(A | {x}) = 0 if x ∉ A")
    print()

    universe = frozenset({"1", "2", "3", "4", "5", "6"})
    # Fair die
    mu = FinAddMeasure(universe, {str(i): Fraction(1, 6) for i in range(1, 7)})

    event_even = frozenset({"2", "4", "6"})
    print("  Fair die: μ({i}) = 1/6 for i = 1,...,6")
    print(f"  Event A = 'even' = {{2, 4, 6}}")
    print()

    for x in sorted(universe):
        singleton = frozenset({x})
        cp = mu.cond_prob(event_even, singleton)
        in_A = x in event_even
        expected = Fraction(1) if in_A else Fraction(0)
        status = "∈ A" if in_A else "∉ A"
        check = "✓" if cp == expected else "✗"
        print(f"    P(even | {{{x}}}) = {cp}  (x {status})  {check}")

    print()

    # Chain rule demonstration
    print("  Chain rule: P(A∩B | C) = P(A | B∩C) · P(B | C)")
    A = frozenset({"1", "2", "3"})
    B = frozenset({"2", "3", "4"})
    C = frozenset({"1", "2", "3", "4"})
    print(f"    A = {{1,2,3}}, B = {{2,3,4}}, C = {{1,2,3,4}}")

    lhs = mu.cond_prob(A & B, C)
    p_a_bc = mu.cond_prob(A, B & C)
    p_b_c = mu.cond_prob(B, C)

    if p_a_bc is not None and p_b_c is not None:
        rhs = p_a_bc * p_b_c
        print(f"    LHS: P(A∩B | C) = P({{2,3}} | {{1,2,3,4}}) = {lhs}")
        print(f"    RHS: P(A | B∩C) · P(B | C) = {p_a_bc} · {p_b_c} = {rhs}")
        print(f"    Equal? {lhs == rhs}  ✓")
    print()


def demo_uniform_measure() -> None:
    """Demonstrate the uniform measure construction (Section 7)."""
    print("=" * 70)
    print("DEMO 5: Uniform Measure and Infinitesimal Scaling")
    print("=" * 70)
    print()
    print("Theorem (uniform_singleton):")
    print("  The uniform measure assigns mass 1/|α| to each singleton.")
    print()

    for n in [3, 5, 10, 100, 1000]:
        elements = frozenset(str(i) for i in range(n))
        weights = {str(i): Fraction(1, n) for i in range(n)}
        mu = FinAddMeasure(elements, weights)

        total = mu.mass(elements)
        singleton_mass = mu.mass(frozenset({"0"}))
        print(f"  |α| = {n}: μ({{x}}) = {singleton_mass}, total = {total}")

    print()
    print("  As |α| → ∞ (or to a non-standard integer ω),")
    print("  μ({x}) = 1/ω → infinitesimal, but total remains exactly 1.")
    print()

    # Simulate the "infinitesimal scaling" behavior
    print("  Infinitesimal scaling behavior:")
    print("  n        | 1/n           | n · (1/n)")
    print("  " + "-" * 45)
    for k in range(1, 13):
        n = 10**k
        print(f"  10^{k:<5} | {1/n:<13.2e} | {n * (1/n):.1f}")
    print()
    print("  In a non-Archimedean field, this pattern continues")
    print("  past all finite n to the infinitesimal regime.\n")


def demo_positivity_principle() -> None:
    """Demonstrate the positivity principle (Theorem 5.1)."""
    print("=" * 70)
    print("DEMO 6: Positivity Principle — Nonempty Sets Have Positive Measure")
    print("=" * 70)
    print()
    print("Theorem (mass_pos_of_pos_weights):")
    print("  If μ({x}) > 0 for all x, then μ(s) > 0 for every nonempty s.")
    print()

    universe = frozenset({"a", "b", "c", "d"})
    weights = {
        "a": Fraction(1, 100),
        "b": Fraction(1, 200),
        "c": Fraction(1, 500),
        "d": Fraction(1, 1000),
    }
    mu = FinAddMeasure(universe, weights)
    print(f"  Weights: {dict(sorted(weights.items()))}")
    print(f"  All positive? {mu.is_faithful()}")
    print()

    # Check all nonempty subsets
    elements = sorted(universe)
    all_positive = True
    for size in range(1, len(elements) + 1):
        for subset_tuple in combinations(elements, size):
            s = frozenset(subset_tuple)
            m = mu.mass(s)
            is_pos = m > 0
            if not is_pos:
                all_positive = False
            print(f"    μ({set(sorted(s))}) = {m} > 0? {is_pos}")

    print()
    print(f"  All nonempty subsets have positive measure? {all_positive}  ✓\n")


# ===========================================================================
# Main
# ===========================================================================

def main() -> None:
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   Non-Archimedean Probability Theory — Numerical Demonstrations    ║")
    print("║                                                                    ║")
    print("║   Companion to: Algebra/NonArchimedeanProbability.lean             ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_archimedean_property()
    demo_non_archimedean_field()
    demo_faithfulness_equivalence()
    demo_conditional_probability()
    demo_uniform_measure()
    demo_positivity_principle()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()
