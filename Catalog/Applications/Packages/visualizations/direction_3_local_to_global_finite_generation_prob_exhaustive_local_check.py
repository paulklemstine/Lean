#!/usr/bin/env python3
"""
Algorithms for Categorical Helly Principle

Implements the verified algorithms corresponding to the formally proved
theorems in the Lean development:

1. ExhaustiveLocalCheck — enumerate all subsets of size ≤ k, test local bound
2. MinimalObstructionSearch — find minimal bad subsets by cardinality ascent
3. HellyBoundCertifier — verify the categorical Helly theorem on concrete data
4. ProbeCapacityComputer — compute probe capacity and fiber bounds

All algorithms have explicit complexity analysis.
"""

from itertools import combinations
from math import prod
from typing import Dict, List, Optional, Set, Tuple
from dataclasses import dataclass


# =============================================================================
# Data Types
# =============================================================================

@dataclass
class PresheafData:
    """Concrete presheaf data on a finite object set.
    
    Attributes:
        objects: list of object names
        fiber_sizes: mapping object -> fiber cardinality
        restrictions: mapping (source, target) -> restriction function
                     (as a list: restrictions[(Y,Z)][i] = r(Y,Z)(i))
    """
    objects: List[str]
    fiber_sizes: Dict[str, int]
    restrictions: Dict[Tuple[str, str], List[int]]

    def total_fiber_card(self, subset: Set[str]) -> int:
        """Σ_{Y ∈ S} |F(Y)| — total fiber cardinality over a subset."""
        return sum(self.fiber_sizes[y] for y in subset)

    def global_fiber_card(self) -> int:
        """Σ_Y |F(Y)| — total fiber cardinality over all objects."""
        return sum(self.fiber_sizes.values())


@dataclass
class ProbeData:
    """A probe family: a subset of objects."""
    probes: Set[str]

    @property
    def card(self) -> int:
        return len(self.probes)

    @property
    def helly_number(self) -> int:
        """|P| + 1"""
        return self.card + 1


@dataclass
class HellyVerdict:
    """Result of the Helly bound verification."""
    separated: bool
    locally_bounded: bool
    global_card: int
    helly_bound: int
    theorem_applicable: bool
    theorem_holds: bool
    bad_subset: Optional[Set[str]] = None
    minimal_obstruction: Optional[Set[str]] = None


# =============================================================================
# Algorithm 1: Exhaustive Local Check
# =============================================================================

def exhaustive_local_check(
    F: PresheafData, k: int, n: int
) -> Tuple[bool, Optional[Set[str]]]:
    """Check LocallyRepFinGen(F, k, n) by exhaustive enumeration.
    
    Tests every subset S ⊆ Ob with |S| ≤ k and verifies totalFiberCard(F, S) ≤ n.
    
    Complexity: O(C(|Ob|, k) · k) where C is the binomial coefficient.
    For fixed k, this is O(|Ob|^k · k).
    
    Args:
        F: presheaf data
        k: radius (maximum subset size to check)
        n: bound on total fiber cardinality
    
    Returns:
        (True, None) if locally bounded, or
        (False, bad_subset) with a witnessing bad subset
    """
    for size in range(1, min(k, len(F.objects)) + 1):
        for subset in combinations(F.objects, size):
            s = set(subset)
            total = F.total_fiber_card(s)
            if total > n:
                return False, s
    return True, None


# =============================================================================
# Algorithm 2: Minimal Obstruction Search
# =============================================================================

def minimal_obstruction_search(
    F: PresheafData, n: int
) -> Optional[Set[str]]:
    """Find a minimal bad subset by ascending cardinality search.
    
    A subset S is bad if totalFiberCard(F, S) > n.
    A bad subset is minimal if no proper subset is bad.
    
    The algorithm searches subsets from smallest to largest. The first bad
    subset found at any cardinality is guaranteed to be minimal by the
    upward closure property (Theorem D): if any proper subset were bad,
    we would have found it at a smaller cardinality.
    
    Complexity: O(2^|Ob| · |Ob|) worst case.
    Expected: O(C(|Ob|, k*) · |Ob|) where k* is the minimal bad cardinality.
    
    This corresponds to the formally verified theorem:
        exists_minimal_bad_or_globally_bounded
    
    Args:
        F: presheaf data
        n: threshold
    
    Returns:
        A minimal bad subset, or None if globally bounded.
    """
    for size in range(1, len(F.objects) + 1):
        for subset in combinations(F.objects, size):
            s = set(subset)
            if F.total_fiber_card(s) > n:
                # Verify minimality by checking all elements are needed
                is_minimal = True
                for obj in list(s):
                    proper = s - {obj}
                    if proper and F.total_fiber_card(proper) > n:
                        is_minimal = False
                        break
                if is_minimal:
                    return s
    return None


# =============================================================================
# Algorithm 3: Probe Separation Check
# =============================================================================

def check_probe_separation(
    F: PresheafData, P: ProbeData
) -> Tuple[bool, Optional[Tuple[str, int, int]]]:
    """Check if probe family P separates presheaf F.
    
    For each object Y, compute probe signatures of all elements in F(Y)
    and check injectivity.
    
    Complexity: O(|Ob| · max|F(Y)| · |P|)
    
    Args:
        F: presheaf data
        P: probe family
    
    Returns:
        (True, None) if separated, or
        (False, (obj, elem1, elem2)) with a non-separated witness
    """
    sorted_probes = sorted(P.probes)
    
    for obj in F.objects:
        seen: Dict[Tuple[int, ...], int] = {}
        for elem in range(F.fiber_sizes[obj]):
            sig = tuple(
                F.restrictions.get((obj, probe), list(range(F.fiber_sizes[obj])))[elem]
                for probe in sorted_probes
            )
            if sig in seen:
                return False, (obj, seen[sig], elem)
            seen[sig] = elem
    
    return True, None


# =============================================================================
# Algorithm 4: Probe Capacity Computer
# =============================================================================

def compute_probe_capacity(F: PresheafData, P: ProbeData) -> int:
    """Compute the probe capacity: ∏_{Z ∈ P} |F(Z)|.
    
    Under separation, this bounds each individual fiber |F(Y)| ≤ probeCapacity.
    
    Complexity: O(|P|)
    """
    return prod(F.fiber_sizes[z] for z in P.probes)


# =============================================================================
# Algorithm 5: Helly Bound Certifier
# =============================================================================

def helly_bound_certifier(
    F: PresheafData, P: ProbeData, n: int
) -> HellyVerdict:
    """Full verification of the categorical Helly theorem.
    
    Checks all hypotheses and the conclusion of the main theorem:
    
        If P separates F and LocallyRepFinGen(F, |P|+1, n),
        then globalFiberCard(F) ≤ |Ob| · n^|P|.
    
    This corresponds to the formally verified theorem:
        repFinGen_of_local_on_probe_closed
    
    Complexity: O(C(|Ob|, |P|+1) · (|P|+1) + |Ob| · max|F(Y)| · |P|)
    
    Args:
        F: presheaf data
        P: probe family  
        n: local bound
    
    Returns:
        HellyVerdict with full diagnostic information
    """
    # Step 1: Check separation
    separated, witness = check_probe_separation(F, P)
    
    # Step 2: Check local bound at Helly radius
    helly_k = P.helly_number
    locally_bounded, bad_subset = exhaustive_local_check(F, helly_k, n)
    
    # Step 3: Compute global card and Helly bound
    global_card = F.global_fiber_card()
    helly_bound = len(F.objects) * (n ** P.card)
    
    # Step 4: The theorem is applicable when both hypotheses hold
    applicable = separated and locally_bounded
    holds = (not applicable) or (global_card <= helly_bound)
    
    # Step 5: If not globally bounded, find minimal obstruction
    minimal_obs = None
    if global_card > helly_bound and applicable:
        minimal_obs = minimal_obstruction_search(F, helly_bound)
    
    return HellyVerdict(
        separated=separated,
        locally_bounded=locally_bounded,
        global_card=global_card,
        helly_bound=helly_bound,
        theorem_applicable=applicable,
        theorem_holds=holds,
        bad_subset=bad_subset,
        minimal_obstruction=minimal_obs,
    )


# =============================================================================
# Algorithm 6: Candidate Global Generators from Local Data
# =============================================================================

def candidate_global_generators(
    F: PresheafData, P: ProbeData, n: int
) -> Dict[str, List[int]]:
    """Construct candidate global generating elements from local data.
    
    For each object Y, select elements whose probe signatures are
    distinct, up to the probe capacity bound. This gives a finite
    generating family of size at most probeCapacity for each fiber.
    
    Complexity: O(|Ob| · max|F(Y)| · |P|)
    
    Args:
        F: presheaf data
        P: probe family
        n: local bound (used for capacity estimation)
    
    Returns:
        Dict mapping each object to a list of generator indices
    """
    sorted_probes = sorted(P.probes)
    generators: Dict[str, List[int]] = {}
    
    for obj in F.objects:
        seen_sigs: Set[Tuple[int, ...]] = set()
        obj_gens: List[int] = []
        
        for elem in range(F.fiber_sizes[obj]):
            sig = tuple(
                F.restrictions.get((obj, probe), list(range(F.fiber_sizes[obj])))[elem]
                for probe in sorted_probes
            )
            if sig not in seen_sigs:
                seen_sigs.add(sig)
                obj_gens.append(elem)
        
        generators[obj] = obj_gens
    
    return generators


# =============================================================================
# Demo / Test
# =============================================================================

if __name__ == "__main__":
    print("Algorithms for Categorical Helly Principle")
    print("=" * 50)
    
    # Create test presheaf
    objects = ["A", "B", "C", "D"]
    fiber_sizes = {"A": 4, "B": 3, "C": 2, "D": 5}
    restrictions = {}
    for y in objects:
        for z in objects:
            sy, sz = fiber_sizes[y], fiber_sizes[z]
            restrictions[(y, z)] = [i % sz for i in range(sy)]
    
    F = PresheafData(objects, fiber_sizes, restrictions)
    P = ProbeData({"B", "C"})
    
    print(f"\nPresheaf: objects={objects}, fibers={fiber_sizes}")
    print(f"Probe family: {P.probes}, |P|={P.card}")
    print(f"Helly number: {P.helly_number}")
    
    # Run algorithms
    print("\n--- Separation Check ---")
    sep, witness = check_probe_separation(F, P)
    print(f"Separated: {sep}")
    
    print("\n--- Probe Capacity ---")
    cap = compute_probe_capacity(F, P)
    print(f"Probe capacity: {cap}")
    
    print("\n--- Helly Bound Certification ---")
    verdict = helly_bound_certifier(F, P, n=7)
    print(f"Separated: {verdict.separated}")
    print(f"Locally bounded: {verdict.locally_bounded}")
    print(f"Global card: {verdict.global_card}")
    print(f"Helly bound: {verdict.helly_bound}")
    print(f"Theorem applicable: {verdict.theorem_applicable}")
    print(f"Theorem holds: {verdict.theorem_holds}")
    
    print("\n--- Global Generators ---")
    gens = candidate_global_generators(F, P, n=7)
    for obj, g in gens.items():
        print(f"  {obj}: {len(g)} generators (indices: {g})")
    
    print("\n--- Minimal Obstruction Search ---")
    obs = minimal_obstruction_search(F, n=8)
    if obs:
        print(f"Minimal bad subset: {obs}")
        print(f"  Total fiber card: {F.total_fiber_card(obs)}")
    else:
        print("No obstruction found — globally bounded at n=8.")
