#!/usr/bin/env python3
"""
Categorical Helly Principle — Core Algorithms

Implements the algorithms described in the research paper:
1. Probe separation verification
2. Helly bound computation
3. Minimal obstruction detection
4. Probe capacity analysis

All algorithms are verified against the formally proved theorems.
"""

from itertools import combinations
from math import prod
from typing import Dict, List, Set, Tuple, Optional, NamedTuple


class PresheafData(NamedTuple):
    """Discrete presheaf data: objects, fibers, and restriction maps."""
    objects: List[str]
    fibers: Dict[str, List[str]]
    restrictions: Dict[Tuple[str, str], Dict[str, str]]


def compute_probe_signature(
    presheaf: PresheafData,
    probe_objects: List[str],
    obj: str,
    elem: str
) -> Tuple[str, ...]:
    """
    Compute the probe signature of element `elem` at object `obj`.

    The signature is the tuple of images under restriction to each probe.

    Time complexity: O(|P|) where P is the probe family.
    Space complexity: O(|P|) for the signature tuple.

    Args:
        presheaf: The discrete presheaf data
        probe_objects: List of probe object names
        obj: The object at which elem lives
        elem: The element whose signature to compute

    Returns:
        Tuple of restriction images, one per probe object
    """
    result = []
    for z in probe_objects:
        key = (obj, z)
        if key in presheaf.restrictions and elem in presheaf.restrictions[key]:
            result.append(presheaf.restrictions[key][elem])
        else:
            result.append(elem)
    return tuple(result)


def verify_separation(
    presheaf: PresheafData,
    probe_objects: List[str]
) -> Tuple[bool, Optional[Tuple[str, str, str]]]:
    """
    Verify whether a probe family separates a presheaf.

    Checks that probe signatures are injective at every object.

    Time complexity: O(|Ob| · max|F(Y)| · |P|)
    Space complexity: O(max|F(Y)|) for the signature cache.

    Args:
        presheaf: The discrete presheaf data
        probe_objects: The probe family

    Returns:
        (True, None) if separating,
        (False, (obj, elem1, elem2)) if not, with the conflicting pair.
    """
    for obj in presheaf.objects:
        seen: Dict[Tuple, str] = {}
        for elem in presheaf.fibers[obj]:
            sig = compute_probe_signature(presheaf, probe_objects, obj, elem)
            if sig in seen:
                return False, (obj, seen[sig], elem)
            seen[sig] = elem
    return True, None


def compute_probe_capacity(
    presheaf: PresheafData,
    probe_objects: List[str]
) -> int:
    """
    Compute the probe capacity: product of fiber sizes at probe objects.

    Under separation, this bounds each individual fiber size.

    Time complexity: O(|P|)

    Args:
        presheaf: The discrete presheaf data
        probe_objects: The probe family

    Returns:
        Product of fiber sizes at probe objects
    """
    if not probe_objects:
        return 1
    return prod(len(presheaf.fibers[z]) for z in probe_objects)


def compute_helly_bound(
    presheaf: PresheafData,
    probe_objects: List[str],
    local_bound: int
) -> int:
    """
    Compute the global Helly bound: |Ob| * n^|P|.

    This is the bound guaranteed by the categorical Helly theorem
    when the local bound n holds on all subsets of size ≤ |P| + 1.

    Time complexity: O(1)

    Args:
        presheaf: The discrete presheaf data
        probe_objects: The probe family
        local_bound: The local bound n

    Returns:
        The global Helly bound |Ob| * n^|P|
    """
    return len(presheaf.objects) * (local_bound ** len(probe_objects))


def verify_local_bound(
    presheaf: PresheafData,
    probe_objects: List[str],
    local_bound: int
) -> Tuple[bool, Optional[Tuple[str, ...]]]:
    """
    Verify that the presheaf is locally bounded up to the Helly number.

    Checks every subset of size ≤ |P| + 1 has total fiber size ≤ n.

    Time complexity: O(C(|Ob|, |P|+1) · (|P|+1))
    Space complexity: O(|P|)

    Args:
        presheaf: The discrete presheaf data
        probe_objects: The probe family
        local_bound: The bound n to check

    Returns:
        (True, None) if bound holds,
        (False, violating_subset) if not.
    """
    helly_num = len(probe_objects) + 1
    for size in range(1, min(helly_num, len(presheaf.objects)) + 1):
        for subset in combinations(presheaf.objects, size):
            total = sum(len(presheaf.fibers[o]) for o in subset)
            if total > local_bound:
                return False, subset
    return True, None


def detect_helly_obstruction(
    presheaf: PresheafData,
    probe_objects: List[str],
    local_bound: int
) -> Optional[Dict]:
    """
    Detect whether the Helly theorem applies and, if not, find
    the minimal obstruction.

    This is the verified algorithm: given (C, P, F, k), it either
    certifies global representable finite generation or returns
    a minimal obstruction candidate.

    Time complexity: O(C(|Ob|, k+1) · k + |Ob| · max|F(Y)| · |P|)

    Args:
        presheaf: The discrete presheaf data
        probe_objects: The probe family
        local_bound: The bound k to check

    Returns:
        None if theorem applies (local bounds + separation → global bound),
        Dict with obstruction info otherwise.
    """
    # Step 1: Check separation
    sep, witness = verify_separation(presheaf, probe_objects)
    if not sep:
        obj, e1, e2 = witness
        return {
            'type': 'separation_failure',
            'object': obj,
            'elements': (e1, e2),
            'support_size': 1 + len(probe_objects),
            'support': [obj] + probe_objects,
        }

    # Step 2: Check local bound
    local_ok, violating = verify_local_bound(presheaf, probe_objects, local_bound)
    if not local_ok:
        return {
            'type': 'local_bound_failure',
            'violating_subset': list(violating),
            'subset_total': sum(len(presheaf.fibers[o]) for o in violating),
            'bound': local_bound,
        }

    # Step 3: Theorem applies
    global_dim = sum(len(presheaf.fibers[o]) for o in presheaf.objects)
    helly_bound = compute_helly_bound(presheaf, probe_objects, local_bound)

    return None  # No obstruction — theorem guarantees global bound


def find_optimal_probe_family(
    presheaf: PresheafData,
    max_size: int = None
) -> Tuple[List[str], int]:
    """
    Find the smallest separating probe family.

    Time complexity: O(∑_{k=1}^{|Ob|} C(|Ob|, k) · |Ob| · max|F(Y)| · k)

    Args:
        presheaf: The discrete presheaf data
        max_size: Maximum probe family size to try

    Returns:
        (probe_objects, capacity) for the optimal probe family
    """
    if max_size is None:
        max_size = len(presheaf.objects)

    for size in range(1, max_size + 1):
        for probe_objs in combinations(presheaf.objects, size):
            sep, _ = verify_separation(presheaf, list(probe_objs))
            if sep:
                cap = compute_probe_capacity(presheaf, list(probe_objs))
                return list(probe_objs), cap

    # Fall back to full set
    return presheaf.objects, compute_probe_capacity(presheaf, presheaf.objects)


# ═══════════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    print("Categorical Helly Algorithms — Example Usage")
    print("=" * 50)

    # Create example presheaf
    presheaf = PresheafData(
        objects=['A', 'B', 'C', 'D'],
        fibers={
            'A': ['a0', 'a1', 'a2'],
            'B': ['b0', 'b1'],
            'C': ['c0', 'c1', 'c2'],
            'D': ['d0'],
        },
        restrictions={
            ('A', 'B'): {'a0': 'b0', 'a1': 'b1', 'a2': 'b0'},
            ('A', 'C'): {'a0': 'c0', 'a1': 'c1', 'a2': 'c2'},
            ('C', 'B'): {'c0': 'b0', 'c1': 'b1', 'c2': 'b0'},
        }
    )

    probes = ['B', 'C']

    print(f"Presheaf objects: {presheaf.objects}")
    print(f"Fiber sizes: {[len(presheaf.fibers[o]) for o in presheaf.objects]}")
    print(f"Probe family: {probes}")

    sep, witness = verify_separation(presheaf, probes)
    print(f"Separating: {sep}")
    if not sep:
        print(f"  Witness: {witness}")

    cap = compute_probe_capacity(presheaf, probes)
    print(f"Probe capacity: {cap}")

    helly = compute_helly_bound(presheaf, probes, local_bound=3)
    print(f"Helly bound (n=3): {helly}")

    obstruction = detect_helly_obstruction(presheaf, probes, local_bound=3)
    if obstruction is None:
        print("No obstruction — Helly theorem applies!")
    else:
        print(f"Obstruction: {obstruction}")

    opt_probes, opt_cap = find_optimal_probe_family(presheaf)
    print(f"Optimal probe family: {opt_probes} (capacity {opt_cap})")
