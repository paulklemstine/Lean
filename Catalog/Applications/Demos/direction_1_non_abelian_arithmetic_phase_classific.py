#!/usr/bin/env python3
"""
Applications of the Derived Torsion Profile

Demonstrates real-world applications of the abelianization torsion
classification theorem and its failure:

1. Lattice Gauge Theory: Phase classification via abelianization
2. Projective Representation Theory: Schur multiplier as obstruction
3. Cryptographic Group Selection: Torsion profiles as distinguishers

Each application shows how the derived torsion profile provides
computable invariants for group-theoretic problems.
"""

from demo import (
    symmetric_group_3, alternating_group_4, quaternion_group_8,
    dihedral_group_4, klein_four, abelianization_orders,
    p_torsion_count, p_torsion_nontrivial, commutator_subgroup,
    generate_group, compose_perm as compose, inverse_perm as invert,
    identity_perm as identity, perm_order
)
from algorithms import (
    compute_derived_torsion_profile, compare_torsion_profiles,
    sieve_primes, prime_factors
)


# ──────────────────────────────────────────────────────────────────────
# Application 1: Lattice Gauge Theory Phase Classification
# ──────────────────────────────────────────────────────────────────────

def lattice_gauge_phase_classification():
    """
    In lattice gauge theory, the gauge group G determines the possible
    phases of the theory. The abelianization G^ab classifies the
    "abelian confinement phases" (degree-1), while the Schur multiplier
    M(G) classifies additional "topological order" phases (degree-2).
    
    Two gauge theories with the same abelianization have identical
    abelian confinement behavior, but may differ in their topological
    order — precisely when their Schur multipliers differ.
    
    This application computes the phase classification for several
    gauge groups commonly used in lattice gauge theory.
    """
    print("=" * 72)
    print("APPLICATION 1: Lattice Gauge Theory Phase Classification")
    print("=" * 72)
    print()
    
    groups_data = [
        (*quaternion_group_8(), "trivial"),
        (*dihedral_group_4(), "ℤ/2ℤ"),
        (*klein_four(), "ℤ/2ℤ"),
        (*symmetric_group_3(), "ℤ/2ℤ"),
    ]
    
    print("For each gauge group G, the phase structure is:")
    print("  - Abelian confinement phases ↔ torsion in G^ab (degree 1)")
    print("  - Topological order phases ↔ torsion in M(G) (degree 2)")
    print()
    
    profiles = []
    for elems, name, expected_order, schur in groups_data:
        info = compute_derived_torsion_profile(elems, name, schur)
        profiles.append(info)
        
        ab_orders = abelianization_orders(elems)
        
        print(f"  Gauge group: {name}")
        print(f"    |G| = {info.order}, G^ab ≅ {'×'.join(f'ℤ/{o}ℤ' for o in ab_orders if o > 1) or 'trivial'}")
        print(f"    Abelian phases: {len([o for o in ab_orders if o > 1])} nontrivial generators")
        print(f"    Topological order: M(G) = {schur}")
        
        if schur == "trivial":
            print(f"    → Abelianization COMPLETE for {name}-gauge theory")
        else:
            print(f"    → Abelianization INCOMPLETE: hidden topological order from M(G)")
        print()
    
    # Key comparison
    q8_info = profiles[0]
    d4_info = profiles[1]
    v4_info = profiles[2]
    
    print("  KEY INSIGHT:")
    print("  Q₈-gauge theory and D₄-gauge theory have the SAME abelian")
    print("  confinement behavior (both have G^ab ≅ (ℤ/2ℤ)²), but")
    print("  DIFFERENT topological order:")
    print(f"    M(Q₈) = {q8_info.schur_multiplier} → no extra topological phases")
    print(f"    M(D₄) = {d4_info.schur_multiplier} → one extra topological phase")
    print()


# ──────────────────────────────────────────────────────────────────────
# Application 2: Projective Representation Theory
# ──────────────────────────────────────────────────────────────────────

def projective_representation_classification():
    """
    The Schur multiplier M(G) = H₂(G, ℤ) classifies the projective
    representations of G up to equivalence. A projective representation
    is a homomorphism ρ: G → PGL(n, ℂ) that may not lift to GL(n, ℂ).
    
    The obstruction to lifting is an element of M(G). When M(G) = 0,
    all projective representations lift to genuine representations.
    When M(G) ≠ 0, there exist "essentially projective" representations.
    
    This application classifies the representation-theoretic complexity
    of several groups using their derived torsion profiles.
    """
    print("=" * 72)
    print("APPLICATION 2: Projective Representation Classification")
    print("=" * 72)
    print()
    
    groups = {
        "Q₈": ("trivial", "All projective reps lift to genuine reps"),
        "V₄": ("ℤ/2ℤ", "Has essentially projective reps (2-cocycle obstruction)"),
        "D₄": ("ℤ/2ℤ", "Has essentially projective reps (2-cocycle obstruction)"),
        "S₃": ("ℤ/2ℤ", "Has essentially projective reps (2-cocycle obstruction)"),
        "A₄": ("ℤ/2ℤ", "Has essentially projective reps (2-cocycle obstruction)"),
    }
    
    print("Projective representation classification:")
    print()
    print(f"{'Group':>6} | {'M(G)':>10} | {'Projective Reps':>50}")
    print("-" * 75)
    for name, (schur, desc) in groups.items():
        print(f"{name:>6} | {schur:>10} | {desc}")
    
    print()
    print("THEOREM (Schur): The number of inequivalent multiplier classes")
    print("for projective representations of G equals |M(G)|.")
    print()
    print("CONSEQUENCE:")
    print("  Q₈ has |M(Q₈)| = 1 multiplier class → all reps are genuine")
    print("  V₄ has |M(V₄)| = 2 multiplier classes → one genuine, one projective")
    print()
    print("  Despite Q₈^ab ≅ V₄^ab, their representation theories DIFFER")
    print("  at the projective level. The Schur multiplier captures this.")
    print()


# ──────────────────────────────────────────────────────────────────────
# Application 3: Group Distinguishing via Torsion
# ──────────────────────────────────────────────────────────────────────

def group_distinguishing():
    """
    Given two finite groups presented as permutation groups,
    determine whether they can be distinguished by their derived
    torsion profiles. This is a polynomial-time computable invariant
    that is strictly finer than abelianization alone.
    """
    print("=" * 72)
    print("APPLICATION 3: Group Distinguishing via Torsion Profiles")
    print("=" * 72)
    print()
    
    all_groups = [
        (*symmetric_group_3(), "ℤ/2ℤ"),
        (*alternating_group_4(), "ℤ/2ℤ"),
        (*quaternion_group_8(), "trivial"),
        (*dihedral_group_4(), "ℤ/2ℤ"),
        (*klein_four(), "ℤ/2ℤ"),
    ]
    
    profiles = []
    for elems, name, expected, schur in all_groups:
        info = compute_derived_torsion_profile(elems, name, schur)
        profiles.append(info)
    
    names = [p.name for p in profiles]
    
    print("Pairwise comparison matrix (✓ = distinguished, ✗ = identical profile):")
    print()
    print(f"{'':>6}", end="")
    for n in names:
        print(f" | {n:>6}", end="")
    print()
    print("-" * (8 + 9 * len(names)))
    
    for i, g1 in enumerate(profiles):
        print(f"{g1.name:>6}", end="")
        for j, g2 in enumerate(profiles):
            if i == j:
                print(f" | {'—':>6}", end="")
            else:
                cmp = compare_torsion_profiles(g1, g2)
                if cmp['full_profile_match']:
                    symbol = "✗"
                elif not cmp['abelianization_isomorphic']:
                    symbol = "✓(ab)"
                elif not cmp['schur_multiplier_match']:
                    symbol = "✓(M)"
                else:
                    symbol = "✓"
                print(f" | {symbol:>6}", end="")
        print()
    
    print()
    print("Legend:")
    print("  ✓(ab) = Distinguished by abelianization alone (degree 1)")
    print("  ✓(M)  = Same abelianization, distinguished by Schur multiplier (degree 2)")
    print("  ✗     = Identical derived torsion profile")
    print()
    
    # Count distinguishing power
    total_pairs = len(profiles) * (len(profiles) - 1) // 2
    ab_distinguished = 0
    schur_distinguished = 0
    
    for i in range(len(profiles)):
        for j in range(i + 1, len(profiles)):
            cmp = compare_torsion_profiles(profiles[i], profiles[j])
            if not cmp['abelianization_isomorphic']:
                ab_distinguished += 1
                schur_distinguished += 1
            elif not cmp['schur_multiplier_match']:
                schur_distinguished += 1
    
    print(f"Distinguishing power:")
    print(f"  Abelianization alone: {ab_distinguished}/{total_pairs} pairs")
    print(f"  With Schur multiplier: {schur_distinguished}/{total_pairs} pairs")
    print(f"  Improvement: +{schur_distinguished - ab_distinguished} pairs distinguished")
    print()


# ──────────────────────────────────────────────────────────────────────
# Application 4: Exponent Analysis
# ──────────────────────────────────────────────────────────────────────

def exponent_analysis():
    """
    Analyze how the exponent of G relates to the exponent of G^ab.
    The exponent of G^ab always divides the exponent of G, but the
    converse fails for non-abelian groups.
    """
    print("=" * 72)
    print("APPLICATION 4: Exponent Analysis (G vs G^ab)")
    print("=" * 72)
    print()
    
    all_groups = [
        symmetric_group_3(),
        alternating_group_4(),
        quaternion_group_8(),
        dihedral_group_4(),
        klein_four(),
    ]
    
    print(f"{'Group':>6} | {'exp(G)':>7} | {'exp(G^ab)':>9} | {'Divides?':>8} | {'Ratio':>6}")
    print("-" * 50)
    
    for elems, name, _ in all_groups:
        # Compute exponent of G
        exp_g = max(perm_order(g) for g in elems)
        
        # Compute exponent of G^ab
        ab_orders = abelianization_orders(elems)
        exp_ab = max(ab_orders)
        
        divides = exp_g % exp_ab == 0
        ratio = exp_g // exp_ab if exp_ab > 0 else "∞"
        
        print(f"{name:>6} | {exp_g:>7} | {exp_ab:>9} | {'Yes' if divides else 'No':>8} | {ratio:>6}")
    
    print()
    print("THEOREM: exp(G^ab) always divides exp(G).")
    print("NOTE: The ratio exp(G)/exp(G^ab) measures 'hidden exponent'")
    print("      contributed by the commutator subgroup [G,G].")
    print()


# ──────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────

def main():
    lattice_gauge_phase_classification()
    print()
    projective_representation_classification()
    print()
    group_distinguishing()
    print()
    exponent_analysis()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Derived Torsion Profile Computation Demo

Demonstrates the abelianization torsion completeness theorem and its failure
for specific finite groups: S₃, A₄, Q₈, D₄, and V₄.

Key insight: Two groups can have isomorphic abelianizations yet differ in
higher torsion structure (Schur multiplier). The demo computes:
  - Group order and structure
  - Abelianization (G/[G,G])
  - p-torsion profile of the abelianization
  - Schur multiplier H₂(G, ℤ) (known values from literature)
"""

from itertools import product as cartesian_product
from collections import Counter
from math import gcd
from functools import reduce


# ──────────────────────────────────────────────────────────────────────
# Finite Group Representations
# ──────────────────────────────────────────────────────────────────────

def identity_perm(n: int) -> tuple:
    return tuple(range(n))

def compose_perm(a: tuple, b: tuple) -> tuple:
    """Compose permutations: (a ∘ b)(i) = a(b(i))."""
    return tuple(a[b[i]] for i in range(len(a)))

def inverse_perm(a: tuple) -> tuple:
    n = len(a)
    inv = [0] * n
    for i in range(n):
        inv[a[i]] = i
    return tuple(inv)

def perm_order(a: tuple) -> int:
    """Order of a permutation."""
    e = identity_perm(len(a))
    x = a
    for k in range(1, len(a) + 100):
        if x == e:
            return k
        x = compose_perm(x, a)
    return -1


def generate_group(generators: list[tuple], n: int) -> list[tuple]:
    """Generate a group from permutation generators via closure."""
    e = identity_perm(n)
    elements = {e}
    queue = [e] + list(generators)
    elements.update(generators)
    idx = 0
    while idx < len(queue):
        g = queue[idx]
        idx += 1
        for gen in generators:
            for h in [compose_perm(g, gen), compose_perm(gen, g),
                       compose_perm(g, inverse_perm(gen)),
                       compose_perm(inverse_perm(gen), g)]:
                if h not in elements:
                    elements.add(h)
                    queue.append(h)
    return sorted(elements)


def commutator(a: tuple, b: tuple) -> tuple:
    """[a, b] = a b a⁻¹ b⁻¹"""
    return compose_perm(compose_perm(a, b),
                        compose_perm(inverse_perm(a), inverse_perm(b)))


def commutator_subgroup(group: list[tuple]) -> set:
    """Compute [G, G] = subgroup generated by all commutators."""
    n = len(group[0])
    comms = set()
    for a in group:
        for b in group:
            comms.add(commutator(a, b))
    # Generate the subgroup
    subgrp = set(comms)
    changed = True
    while changed:
        changed = False
        new = set()
        for a in subgrp:
            for b in comms:
                for h in [compose_perm(a, b), compose_perm(b, a),
                          compose_perm(a, inverse_perm(b))]:
                    if h not in subgrp:
                        new.add(h)
        if new:
            subgrp.update(new)
            changed = True
    return subgrp


def abelianization_orders(group: list[tuple]) -> list[int]:
    """Compute the abelianization G/[G,G] and return element orders."""
    comm = commutator_subgroup(group)
    n = len(group[0])
    e = identity_perm(n)
    # Compute cosets
    cosets = {}
    for g in group:
        # Find which coset g belongs to
        found = False
        for rep in cosets:
            diff = compose_perm(inverse_perm(rep), g)
            if diff in comm:
                cosets[rep].append(g)
                found = True
                break
        if not found:
            cosets[g] = [g]
    
    # Compute orders of coset representatives in the quotient
    coset_reps = list(cosets.keys())
    orders = []
    for rep in coset_reps:
        # Find order of rep in G/[G,G]
        power = rep
        for k in range(1, len(group) + 1):
            if power in comm:
                orders.append(k)
                break
            power = compose_perm(power, rep)
    
    return sorted(orders)


def p_torsion_count(orders: list[int], p: int) -> int:
    """Count elements with order dividing p (i.e., x^p = 1)."""
    return sum(1 for o in orders if o > 0 and p % o == 0)


def p_torsion_nontrivial(orders: list[int], p: int) -> int:
    """Count nontrivial p-torsion elements (order dividing p, not identity)."""
    return sum(1 for o in orders if 1 < o and o <= p and p % o == 0)


# ──────────────────────────────────────────────────────────────────────
# Specific Groups
# ──────────────────────────────────────────────────────────────────────

def symmetric_group_3():
    """S₃ as permutations of {0, 1, 2}."""
    s = (1, 0, 2)  # transposition (0 1)
    r = (1, 2, 0)  # 3-cycle (0 1 2)
    return generate_group([s, r], 3), "S₃", 6

def alternating_group_4():
    """A₄ as permutations of {0, 1, 2, 3}."""
    r = (1, 2, 0, 3)  # (0 1 2)
    s = (1, 0, 3, 2)  # (0 1)(2 3)
    return generate_group([r, s], 4), "A₄", 12

def quaternion_group_8():
    """Q₈ as permutations of {0, ..., 7}.
    Embedding: 1→e, i→(0 1 2 3)(4 5 6 7), j→(0 4 2 6)(1 7 3 5), k→(0 5 2 7)(1 4 3 6)"""
    i = (1, 2, 3, 0, 5, 6, 7, 4)
    j = (4, 7, 6, 5, 2, 1, 0, 3)
    return generate_group([i, j], 8), "Q₈", 8

def dihedral_group_4():
    """D₄ (dihedral group of order 8) as permutations of vertices of a square."""
    r = (1, 2, 3, 0)  # rotation by 90°
    s = (0, 3, 2, 1)  # reflection
    return generate_group([r, s], 4), "D₄", 8

def klein_four():
    """V₄ = ℤ/2ℤ × ℤ/2ℤ as permutations."""
    a = (1, 0, 2, 3)  # (0 1)
    b = (0, 1, 3, 2)  # (2 3)
    return generate_group([a, b], 4), "V₄", 4


# Known Schur multipliers from the literature
SCHUR_MULTIPLIERS = {
    "S₃": "ℤ/2ℤ",
    "A₄": "ℤ/2ℤ",
    "Q₈": "trivial",
    "D₄": "ℤ/2ℤ",
    "V₄": "ℤ/2ℤ",
}


# ──────────────────────────────────────────────────────────────────────
# Main Demo
# ──────────────────────────────────────────────────────────────────────

def main():
    print("=" * 72)
    print("DERIVED TORSION PROFILE COMPUTATION")
    print("Abelianization Completeness and Its Failure")
    print("=" * 72)
    print()

    groups = [
        symmetric_group_3(),
        alternating_group_4(),
        quaternion_group_8(),
        dihedral_group_4(),
        klein_four(),
    ]

    results = {}
    
    for group_elems, name, expected_order in groups:
        print(f"── {name} ({'|G| = ' + str(len(group_elems))}) ──")
        
        if len(group_elems) != expected_order:
            print(f"  WARNING: Expected order {expected_order}, got {len(group_elems)}")
        
        comm = commutator_subgroup(group_elems)
        ab_orders = abelianization_orders(group_elems)
        ab_size = len(ab_orders)
        comm_size = len(comm)
        
        print(f"  |G|           = {len(group_elems)}")
        print(f"  |[G,G]|       = {comm_size}")
        print(f"  |G^ab|        = {ab_size}")
        print(f"  G^ab orders   = {ab_orders}")
        
        # p-torsion profile for primes 2, 3, 5
        print(f"  p-torsion profile of G^ab:")
        for p in [2, 3, 5]:
            count = p_torsion_count(ab_orders, p)
            nontrivial = p_torsion_nontrivial(ab_orders, p)
            has_torsion = nontrivial > 0
            print(f"    p={p}: {count} elements with x^{p}=1 "
                  f"({nontrivial} nontrivial) → "
                  f"{'HAS' if has_torsion else 'NO'} {p}-torsion")
        
        # Schur multiplier (known values)
        schur = SCHUR_MULTIPLIERS.get(name, "unknown")
        print(f"  Schur mult.   = M(G) = {schur}")
        
        results[name] = {
            "order": len(group_elems),
            "commutator_order": comm_size,
            "abelianization_order": ab_size,
            "abelianization_element_orders": ab_orders,
            "schur_multiplier": schur,
        }
        print()

    # ── The Q₈ vs V₄ Counterexample ──
    print("=" * 72)
    print("THE Q₈ vs V₄ COUNTEREXAMPLE")
    print("=" * 72)
    print()
    
    q8 = results["Q₈"]
    v4 = results["V₄"]
    
    print("Q₈ and V₄ comparison:")
    print(f"  Q₈^ab orders = {q8['abelianization_element_orders']}")
    print(f"  V₄^ab orders = {v4['abelianization_element_orders']}")
    
    q8_ab = sorted(q8['abelianization_element_orders'])
    v4_ab = sorted(v4['abelianization_element_orders'])
    
    ab_match = q8_ab == v4_ab
    print(f"  Abelianizations isomorphic? {ab_match}")
    print(f"  (Both are (ℤ/2ℤ)² with elements of orders {q8_ab})")
    print()
    print(f"  Schur multiplier of Q₈: {q8['schur_multiplier']}")
    print(f"  Schur multiplier of V₄: {v4['schur_multiplier']}")
    print()
    
    if q8['schur_multiplier'] != v4['schur_multiplier']:
        print("  ✓ COUNTEREXAMPLE CONFIRMED:")
        print("    Q₈ and V₄ have isomorphic abelianizations")
        print("    but DIFFERENT Schur multipliers.")
        print("    → Abelianization is INCOMPLETE for degree-2 torsion.")
    print()

    # ── The D₄ vs Q₈ Comparison ──
    print("=" * 72)
    print("THE D₄ vs Q₈ COMPARISON")
    print("=" * 72)
    print()
    
    d4 = results["D₄"]
    print(f"  D₄^ab orders = {d4['abelianization_element_orders']}")
    print(f"  Q₈^ab orders = {q8['abelianization_element_orders']}")
    
    d4_ab = sorted(d4['abelianization_element_orders'])
    ab_match_dq = d4_ab == q8_ab
    print(f"  Abelianizations isomorphic? {ab_match_dq}")
    print(f"  Schur multiplier of D₄: {d4['schur_multiplier']}")
    print(f"  Schur multiplier of Q₈: {q8['schur_multiplier']}")
    print()
    if d4['schur_multiplier'] != q8['schur_multiplier']:
        print("  ✓ D₄ and Q₈ have isomorphic abelianizations")
        print("    but DIFFERENT Schur multipliers.")
        print("    → Another instance of abelianization incompleteness.")
    print()

    # ── Summary Table ──
    print("=" * 72)
    print("DERIVED TORSION PROFILE SUMMARY TABLE")
    print("=" * 72)
    print()
    print(f"{'Group':>6} | {'|G|':>4} | {'|G^ab|':>6} | {'2-tor':>5} | {'3-tor':>5} | {'M(G)':>10}")
    print("-" * 55)
    for name in ["S₃", "A₄", "Q₈", "D₄", "V₄"]:
        r = results[name]
        orders = r['abelianization_element_orders']
        t2 = p_torsion_nontrivial(orders, 2)
        t3 = p_torsion_nontrivial(orders, 3)
        print(f"{name:>6} | {r['order']:>4} | {r['abelianization_order']:>6} | "
              f"{t2:>5} | {t3:>5} | {r['schur_multiplier']:>10}")
    
    print()
    print("Key: '2-tor' = nontrivial 2-torsion elements in G^ab")
    print("     '3-tor' = nontrivial 3-torsion elements in G^ab")
    print("     'M(G)' = Schur multiplier H₂(G, ℤ)")
    print()
    print("THEOREM (Degree-1 Completeness):")
    print("  Groups with isomorphic G^ab have identical p-torsion profiles")
    print("  at degree 1 (first row of each pair agrees).")
    print()
    print("THEOREM (Degree-2 Incompleteness):")
    print("  Q₈^ab ≅ V₄^ab ≅ (ℤ/2ℤ)², but M(Q₈) = 0 ≠ ℤ/2ℤ = M(V₄).")
    print("  The Schur multiplier captures strictly more information.")


if __name__ == "__main__":
    main()
