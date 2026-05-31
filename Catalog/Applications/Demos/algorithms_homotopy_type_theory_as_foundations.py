"""
Algorithms for Homotopy Type Theory Foundations

Implements core HoTT algorithms: winding number computation,
truncation level classification, structural equivalence checking,
and foundational system comparison.
"""

from typing import List, Tuple, Optional, Dict, Set
from itertools import permutations
from dataclasses import dataclass
from enum import IntEnum
import math


# ============================================================
# Algorithm 1: Winding Number Computation
# ============================================================

def winding_number(loop: List[bool]) -> int:
    """
    Compute the winding number of a formal loop on S¹.

    Each True represents a forward step (+1), each False a backward step (-1).
    The winding number is the net displacement.

    This implements the group homomorphism π₁(S¹) → ℤ.

    Args:
        loop: List of boolean steps (True=forward, False=backward)

    Returns:
        The winding number (integer)

    Examples:
        >>> winding_number([True, True, False])
        1
        >>> winding_number([])
        0
        >>> winding_number([False, False, False])
        -3
    """
    acc = 0
    for step in loop:
        acc += 1 if step else -1
    return acc


def make_loop_with_winding(n: int) -> List[bool]:
    """
    Construct a canonical formal loop with given winding number.

    This demonstrates the surjectivity of the winding number map:
    every integer is realized as a winding number.

    Args:
        n: Target winding number

    Returns:
        A list of boolean steps with winding number n
    """
    if n >= 0:
        return [True] * n
    else:
        return [False] * (-n)


def loop_concat(l1: List[bool], l2: List[bool]) -> List[bool]:
    """Concatenate two formal loops."""
    return l1 + l2


def loop_reverse(loop: List[bool]) -> List[bool]:
    """Reverse a formal loop (path inverse)."""
    return [not b for b in reversed(loop)]


def verify_winding_properties(loop: List[bool]) -> Dict[str, bool]:
    """
    Verify the key winding number properties for a given loop.

    Returns a dict of property names to verification results.
    """
    w = winding_number(loop)
    rev = loop_reverse(loop)
    w_rev = winding_number(rev)

    concat_rev = loop_concat(loop, rev)
    w_concat_rev = winding_number(concat_rev)

    canonical = make_loop_with_winding(w)
    w_canonical = winding_number(canonical)

    return {
        "inverse_negates": w_rev == -w,
        "concat_reverse_zero": w_concat_rev == 0,
        "surjectivity": w_canonical == w,
    }


# ============================================================
# Algorithm 2: Truncation Level Classification
# ============================================================

class TruncationLevel(IntEnum):
    """Truncation levels from HoTT."""
    CONTRACTIBLE = 0  # Level -2
    PROPOSITION = 1   # Level -1
    SET = 2           # Level 0
    GROUPOID = 3      # Level 1


def classify_truncation_level(
    elements: Set[str],
    equalities: Dict[Tuple[str, str], Set[str]]
) -> TruncationLevel:
    """
    Classify the truncation level of a discrete type.

    Args:
        elements: The elements of the type
        equalities: For each pair (a,b), the set of "paths" between them.
                   Empty set means a ≠ b.

    Returns:
        The truncation level

    The classification:
    - Contractible: exactly one element, one self-path
    - Proposition: at most one element (up to paths)
    - Set: possibly multiple elements, but each equality is unique
    - Groupoid: equalities can have multiple witnesses
    """
    if len(elements) == 0:
        return TruncationLevel.CONTRACTIBLE

    # Check contractible: one element, one self-path
    if len(elements) == 1:
        elem = next(iter(elements))
        paths = equalities.get((elem, elem), set())
        if len(paths) <= 1:
            return TruncationLevel.CONTRACTIBLE

    # Check if all equalities have at most one path
    max_paths = 0
    connected_components = 0
    for a in elements:
        for b in elements:
            paths = equalities.get((a, b), set())
            max_paths = max(max_paths, len(paths))

    # Check proposition: at most one element up to paths
    # (all elements are connected)
    all_connected = True
    for a in elements:
        for b in elements:
            if a != b and len(equalities.get((a, b), set())) == 0:
                all_connected = False
                break

    if all_connected and len(elements) <= 1:
        return TruncationLevel.PROPOSITION

    if max_paths <= 1:
        return TruncationLevel.SET

    return TruncationLevel.GROUPOID


# ============================================================
# Algorithm 3: Structural Equivalence Checker (FinGroupEquiv)
# ============================================================

def check_fin_group_equiv(
    n: int,
    op1: List[List[int]],
    op2: List[List[int]]
) -> Optional[List[int]]:
    """
    Check if two Fin n-indexed binary operations are structurally equivalent.

    Tests all permutations σ of {0,...,n-1} to find one satisfying:
        σ(op1(i,j)) = op2(σ(i), σ(j)) for all i, j

    Args:
        n: Size of the domain
        op1: First operation as n×n matrix (op1[i][j] = result)
        op2: Second operation as n×n matrix

    Returns:
        The permutation σ as a list, or None if not equivalent
    """
    if n == 0:
        return []

    for perm in permutations(range(n)):
        sigma = list(perm)
        is_equiv = True
        for i in range(n):
            for j in range(n):
                if sigma[op1[i][j]] != op2[sigma[i]][sigma[j]]:
                    is_equiv = False
                    break
            if not is_equiv:
                break
        if is_equiv:
            return sigma

    return None


def verify_equiv_relation(
    n: int,
    op1: List[List[int]],
    op2: List[List[int]],
    op3: List[List[int]]
) -> Dict[str, bool]:
    """
    Verify the equivalence relation properties of FinGroupEquiv.
    """
    refl = check_fin_group_equiv(n, op1, op1) is not None
    sym_12 = check_fin_group_equiv(n, op1, op2) is not None
    sym_21 = check_fin_group_equiv(n, op2, op1) is not None
    trans = True
    if sym_12 and check_fin_group_equiv(n, op2, op3) is not None:
        trans = check_fin_group_equiv(n, op1, op3) is not None

    return {
        "reflexive": refl,
        "symmetric": sym_12 == sym_21,
        "transitive": trans,
    }


# ============================================================
# Algorithm 4: Foundational System Comparison
# ============================================================

@dataclass
class FoundationalSystem:
    """A mathematical foundational system."""
    name: str
    strength: int
    is_constructive: bool
    has_univalence: bool
    has_choice: bool

    def __le__(self, other: 'FoundationalSystem') -> bool:
        return self.strength <= other.strength

    def __lt__(self, other: 'FoundationalSystem') -> bool:
        return self.strength < other.strength

    def features(self) -> Set[str]:
        result = set()
        if self.is_constructive:
            result.add("constructive")
        if self.has_univalence:
            result.add("univalence")
        if self.has_choice:
            result.add("choice")
        return result


# Standard foundational systems
ZFC = FoundationalSystem("ZFC", 100, False, False, True)
MLTT = FoundationalSystem("MLTT", 80, True, False, False)
HOTT = FoundationalSystem("HoTT", 100, True, True, False)
HOTT_LEM = FoundationalSystem("HoTT+LEM", 100, False, True, True)
CIC = FoundationalSystem("CIC", 90, True, False, False)


def compare_foundations(
    systems: List[FoundationalSystem]
) -> Dict[str, any]:
    """
    Compare foundational systems by strength and features.

    Returns analysis including ordering, equiconsistency classes,
    and feature coverage.
    """
    sorted_systems = sorted(systems, key=lambda s: s.strength)

    # Find equiconsistency classes
    equiv_classes: Dict[int, List[str]] = {}
    for s in systems:
        if s.strength not in equiv_classes:
            equiv_classes[s.strength] = []
        equiv_classes[s.strength].append(s.name)

    # Find which features each strength level has
    strength_features: Dict[int, Set[str]] = {}
    for s in systems:
        if s.strength not in strength_features:
            strength_features[s.strength] = set()
        strength_features[s.strength] |= s.features()

    return {
        "ordering": [s.name for s in sorted_systems],
        "equiconsistency_classes": equiv_classes,
        "strength_features": {k: list(v) for k, v in strength_features.items()},
        "max_strength": max(s.strength for s in systems),
        "constructive_systems": [s.name for s in systems if s.is_constructive],
        "univalent_systems": [s.name for s in systems if s.has_univalence],
    }


# ============================================================
# Algorithm 5: Fiber Analysis
# ============================================================

def compute_fibers(
    domain: List[any],
    codomain: List[any],
    f: callable
) -> Dict[any, List[any]]:
    """
    Compute the fibers of a function f: domain → codomain.

    The fiber over b is {a ∈ domain | f(a) = b}.
    """
    fibers: Dict[any, List[any]] = {b: [] for b in codomain}
    for a in domain:
        b = f(a)
        if b in fibers:
            fibers[b].append(a)
    return fibers


def check_bijective_via_fibers(
    domain: List[any],
    codomain: List[any],
    f: callable
) -> Tuple[bool, Dict[str, any]]:
    """
    Check bijectivity using the fiber characterization.

    A function is bijective iff every fiber has exactly one element.

    Returns (is_bijective, diagnostic_info)
    """
    fibers = compute_fibers(domain, codomain, f)

    empty_fibers = [b for b, fiber in fibers.items() if len(fiber) == 0]
    singleton_fibers = [b for b, fiber in fibers.items() if len(fiber) == 1]
    multi_fibers = [b for b, fiber in fibers.items() if len(fiber) > 1]

    is_bijective = len(empty_fibers) == 0 and len(multi_fibers) == 0

    return is_bijective, {
        "empty_fibers": len(empty_fibers),
        "singleton_fibers": len(singleton_fibers),
        "multi_fibers": len(multi_fibers),
        "is_injective": len(multi_fibers) == 0,
        "is_surjective": len(empty_fibers) == 0,
    }


if __name__ == "__main__":
    # Quick self-test
    assert winding_number([True, True, False]) == 1
    assert winding_number([]) == 0
    assert winding_number(make_loop_with_winding(5)) == 5
    assert winding_number(make_loop_with_winding(-3)) == -3

    props = verify_winding_properties([True, False, True, True, False])
    assert all(props.values())

    # Z/3Z addition vs Z/3Z addition (should be equivalent to itself)
    z3_add = [[0, 1, 2], [1, 2, 0], [2, 0, 1]]
    assert check_fin_group_equiv(3, z3_add, z3_add) is not None

    comparison = compare_foundations([ZFC, MLTT, HOTT, HOTT_LEM, CIC])
    assert "HoTT" in comparison["univalent_systems"]

    print("All self-tests passed!")
