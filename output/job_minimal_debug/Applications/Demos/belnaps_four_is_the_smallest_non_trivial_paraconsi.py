#!/usr/bin/env python3
"""
Berggren Tree of Primitive Pythagorean Triples — Numerical Demonstrations

This script demonstrates the key results verified in
Catalog/Bridges/BerggrenLatticeReduction/Core.lean:

1. The three Berggren matrices preserve the Pythagorean equation a² + b² = c².
2. Each step preserves positivity, coprimality, and parity orientation.
3. The hypotenuse strictly increases at every step.
4. The tree generates distinct primitive triples from (3, 4, 5).
"""

from __future__ import annotations

from math import gcd
from typing import NamedTuple


class PrimitiveTriple(NamedTuple):
    """A primitive Pythagorean triple (a, b, c) with a odd."""
    a: int
    b: int
    c: int


def is_primitive_triple(t: PrimitiveTriple) -> bool:
    """Check all five defining properties of a primitive Pythagorean triple."""
    a, b, c = t
    return (
        a**2 + b**2 == c**2  # Pythagorean equation
        and a > 0 and b > 0 and c > 0  # positivity
        and gcd(a, b) == 1  # coprimality
        and a % 2 == 1  # odd orientation
    )


def berggren_left(t: PrimitiveTriple) -> PrimitiveTriple:
    """Apply the left Berggren step."""
    a, b, c = t
    return PrimitiveTriple(
        a - 2 * b + 2 * c,
        2 * a - b + 2 * c,
        2 * a - 2 * b + 3 * c,
    )


def berggren_mid(t: PrimitiveTriple) -> PrimitiveTriple:
    """Apply the middle Berggren step."""
    a, b, c = t
    return PrimitiveTriple(
        a + 2 * b + 2 * c,
        2 * a + b + 2 * c,
        2 * a + 2 * b + 3 * c,
    )


def berggren_right(t: PrimitiveTriple) -> PrimitiveTriple:
    """Apply the right Berggren step."""
    a, b, c = t
    return PrimitiveTriple(
        -a + 2 * b + 2 * c,
        -2 * a + b + 2 * c,
        -2 * a + 2 * b + 3 * c,
    )


BERGGREN_STEPS = {
    "left": berggren_left,
    "mid": berggren_mid,
    "right": berggren_right,
}

ROOT = PrimitiveTriple(3, 4, 5)


# ============================================================
# Demo 1: Invariant preservation for the first few levels
# ============================================================

def demo_invariant_preservation() -> None:
    """Demonstrate that all Berggren steps preserve primitive triple properties."""
    print("=" * 70)
    print("DEMO 1: Invariant Preservation")
    print("=" * 70)
    print()

    queue: list[tuple[PrimitiveTriple, str]] = [(ROOT, "root")]
    visited: list[tuple[str, PrimitiveTriple]] = []

    # Generate 3 levels of the tree (1 + 3 + 9 + 27 = 40 nodes)
    for depth in range(3):
        next_queue: list[tuple[PrimitiveTriple, str]] = []
        for triple, path in queue:
            visited.append((path, triple))
            for name, step_fn in BERGGREN_STEPS.items():
                child = step_fn(triple)
                child_path = f"{path}.{name}"
                next_queue.append((child, child_path))
        queue = next_queue

    # Check invariants for all visited triples
    all_ok = True
    for path, triple in visited:
        ok = is_primitive_triple(triple)
        if not ok:
            print(f"  FAIL: {path} -> {triple}")
            all_ok = False

    print(f"  Checked {len(visited)} triples across 3 levels of the tree.")
    print(f"  All primitive triple invariants preserved: {all_ok}")
    print()


# ============================================================
# Demo 2: Hypotenuse strict increase
# ============================================================

def demo_hypotenuse_monotonicity() -> None:
    """Demonstrate that c strictly increases at every Berggren step."""
    print("=" * 70)
    print("DEMO 2: Hypotenuse Strict Increase (berggren_c_strict_increase)")
    print("=" * 70)
    print()

    # Show a long path down the tree
    t = ROOT
    path_steps = ["left", "right", "mid", "left", "right", "mid", "left", "mid"]

    print(f"  {'Step':<8} {'Triple':>25}  {'c':>8}  {'c increased?':>14}")
    print(f"  {'----':<8} {'------':>25}  {'---':>8}  {'-----------':>14}")
    prev_c = 0
    print(f"  {'root':<8} {str(tuple(t)):>25}  {t.c:>8}  {'(start)':>14}")
    prev_c = t.c

    for step_name in path_steps:
        step_fn = BERGGREN_STEPS[step_name]
        t = step_fn(t)
        increased = t.c > prev_c
        print(f"  {step_name:<8} {str(tuple(t)):>25}  {t.c:>8}  {str(increased):>14}")
        assert increased, f"Hypotenuse did not increase at step {step_name}!"
        prev_c = t.c

    print()
    print(f"  Hypotenuse grew from 5 to {t.c} over {len(path_steps)} steps.")
    print()


# ============================================================
# Demo 3: Parity and coprimality
# ============================================================

def demo_parity_coprimality() -> None:
    """Show parity (a odd, b even, c odd) and coprimality for generated triples."""
    print("=" * 70)
    print("DEMO 3: Parity and Coprimality")
    print("=" * 70)
    print()

    # Generate all triples at depth 3
    def generate_tree(t: PrimitiveTriple, depth: int) -> list[PrimitiveTriple]:
        if depth == 0:
            return [t]
        result = [t]
        for step_fn in BERGGREN_STEPS.values():
            result.extend(generate_tree(step_fn(t), depth - 1))
        return result

    triples = generate_tree(ROOT, 4)
    print(f"  Generated {len(triples)} triples (depth ≤ 4).")
    print()

    print(f"  {'Triple':>25}  {'a odd':>7}  {'b even':>7}  {'c odd':>7}  {'gcd(a,b)':>9}")
    print(f"  {'------':>25}  {'-----':>7}  {'------':>7}  {'-----':>7}  {'--------':>9}")

    # Show first 15 triples
    for t in triples[:15]:
        print(
            f"  {str(tuple(t)):>25}"
            f"  {str(t.a % 2 == 1):>7}"
            f"  {str(t.b % 2 == 0):>7}"
            f"  {str(t.c % 2 == 1):>7}"
            f"  {gcd(t.a, t.b):>9}"
        )
    print(f"  ... ({len(triples) - 15} more triples omitted)")
    print()

    all_a_odd = all(t.a % 2 == 1 for t in triples)
    all_b_even = all(t.b % 2 == 0 for t in triples)
    all_c_odd = all(t.c % 2 == 1 for t in triples)
    all_coprime = all(gcd(t.a, t.b) == 1 for t in triples)

    print(f"  All a odd:     {all_a_odd}")
    print(f"  All b even:    {all_b_even}")
    print(f"  All c odd:     {all_c_odd}")
    print(f"  All coprime:   {all_coprime}")
    print()


# ============================================================
# Demo 4: Uniqueness — no duplicates in the tree
# ============================================================

def demo_uniqueness() -> None:
    """Show that all generated triples are distinct (consequence of c-monotonicity)."""
    print("=" * 70)
    print("DEMO 4: Uniqueness (No Duplicate Triples)")
    print("=" * 70)
    print()

    def generate_all(t: PrimitiveTriple, depth: int) -> list[PrimitiveTriple]:
        if depth == 0:
            return [t]
        result = [t]
        for step_fn in BERGGREN_STEPS.values():
            result.extend(generate_all(step_fn(t), depth - 1))
        return result

    triples = generate_all(ROOT, 5)
    triple_set = set(triples)

    print(f"  Generated {len(triples)} triples (depth ≤ 5).")
    print(f"  Unique triples: {len(triple_set)}.")
    print(f"  All distinct: {len(triples) == len(triple_set)}")
    print()


# ============================================================
# Demo 5: Lattice geometry connection
# ============================================================

def demo_lattice_connection() -> None:
    """Show the lattice geometry associated with each triple."""
    print("=" * 70)
    print("DEMO 5: Lattice Geometry Connection")
    print("=" * 70)
    print()
    print("  Each triple (a, b, c) defines a 2D lattice with basis vectors")
    print("  v₁ = (c, 0) and v₂ = (a, b). The shortest nonzero vector has")
    print("  length c, and the lattice determinant is b·c.")
    print()

    triples_to_show = [
        ROOT,
        berggren_left(ROOT),
        berggren_mid(ROOT),
        berggren_right(ROOT),
    ]
    names = ["(3,4,5)", "Left child", "Mid child", "Right child"]

    print(f"  {'Triple':>18}  {'|v₁|':>8}  {'|v₂|':>8}  {'det(Λ)':>10}  {'ratio |v₂|/|v₁|':>18}")
    print(f"  {'------':>18}  {'----':>8}  {'----':>8}  {'------':>10}  {'----------------':>18}")

    for name, t in zip(names, triples_to_show):
        v1_len = t.c
        v2_len = (t.a**2 + t.b**2) ** 0.5  # = c
        det = t.b * t.c
        ratio = v2_len / v1_len
        print(
            f"  {name:>18}"
            f"  {v1_len:>8}"
            f"  {v2_len:>8.2f}"
            f"  {det:>10}"
            f"  {ratio:>18.6f}"
        )
    print()


# ============================================================
# Main
# ============================================================

def main() -> None:
    """Run all demonstrations."""
    print()
    print("  BERGGREN TREE OF PRIMITIVE PYTHAGOREAN TRIPLES")
    print("  Numerical Demonstrations of Verified Results")
    print()

    demo_invariant_preservation()
    demo_hypotenuse_monotonicity()
    demo_parity_coprimality()
    demo_uniqueness()
    demo_lattice_connection()

    print("=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()
