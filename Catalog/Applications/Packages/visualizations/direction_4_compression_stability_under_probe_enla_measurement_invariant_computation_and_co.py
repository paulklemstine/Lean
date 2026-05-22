#!/usr/bin/env python3
"""
Algorithms for Observational Compression Stability

This module implements the core algorithms for computing and comparing
measurement invariants of probe families on finite presheaf models.

The algorithms formalize the computational content of the monotonicity
and rigidity theorems for probe enlargement.

Time complexity: O(|Ob| · max|F(Y)| · |P|) for signature computation
Space complexity: O(|Ob| · max|F(Y)|) for storing signatures
"""

from typing import Any, Callable, Dict, List, Optional, Set, Tuple
from collections import defaultdict
from itertools import combinations


# =============================================================================
# Data Structures
# =============================================================================

class FinitePresheaf:
    """A presheaf on a finite discrete category.

    A presheaf F assigns to each object Y a finite set F(Y), and to each
    pair (Y, Z) a restriction map r(Y, Z): F(Y) → F(Z).

    Attributes:
        objects: List of object names.
        fibers: Dict mapping each object to its fiber (list of elements).
        restriction: Dict mapping (Y, Z) pairs to restriction functions.
    """

    def __init__(self, objects: List[str], fibers: Dict[str, List[Any]],
                 restriction: Dict[Tuple[str, str], Callable]):
        self.objects = objects
        self.fibers = fibers
        self.restriction = restriction

    def restrict(self, y: str, z: str, x: Any) -> Any:
        """Apply restriction map r(Y,Z) to element x ∈ F(Y)."""
        return self.restriction[(y, z)](x)

    def total_card(self) -> int:
        """Total objectwise cardinality: ∑_Y |F(Y)|."""
        return sum(len(self.fibers[y]) for y in self.objects)


# =============================================================================
# Algorithm 1: Probe Signature Computation
# =============================================================================

def compute_probe_signature(
    presheaf: FinitePresheaf,
    probe_family: Set[str],
    y: str,
    x: Any
) -> Tuple:
    """Compute the probe signature of element x ∈ F(Y).

    The signature is the tuple (r(Y, Z)(x) for Z ∈ P), encoding how
    x is observed through each probe.

    Time: O(|P|) per element.

    Args:
        presheaf: The finite presheaf.
        probe_family: Set of probe object names.
        y: The object where x lives.
        x: An element of F(Y).

    Returns:
        Tuple of restriction values, one per probe.
    """
    return tuple(presheaf.restrict(y, z, x) for z in sorted(probe_family))


def compute_all_signatures(
    presheaf: FinitePresheaf,
    probe_family: Set[str],
    y: str
) -> Dict[Any, Tuple]:
    """Compute probe signatures for all elements at object Y.

    Time: O(|F(Y)| · |P|).

    Returns:
        Dict mapping each element x ∈ F(Y) to its signature.
    """
    return {x: compute_probe_signature(presheaf, probe_family, y, x)
            for x in presheaf.fibers[y]}


# =============================================================================
# Algorithm 2: Measurement Space Image Cardinality
# =============================================================================

def compute_image_card(
    presheaf: FinitePresheaf,
    probe_family: Set[str],
    y: str
) -> int:
    """Compute the measurement space image cardinality at object Y.

    This is the number of distinct probe signatures realized by elements
    of F(Y). It satisfies:
        image_card(P, Y) ≤ |F(Y)|
    with equality iff the probe signature map is injective at Y.

    Time: O(|F(Y)| · |P|).

    Args:
        presheaf: The finite presheaf.
        probe_family: Set of probe object names.
        y: The object to analyze.

    Returns:
        Number of distinct signatures at Y.
    """
    signatures = set()
    for x in presheaf.fibers[y]:
        sig = compute_probe_signature(presheaf, probe_family, y, x)
        signatures.add(sig)
    return len(signatures)


def compute_measurement_invariant(
    presheaf: FinitePresheaf,
    probe_family: Set[str]
) -> int:
    """Compute the measurement invariant: ∑_Y image_card(P, Y).

    This is the total number of distinct signatures across all objects,
    measuring the overall discriminatory power of the probe family.

    Time: O(|Ob| · max|F(Y)| · |P|).

    Args:
        presheaf: The finite presheaf.
        probe_family: Set of probe object names.

    Returns:
        The measurement invariant value.
    """
    return sum(compute_image_card(presheaf, probe_family, y)
               for y in presheaf.objects)


# =============================================================================
# Algorithm 3: Separation Detection
# =============================================================================

def detect_separations(
    presheaf: FinitePresheaf,
    probe_family: Set[str],
    y: str
) -> List[Tuple[Any, Any]]:
    """Find all pairs of elements at object Y that are separated by the probe family.

    Time: O(|F(Y)|² · |P|).

    Returns:
        List of separated pairs (x1, x2) with x1 < x2 in index order.
    """
    elems = presheaf.fibers[y]
    sigs = compute_all_signatures(presheaf, probe_family, y)
    separated = []
    for i in range(len(elems)):
        for j in range(i + 1, len(elems)):
            if sigs[elems[i]] != sigs[elems[j]]:
                separated.append((elems[i], elems[j]))
    return separated


def detect_new_separations(
    presheaf: FinitePresheaf,
    P: Set[str],
    P_prime: Set[str]
) -> List[Tuple[str, Any, Any]]:
    """Find all pairs newly separated by P' but not by P.

    Time: O(|Ob| · |F(Y)|² · |P'|).

    Returns:
        List of (object, x1, x2) triples for newly separated pairs.
    """
    new_seps = []
    for y in presheaf.objects:
        sigs_P = compute_all_signatures(presheaf, P, y)
        sigs_Pp = compute_all_signatures(presheaf, P_prime, y)
        elems = presheaf.fibers[y]
        for i in range(len(elems)):
            for j in range(i + 1, len(elems)):
                x1, x2 = elems[i], elems[j]
                if sigs_Pp[x1] != sigs_Pp[x2] and sigs_P[x1] == sigs_P[x2]:
                    new_seps.append((y, x1, x2))
    return new_seps


# =============================================================================
# Algorithm 4: Restriction Map Construction
# =============================================================================

def construct_restriction_map(
    presheaf: FinitePresheaf,
    P: Set[str],
    P_prime: Set[str],
    y: str
) -> Dict[Tuple, Tuple]:
    """Construct the restriction map from P'-signatures to P-signatures at object Y.

    For each realized P'-signature σ', compute the unique P-signature σ
    such that every element with P'-signature σ' has P-signature σ.

    This map is always well-defined (by the refinement property) and
    surjective (every P-signature lifts to some P'-signature from the
    same element).

    Time: O(|F(Y)| · |P'|).

    Returns:
        Dict mapping P'-signatures to P-signatures.
    """
    result = {}
    for x in presheaf.fibers[y]:
        sig_prime = compute_probe_signature(presheaf, P_prime, y, x)
        sig = compute_probe_signature(presheaf, P, y, x)
        result[sig_prime] = sig
    return result


# =============================================================================
# Algorithm 5: Complete Comparison
# =============================================================================

def full_comparison(
    presheaf: FinitePresheaf,
    P: Set[str],
    P_prime: Set[str]
) -> Dict:
    """Complete comparison of nested probe families P ⊆ P'.

    Computes:
    1. Both measurement invariants
    2. Monotonicity check
    3. Equality check
    4. No-new-separation check
    5. New separations (if any)
    6. Restriction maps at each object
    7. Equivalence class structure

    Time: O(|Ob| · max|F(Y)|² · |P'|).

    Args:
        presheaf: The finite presheaf.
        P: The smaller probe family.
        P_prime: The larger probe family (must satisfy P ⊆ P').

    Returns:
        Comprehensive comparison dictionary.
    """
    assert P.issubset(P_prime), "P must be a subset of P'"

    inv_P = compute_measurement_invariant(presheaf, P)
    inv_Pp = compute_measurement_invariant(presheaf, P_prime)
    new_seps = detect_new_separations(presheaf, P, P_prime)

    rest_maps = {}
    equiv_classes_P = {}
    equiv_classes_Pp = {}

    for y in presheaf.objects:
        rest_maps[y] = construct_restriction_map(presheaf, P, P_prime, y)

        # Compute equivalence classes
        sigs_P = compute_all_signatures(presheaf, P, y)
        sigs_Pp = compute_all_signatures(presheaf, P_prime, y)

        classes_P: Dict[Tuple, List] = defaultdict(list)
        classes_Pp: Dict[Tuple, List] = defaultdict(list)
        for x in presheaf.fibers[y]:
            classes_P[sigs_P[x]].append(x)
            classes_Pp[sigs_Pp[x]].append(x)

        equiv_classes_P[y] = dict(classes_P)
        equiv_classes_Pp[y] = dict(classes_Pp)

    return {
        'invariant_P': inv_P,
        'invariant_P_prime': inv_Pp,
        'is_monotone': inv_P <= inv_Pp,
        'is_equal': inv_P == inv_Pp,
        'no_new_separation': len(new_seps) == 0,
        'new_separations': new_seps,
        'restriction_maps': rest_maps,
        'equiv_classes_P': equiv_classes_P,
        'equiv_classes_P_prime': equiv_classes_Pp,
        'equality_iff_verified': (inv_P == inv_Pp) == (len(new_seps) == 0),
    }


# =============================================================================
# Algorithm 6: Optimal Probe Family Search
# =============================================================================

def find_minimal_separating_family(
    presheaf: FinitePresheaf
) -> Optional[Set[str]]:
    """Find a probe family of minimum size that separates all elements.

    A probe family P separates the presheaf if probe signatures are
    injective at every object Y.

    Time: O(2^|Ob| · |Ob| · max|F(Y)| · |Ob|) in the worst case.

    Returns:
        Minimal separating probe family, or None if none exists.
    """
    for size in range(len(presheaf.objects) + 1):
        for subset in combinations(presheaf.objects, size):
            P = set(subset)
            is_sep = True
            for y in presheaf.objects:
                sigs = [compute_probe_signature(presheaf, P, y, x)
                        for x in presheaf.fibers[y]]
                if len(sigs) != len(set(sigs)):
                    is_sep = False
                    break
            if is_sep:
                return P
    return None


def find_redundant_probes(
    presheaf: FinitePresheaf,
    probe_family: Set[str]
) -> Set[str]:
    """Find probes in P that can be removed without changing the invariant.

    A probe Z ∈ P is redundant if removing it doesn't change any
    separation, equivalently if meas_inv(P \\ {Z}) = meas_inv(P).

    Time: O(|P| · |Ob| · max|F(Y)| · |P|).

    Returns:
        Set of redundant probe objects.
    """
    inv = compute_measurement_invariant(presheaf, probe_family)
    redundant = set()
    for z in probe_family:
        P_minus = probe_family - {z}
        if compute_measurement_invariant(presheaf, P_minus) == inv:
            redundant.add(z)
    return redundant


# =============================================================================
# Example usage
# =============================================================================

if __name__ == "__main__":
    # Create a small example
    objects = ['A', 'B']
    fibers = {
        'A': [1, 2, 3],
        'B': [10, 20],
    }
    maps = {
        ('A', 'A'): {1: 1, 2: 2, 3: 3},
        ('A', 'B'): {1: 10, 2: 10, 3: 20},
        ('B', 'A'): {10: 1, 20: 3},
        ('B', 'B'): {10: 10, 20: 20},
    }
    restriction = {k: (lambda m: lambda x: m[x])(v) for k, v in maps.items()}
    F = FinitePresheaf(objects, fibers, restriction)

    print("=== Algorithm Suite Demo ===\n")

    # Compute invariants
    for P in [set(), {'A'}, {'B'}, {'A', 'B'}]:
        inv = compute_measurement_invariant(F, P)
        print(f"  meas_inv({P}) = {inv}")

    # Full comparison
    print("\n--- Full Comparison: {A} vs {A, B} ---")
    result = full_comparison(F, {'A'}, {'A', 'B'})
    for k, v in result.items():
        if k not in ['restriction_maps', 'equiv_classes_P', 'equiv_classes_P_prime']:
            print(f"  {k}: {v}")

    # Find minimal separating family
    print("\n--- Minimal Separating Family ---")
    min_sep = find_minimal_separating_family(F)
    print(f"  Minimal separating family: {min_sep}")

    # Find redundant probes
    print("\n--- Redundant Probes in {A, B} ---")
    redundant = find_redundant_probes(F, {'A', 'B'})
    print(f"  Redundant probes: {redundant}")
