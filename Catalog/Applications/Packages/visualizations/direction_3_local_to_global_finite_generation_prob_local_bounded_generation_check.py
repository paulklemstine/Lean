#!/usr/bin/env python3
"""
Algorithms for Categorical Helly Theory

Implements the core algorithms from the research paper:
1. Local bounded generation checker
2. Minimal bad subset finder (obstruction search)
3. Helly bound verifier
4. Probe closure computation
5. Global generator candidate builder

All algorithms operate on the discrete presheaf model where a presheaf
is a family F(Y) of finite sets indexed by objects Y, with restriction
maps r(Y,Z) : F(Y) -> F(Z).
"""

from itertools import combinations
from typing import Dict, List, Optional, Tuple, Set, FrozenSet
from dataclasses import dataclass, field
import math


# =============================================================================
# Data Types
# =============================================================================

@dataclass
class PresheafData:
    """A discrete presheaf: families of finite types with restriction maps.

    Attributes:
        objects: list of object names
        fibers: dict mapping each object to its fiber elements
        restrictions: dict mapping (Y,Z) to a function F(Y) -> F(Z)
    """
    objects: List[str]
    fibers: Dict[str, List[str]]
    restrictions: Dict[Tuple[str, str], Dict[str, str]]

    def fiber_card(self, obj: str) -> int:
        """Cardinality of the fiber at obj."""
        return len(self.fibers.get(obj, []))

    def restricted_rep_dim(self, subset: FrozenSet[str]) -> int:
        """Restricted representable dimension on a subset: Σ_{Y ∈ S} |F(Y)|."""
        return sum(self.fiber_card(y) for y in subset)

    def global_rep_dim(self) -> int:
        """Global representable dimension: Σ_Y |F(Y)|."""
        return sum(self.fiber_card(y) for y in self.objects)


@dataclass
class ProbeData:
    """A probe family: a subset of objects used for measurement/separation.

    Attributes:
        probes: list of probe object names
    """
    probes: List[str]

    @property
    def card(self) -> int:
        return len(self.probes)

    def helly_number(self) -> int:
        """The categorical Helly number |P| + 1."""
        return self.card + 1

    def probe_signature(self, presheaf: PresheafData, obj: str, elem: str) -> Tuple:
        """Compute the probe signature of elem ∈ F(obj).

        The signature records r(obj, Z)(elem) for each probe Z ∈ P.

        Time complexity: O(|P|)
        """
        sig = []
        for z in self.probes:
            r = presheaf.restrictions.get((obj, z), {})
            sig.append(r.get(elem, None))
        return tuple(sig)

    def is_separating(self, presheaf: PresheafData) -> bool:
        """Check if probe signatures are injective at every object.

        Time complexity: O(|Ob| · max|F(Y)| · |P|)
        """
        for obj in presheaf.objects:
            sigs: Set[Tuple] = set()
            for elem in presheaf.fibers.get(obj, []):
                sig = self.probe_signature(presheaf, obj, elem)
                if sig in sigs:
                    return False
                sigs.add(sig)
        return True

    def probe_capacity(self, presheaf: PresheafData) -> int:
        """Probe capacity: Π_{Z ∈ P} |F(Z)|.

        Time complexity: O(|P|)
        """
        result = 1
        for z in self.probes:
            result *= presheaf.fiber_card(z)
        return result


@dataclass
class HellyResult:
    """Result of a Helly bound verification."""
    helly_number: int
    locally_bounded: bool
    global_dim: int
    predicted_bound: int
    bound_holds: Optional[bool]
    separating: bool
    probe_capacity: int


@dataclass
class ObstructionResult:
    """Result of an obstruction search."""
    has_obstruction: bool
    minimal_bad_subsets: List[FrozenSet[str]]
    max_minimal_size: int
    bound: int
    bound_satisfied: bool


# =============================================================================
# Algorithm 1: Enumerate Subsets of Bounded Size
# =============================================================================

def enumerate_subsets(objects: List[str], max_size: int) -> List[FrozenSet[str]]:
    """Enumerate all subsets of objects with cardinality ≤ max_size.

    Time complexity: O(Σ_{k=0}^{max_size} C(|Ob|, k))
    Space complexity: O(same)

    Args:
        objects: list of object names
        max_size: maximum subset size

    Returns:
        list of frozensets representing subsets
    """
    result = []
    for k in range(min(max_size, len(objects)) + 1):
        for combo in combinations(objects, k):
            result.append(frozenset(combo))
    return result


# =============================================================================
# Algorithm 2: Check Local Bounded Generation
# =============================================================================

def check_locally_bounded(presheaf: PresheafData, k: int, n: int) -> bool:
    """Check if F is locally boundedly generated at radius k with bound n.

    Checks: ∀ S ⊆ Ob, |S| ≤ k → RestrictedRepDim(F, S) ≤ n

    Time complexity: O(Σ_{j=0}^{k} C(|Ob|, j) · j)
    Space complexity: O(C(|Ob|, k))

    Args:
        presheaf: the presheaf data
        k: radius (max subset size)
        n: bound on restricted rep dim

    Returns:
        True if locally bounded, False otherwise
    """
    for subset in enumerate_subsets(presheaf.objects, k):
        if presheaf.restricted_rep_dim(subset) > n:
            return False
    return True


# =============================================================================
# Algorithm 3: Find Bad Subsets
# =============================================================================

def find_bad_subsets(presheaf: PresheafData, n: int,
                    max_size: Optional[int] = None) -> List[FrozenSet[str]]:
    """Find all bad subsets of bounded size.

    A subset S is bad if RestrictedRepDim(F, S) > n.

    Time complexity: O(2^|Ob| · |Ob|) if max_size is None
    Space complexity: O(|bad subsets|)

    Args:
        presheaf: the presheaf data
        n: the bound
        max_size: if given, only search subsets of this size or smaller

    Returns:
        list of bad subsets (as frozensets)
    """
    if max_size is None:
        max_size = len(presheaf.objects)

    bad = []
    for subset in enumerate_subsets(presheaf.objects, max_size):
        if presheaf.restricted_rep_dim(subset) > n:
            bad.append(subset)
    return bad


# =============================================================================
# Algorithm 4: Find Minimal Bad Subsets (Obstruction Search)
# =============================================================================

def find_minimal_bad_subsets(presheaf: PresheafData,
                             n: int) -> List[FrozenSet[str]]:
    """Find all minimal bad subsets — the minimal obstructions.

    A subset S is minimal bad if S is bad but every proper subset is good.
    By the upward closure theorem, these control global failure entirely.

    Time complexity: O(2^|Ob| · |Ob|) for enumeration + filtering
    Space complexity: O(|bad subsets|)

    Pseudocode:
        1. Enumerate all bad subsets
        2. For each bad subset S, check if any proper subset is also bad
        3. If not, S is minimal bad

    Args:
        presheaf: the presheaf data
        n: the bound

    Returns:
        list of minimal bad subsets
    """
    bad = find_bad_subsets(presheaf, n)
    bad_set = set(bad)

    minimal = []
    for s in sorted(bad, key=len):  # Process smallest first
        is_min = True
        # Check all proper subsets
        for size in range(len(s)):
            for sub in combinations(s, size):
                if frozenset(sub) in bad_set:
                    is_min = False
                    break
            if not is_min:
                break
        if is_min:
            minimal.append(s)

    return minimal


# =============================================================================
# Algorithm 5: Verify Helly Bound
# =============================================================================

def verify_helly_bound(presheaf: PresheafData,
                       probe: ProbeData, n: int) -> HellyResult:
    """Verify the categorical Helly bound.

    Under probe separation: if locally bounded at radius |P|+1 with bound n,
    then GlobalRepDim(F) ≤ |Ob| · n^|P|.

    Time complexity: O(Σ_{k=0}^{|P|+1} C(|Ob|, k) · k + |Ob| · max|F(Y)| · |P|)

    Args:
        presheaf: the presheaf data
        probe: the probe family
        n: the local bound

    Returns:
        HellyResult with verification details
    """
    helly_num = probe.helly_number()
    locally_bounded = check_locally_bounded(presheaf, helly_num, n)
    global_dim = presheaf.global_rep_dim()
    predicted_bound = len(presheaf.objects) * (n ** probe.card)
    separating = probe.is_separating(presheaf)
    cap = probe.probe_capacity(presheaf)

    bound_holds = None
    if locally_bounded and separating:
        bound_holds = global_dim <= predicted_bound

    return HellyResult(
        helly_number=helly_num,
        locally_bounded=locally_bounded,
        global_dim=global_dim,
        predicted_bound=predicted_bound,
        bound_holds=bound_holds,
        separating=separating,
        probe_capacity=cap,
    )


# =============================================================================
# Algorithm 6: Compute Probe Closure
# =============================================================================

def probe_closure(probe: ProbeData, subset: FrozenSet[str]) -> FrozenSet[str]:
    """Compute the probe closure of a subset: S ∪ P.

    The probe closure is idempotent and always produces a probe-closed set.

    Time complexity: O(|S| + |P|)
    Space complexity: O(|S| + |P|)

    Args:
        probe: the probe family
        subset: the subset to close

    Returns:
        the probe closure S ∪ P
    """
    return subset | frozenset(probe.probes)


def is_probe_closed(probe: ProbeData, subset: FrozenSet[str]) -> bool:
    """Check if a subset is probe-closed: P ⊆ S.

    Time complexity: O(|P|)

    Args:
        probe: the probe family
        subset: the subset to check

    Returns:
        True if P ⊆ S
    """
    return all(p in subset for p in probe.probes)


# =============================================================================
# Algorithm 7: Build Global Generator Candidates from Local Data
# =============================================================================

def candidate_global_generators(presheaf: PresheafData,
                                 probe: ProbeData,
                                 n: int) -> Optional[Dict[str, Set[str]]]:
    """Attempt to build global generator candidates from local data.

    For each object Y, collect all elements of F(Y) that appear as generators
    in some local window of size ≤ |P|+1 containing Y. If these local
    generators are consistent (same elements across overlapping windows),
    they form a candidate global generating set.

    Time complexity: O(Σ C(|Ob|, |P|+1) · (|P|+1) · max|F(Y)|)

    Args:
        presheaf: the presheaf data
        probe: the probe family
        n: the local bound

    Returns:
        Dict mapping objects to their generator candidates, or None if
        local bounds are not satisfied.
    """
    helly_num = probe.helly_number()
    generators: Dict[str, Set[str]] = {obj: set() for obj in presheaf.objects}

    for subset in enumerate_subsets(presheaf.objects, helly_num):
        if presheaf.restricted_rep_dim(subset) <= n:
            # All elements in this window are "locally generated"
            for obj in subset:
                generators[obj].update(presheaf.fibers.get(obj, []))

    # Check if we covered everything
    for obj in presheaf.objects:
        expected = set(presheaf.fibers.get(obj, []))
        if generators[obj] != expected:
            return None  # Some elements not covered

    return generators


# =============================================================================
# Algorithm 8: Full Obstruction Analysis
# =============================================================================

def full_obstruction_analysis(presheaf: PresheafData,
                               probe: ProbeData,
                               n: int) -> ObstructionResult:
    """Complete obstruction analysis: find minimal bad subsets and verify bounds.

    Implements the Helly dichotomy: either global bound holds, or there
    exist minimal bad subsets with bounded cardinality.

    Time complexity: O(2^|Ob| · |Ob|)

    Args:
        presheaf: the presheaf data
        probe: the probe family
        n: the bound

    Returns:
        ObstructionResult with analysis details
    """
    minimals = find_minimal_bad_subsets(presheaf, n)
    has_obstruction = len(minimals) > 0
    max_size = max((len(s) for s in minimals), default=0)

    # Check if all fibers in minimal bad sets are nonempty
    all_fibers_pos = all(
        presheaf.fiber_card(y) >= 1
        for s in minimals
        for y in s
    ) if minimals else True

    # The bound: |S| ≤ n+1 when all fibers positive
    bound = n + 1
    bound_satisfied = max_size <= bound if (all_fibers_pos and has_obstruction) else True

    return ObstructionResult(
        has_obstruction=has_obstruction,
        minimal_bad_subsets=minimals,
        max_minimal_size=max_size,
        bound=bound,
        bound_satisfied=bound_satisfied,
    )


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == "__main__":
    # Create a test presheaf
    objects = ["A", "B", "C", "D"]
    fibers = {
        "A": ["a1", "a2", "a3"],
        "B": ["b1", "b2"],
        "C": ["c1"],
        "D": ["d1", "d2"],
    }
    restrictions = {}
    for y in objects:
        for z in objects:
            restrictions[(y, z)] = {
                fibers[y][i]: fibers[z][i % len(fibers[z])]
                for i in range(len(fibers[y]))
            }

    presheaf = PresheafData(objects, fibers, restrictions)
    probe = ProbeData(["A", "B"])

    print("=== Helly Bound Verification ===")
    result = verify_helly_bound(presheaf, probe, n=4)
    print(f"  Helly number: {result.helly_number}")
    print(f"  Separating: {result.separating}")
    print(f"  Locally bounded: {result.locally_bounded}")
    print(f"  Global dim: {result.global_dim}")
    print(f"  Predicted bound: {result.predicted_bound}")
    print(f"  Bound holds: {result.bound_holds}")
    print(f"  Probe capacity: {result.probe_capacity}")

    print("\n=== Obstruction Analysis ===")
    obs = full_obstruction_analysis(presheaf, probe, n=3)
    print(f"  Has obstruction: {obs.has_obstruction}")
    print(f"  Minimal bad count: {len(obs.minimal_bad_subsets)}")
    print(f"  Max minimal size: {obs.max_minimal_size}")
    print(f"  Bound (n+1): {obs.bound}")
    print(f"  Bound satisfied: {obs.bound_satisfied}")
    for mb in obs.minimal_bad_subsets:
        print(f"    → {sorted(mb)}")

    print("\n=== Probe Closure ===")
    S = frozenset(["C", "D"])
    cl = probe_closure(probe, S)
    print(f"  S = {sorted(S)}")
    print(f"  Probe closure = {sorted(cl)}")
    print(f"  Is probe-closed: {is_probe_closed(probe, cl)}")

    print("\n=== Generator Candidates ===")
    gens = candidate_global_generators(presheaf, probe, n=5)
    if gens:
        for obj, gen_set in gens.items():
            print(f"  {obj}: {sorted(gen_set)}")
