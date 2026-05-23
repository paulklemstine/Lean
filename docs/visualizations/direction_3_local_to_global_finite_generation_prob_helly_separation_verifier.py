#!/usr/bin/env python3
"""
algorithms.py — Algorithms for the Categorical Helly Principle

Implements:
  1. Helly Separation Checker: verifies local-to-global separation
  2. Obstruction Detector: finds minimal non-separated subsets
  3. Helly Number Computer: finds the sharp Helly bound for a presheaf
  4. Probe Signature Analyzer: computes and analyzes probe fingerprints

All algorithms are backed by the formally verified Helly separation principle.
"""

import itertools
from typing import Dict, List, Tuple, Set, Optional, Callable
from dataclasses import dataclass, field


@dataclass
class FinitePresheaf:
    """A presheaf on a discrete finite category.

    Attributes:
        objects: List of object names
        fibers: Dict mapping each object to its list of elements
        restriction: Dict mapping (source, target) to a function F(source) -> F(target)
    """
    objects: List[str]
    fibers: Dict[str, List[str]]
    restriction: Dict[Tuple[str, str], Callable]


def compute_probe_signature(
    presheaf: FinitePresheaf,
    probes: Set[str],
    obj: str,
    elem: str
) -> Tuple:
    """Compute the probe signature of an element.

    The signature records, for each probe Z in P, the image r(Y, Z)(x).
    Two elements are distinguished by the probe family iff they have
    different signatures.

    Args:
        presheaf: The presheaf data
        probes: Set of probe objects
        obj: The object Y where the element lives
        elem: The element x ∈ F(Y)

    Returns:
        A hashable tuple encoding the signature

    Time complexity: O(|P|) per element
    """
    sig = []
    for z in sorted(probes):
        key = (obj, z)
        if key in presheaf.restriction:
            sig.append((z, presheaf.restriction[key](elem)))
        else:
            sig.append((z, elem))
    return tuple(sig)


def check_local_separation(
    presheaf: FinitePresheaf,
    probes: Set[str],
    subset: Set[str]
) -> Tuple[bool, Optional[Tuple[str, str, str]]]:
    """Check local probe separation on a subset S.

    Verifies: for each Y ∈ S, the probe signature using P ∩ S is injective.

    Args:
        presheaf: The presheaf
        probes: Probe family P
        subset: Subset S ⊆ Ob

    Returns:
        (is_separated, witness) where witness is (obj, elem1, elem2) if separation fails

    Time complexity: O(|S| · max|F(Y)| · |P ∩ S|)
    """
    active_probes = probes & subset
    for y in subset:
        if y not in presheaf.fibers:
            continue
        sigs: Dict[Tuple, str] = {}
        for elem in presheaf.fibers[y]:
            sig = compute_probe_signature(presheaf, active_probes, y, elem)
            if sig in sigs:
                return False, (y, sigs[sig], elem)
            sigs[sig] = elem
    return True, None


def check_global_separation(
    presheaf: FinitePresheaf,
    probes: Set[str]
) -> Tuple[bool, Optional[Tuple[str, str, str]]]:
    """Check global probe separation.

    Args:
        presheaf: The presheaf
        probes: Probe family P

    Returns:
        (is_separated, witness) where witness is (obj, elem1, elem2) if fails

    Time complexity: O(|Ob| · max|F(Y)| · |P|)
    """
    for y in presheaf.objects:
        sigs: Dict[Tuple, str] = {}
        for elem in presheaf.fibers[y]:
            sig = compute_probe_signature(presheaf, probes, y, elem)
            if sig in sigs:
                return False, (y, sigs[sig], elem)
            sigs[sig] = elem
    return True, None


def verify_helly_principle(
    presheaf: FinitePresheaf,
    probes: Set[str]
) -> Dict:
    """Verify the Helly separation principle.

    Checks: local separation on all ≤ |P|+1 subsets ⟹ global separation.

    Algorithm:
        1. Enumerate all subsets of Ob with ≤ |P|+1 elements
        2. Check local separation on each
        3. If all pass, verify global separation

    Returns:
        Dict with keys:
            'helly_holds': bool — whether the principle is verified
            'locally_separated': bool — whether the local condition holds
            'globally_separated': bool — whether global separation holds
            'helly_bound': int — the bound |P| + 1
            'subsets_checked': int — number of subsets examined
            'failed_subsets': list — subsets where local separation fails

    Time complexity: O(C(|Ob|, |P|+1) · |P| · max|F(Y)|)
    Space complexity: O(|Ob| · max|F(Y)|)
    """
    k = len(probes) + 1
    subsets_checked = 0
    failed_subsets = []

    for size in range(k + 1):
        for subset_tuple in itertools.combinations(presheaf.objects, size):
            subset = set(subset_tuple)
            subsets_checked += 1
            is_sep, witness = check_local_separation(presheaf, probes, subset)
            if not is_sep:
                failed_subsets.append({
                    'subset': sorted(subset),
                    'witness': witness
                })

    locally_separated = len(failed_subsets) == 0
    is_global, _ = check_global_separation(presheaf, probes)

    return {
        'helly_holds': not locally_separated or is_global,
        'locally_separated': locally_separated,
        'globally_separated': is_global,
        'helly_bound': k,
        'subsets_checked': subsets_checked,
        'failed_subsets': failed_subsets
    }


def find_minimal_obstruction(
    presheaf: FinitePresheaf,
    probes: Set[str]
) -> Optional[Dict]:
    """Find the minimal subset where local separation fails.

    This implements the constructive content of the minimal obstruction theorem:
    if global separation fails, there exists a subset of size ≤ |P|+1 where
    local separation also fails.

    Algorithm:
        1. Enumerate subsets by increasing size
        2. Return the first subset where local separation fails
        3. Report the specific witness (object, two elements)

    Returns:
        Dict with 'subset', 'size', 'object', 'elem1', 'elem2', or None

    Time complexity: O(C(|Ob|, k) · |P| · max|F(Y)|) where k is minimal obstruction size
    """
    for size in range(1, len(presheaf.objects) + 1):
        for subset_tuple in itertools.combinations(presheaf.objects, size):
            subset = set(subset_tuple)
            is_sep, witness = check_local_separation(presheaf, probes, subset)
            if not is_sep:
                return {
                    'subset': sorted(subset),
                    'size': size,
                    'object': witness[0],
                    'elem1': witness[1],
                    'elem2': witness[2],
                    'active_probes': sorted(probes & subset),
                    'bound': len(probes) + 1
                }
    return None


def compute_helly_number(
    presheaf: FinitePresheaf,
    probes: Set[str]
) -> int:
    """Compute the sharp categorical Helly number.

    The Helly number is the smallest k such that local separation on all
    ≤ k subsets implies global separation.

    Algorithm:
        1. If global separation fails, return ∞ (represented as |Ob| + 1)
        2. Otherwise, binary search for the smallest k that works

    Returns:
        The Helly number (always ≤ |P| + 1 by the theorem)

    Time complexity: O(|Ob| · C(|Ob|, |P|+1) · |P| · max|F(Y)|)
    """
    is_global, _ = check_global_separation(presheaf, probes)
    if not is_global:
        # If not globally separated, need to check if local separation
        # fails somewhere (it should, by contrapositive of Helly)
        return len(presheaf.objects) + 1  # Convention: ∞

    # Binary search for minimal k
    for k in range(0, len(probes) + 2):
        all_local = True
        for size in range(k + 1):
            for subset_tuple in itertools.combinations(presheaf.objects, size):
                subset = set(subset_tuple)
                is_sep, _ = check_local_separation(presheaf, probes, subset)
                if not is_sep:
                    all_local = False
                    break
            if not all_local:
                break
        if all_local:
            return k

    return len(probes) + 1


def analyze_signatures(
    presheaf: FinitePresheaf,
    probes: Set[str]
) -> Dict:
    """Analyze the probe signature structure.

    Returns:
        Dict with signature analysis per object:
            - number of distinct signatures
            - signature collision groups
            - measurement invariant contribution
    """
    analysis = {}
    total_invariant = 0

    for obj in presheaf.objects:
        sigs: Dict[Tuple, List[str]] = {}
        for elem in presheaf.fibers[obj]:
            sig = compute_probe_signature(presheaf, probes, obj, elem)
            if sig not in sigs:
                sigs[sig] = []
            sigs[sig].append(elem)

        n_distinct = len(sigs)
        n_elements = len(presheaf.fibers[obj])
        is_injective = n_distinct == n_elements

        analysis[obj] = {
            'n_elements': n_elements,
            'n_distinct_sigs': n_distinct,
            'is_injective': is_injective,
            'collision_groups': {str(k): v for k, v in sigs.items() if len(v) > 1}
        }
        total_invariant += n_distinct

    return {
        'per_object': analysis,
        'measurement_invariant': total_invariant,
        'objectwise_total': sum(len(presheaf.fibers[obj]) for obj in presheaf.objects),
        'globally_separated': all(a['is_injective'] for a in analysis.values())
    }


# ═══════════════════════════════════════════════════════════════
# Example usage
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Categorical Helly Principle — Algorithms")
    print("=" * 50)

    # Example presheaf
    presheaf = FinitePresheaf(
        objects=["A", "B", "C", "D"],
        fibers={
            "A": ["a1", "a2", "a3"],
            "B": ["b1", "b2"],
            "C": ["c1", "c2"],
            "D": ["d1"],
        },
        restriction={
            ("A", "B"): lambda x: "b1" if x in ["a1", "a2"] else "b2",
            ("A", "C"): lambda x: {"a1": "c1", "a2": "c2", "a3": "c1"}[x],
            ("B", "A"): lambda x: "a1",
            ("B", "C"): lambda x: "c1",
            ("C", "A"): lambda x: "a1" if x == "c1" else "a2",
            ("C", "B"): lambda x: "b1",
            ("D", "A"): lambda x: "a1",
            ("D", "B"): lambda x: "b1",
            ("D", "C"): lambda x: "c1",
            ("A", "D"): lambda x: "d1",
            ("B", "D"): lambda x: "d1",
            ("C", "D"): lambda x: "d1",
        }
    )

    probes = {"B", "C"}

    print("\n1. Helly Principle Verification:")
    result = verify_helly_principle(presheaf, probes)
    for k, v in result.items():
        if k != 'failed_subsets':
            print(f"   {k}: {v}")
    if result['failed_subsets']:
        print(f"   failed_subsets: {len(result['failed_subsets'])} subsets")

    print("\n2. Minimal Obstruction:")
    obs = find_minimal_obstruction(presheaf, probes)
    if obs:
        print(f"   Found: {obs}")
    else:
        print("   None — presheaf is fully separated")

    print("\n3. Helly Number:")
    hn = compute_helly_number(presheaf, probes)
    print(f"   Helly number: {hn}")
    print(f"   Upper bound (|P|+1): {len(probes) + 1}")

    print("\n4. Signature Analysis:")
    analysis = analyze_signatures(presheaf, probes)
    for obj, data in analysis['per_object'].items():
        print(f"   {obj}: {data['n_elements']} elems, "
              f"{data['n_distinct_sigs']} signatures, "
              f"injective={data['is_injective']}")
    print(f"   Measurement invariant: {analysis['measurement_invariant']}")
    print(f"   Total card: {analysis['objectwise_total']}")
