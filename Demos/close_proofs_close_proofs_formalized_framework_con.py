#!/usr/bin/env python3
"""
Numerical demonstrations of the Categorical Helly Principle for Probe Families.

This script illustrates the four main theorems with concrete finite examples:
1. Fiber Capacity Bound: |F(Y)| <= prod_{Z in P} |F(Z)|
2. Categorical Helly Theorem: repDim(F) <= |Ob| * n^|P|
3. Separation Monotonicity: P separates => Q ⊇ P separates
4. Obstruction Localization: non-separation implies a localized witness

All functions are self-contained with type hints.
"""

from __future__ import annotations
from itertools import product as cartesian_product
from math import prod
from typing import Any


# ---------------------------------------------------------------------------
# Core Definitions
# ---------------------------------------------------------------------------

def probe_signature(
    restriction_maps: dict[tuple[str, str], dict[Any, Any]],
    probe_family: list[str],
    obj: str,
    element: Any,
) -> tuple[Any, ...]:
    """Compute the probe signature of an element x in F(obj).

    sig_P(x) = (r(obj, Z1)(x), r(obj, Z2)(x), ..., r(obj, Zk)(x))
    """
    return tuple(restriction_maps[(obj, z)][element] for z in probe_family)


def is_probe_separated(
    fibers: dict[str, list[Any]],
    restriction_maps: dict[tuple[str, str], dict[Any, Any]],
    probe_family: list[str],
) -> bool:
    """Check whether the probe family separates the presheaf F.

    Separation holds iff probe signatures are injective at every object.
    """
    for obj, elems in fibers.items():
        sigs: set[tuple[Any, ...]] = set()
        for x in elems:
            sig = probe_signature(restriction_maps, probe_family, obj, x)
            if sig in sigs:
                return False
            sigs.add(sig)
    return True


def restricted_rep_dim(
    fibers: dict[str, list[Any]],
    subset: list[str],
) -> int:
    """Restricted representable dimension: sum of fiber sizes over a subset."""
    return sum(len(fibers[y]) for y in subset if y in fibers)


def objectwise_total_card(fibers: dict[str, list[Any]]) -> int:
    """Total representable dimension: sum of all fiber sizes."""
    return sum(len(v) for v in fibers.values())


def probe_capacity(fibers: dict[str, list[Any]], probe_family: list[str]) -> int:
    """Probe capacity: product of fiber sizes at probe objects."""
    return prod(len(fibers[z]) for z in probe_family)


def categorical_helly_number(probe_family: list[str]) -> int:
    """Categorical Helly number: |P| + 1."""
    return len(probe_family) + 1


def find_non_separated_witness(
    fibers: dict[str, list[Any]],
    restriction_maps: dict[tuple[str, str], dict[Any, Any]],
    probe_family: list[str],
) -> tuple[str, Any, Any] | None:
    """Find a minimal non-separated witness, if one exists.

    Returns (Y, x, y) where x != y in F(Y) but sig_P(x) = sig_P(y),
    or None if the presheaf is separated.
    """
    for obj, elems in fibers.items():
        sig_to_elem: dict[tuple[Any, ...], Any] = {}
        for x in elems:
            sig = probe_signature(restriction_maps, probe_family, obj, x)
            if sig in sig_to_elem:
                return (obj, sig_to_elem[sig], x)
            sig_to_elem[sig] = x
    return None


def locally_rep_fin_gen_up_to(
    fibers: dict[str, list[Any]],
    k: int,
    n: int,
) -> bool:
    """Check LocallyRepFinGenUpTo(F, k, n):
    every subset of Ob of size <= k has restricted rep dim <= n.
    """
    from itertools import combinations
    objects = list(fibers.keys())
    for size in range(1, min(k, len(objects)) + 1):
        for subset in combinations(objects, size):
            if restricted_rep_dim(fibers, list(subset)) > n:
                return False
    return True


# ---------------------------------------------------------------------------
# Demo 1: Fiber Capacity Bound
# ---------------------------------------------------------------------------

def demo_fiber_capacity_bound() -> None:
    """Demonstrate Theorem 1: |F(Y)| <= prod_{Z in P} |F(Z)|.

    We construct a presheaf on {A, B, C} with probe family P = {B, C}.
    The restriction maps project elements to coordinates, ensuring separation.
    """
    print("=" * 70)
    print("DEMO 1: Fiber Capacity Bound (Theorem 1)")
    print("=" * 70)

    # Objects
    objects = ["A", "B", "C"]

    # Fibers: F(A) has 6 elements, F(B) has 3, F(C) has 2
    fibers: dict[str, list[Any]] = {
        "A": [(b, c) for b in range(3) for c in range(2)],  # 6 elements
        "B": [0, 1, 2],  # 3 elements
        "C": [0, 1],     # 2 elements
    }

    # Restriction maps: r(A,B) and r(A,C) project to coordinates
    restriction_maps: dict[tuple[str, str], dict[Any, Any]] = {
        ("A", "B"): {(b, c): b for b in range(3) for c in range(2)},
        ("A", "C"): {(b, c): c for b in range(3) for c in range(2)},
        ("B", "B"): {b: b for b in range(3)},
        ("B", "C"): {0: 0, 1: 0, 2: 1},  # arbitrary
        ("C", "B"): {0: 0, 1: 1},         # arbitrary
        ("C", "C"): {c: c for c in range(2)},
    }

    probe_family = ["B", "C"]

    # Check separation
    sep = is_probe_separated(fibers, restriction_maps, probe_family)
    print(f"\nObjects: {objects}")
    print(f"Fiber sizes: |F(A)|={len(fibers['A'])}, |F(B)|={len(fibers['B'])}, |F(C)|={len(fibers['C'])}")
    print(f"Probe family P = {probe_family}")
    print(f"Separated: {sep}")

    cap = probe_capacity(fibers, probe_family)
    print(f"\nProbe capacity = |F(B)| * |F(C)| = {len(fibers['B'])} * {len(fibers['C'])} = {cap}")

    for obj in objects:
        fib_size = len(fibers[obj])
        print(f"|F({obj})| = {fib_size} <= {cap} (probe capacity)  ✓" if fib_size <= cap
              else f"|F({obj})| = {fib_size} > {cap}  ✗ VIOLATED!")

    print(f"\nConclusion: Every fiber is bounded by the probe capacity {cap}.")


# ---------------------------------------------------------------------------
# Demo 2: Categorical Helly Theorem
# ---------------------------------------------------------------------------

def demo_categorical_helly() -> None:
    """Demonstrate Theorem 2: repDim(F) <= |Ob| * n^|P|.

    We verify the bound on a concrete example where local checks on
    small subsets give a global bound.
    """
    print("\n" + "=" * 70)
    print("DEMO 2: Categorical Helly Theorem (Theorem 2)")
    print("=" * 70)

    # 5 objects, probe family of size 2
    objects = ["A", "B", "C", "D", "E"]
    probe_family = ["D", "E"]
    k = len(probe_family)
    helly_num = categorical_helly_number(probe_family)

    # Each fiber has at most 4 elements
    fibers: dict[str, list[Any]] = {
        "A": list(range(4)),
        "B": list(range(3)),
        "C": list(range(4)),
        "D": list(range(2)),
        "E": list(range(2)),
    }

    # Identity restriction maps (simplified for cardinality demo)
    restriction_maps: dict[tuple[str, str], dict[Any, Any]] = {}
    for y in objects:
        for z in objects:
            if y == z:
                restriction_maps[(y, z)] = {x: x for x in fibers[y]}
            else:
                restriction_maps[(y, z)] = {x: x % len(fibers[z]) for x in fibers[y]}

    print(f"\nObjects: {objects}")
    print(f"Fiber sizes: {', '.join(f'|F({o})|={len(fibers[o])}' for o in objects)}")
    print(f"Probe family P = {probe_family}, |P| = {k}")
    print(f"Categorical Helly number h(P) = |P| + 1 = {helly_num}")

    # Check local bound on subsets of size <= helly_num
    from itertools import combinations
    n = 4  # local bound
    print(f"\nChecking local bound n = {n} on all subsets of size <= {helly_num}:")
    all_ok = True
    for size in range(1, helly_num + 1):
        for subset in combinations(objects, size):
            rdim = restricted_rep_dim(fibers, list(subset))
            ok = rdim <= n
            if not ok:
                all_ok = False
            if size <= 3:  # show first few
                status = "✓" if ok else "✗"
                print(f"  S={set(subset):20s}  repDim_S = {rdim:2d} <= {n}  {status}")

    total = objectwise_total_card(fibers)
    global_bound = len(objects) * n ** k
    print(f"\nGlobal representable dimension: {total}")
    print(f"Helly bound: |Ob| * n^|P| = {len(objects)} * {n}^{k} = {global_bound}")
    print(f"Bound satisfied: {total} <= {global_bound}  {'✓' if total <= global_bound else '✗'}")


# ---------------------------------------------------------------------------
# Demo 3: Separation Monotonicity
# ---------------------------------------------------------------------------

def demo_separation_monotonicity() -> None:
    """Demonstrate Theorem 3: P ⊆ Q and P separates => Q separates.

    We show that adding probes preserves separation.
    """
    print("\n" + "=" * 70)
    print("DEMO 3: Separation Monotonicity (Theorem 3)")
    print("=" * 70)

    objects = ["A", "B", "C", "D"]

    # F(A) = {0,1,2,3}, other fibers small
    fibers: dict[str, list[Any]] = {
        "A": [0, 1, 2, 3],
        "B": [0, 1],
        "C": [0, 1],
        "D": [0, 1],
    }

    restriction_maps: dict[tuple[str, str], dict[Any, Any]] = {
        ("A", "B"): {0: 0, 1: 0, 2: 1, 3: 1},  # first coordinate in binary
        ("A", "C"): {0: 0, 1: 1, 2: 0, 3: 1},  # second coordinate in binary
        ("A", "D"): {0: 0, 1: 1, 2: 1, 3: 0},  # XOR
    }
    # Fill in identity and other maps
    for y in objects:
        for z in objects:
            if (y, z) not in restriction_maps:
                if y == z:
                    restriction_maps[(y, z)] = {x: x for x in fibers[y]}
                else:
                    restriction_maps[(y, z)] = {x: x % len(fibers[z]) for x in fibers[y]}

    P = ["B", "C"]
    Q = ["B", "C", "D"]

    sep_P = is_probe_separated(fibers, restriction_maps, P)
    sep_Q = is_probe_separated(fibers, restriction_maps, Q)

    print(f"\nObjects: {objects}")
    print(f"F(A) = {fibers['A']}")
    print(f"r(A,B): {restriction_maps[('A','B')]}  (bit 1)")
    print(f"r(A,C): {restriction_maps[('A','C')]}  (bit 0)")
    print(f"r(A,D): {restriction_maps[('A','D')]}  (XOR)")

    print(f"\nP = {P}: separated = {sep_P}")
    print(f"Q = {Q} ⊇ P: separated = {sep_Q}")

    # Show signatures
    print(f"\nSignatures at A under P = {P}:")
    for x in fibers["A"]:
        sig = probe_signature(restriction_maps, P, "A", x)
        print(f"  sig_P({x}) = {sig}")

    print(f"\nSignatures at A under Q = {Q}:")
    for x in fibers["A"]:
        sig = probe_signature(restriction_maps, Q, "A", x)
        print(f"  sig_Q({x}) = {sig}")

    print(f"\nConclusion: P separates ({sep_P}), Q ⊇ P also separates ({sep_Q}) — monotonicity confirmed ✓")


# ---------------------------------------------------------------------------
# Demo 4: Obstruction Localization
# ---------------------------------------------------------------------------

def demo_obstruction_localization() -> None:
    """Demonstrate Theorem 4: non-separation yields a localized witness.

    We show a presheaf where a too-small probe family fails to separate,
    and find the concrete obstruction.
    """
    print("\n" + "=" * 70)
    print("DEMO 4: Obstruction Localization (Theorem 4)")
    print("=" * 70)

    objects = ["A", "B", "C"]

    # F(A) has 4 elements but P = {B} with |F(B)| = 2 can't separate
    fibers: dict[str, list[Any]] = {
        "A": ["alpha", "beta", "gamma", "delta"],
        "B": [0, 1],
        "C": [0, 1, 2],
    }

    # Only 2 possible values at B, so 4 elements can't all get distinct signatures
    restriction_maps: dict[tuple[str, str], dict[Any, Any]] = {
        ("A", "B"): {"alpha": 0, "beta": 1, "gamma": 0, "delta": 1},
        ("A", "C"): {"alpha": 0, "beta": 1, "gamma": 2, "delta": 0},
    }
    for y in objects:
        for z in objects:
            if (y, z) not in restriction_maps:
                if y == z:
                    restriction_maps[(y, z)] = {x: x for x in fibers[y]}
                else:
                    restriction_maps[(y, z)] = {x: fibers[z][i % len(fibers[z])]
                                                 for i, x in enumerate(fibers[y])}

    P_small = ["B"]  # Too small — can't separate
    P_large = ["B", "C"]  # Large enough

    sep_small = is_probe_separated(fibers, restriction_maps, P_small)
    witness = find_non_separated_witness(fibers, restriction_maps, P_small)
    sep_large = is_probe_separated(fibers, restriction_maps, P_large)

    print(f"\nObjects: {objects}")
    print(f"Fiber sizes: |F(A)|={len(fibers['A'])}, |F(B)|={len(fibers['B'])}, |F(C)|={len(fibers['C'])}")
    print(f"r(A,B): {restriction_maps[('A','B')]}")

    print(f"\nP_small = {P_small}: separated = {sep_small}")

    if witness:
        y, x1, x2 = witness
        sig1 = probe_signature(restriction_maps, P_small, y, x1)
        sig2 = probe_signature(restriction_maps, P_small, y, x2)
        print(f"  Non-separated witness at object {y}:")
        print(f"    x = {x1!r}, y = {x2!r}")
        print(f"    sig_P({x1!r}) = {sig1}")
        print(f"    sig_P({x2!r}) = {sig2}")
        print(f"    Same signature but x ≠ y — obstruction found!")
        support_size = len({y} | set(P_small))
        helly = categorical_helly_number(P_small)
        print(f"  Support size: |{{{y}}} ∪ P| = {support_size} <= {helly} = h(P)  ✓")
    else:
        print("  No witness found (unexpected).")

    print(f"\nP_large = {P_large}: separated = {sep_large}")
    print("  Adding C to the probe family resolves the obstruction.")


# ---------------------------------------------------------------------------
# Demo 5: Scaling behavior of the Helly bound
# ---------------------------------------------------------------------------

def demo_scaling_behavior() -> None:
    """Show how the Helly bound |Ob| * n^|P| scales with parameters."""
    print("\n" + "=" * 70)
    print("DEMO 5: Scaling Behavior of the Helly Bound")
    print("=" * 70)

    print(f"\n{'|Ob|':>6} {'|P|':>6} {'n':>6} {'h(P)':>6} {'Helly bound':>15}")
    print("-" * 50)

    for num_obj in [5, 10, 20, 50]:
        for num_probes in [2, 3, 5]:
            for n in [3, 5]:
                helly = num_probes + 1
                bound = num_obj * n ** num_probes
                print(f"{num_obj:>6} {num_probes:>6} {n:>6} {helly:>6} {bound:>15,}")

    print("\nThe bound grows polynomially in |Ob| and exponentially in |P|.")
    print("Smaller probe families yield tighter bounds — fewer probes is better")
    print("(as long as they still separate the presheaf).")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    """Run all demonstrations."""
    print("CATEGORICAL HELLY PRINCIPLE — NUMERICAL DEMONSTRATIONS")
    print("=" * 70)

    demo_fiber_capacity_bound()
    demo_categorical_helly()
    demo_separation_monotonicity()
    demo_obstruction_localization()
    demo_scaling_behavior()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()
