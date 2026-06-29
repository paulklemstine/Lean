#!/usr/bin/env python3
"""
Proof-Congruence Automata: Concrete Numerical Demonstrations

This demo illustrates the key mathematical concepts from the Lean 4 formalization:
1. Contextual collapse theorem (contextualRel ≡ equality)
2. Observational equivalence and Myhill-Nerode quotients
3. Prime spectral separation
4. Automaton minimization with state count bounds

All examples use finite semirings (integers mod n) for computability.
"""

import itertools
from collections import defaultdict
from typing import Set, Tuple, Dict, List

# =============================================================================
# Section 1: Finite Semiring Z/nZ
# =============================================================================

class ZMod:
    """The semiring Z/nZ (integers modulo n)."""

    def __init__(self, n: int):
        self.n = n
        self.elements = list(range(n))

    def add(self, a: int, b: int) -> int:
        return (a + b) % self.n

    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.n

    def zero(self) -> int:
        return 0

    def one(self) -> int:
        return 1

# =============================================================================
# Section 2: Contextual Relation and Collapse
# =============================================================================

def contextual_rel(S: ZMod, x: int, y: int) -> bool:
    """Check if x ≡ y contextually: ∀ a b, a*x*b = a*y*b."""
    for a in S.elements:
        for b in S.elements:
            if S.mul(S.mul(a, x), b) != S.mul(S.mul(a, y), b):
                return False
    return True

def demo_contextual_collapse():
    """Demonstrate that contextualRel = equality (contextualRel_iff_eq)."""
    print("=" * 60)
    print("DEMO 1: Contextual Collapse Theorem")
    print("contextualRel(x, y) ⟺ x = y")
    print("=" * 60)

    for n in [2, 3, 5, 6]:
        S = ZMod(n)
        all_collapse = True
        for x in S.elements:
            for y in S.elements:
                cr = contextual_rel(S, x, y)
                eq = (x == y)
                if cr != eq:
                    all_collapse = False
                    print(f"  COUNTEREXAMPLE in Z/{n}Z: contextualRel({x},{y})={cr}, x=y is {eq}")

        if all_collapse:
            print(f"  Z/{n}Z: ✓ contextualRel = equality (verified for all {n*n} pairs)")

    print()

# =============================================================================
# Section 3: Observational Equivalence
# =============================================================================

def observational_equiv(S: ZMod, L: Set[int], x: int, y: int) -> bool:
    """Check if x ≡_L y: ∀ a b, a*x*b ∈ L ⟺ a*y*b ∈ L."""
    for a in S.elements:
        for b in S.elements:
            axb = S.mul(S.mul(a, x), b)
            ayb = S.mul(S.mul(a, y), b)
            if (axb in L) != (ayb in L):
                return False
    return True

def compute_obs_classes(S: ZMod, L: Set[int]) -> Dict[int, int]:
    """Compute observational equivalence classes."""
    class_of = {}
    next_class = 0
    for x in S.elements:
        found = False
        for y in class_of:
            if observational_equiv(S, L, x, y):
                class_of[x] = class_of[y]
                found = True
                break
        if not found:
            class_of[x] = next_class
            next_class += 1
    return class_of

def demo_observational_equivalence():
    """Demonstrate observational equivalence and Myhill-Nerode quotients."""
    print("=" * 60)
    print("DEMO 2: Observational Equivalence (Myhill-Nerode)")
    print("x ≡_L y ⟺ ∀ a b, a*x*b ∈ L ↔ a*y*b ∈ L")
    print("=" * 60)

    S = ZMod(6)

    # Language 1: multiples of 2
    L1 = {0, 2, 4}
    classes1 = compute_obs_classes(S, L1)
    n_classes1 = len(set(classes1.values()))
    print(f"\n  Z/6Z, L = {{0,2,4}} (multiples of 2):")
    print(f"  Observational classes: {n_classes1}")
    by_class = defaultdict(list)
    for x, c in sorted(classes1.items()):
        by_class[c].append(x)
    for c, members in sorted(by_class.items()):
        print(f"    Class {c}: {members}")

    # Language 2: multiples of 3
    L2 = {0, 3}
    classes2 = compute_obs_classes(S, L2)
    n_classes2 = len(set(classes2.values()))
    print(f"\n  Z/6Z, L = {{0,3}} (multiples of 3):")
    print(f"  Observational classes: {n_classes2}")
    by_class = defaultdict(list)
    for x, c in sorted(classes2.items()):
        by_class[c].append(x)
    for c, members in sorted(by_class.items()):
        print(f"    Class {c}: {members}")

    # Language 3: just {0}
    L3 = {0}
    classes3 = compute_obs_classes(S, L3)
    n_classes3 = len(set(classes3.values()))
    print(f"\n  Z/6Z, L = {{0}} (just zero):")
    print(f"  Observational classes: {n_classes3}")
    by_class = defaultdict(list)
    for x, c in sorted(classes3.items()):
        by_class[c].append(x)
    for c, members in sorted(by_class.items()):
        print(f"    Class {c}: {members}")

    # Language 4: empty set (universal equivalence)
    L4: Set[int] = set()
    classes4 = compute_obs_classes(S, L4)
    n_classes4 = len(set(classes4.values()))
    print(f"\n  Z/6Z, L = ∅ (empty):")
    print(f"  Observational classes: {n_classes4} (all equivalent, as proved in observationalEquiv_empty_universal)")

    # Language 5: everything (universal equivalence)
    L5 = set(S.elements)
    classes5 = compute_obs_classes(S, L5)
    n_classes5 = len(set(classes5.values()))
    print(f"\n  Z/6Z, L = Z/6Z (everything):")
    print(f"  Observational classes: {n_classes5} (all equivalent, as proved in observationalEquiv_univ_universal)")

    print()

# =============================================================================
# Section 4: Multiplicative Compatibility
# =============================================================================

def demo_mul_compatibility():
    """Demonstrate elimination_shadow_refinement: ≡_L is mul-compatible."""
    print("=" * 60)
    print("DEMO 3: Multiplicative Compatibility (elimination_shadow_refinement)")
    print("x ≡_L y ∧ z ≡_L w ⟹ x*z ≡_L y*w")
    print("=" * 60)

    S = ZMod(6)
    L = {0, 2, 4}
    classes = compute_obs_classes(S, L)

    violations = 0
    checks = 0
    for x in S.elements:
        for y in S.elements:
            if not observational_equiv(S, L, x, y):
                continue
            for z in S.elements:
                for w in S.elements:
                    if not observational_equiv(S, L, z, w):
                        continue
                    checks += 1
                    xz = S.mul(x, z)
                    yw = S.mul(y, w)
                    if not observational_equiv(S, L, xz, yw):
                        violations += 1

    print(f"  Checked {checks} quadruples (x,y,z,w) with x≡y and z≡w")
    print(f"  Violations of x*z ≡ y*w: {violations}")
    print(f"  ✓ Multiplicative compatibility verified!" if violations == 0 else "  ✗ VIOLATION FOUND!")
    print()

# =============================================================================
# Section 5: Entropy Bounds
# =============================================================================

def demo_entropy_bounds():
    """Demonstrate thermodynamic_proof_entropy_monotone: |S/≡| ≤ |S|."""
    print("=" * 60)
    print("DEMO 4: Entropy Bounds (thermodynamic_proof_entropy_monotone)")
    print("|S/≡_L| ≤ |S| for all languages L")
    print("=" * 60)

    for n in [4, 5, 6, 7, 8]:
        S = ZMod(n)
        max_classes = 0
        max_L = set()

        # Sample random languages to find max quotient size
        for subset_bits in range(2**n):
            L = {i for i in range(n) if (subset_bits >> i) & 1}
            classes = compute_obs_classes(S, L)
            nc = len(set(classes.values()))
            if nc > max_classes:
                max_classes = nc
                max_L = L

        print(f"  Z/{n}Z: max |S/≡_L| = {max_classes} ≤ {n} = |S|  "
              f"(achieved by L = {max_L})")

    print()

# =============================================================================
# Section 6: Prime Congruence Separation
# =============================================================================

def demo_prime_separation():
    """Demonstrate prime_spectrum_whispers_inequivalence."""
    print("=" * 60)
    print("DEMO 5: Prime Spectral Separation")
    print("Prime congruences separate observationally inequivalent elements")
    print("=" * 60)

    # Work in Z/6Z
    S = ZMod(6)

    # Define "vanishing at P" as "≡ 0 mod p" for prime p
    # This gives prime congruences from the factorization 6 = 2 × 3
    primes = [2, 3]

    print(f"\n  Z/6Z with prime congruences from p = 2 and p = 3:")
    print(f"  Element | vanishes mod 2 | vanishes mod 3 | observational class (L={'{0}'})")

    L = {0}
    classes = compute_obs_classes(S, L)

    for x in S.elements:
        v2 = (x % 2 == 0)
        v3 = (x % 3 == 0)
        print(f"    {x}      |      {v2!s:5}      |      {v3!s:5}      |    {classes[x]}")

    # Check separation: different obs classes → separated by some prime
    print(f"\n  Separation check:")
    for x in S.elements:
        for y in range(x+1, S.n):
            if classes[x] != classes[y]:
                # Find a separating prime
                for p in primes:
                    if (x % p == 0) != (y % p == 0):
                        print(f"    {x} ≢ {y}: separated by prime p={p} "
                              f"(vanishes at {x}: {x%p==0}, at {y}: {y%p==0})")
                        break

    print()

# =============================================================================
# Section 7: Tropical Entropy Example
# =============================================================================

def demo_tropical():
    """Demonstrate tropical entropy bound."""
    print("=" * 60)
    print("DEMO 6: Tropical Entropy Bound")
    print("bit_bound ≤ n² + 1 (post_quantum_state_compression_bound)")
    print("=" * 60)

    for n in [2, 3, 4, 5, 10, 100]:
        bit_bound = n * n + 1
        print(f"  n = {n:3d} states → bit bound = {bit_bound:6d} = {n}² + 1")

    print()

# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("PROOF-CONGRUENCE AUTOMATA: NUMERICAL DEMONSTRATIONS")
    print("Companion to Lean 4 formalization in")
    print("Bridges/ProofCongruenceAutomata.lean")
    print("=" * 60 + "\n")

    demo_contextual_collapse()
    demo_observational_equivalence()
    demo_mul_compatibility()
    demo_entropy_bounds()
    demo_prime_separation()
    demo_tropical()

    print("=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)
