#!/usr/bin/env python3
"""
Algorithms for Causal Holography: Profile-Based Causal Reconstruction

Implements the core algorithms from the reconstruction theorems:
1. Profile computation
2. Separation verification
3. Order reconstruction
4. Cover extraction
5. Interval computation
6. Minimal separating boundary search
"""

from dataclasses import dataclass, field
from itertools import combinations
from typing import Dict, FrozenSet, List, Optional, Set, Tuple


@dataclass
class Poset:
    """
    A finite partially ordered set, stored via adjacency (Hasse diagram).

    Attributes:
        elements: list of element labels
        covers: list of (x, y) meaning x is covered by y (x ⋖ y)
    """
    elements: List[str]
    covers: List[Tuple[str, str]]
    _closure: Dict[str, Set[str]] = field(default_factory=dict, repr=False)

    def __post_init__(self):
        self._compute_closure()

    def _compute_closure(self):
        """Compute transitive closure of the cover relation."""
        self._closure = {e: {e} for e in self.elements}
        changed = True
        while changed:
            changed = False
            for a, b in self.covers:
                before = len(self._closure[a])
                self._closure[a] |= self._closure[b]
                if len(self._closure[a]) > before:
                    changed = True

    def le(self, x: str, y: str) -> bool:
        """Check x ≤ y."""
        return y in self._closure[x]

    def lt(self, x: str, y: str) -> bool:
        """Check x < y."""
        return x != y and self.le(x, y)

    def is_cover(self, x: str, y: str) -> bool:
        """Check if x ⋖ y (x is covered by y)."""
        if not self.lt(x, y):
            return False
        return not any(self.lt(x, z) and self.lt(z, y)
                       for z in self.elements)

    def interval(self, x: str, y: str) -> List[str]:
        """Compute the Alexandrov interval [x, y]."""
        return [z for z in self.elements if self.le(x, z) and self.le(z, y)]


ProfilePair = Tuple[FrozenSet[str], FrozenSet[str]]


def compute_past_profile(poset: Poset, boundary: List[str], x: str) -> FrozenSet[str]:
    """
    Compute the past profile of x relative to boundary B.

    past_B(x) = {b ∈ B : b ≤ x}

    Time complexity: O(|B|) per element
    """
    return frozenset(b for b in boundary if poset.le(b, x))


def compute_future_profile(poset: Poset, boundary: List[str], x: str) -> FrozenSet[str]:
    """
    Compute the future profile of x relative to boundary B.

    future_B(x) = {b ∈ B : x ≤ b}

    Time complexity: O(|B|) per element
    """
    return frozenset(b for b in boundary if poset.le(x, b))


def compute_profile_pair(poset: Poset, boundary: List[str], x: str) -> ProfilePair:
    """
    Compute the bi-profile Φ_B(x) = (past_B(x), future_B(x)).

    Time complexity: O(|B|) per element
    """
    return (compute_past_profile(poset, boundary, x),
            compute_future_profile(poset, boundary, x))


def compute_all_profiles(poset: Poset, boundary: List[str]) -> Dict[str, ProfilePair]:
    """
    Compute profile pairs for all elements.

    Time complexity: O(|C| · |B|)
    """
    return {x: compute_profile_pair(poset, boundary, x) for x in poset.elements}


def verify_separation(poset: Poset, boundary: List[str]) -> Tuple[bool, Optional[Tuple[str, str]]]:
    """
    Verify the boundary separation condition: Φ_B is injective.

    Returns (True, None) if separation holds, or (False, (x, y)) with a
    counterexample pair.

    Time complexity: O(|C|² · |B|)
    """
    profiles = compute_all_profiles(poset, boundary)
    seen: Dict[ProfilePair, str] = {}
    for x, p in profiles.items():
        if p in seen:
            return False, (seen[p], x)
        seen[p] = x
    return True, None


def verify_order_reflection(poset: Poset, boundary: List[str]) -> Tuple[bool, Optional[Tuple[str, str]]]:
    """
    Verify the order reflection condition:
    x ≤ y ⟺ past(x) ⊆ past(y) ∧ future(y) ⊆ future(x)

    Returns (True, None) if reflection holds, or (False, (x, y)) with
    a counterexample.

    Time complexity: O(|C|² · |B|)
    """
    profiles = compute_all_profiles(poset, boundary)
    for x in poset.elements:
        for y in poset.elements:
            px, fx = profiles[x]
            py, fy = profiles[y]
            profile_le = px.issubset(py) and fy.issubset(fx)
            if profile_le != poset.le(x, y):
                return False, (x, y)
    return True, None


def reconstruct_order(profiles: Dict[str, ProfilePair]) -> List[Tuple[str, str]]:
    """
    Reconstruct all order relations from profile data alone.

    Algorithm: For each pair (x, y), check if past(x) ⊆ past(y) and
    future(y) ⊆ future(x).

    Time complexity: O(|C|² · |B|)

    Returns: List of (x, y) pairs where x ≤ y in the reconstructed order.
    """
    relations = []
    for x, (px, fx) in profiles.items():
        for y, (py, fy) in profiles.items():
            if px.issubset(py) and fy.issubset(fx):
                relations.append((x, y))
    return relations


def reconstruct_covers(profiles: Dict[str, ProfilePair]) -> List[Tuple[str, str]]:
    """
    Reconstruct cover relations from profile data.

    Algorithm: Find pairs where x < y in profile order with no z strictly between.

    Time complexity: O(|C|³ · |B|)

    Returns: List of (x, y) pairs where x ⋖ y in the reconstructed order.
    """
    elements = list(profiles.keys())
    covers = []

    for x in elements:
        for y in elements:
            if x == y:
                continue
            px, fx = profiles[x]
            py, fy = profiles[y]
            # Check x < y
            if not (px.issubset(py) and fy.issubset(fx)):
                continue
            if px == py and fx == fy:
                continue

            # Check no z strictly between
            is_cover = True
            for z in elements:
                if z == x or z == y:
                    continue
                pz, fz = profiles[z]
                x_lt_z = (px.issubset(pz) and fz.issubset(fx) and
                          not (px == pz and fx == fz))
                z_lt_y = (pz.issubset(py) and fy.issubset(fz) and
                          not (pz == py and fz == fy))
                if x_lt_z and z_lt_y:
                    is_cover = False
                    break

            if is_cover:
                covers.append((x, y))

    return covers


def reconstruct_interval(profiles: Dict[str, ProfilePair],
                          x: str, y: str) -> List[str]:
    """
    Reconstruct the Alexandrov interval [x, y] from profile data.

    Algorithm: Find all z whose profile is between x's and y's profiles.

    Time complexity: O(|C| · |B|)
    """
    px, fx = profiles[x]
    py, fy = profiles[y]
    return [z for z, (pz, fz) in profiles.items()
            if px.issubset(pz) and pz.issubset(py) and
               fy.issubset(fz) and fz.issubset(fx)]


def find_minimal_separating_boundary(poset: Poset) -> Optional[List[str]]:
    """
    Find a minimal-cardinality antichain that separates all elements.

    Algorithm: Brute-force search over antichains of increasing size.

    Time complexity: O(|C|^k · |C|² · |C|) where k is the answer size.
    Not efficient for large posets, but correct.
    """
    for k in range(1, len(poset.elements) + 1):
        for subset in combinations(poset.elements, k):
            boundary = list(subset)
            # Check antichain
            is_ac = True
            for i, x in enumerate(boundary):
                for y in boundary[i+1:]:
                    if poset.le(x, y) or poset.le(y, x):
                        is_ac = False
                        break
                if not is_ac:
                    break
            if not is_ac:
                continue
            # Check separation
            sep, _ = verify_separation(poset, boundary)
            if sep:
                return boundary
    return None


def is_compatible_pair(past: FrozenSet[str], future: FrozenSet[str],
                       poset: Poset) -> bool:
    """Check if (past, future) is a compatible profile pair."""
    return all(poset.le(bp, bf) for bp in past for bf in future)


def enumerate_compatible_pairs(poset: Poset, boundary: List[str]) -> List[ProfilePair]:
    """
    Enumerate all compatible profile pairs.

    Time complexity: O(2^(2|B|) · |B|²)
    """
    compatible = []
    bset = frozenset(boundary)
    for r in range(len(boundary) + 1):
        for past_sub in combinations(boundary, r):
            past = frozenset(past_sub)
            for s in range(len(boundary) + 1):
                for future_sub in combinations(boundary, s):
                    future = frozenset(future_sub)
                    if is_compatible_pair(past, future, poset):
                        compatible.append((past, future))
    return compatible


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    # Build a diamond poset
    diamond = Poset(
        elements=["bot", "mid1", "mid2", "top"],
        covers=[("bot", "mid1"), ("bot", "mid2"), ("mid1", "top"), ("mid2", "top")]
    )

    boundary = ["mid1", "mid2"]

    print("=== Profile Computation ===")
    profiles = compute_all_profiles(diamond, boundary)
    for x, (p, f) in profiles.items():
        print(f"  {x}: past={set(p)}, future={set(f)}")

    print("\n=== Separation Verification ===")
    sep, counter = verify_separation(diamond, boundary)
    print(f"  Separates: {sep}")

    print("\n=== Order Reflection Verification ===")
    ref, counter = verify_order_reflection(diamond, boundary)
    print(f"  Reflects order: {ref}")

    print("\n=== Order Reconstruction ===")
    relations = reconstruct_order(profiles)
    print(f"  Reconstructed {len(relations)} order relations:")
    for x, y in relations:
        if x != y:
            print(f"    {x} ≤ {y}")

    print("\n=== Cover Reconstruction ===")
    covers = reconstruct_covers(profiles)
    print(f"  Reconstructed covers:")
    for x, y in covers:
        print(f"    {x} ⋖ {y}")

    print("\n=== Interval Reconstruction ===")
    interval = reconstruct_interval(profiles, "bot", "top")
    print(f"  [bot, top] = {interval}")

    print("\n=== Minimal Separating Boundary ===")
    min_boundary = find_minimal_separating_boundary(diamond)
    print(f"  Minimal separating boundary: {min_boundary}")

    print("\n=== Compatible Pairs ===")
    compatible = enumerate_compatible_pairs(diamond, boundary)
    realized = set(profiles.values())
    print(f"  Total compatible pairs: {len(compatible)}")
    print(f"  Realized by bulk points: {len(realized)}")
    print(f"  Interval generated: {len(compatible) == len(realized)}")
