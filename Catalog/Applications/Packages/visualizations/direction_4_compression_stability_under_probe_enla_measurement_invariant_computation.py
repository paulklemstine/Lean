#!/usr/bin/env python3
"""
algorithms.py — Certified Algorithms for Probe Complexity Analysis

Implements the core algorithms for computing measurement invariants,
detecting probe redundancy, and analyzing partition refinement
in finite presheaf categories.

All algorithms correspond directly to the formally verified theorems
in CompressionStability.lean.
"""

from itertools import combinations, product
from collections import defaultdict
from typing import Dict, List, Set, Tuple, FrozenSet, Optional


# ─────────────────────────────────────────────────────────────────────────────
# Data Types
# ─────────────────────────────────────────────────────────────────────────────

class FinitePresheaf:
    """A presheaf on a discrete finite category.

    A presheaf F assigns to each object Y a finite set F(Y) of "elements"
    and to each pair (Y, Z) a restriction map r(Y, Z) : F(Y) → F(Z).

    Attributes:
        objects: List of objects in the category.
        fibers: Dict mapping each object to its list of elements.
        restrictions: Dict mapping (Y, Z) pairs to dicts {elem: image}.
    """

    def __init__(self, objects: list, fibers: dict, restrictions: dict):
        self.objects = sorted(objects)
        self.fibers = fibers
        self.restrictions = restrictions

    def restrict(self, y, z, x):
        """Apply restriction map r(y, z) to element x ∈ F(y)."""
        return self.restrictions[(y, z)][x]

    def fiber_card(self, y) -> int:
        """Cardinality of F(y)."""
        return len(self.fibers[y])

    def total_card(self) -> int:
        """Total objectwise cardinality: Σ_Y |F(Y)|."""
        return sum(self.fiber_card(y) for y in self.objects)


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 1: Probe Signature Computation
# ─────────────────────────────────────────────────────────────────────────────

def compute_probe_signature(
    presheaf: FinitePresheaf,
    probe_family: Set,
    y,
    x
) -> tuple:
    """Compute the probe signature of element x at object y.

    The signature is the tuple (r(y, z₁)(x), r(y, z₂)(x), ...) for all
    probe objects z₁, z₂, ... ∈ P, in sorted order.

    Time complexity: O(|P|) per element.
    Space complexity: O(|P|) for the signature tuple.

    Args:
        presheaf: The finite presheaf.
        probe_family: Set of probe objects.
        y: The object at which to compute the signature.
        x: The element of F(y) to fingerprint.

    Returns:
        A hashable tuple representing the probe signature.
    """
    return tuple(presheaf.restrict(y, z, x) for z in sorted(probe_family))


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 2: Measurement Space Image Cardinality
# ─────────────────────────────────────────────────────────────────────────────

def compute_measurement_space_image_card(
    presheaf: FinitePresheaf,
    probe_family: Set,
    y
) -> int:
    """Compute the measurement space image cardinality at object y.

    This is |{sig_P(x) : x ∈ F(y)}|, the number of distinct probe
    signatures at y.

    Time complexity: O(|F(y)| · |P|)
    Space complexity: O(|F(y)|) for the signature set.

    Args:
        presheaf: The finite presheaf.
        probe_family: Set of probe objects.
        y: The object at which to count signatures.

    Returns:
        Number of distinct probe signatures at y.
    """
    signatures = set()
    for x in presheaf.fibers[y]:
        sig = compute_probe_signature(presheaf, probe_family, y, x)
        signatures.add(sig)
    return len(signatures)


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 3: Measurement Invariant
# ─────────────────────────────────────────────────────────────────────────────

def compute_measurement_invariant(
    presheaf: FinitePresheaf,
    probe_family: Set
) -> int:
    """Compute the measurement invariant: Σ_Y |image(sig_P at Y)|.

    This is the total number of distinguishable signature classes
    across all objects.

    Time complexity: O(Σ_Y |F(Y)| · |P|)
    Space complexity: O(max_Y |F(Y)|)

    Args:
        presheaf: The finite presheaf.
        probe_family: Set of probe objects.

    Returns:
        The measurement invariant value.
    """
    return sum(
        compute_measurement_space_image_card(presheaf, probe_family, y)
        for y in presheaf.objects
    )


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 4: Observational Equivalence Classes (Partition)
# ─────────────────────────────────────────────────────────────────────────────

def compute_partition(
    presheaf: FinitePresheaf,
    probe_family: Set,
    y
) -> List[List]:
    """Compute the partition of F(y) into observational equivalence classes.

    Two elements x, x' ∈ F(y) are in the same class iff they have the
    same probe signature: sig_P(x) = sig_P(x').

    Time complexity: O(|F(y)| · |P|)
    Space complexity: O(|F(y)|)

    Args:
        presheaf: The finite presheaf.
        probe_family: Set of probe objects.
        y: The object at which to compute the partition.

    Returns:
        List of equivalence classes (each a list of elements).
    """
    groups = defaultdict(list)
    for x in presheaf.fibers[y]:
        sig = compute_probe_signature(presheaf, probe_family, y, x)
        groups[sig].append(x)
    return [sorted(group) for group in groups.values()]


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 5: No-New-Separation Detection
# ─────────────────────────────────────────────────────────────────────────────

def check_no_new_separation(
    presheaf: FinitePresheaf,
    p_small: Set,
    p_large: Set
) -> Tuple[bool, List[Tuple]]:
    """Check if p_large introduces no new separations beyond p_small.

    Returns (True, []) if no new separations exist, or
    (False, [(y, x1, x2), ...]) listing newly separated pairs.

    Time complexity: O(Σ_Y |F(Y)|² · max(|P|, |P'|))
    Space complexity: O(Σ_Y |F(Y)|)

    Args:
        presheaf: The finite presheaf.
        p_small: The smaller probe family.
        p_large: The larger probe family (must contain p_small).

    Returns:
        Tuple of (is_redundant, new_separation_pairs).
    """
    new_separations = []
    for y in presheaf.objects:
        for x1, x2 in combinations(presheaf.fibers[y], 2):
            sig_small_1 = compute_probe_signature(presheaf, p_small, y, x1)
            sig_small_2 = compute_probe_signature(presheaf, p_small, y, x2)
            sig_large_1 = compute_probe_signature(presheaf, p_large, y, x1)
            sig_large_2 = compute_probe_signature(presheaf, p_large, y, x2)

            if sig_large_1 != sig_large_2 and sig_small_1 == sig_small_2:
                new_separations.append((y, x1, x2))

    return (len(new_separations) == 0, new_separations)


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 6: Full Monotonicity + Rigidity Verification
# ─────────────────────────────────────────────────────────────────────────────

def verify_compression_stability(
    presheaf: FinitePresheaf,
) -> Dict:
    """Run the complete compression stability analysis.

    For every pair of nested probe families P ⊆ P', verify:
    1. Monotonicity: μ(P) ≤ μ(P')
    2. Equality characterization: μ(P) = μ(P') ⟺ no new separation
    3. Strict monotonicity: new separation ⟹ μ(P) < μ(P')

    Time complexity: O(2^{2|Ob|} · Σ_Y |F(Y)|² · |Ob|)

    Args:
        presheaf: The finite presheaf to analyze.

    Returns:
        Dict with keys 'monotonicity_ok', 'iff_ok', 'strict_ok',
        'violations', and 'statistics'.
    """
    objects = presheaf.objects
    all_subsets = []
    for size in range(len(objects) + 1):
        for subset in combinations(objects, size):
            all_subsets.append(frozenset(subset))

    # Precompute all measurement invariants
    invariants = {s: compute_measurement_invariant(presheaf, s) for s in all_subsets}

    results = {
        'monotonicity_ok': True,
        'iff_ok': True,
        'strict_ok': True,
        'violations': [],
        'statistics': {
            'num_probe_families': len(all_subsets),
            'num_nested_pairs': 0,
            'num_equality_cases': 0,
            'num_strict_increases': 0,
            'num_new_separation_pairs': 0,
        },
        'invariants': {str(sorted(s)): v for s, v in invariants.items()},
    }

    for s1 in all_subsets:
        for s2 in all_subsets:
            if s1 <= s2:
                results['statistics']['num_nested_pairs'] += 1

                mi1 = invariants[s1]
                mi2 = invariants[s2]

                # Check monotonicity
                if mi1 > mi2:
                    results['monotonicity_ok'] = False
                    results['violations'].append(
                        f"Monotonicity: {sorted(s1)} ⊆ {sorted(s2)} but μ={mi1} > {mi2}")

                # Check iff characterization
                is_redundant, new_seps = check_no_new_separation(presheaf, s1, s2)
                eq = (mi1 == mi2)
                if eq != is_redundant:
                    results['iff_ok'] = False
                    results['violations'].append(
                        f"Iff: {sorted(s1)} ⊆ {sorted(s2)}, eq={eq}, redundant={is_redundant}")

                if eq:
                    results['statistics']['num_equality_cases'] += 1

                # Check strict monotonicity
                if new_seps:
                    results['statistics']['num_new_separation_pairs'] += len(new_seps)
                    if mi1 >= mi2:
                        results['strict_ok'] = False
                        results['violations'].append(
                            f"Strict: {sorted(s1)} ⊆ {sorted(s2)}, new sep but μ={mi1} ≥ {mi2}")
                    else:
                        results['statistics']['num_strict_increases'] += 1

    return results


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 7: Partition Refinement Lattice
# ─────────────────────────────────────────────────────────────────────────────

def compute_refinement_lattice(
    presheaf: FinitePresheaf,
    y
) -> Dict:
    """Compute the partition refinement lattice at object y.

    Returns a dict mapping each probe family to its partition and
    the refinement edges (which pairs are comparable).

    Args:
        presheaf: The finite presheaf.
        y: The object at which to compute refinements.

    Returns:
        Dict with 'partitions' and 'refinement_edges'.
    """
    objects = presheaf.objects
    all_subsets = []
    for size in range(len(objects) + 1):
        for subset in combinations(objects, size):
            all_subsets.append(frozenset(subset))

    partitions = {}
    for s in all_subsets:
        partitions[s] = compute_partition(presheaf, s, y)

    # Compute refinement edges (Hasse diagram)
    edges = []
    for s1 in all_subsets:
        for s2 in all_subsets:
            if s1 < s2:
                # s1 ⊂ s2, check if s2's partition refines s1's
                part1 = partitions[s1]
                part2 = partitions[s2]
                if len(part2) > len(part1):
                    edges.append((str(sorted(s1)), str(sorted(s2)),
                                  len(part1), len(part2)))

    return {
        'partitions': {str(sorted(s)): p for s, p in partitions.items()},
        'refinement_edges': edges,
    }


# ─────────────────────────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Build a small example presheaf
    presheaf = FinitePresheaf(
        objects=['A', 'B', 'C'],
        fibers={
            'A': ['a1', 'a2', 'a3', 'a4'],
            'B': ['b1', 'b2'],
            'C': ['c1', 'c2', 'c3'],
        },
        restrictions={
            ('A', 'A'): {'a1': 'a1', 'a2': 'a2', 'a3': 'a3', 'a4': 'a4'},
            ('A', 'B'): {'a1': 'b1', 'a2': 'b1', 'a3': 'b2', 'a4': 'b2'},
            ('A', 'C'): {'a1': 'c1', 'a2': 'c2', 'a3': 'c1', 'a4': 'c3'},
            ('B', 'A'): {'b1': 'a1', 'b2': 'a3'},
            ('B', 'B'): {'b1': 'b1', 'b2': 'b2'},
            ('B', 'C'): {'b1': 'c1', 'b2': 'c1'},
            ('C', 'A'): {'c1': 'a1', 'c2': 'a2', 'c3': 'a4'},
            ('C', 'B'): {'c1': 'b1', 'c2': 'b1', 'c3': 'b2'},
            ('C', 'C'): {'c1': 'c1', 'c2': 'c2', 'c3': 'c3'},
        }
    )

    print("=== Compression Stability Analysis ===\n")

    results = verify_compression_stability(presheaf)

    print(f"Probe families tested: {results['statistics']['num_probe_families']}")
    print(f"Nested pairs checked: {results['statistics']['num_nested_pairs']}")
    print(f"Equality cases: {results['statistics']['num_equality_cases']}")
    print(f"Strict increases: {results['statistics']['num_strict_increases']}")
    print()
    print(f"Monotonicity: {'PASS ✓' if results['monotonicity_ok'] else 'FAIL ✗'}")
    print(f"Iff characterization: {'PASS ✓' if results['iff_ok'] else 'FAIL ✗'}")
    print(f"Strict monotonicity: {'PASS ✓' if results['strict_ok'] else 'FAIL ✗'}")
    print()

    print("Measurement invariants:")
    for k, v in sorted(results['invariants'].items()):
        print(f"  P = {k}: μ = {v}")
    print()

    print("=== Partition Refinement at Object A ===\n")
    lattice = compute_refinement_lattice(presheaf, 'A')
    for k, v in sorted(lattice['partitions'].items()):
        print(f"  P = {k}: {v}")
