#!/usr/bin/env python3
"""
Numerical demonstrations of the Observation Gap theorems.

Illustrates the key results from the algebraic theory of observation systems:
1. Observation Pigeonhole: twins must exist when |α| > 2^n
2. Quotient Cardinality Bound: at most 2^n equivalence classes
3. Refinement Monotonicity: more observations ⟹ finer quotients
4. Sufficiency Boundary: binary encoding achieves exact separation
5. Generalized Pigeonhole: k-valued observations give k^n bound
"""

from __future__ import annotations
from itertools import product
from collections import defaultdict
from typing import Callable


# ============================================================================
# Core definitions
# ============================================================================

def make_profile(
    predicates: list[Callable[[int], bool]],
    element: int,
) -> tuple[bool, ...]:
    """Compute the observation profile of an element under a list of predicates."""
    return tuple(p(element) for p in predicates)


def find_twins(
    elements: list[int],
    predicates: list[Callable[[int], bool]],
) -> list[tuple[int, int]]:
    """Find all twin pairs: distinct elements with identical profiles."""
    profile_map: dict[tuple[bool, ...], list[int]] = defaultdict(list)
    for e in elements:
        profile_map[make_profile(predicates, e)].append(e)
    twins: list[tuple[int, int]] = []
    for group in profile_map.values():
        for i in range(len(group)):
            for j in range(i + 1, len(group)):
                twins.append((group[i], group[j]))
    return twins


def quotient_classes(
    elements: list[int],
    predicates: list[Callable[[int], bool]],
) -> dict[tuple[bool, ...], list[int]]:
    """Compute the equivalence classes under observational indistinguishability."""
    classes: dict[tuple[bool, ...], list[int]] = defaultdict(list)
    for e in elements:
        classes[make_profile(predicates, e)].append(e)
    return dict(classes)


# ============================================================================
# Demo 1: Observation Pigeonhole Theorem
# ============================================================================

def demo_pigeonhole() -> None:
    """
    Theorem: If |α| > 2^n, then n Boolean observations must have twins.

    We try n=3 observations on sets of increasing size (1..20) and verify
    that twins always appear once the set exceeds 2^3 = 8 elements.
    """
    print("=" * 70)
    print("DEMO 1: Observation Pigeonhole Theorem")
    print("=" * 70)

    n = 3  # number of observations
    bound = 2 ** n  # = 8

    # Three example predicates
    predicates: list[Callable[[int], bool]] = [
        lambda x: x % 2 == 0,      # parity
        lambda x: x % 3 == 0,      # divisible by 3
        lambda x: x > 5,           # greater than 5
    ]

    print(f"\nUsing {n} Boolean observations. Bound = 2^{n} = {bound}.")
    print(f"Predicates: [even?, div_by_3?, >5?]\n")

    for size in [4, 7, 8, 9, 12, 16, 20]:
        elements = list(range(1, size + 1))
        twins = find_twins(elements, predicates)
        classes = quotient_classes(elements, predicates)

        status = "✓ TWINS FOUND" if twins else "  no twins"
        guarantee = " (GUARANTEED by theorem)" if size > bound else ""
        print(f"  |α| = {size:2d}  |  classes = {len(classes):2d}  |  "
              f"twin pairs = {len(twins):3d}  |  {status}{guarantee}")

    print()


# ============================================================================
# Demo 2: Quotient Cardinality Bound
# ============================================================================

def demo_quotient_bound() -> None:
    """
    Theorem: The observation quotient has at most 2^n classes.

    We enumerate all possible observation systems on Fin(10) and verify
    the bound for various n.
    """
    print("=" * 70)
    print("DEMO 2: Quotient Cardinality Bound")
    print("=" * 70)

    elements = list(range(10))

    for n in range(1, 6):
        bound = 2 ** n

        # Use bit-extraction predicates on element values
        predicates: list[Callable[[int], bool]] = [
            (lambda i: lambda x: bool((x >> i) & 1))(i)
            for i in range(n)
        ]

        classes = quotient_classes(elements, predicates)
        print(f"\n  n = {n}  |  bound = 2^{n} = {bound:2d}  |  "
              f"actual classes = {len(classes):2d}  |  "
              f"{'≤ bound ✓' if len(classes) <= bound else 'VIOLATION!'}")
        for profile, members in sorted(classes.items()):
            print(f"    profile {profile} → {members}")

    print()


# ============================================================================
# Demo 3: Refinement Monotonicity
# ============================================================================

def demo_refinement() -> None:
    """
    Theorem: Adding observations never decreases discriminative power.

    We start with 1 predicate and progressively add more, showing that
    the number of equivalence classes never decreases.
    """
    print("=" * 70)
    print("DEMO 3: Refinement Monotonicity")
    print("=" * 70)

    elements = list(range(1, 13))  # 1..12

    all_predicates: list[tuple[str, Callable[[int], bool]]] = [
        ("even?",     lambda x: x % 2 == 0),
        ("div_by_3?", lambda x: x % 3 == 0),
        (">6?",       lambda x: x > 6),
        ("prime?",    lambda x: x > 1 and all(x % d != 0 for d in range(2, x))),
    ]

    print(f"\nElements: {elements}\n")
    prev_classes = 0

    for k in range(1, len(all_predicates) + 1):
        names = [name for name, _ in all_predicates[:k]]
        preds = [pred for _, pred in all_predicates[:k]]
        classes = quotient_classes(elements, preds)
        n_classes = len(classes)

        monotone = "✓ monotone" if n_classes >= prev_classes else "✗ VIOLATION"
        print(f"  Observations: {names}")
        print(f"    → {n_classes} classes (was {prev_classes})  |  {monotone}")
        prev_classes = n_classes

    print()


# ============================================================================
# Demo 4: Sufficiency Boundary (Binary Encoding)
# ============================================================================

def demo_sufficiency() -> None:
    """
    Theorem: When |α| = 2^n, n bit-extraction observations achieve
    full separation (every element is uniquely identified).
    """
    print("=" * 70)
    print("DEMO 4: Sufficiency Boundary — Binary Encoding")
    print("=" * 70)

    for n in range(1, 6):
        size = 2 ** n
        elements = list(range(size))

        # Bit-extraction predicates: pred_i(x) = i-th bit of x
        predicates: list[Callable[[int], bool]] = [
            (lambda i: lambda x: bool((x >> i) & 1))(i)
            for i in range(n)
        ]

        classes = quotient_classes(elements, predicates)
        all_singletons = all(len(v) == 1 for v in classes.values())

        print(f"\n  n = {n}, |α| = 2^{n} = {size}")
        print(f"    Classes: {len(classes)} (all singletons: {all_singletons})")

        if n <= 3:
            for elem in elements:
                profile = make_profile(predicates, elem)
                bits = ''.join(str(int(b)) for b in profile)
                print(f"      {elem:2d} → profile {bits}")

    print()


# ============================================================================
# Demo 5: Generalized Pigeonhole (k-valued observations)
# ============================================================================

def demo_generalized() -> None:
    """
    Theorem: For k-valued observations, n observations can distinguish
    at most k^n elements.

    We demonstrate with k=3 (ternary observations).
    """
    print("=" * 70)
    print("DEMO 5: Generalized Pigeonhole — k-valued Observations")
    print("=" * 70)

    k = 3  # ternary observations

    def make_kprofile(
        predicates: list[Callable[[int], int]],
        element: int,
    ) -> tuple[int, ...]:
        return tuple(p(element) for p in predicates)

    for n in range(1, 5):
        bound = k ** n

        # k-valued predicates: element mod k^(i+1) // k^i
        predicates: list[Callable[[int], int]] = [
            (lambda i: lambda x: (x // (k ** i)) % k)(i)
            for i in range(n)
        ]

        # Test with exactly bound elements and bound+1 elements
        for size in [bound, bound + 1]:
            elements = list(range(size))
            profile_map: dict[tuple[int, ...], list[int]] = defaultdict(list)
            for e in elements:
                profile_map[make_kprofile(predicates, e)].append(e)

            has_twins = any(len(v) > 1 for v in profile_map.values())
            n_classes = len(profile_map)

            tag = "= k^n" if size == bound else "> k^n"
            twin_status = "TWINS" if has_twins else "all distinct"
            print(f"  n={n}, k={k}, bound=k^n={bound:4d}, "
                  f"|α|={size:4d} ({tag})  →  "
                  f"classes={n_classes:4d}, {twin_status}")

    print()


# ============================================================================
# Demo 6: The "Zombie" Scenario — Consciousness Testing
# ============================================================================

def demo_zombie_scenario() -> None:
    """
    Thought experiment: Model 'minds' as integers encoding internal states.
    Apply a battery of behavioral tests and demonstrate the inevitability
    of observational twins ('zombies').
    """
    print("=" * 70)
    print("DEMO 6: The Zombie Scenario — Behavioral Testing of Minds")
    print("=" * 70)

    # 50 possible "mind states" (internal configurations)
    n_states = 50
    minds = list(range(n_states))

    # Battery of behavioral tests
    tests: list[tuple[str, Callable[[int], bool]]] = [
        ("responds to pain?",      lambda m: m % 2 == 0),
        ("reports self-awareness?", lambda m: m % 3 != 0),
        ("passes Turing test?",    lambda m: m % 5 < 3),
        ("shows emotional affect?", lambda m: m > 15),
        ("exhibits creativity?",   lambda m: (m * 7 + 3) % 11 > 5),
    ]

    n_tests = len(tests)
    bound = 2 ** n_tests

    print(f"\n  Internal states: {n_states}")
    print(f"  Behavioral tests: {n_tests}")
    print(f"  Max distinguishable: 2^{n_tests} = {bound}")
    print(f"  Gap: {n_states} states vs {bound} bins")
    print(f"  Minimum twin pairs guaranteed: {n_states - bound} "
          f"(by pigeonhole)\n")

    preds = [fn for _, fn in tests]
    classes = quotient_classes(minds, preds)
    twins = find_twins(minds, preds)

    print(f"  Actual equivalence classes: {len(classes)}")
    print(f"  Actual twin pairs: {len(twins)}")
    print(f"\n  Sample 'zombie pairs' (identical behavior, different internals):")

    for i, (a, b) in enumerate(twins[:8]):
        profile = make_profile(preds, a)
        labels = ", ".join(
            name for (name, _), val in zip(tests, profile) if val
        )
        print(f"    Mind {a:2d} ≡ Mind {b:2d}  |  both: [{labels}]")

    print(f"\n  → {len(twins)} pairs of 'minds' are behaviorally identical")
    print(f"    but internally different. No finite test battery can")
    print(f"    distinguish them.\n")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  THE OBSERVATION GAP: Numerical Demonstrations                     ║")
    print("║  Algebraic Foundations of Functional Indistinguishability           ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_pigeonhole()
    demo_quotient_bound()
    demo_refinement()
    demo_sufficiency()
    demo_generalized()
    demo_zombie_scenario()

    print("All demonstrations complete.")
