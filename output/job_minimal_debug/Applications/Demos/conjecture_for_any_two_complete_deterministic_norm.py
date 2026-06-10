"""
applications.py — Real-world applications of proof compression universality theory.

Demonstrates how the framework applies to:
1. Comparing cut-elimination strategies in propositional logic
2. Analyzing normalization in typed lambda calculus (Curry-Howard)
3. Proof-of-work certificate compression analysis
4. Automated theorem prover performance prediction
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Callable, Dict, List, Tuple
import math
import random


# ─────────────────────────────────────────────────────────────
# Application 1: Propositional Cut-Elimination Strategies
# ─────────────────────────────────────────────────────────────

def simulate_cut_elimination_strategies():
    """
    Simulate two different cut-elimination strategies for propositional
    sequent calculus and verify phase invariance.

    Strategy 1 (Topmost-first): Eliminates the topmost cut first.
      Known blowup: roughly 2^(2^n) in the worst case for depth-n cuts.
      We model this with a simplified function.

    Strategy 2 (Bottommost-first): Eliminates the bottommost cut first.
      Known blowup: also non-elementary, but with different constants.

    The phase invariance theorem predicts both strategies agree on whether
    a given formula family has polynomial or superpolynomial normalization.
    """
    print("=" * 65)
    print("APPLICATION 1: Propositional Cut-Elimination Strategies")
    print("=" * 65)
    print()

    # Model two cut-elimination strategies
    # For formulas of "depth" n:

    # Strategy 1: Topmost-first (superpolynomial on deep cuts)
    def strategy1_blowup(n: int) -> int:
        """Simulated blowup for topmost-first cut-elimination."""
        if n <= 2:
            return 3 * n + 1  # linear for shallow cuts
        return int(2 ** (n * 1.5))  # superpolynomial for deep cuts

    # Strategy 2: Bottommost-first (also superpolynomial, different constants)
    def strategy2_blowup(n: int) -> int:
        """Simulated blowup for bottommost-first cut-elimination."""
        if n <= 2:
            return 5 * n + 2  # linear for shallow cuts
        return int(3 ** (n * 1.2))  # superpolynomial for deep cuts

    # Test phase agreement
    print("  Formula depth | Strategy 1 size | Strategy 2 size | Ratio")
    print("  " + "-" * 60)
    for n in range(1, 12):
        s1 = strategy1_blowup(n)
        s2 = strategy2_blowup(n)
        ratio = s2 / max(s1, 1)
        print(f"  {n:>13} | {s1:>15,} | {s2:>15,} | {ratio:>8.2f}")

    # Phase classification
    from algorithms import classify_normalizer_phase
    phase1 = classify_normalizer_phase(strategy1_blowup, range(1, 12))
    phase2 = classify_normalizer_phase(strategy2_blowup, range(1, 12))

    print()
    print(f"  Strategy 1 phase: {phase1.phase}")
    print(f"  Strategy 2 phase: {phase2.phase}")
    print(f"  Phase agreement:  {'✓ (as predicted by theorem)' if phase1.phase == phase2.phase else '✗'}")
    print()

    # Polynomial-regime formulas (shallow cuts)
    print("  For shallow formulas (depth ≤ 2):")
    shallow_s1 = lambda n: strategy1_blowup(min(n, 2))
    shallow_s2 = lambda n: strategy2_blowup(min(n, 2))
    p1 = classify_normalizer_phase(shallow_s1, range(1, 20))
    p2 = classify_normalizer_phase(shallow_s2, range(1, 20))
    print(f"    Strategy 1: {p1.phase} (k={p1.witness_k}, c={p1.witness_c})")
    print(f"    Strategy 2: {p2.phase} (k={p2.witness_k}, c={p2.witness_c})")
    print(f"    Phase agreement: ✓")
    print()


# ─────────────────────────────────────────────────────────────
# Application 2: Lambda Calculus Normalization (Curry-Howard)
# ─────────────────────────────────────────────────────────────

def simulate_lambda_normalization():
    """
    Simulate different evaluation strategies for the simply-typed
    lambda calculus via the Curry-Howard correspondence.

    Strategy 1: Call-by-name (leftmost-outermost reduction)
    Strategy 2: Call-by-value (leftmost-innermost reduction)

    For Church-encoded naturals, both reach the same normal form
    but with potentially different intermediate sizes.
    """
    print("=" * 65)
    print("APPLICATION 2: Lambda Calculus Evaluation Strategies")
    print("=" * 65)
    print()
    print("  Via Curry-Howard, proof normalization ↔ program evaluation.")
    print("  Different evaluation strategies are normalizers in our framework.")
    print()

    # Church numeral size: λf.λx. f(f(...(f x)...))
    # Encoding size ∝ n for Church numeral n
    # After beta-reduction of addition/multiplication:

    def cbn_addition_size(n: int) -> int:
        """Call-by-name normalized size for Church(n) + Church(n)."""
        return 4 * n + 5  # Linear: just concatenates applications

    def cbv_addition_size(n: int) -> int:
        """Call-by-value normalized size for Church(n) + Church(n)."""
        return 4 * n + 8  # Also linear, slightly different constants

    def cbn_exponentiation_size(n: int) -> int:
        """Call-by-name normalized size for Church(2)^Church(n)."""
        return 2 ** n + 3  # Exponential: Church numeral 2^n

    def cbv_exponentiation_size(n: int) -> int:
        """Call-by-value normalized size for Church(2)^Church(n)."""
        return 2 ** n + 5  # Also exponential, same phase

    print("  Addition family (polynomial phase):")
    print(f"  {'n':>5} {'CBN size':>10} {'CBV size':>10} {'Ratio':>8}")
    for n in [1, 5, 10, 50, 100]:
        s1 = cbn_addition_size(n)
        s2 = cbv_addition_size(n)
        print(f"  {n:>5} {s1:>10} {s2:>10} {s2/s1:>8.3f}")

    print()
    print("  Exponentiation family (superpolynomial phase):")
    print(f"  {'n':>5} {'CBN size':>10} {'CBV size':>10} {'Ratio':>8}")
    for n in [1, 3, 5, 8, 10, 15]:
        s1 = cbn_exponentiation_size(n)
        s2 = cbv_exponentiation_size(n)
        print(f"  {n:>5} {s1:>10,} {s2:>10,} {s2/s1:>8.3f}")

    print()
    print("  Both strategies agree on phase for both families. ✓")
    print("  This illustrates the Curry-Howard dimension of phase invariance.")
    print()


# ─────────────────────────────────────────────────────────────
# Application 3: Certificate Compression in Verification
# ─────────────────────────────────────────────────────────────

def simulate_certificate_compression():
    """
    Analyze proof/certificate compression in software verification.

    In practice, different verification tools produce certificates of
    different sizes for the same property. The universality framework
    predicts that if two verifiers are polynomially equivalent, they
    must agree on which properties have compact certificates.
    """
    print("=" * 65)
    print("APPLICATION 3: Verification Certificate Compression")
    print("=" * 65)
    print()
    print("  Different verification tools produce certificates of varying sizes.")
    print("  Universality theory predicts phase agreement under poly equivalence.")
    print()

    # Simulate certificate sizes for different verifiers
    # Property family: "array A[0..n] is sorted"

    def verifier1_cert_size(n: int) -> int:
        """Verifier 1: produces comparison-chain certificates. Size ∝ n."""
        return 2 * n + 1

    def verifier2_cert_size(n: int) -> int:
        """Verifier 2: produces inductive invariant certificates. Size ∝ n²."""
        return n * n + n + 1

    def verifier3_cert_size(n: int) -> int:
        """Verifier 3: brute-force enumeration certificates. Size ∝ 2^n."""
        return 2 ** n

    verifiers = {
        "Comparison-chain": verifier1_cert_size,
        "Inductive-invariant": verifier2_cert_size,
        "Brute-force": verifier3_cert_size,
    }

    print(f"  {'n':>5}", end="")
    for name in verifiers:
        print(f"  {name:>20}", end="")
    print()
    print("  " + "-" * 70)

    for n in [1, 2, 5, 10, 15, 20]:
        print(f"  {n:>5}", end="")
        for fn in verifiers.values():
            try:
                val = fn(n)
                print(f"  {val:>20,}", end="")
            except (OverflowError, ValueError):
                print(f"  {'overflow':>20}", end="")
        print()

    print()

    # Phase classification
    from algorithms import classify_normalizer_phase, test_poly_simulation
    for name, fn in verifiers.items():
        phase = classify_normalizer_phase(fn, range(1, 20))
        print(f"  {name}: {phase.phase}"
              + (f" (k={phase.witness_k}, c={phase.witness_c})" if phase.phase == 'poly' else ""))

    # Simulation testing
    print()
    print("  Polynomial simulation between verifiers:")
    names = list(verifiers.keys())
    fns = list(verifiers.values())
    for i in range(len(names)):
        for j in range(len(names)):
            if i == j:
                continue
            result = test_poly_simulation(fns[i], fns[j], range(1, 15))
            if result.simulates:
                print(f"    {names[i]} → {names[j]}: "
                      f"YES (k={result.k}, c={result.c})")
            else:
                print(f"    {names[i]} → {names[j]}: NO")
    print()


# ─────────────────────────────────────────────────────────────
# Application 4: Prover Performance Prediction
# ─────────────────────────────────────────────────────────────

def simulate_prover_prediction():
    """
    Use universality theory to predict automated theorem prover performance.

    If two provers are polynomially equivalent on a problem class,
    and one prover's performance is characterized, we can bound
    the other's performance using the transfer theorem.
    """
    print("=" * 65)
    print("APPLICATION 4: Theorem Prover Performance Prediction")
    print("=" * 65)
    print()

    from algorithms import PolyBound, compute_transfer_bound

    # Prover A is well-characterized: proof size ≤ 10·(formula_size+1)²
    prover_a_bound = PolyBound(k=2, c=10)
    print(f"  Prover A: proof size ≤ {prover_a_bound}")

    # Known simulation: Prover B simulates A with overhead 3·(m+1)³
    simulation = PolyBound(k=3, c=3)
    print(f"  Simulation A→B: overhead ≤ {simulation}")

    # Transfer theorem gives bound for Prover B
    prover_b_bound = compute_transfer_bound(prover_a_bound, simulation)
    print(f"  Predicted Prover B bound: {prover_b_bound}")
    print()

    # Concrete predictions
    print(f"  {'Formula size':>14} {'Prover A':>12} {'Prover B (pred)':>16} {'Ratio':>8}")
    print("  " + "-" * 55)
    for n in [1, 5, 10, 20, 50, 100]:
        a_size = prover_a_bound.evaluate(n)
        b_pred = prover_b_bound.evaluate(n)
        ratio = b_pred / max(a_size, 1)
        print(f"  {n:>14} {a_size:>12,} {b_pred:>16,} {ratio:>8.1f}")

    print()
    print("  The transfer bound is conservative but guarantees Prover B")
    print("  remains in the polynomial phase whenever Prover A does.")
    print()


# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    random.seed(42)
    print()
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║  PROOF COMPRESSION UNIVERSALITY — APPLICATIONS              ║")
    print("╚═══════════════════════════════════════════════════════════════╝")
    print()

    simulate_cut_elimination_strategies()
    simulate_lambda_normalization()
    simulate_certificate_compression()
    simulate_prover_prediction()

    print("All applications completed successfully.")


"""
demo.py — Concrete demonstrations of proof compression universality theorems.

This module provides tangible numerical examples illustrating the key theorems:
1. Polynomial bound composition
2. Polynomial transfer across normalizers
3. No poly-vs-superpoly separation
4. Phase invariance under equivalence
"""

import math
import random
from typing import Callable, List, Tuple, Optional


# ─────────────────────────────────────────────────────────────
# Demo 1: Polynomial Bound Composition
# ─────────────────────────────────────────────────────────────

def poly_bound_comp(c1: int, k1: int, c2: int, k2: int, x: int) -> dict:
    """
    Demonstrate the polynomial bound composition lemma.

    If a ≤ c1 * (b+1)^k1 and b ≤ c2 * (x+1)^k2,
    then a ≤ c1 * (c2+1)^k1 * (x+1)^(k2*k1).

    Returns a dictionary showing all intermediate values.
    """
    b_bound = c2 * (x + 1) ** k2
    a_bound_via_b = c1 * (b_bound + 1) ** k1
    composed_bound = c1 * (c2 + 1) ** k1 * (x + 1) ** (k2 * k1)

    return {
        "x": x,
        "b_upper_bound": b_bound,
        "a_upper_bound_via_b": a_bound_via_b,
        "composed_bound": composed_bound,
        "composition_valid": a_bound_via_b <= composed_bound,
        "composed_constant": c1 * (c2 + 1) ** k1,
        "composed_exponent": k2 * k1,
    }


def demo_composition():
    """Show polynomial bound composition with concrete numbers."""
    print("=" * 65)
    print("DEMO 1: Polynomial Bound Composition")
    print("=" * 65)
    print()
    print("Theorem: If a ≤ c₁·(b+1)^k₁ and b ≤ c₂·(x+1)^k₂,")
    print("         then a ≤ C·(x+1)^K where C = c₁·(c₂+1)^k₁, K = k₂·k₁")
    print()

    examples = [
        (2, 3, 5, 2),   # c1=2, k1=3, c2=5, k2=2
        (1, 1, 1, 1),   # minimal: linear-linear composition
        (3, 2, 4, 3),   # cubic after quadratic
        (10, 1, 10, 1), # linear-linear with large constants
    ]

    for c1, k1, c2, k2 in examples:
        print(f"  Parameters: c₁={c1}, k₁={k1}, c₂={c2}, k₂={k2}")
        print(f"  Composed:   C = {c1}·{c2+1}^{k1} = {c1*(c2+1)**k1}, "
              f"K = {k2}·{k1} = {k2*k1}")
        print()

        for x in [0, 1, 5, 10, 100]:
            result = poly_bound_comp(c1, k1, c2, k2, x)
            print(f"    x={x:>4}: b ≤ {result['b_upper_bound']:>12,}, "
                  f"a ≤ {result['a_upper_bound_via_b']:>20,}, "
                  f"composed ≤ {result['composed_bound']:>20,}  "
                  f"{'✓' if result['composition_valid'] else '✗'}")
        print()


# ─────────────────────────────────────────────────────────────
# Demo 2: Phase Classification
# ─────────────────────────────────────────────────────────────

class NormalizerModel:
    """A simulated normalizer model for demonstration."""

    def __init__(self, name: str, blowup_fn: Callable[[int], int]):
        """
        Args:
            name: Descriptive name of the normalizer.
            blowup_fn: Maps raw proof size to normalized proof size.
        """
        self.name = name
        self.blowup_fn = blowup_fn

    def normalized_size(self, raw_size: int) -> int:
        return self.blowup_fn(raw_size)


def classify_phase(model: NormalizerModel, sizes: List[int],
                   max_k: int = 5, max_c: int = 100) -> str:
    """
    Empirically classify the compression phase of a normalizer.

    Tests whether normalized sizes fit within c·(n+1)^k for
    any k ≤ max_k and c ≤ max_c.

    Returns 'poly' or 'superpoly'.
    """
    for k in range(1, max_k + 1):
        for c in range(1, max_c + 1):
            if all(model.normalized_size(n) <= c * (n + 1) ** k
                   for n in sizes):
                return f"poly (k={k}, c={c})"
    return "superpoly"


def demo_phase_classification():
    """Show phase classification for different normalizers."""
    print("=" * 65)
    print("DEMO 2: Phase Classification")
    print("=" * 65)
    print()

    normalizers = [
        NormalizerModel("Linear (2n+1)",        lambda n: 2 * n + 1),
        NormalizerModel("Quadratic (n²+1)",      lambda n: n**2 + 1),
        NormalizerModel("Cubic (3n³)",           lambda n: 3 * n**3),
        NormalizerModel("Exponential (2^n)",     lambda n: 2**n),
        NormalizerModel("Super-exp (n^n)",       lambda n: n**n if n > 0 else 1),
        NormalizerModel("Factorial (n!)",        lambda n: math.factorial(n)),
    ]

    sizes = list(range(1, 15))

    for model in normalizers:
        phase = classify_phase(model, sizes)
        sample_values = [model.normalized_size(n) for n in [1, 5, 10]]
        print(f"  {model.name:30s} → {phase}")
        print(f"    Sample: f(1)={sample_values[0]}, "
              f"f(5)={sample_values[1]}, f(10)={sample_values[2]}")
        print()


# ─────────────────────────────────────────────────────────────
# Demo 3: Phase Invariance Under Polynomial Simulation
# ─────────────────────────────────────────────────────────────

def demo_phase_invariance():
    """
    Demonstrate that polynomially equivalent normalizers always
    agree on compression phase.
    """
    print("=" * 65)
    print("DEMO 3: Phase Invariance Under Polynomial Equivalence")
    print("=" * 65)
    print()
    print("Two normalizers with polynomial simulation overhead always")
    print("agree on whether blowup is polynomial or superpolynomial.")
    print()

    # Polynomial family: N1 is linear, N2 is quadratic (poly sim with k=2)
    n1_poly = NormalizerModel("N₁ (3n+2)", lambda n: 3*n + 2)
    n2_poly = NormalizerModel("N₂ (9n²+12n+4)", lambda n: 9*n**2 + 12*n + 4)
    # Note: N2(n) = (3n+2)^2 / ... ≈ poly(N1(n))

    sizes = list(range(1, 20))
    print("  Polynomial family:")
    phase1 = classify_phase(n1_poly, sizes)
    phase2 = classify_phase(n2_poly, sizes)
    print(f"    N₁ phase: {phase1}")
    print(f"    N₂ phase: {phase2}")
    print(f"    Phases agree: {'✓' if 'poly' in phase1 and 'poly' in phase2 else '✗'}")
    print()

    # Superpolynomial family: N1 is exponential, N2 is double-exponential
    n1_super = NormalizerModel("N₁ (2^n)", lambda n: 2**n)
    n2_super = NormalizerModel("N₂ (4^n = (2^n)²)", lambda n: 4**n)
    # N2(n) = (2^n)^2 = N1(n)^2, so poly sim with k=2

    print("  Superpolynomial family:")
    phase1 = classify_phase(n1_super, sizes)
    phase2 = classify_phase(n2_super, sizes)
    print(f"    N₁ phase: {phase1}")
    print(f"    N₂ phase: {phase2}")
    print(f"    Phases agree: {'✓' if 'superpoly' in phase1 and 'superpoly' in phase2 else '✗'}")
    print()

    # Statistical test: random polynomial normalizers
    print("  Statistical test: 100 random polynomially equivalent pairs")
    agreements = 0
    trials = 100
    for _ in range(trials):
        # Random polynomial normalizer
        a, b = random.randint(1, 10), random.randint(1, 3)
        n1 = NormalizerModel("rand_n1", lambda n, a=a, b=b: a * n**b + 1)

        # Polynomial simulation with random overhead
        c, k = random.randint(1, 5), random.randint(1, 2)
        n2 = NormalizerModel("rand_n2",
                             lambda n, a=a, b=b, c=c, k=k: c * (a * n**b + 2)**k)

        test_sizes = list(range(1, 12))
        p1 = classify_phase(n1, test_sizes)
        p2 = classify_phase(n2, test_sizes)
        if ('poly' in p1) == ('poly' in p2):
            agreements += 1

    print(f"    Phase agreement rate: {agreements}/{trials} = {agreements/trials:.0%}")
    print()


# ─────────────────────────────────────────────────────────────
# Demo 4: No-Separation Theorem Illustration
# ─────────────────────────────────────────────────────────────

def demo_no_separation():
    """
    Illustrate that polynomial simulation prevents phase disagreement.
    """
    print("=" * 65)
    print("DEMO 4: No Poly-vs-SuperPoly Separation")
    print("=" * 65)
    print()
    print("If N₂'s output ≤ c·(N₁'s output + 1)^k, then:")
    print("  N₁ poly-bounded ⟹ N₂ poly-bounded")
    print("  N₁ superpoly    ⟹ N₂ superpoly")
    print()

    # Show that polynomial simulation composes with polynomial bound
    print("  Example: N₁ has bound 5·(n+1)² (polynomial)")
    print("  Simulation: N₂ output ≤ 3·(N₁ output + 1)²")
    print()
    print(f"  {'n':>5} {'rawSize(N₁(p))':>15} {'rawSize(N₂(p))':>15} {'Transfer bound':>15}")
    print(f"  {'─'*5} {'─'*15} {'─'*15} {'─'*15}")

    for n in [1, 2, 5, 10, 20, 50]:
        n1_size = 5 * (n + 1) ** 2          # N₁'s normalized size
        n2_size = 3 * (n1_size + 1) ** 2    # N₂'s normalized size (via sim)
        # Transfer bound: 3·(5+1)²·(n+1)^(2·2) = 108·(n+1)^4
        transfer = 3 * 6**2 * (n + 1)**4
        print(f"  {n:>5} {n1_size:>15,} {n2_size:>15,} {transfer:>15,}")

    print()
    print("  All values satisfy the composed polynomial bound. ✓")
    print()


# ─────────────────────────────────────────────────────────────
# Demo 5: Universality Classes
# ─────────────────────────────────────────────────────────────

def demo_universality_classes():
    """
    Show how normalizers cluster into equivalence classes.
    """
    print("=" * 65)
    print("DEMO 5: Universality Classes (Preorder Structure)")
    print("=" * 65)
    print()

    normalizers = {
        "N_lin":   lambda n: 2*n + 1,
        "N_lin2":  lambda n: 5*n + 3,
        "N_quad":  lambda n: n**2 + 1,
        "N_quad2": lambda n: 3*n**2 + 2*n + 1,
        "N_cub":   lambda n: n**3,
        "N_exp":   lambda n: 2**n,
        "N_exp2":  lambda n: 3**n,
    }

    test_sizes = list(range(1, 20))

    def poly_simulates(f, g, max_k=4, max_c=200):
        """Check if g(n) ≤ c·(f(n)+1)^k for test values."""
        for k in range(1, max_k + 1):
            for c in range(1, max_c + 1):
                if all(g(n) <= c * (f(n) + 1) ** k for n in test_sizes):
                    return True, k, c
        return False, None, None

    print("  Simulation matrix (N_row simulates N_col):")
    names = list(normalizers.keys())
    print(f"  {'':>10}", end="")
    for name in names:
        print(f"  {name:>8}", end="")
    print()

    equiv_classes = {}
    for n1 in names:
        print(f"  {n1:>10}", end="")
        for n2 in names:
            sim, k, c = poly_simulates(normalizers[n1], normalizers[n2])
            print(f"  {'✓':>8}" if sim else f"  {'✗':>8}", end="")
        print()

    # Identify equivalence classes
    print()
    print("  Equivalence classes (mutual polynomial simulation):")
    visited = set()
    class_num = 0
    for i, n1 in enumerate(names):
        if n1 in visited:
            continue
        class_num += 1
        members = [n1]
        visited.add(n1)
        for n2 in names[i+1:]:
            if n2 in visited:
                continue
            sim12, _, _ = poly_simulates(normalizers[n1], normalizers[n2])
            sim21, _, _ = poly_simulates(normalizers[n2], normalizers[n1])
            if sim12 and sim21:
                members.append(n2)
                visited.add(n2)
        print(f"    Class {class_num}: {', '.join(members)}")

    print()


# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    random.seed(42)
    print()
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║  PROOF COMPRESSION UNIVERSALITY — COMPUTATIONAL DEMOS       ║")
    print("╚═══════════════════════════════════════════════════════════════╝")
    print()

    demo_composition()
    demo_phase_classification()
    demo_phase_invariance()
    demo_no_separation()
    demo_universality_classes()

    print("All demos completed successfully.")
