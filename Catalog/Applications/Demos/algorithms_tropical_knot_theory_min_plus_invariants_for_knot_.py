"""
Tropical Knot Theory: Algorithms for Min-Plus Knot Invariants

This module implements the core algorithms for computing tropical Jones invariants,
crossing number bounds, and diagram simplification via min-plus skein recursion.

The tropical semiring replaces polynomial addition with min and multiplication with +,
transforming knot invariants into shortest-path / dynamic programming problems.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional
import math


# ============================================================================
# Core Data Structures
# ============================================================================

@dataclass
class KnotDiagram:
    """A combinatorial knot diagram as a binary tree of crossings.

    - A leaf (loop) has no children and represents an unknotted loop.
    - An internal node (crossing) has two children: the A-resolution (left)
      and B-resolution (right).

    Each crossing shifts the Laurent degree by -1 for the A-resolution
    and +1 for the B-resolution, mirroring the Kauffman bracket variables.

    Attributes:
        is_loop: True if this is an unknotted loop (leaf node)
        left: A-resolution sub-diagram (None for loops)
        right: B-resolution sub-diagram (None for loops)
        label: Optional label for display purposes
    """
    is_loop: bool = True
    left: Optional['KnotDiagram'] = None
    right: Optional['KnotDiagram'] = None
    label: str = ""

    @staticmethod
    def loop(label: str = "○") -> 'KnotDiagram':
        """Create an unknotted loop."""
        return KnotDiagram(is_loop=True, label=label)

    @staticmethod
    def crossing(d0: 'KnotDiagram', d1: 'KnotDiagram', label: str = "×") -> 'KnotDiagram':
        """Create a crossing with A-resolution d0 and B-resolution d1."""
        return KnotDiagram(is_loop=False, left=d0, right=d1, label=label)

    @property
    def num_crossings(self) -> int:
        """Number of crossings in the diagram (internal nodes in the tree)."""
        if self.is_loop:
            return 0
        return 1 + self.left.num_crossings + self.right.num_crossings

    def resolve_a(self) -> 'KnotDiagram':
        """A-resolution of the outermost crossing."""
        if self.is_loop:
            return KnotDiagram.loop()
        return self.left

    def resolve_b(self) -> 'KnotDiagram':
        """B-resolution of the outermost crossing."""
        if self.is_loop:
            return KnotDiagram.loop()
        return self.right

    def __repr__(self) -> str:
        if self.is_loop:
            return "○"
        return f"×({self.left}, {self.right})"


# ============================================================================
# Tropical Laurent Polynomials
# ============================================================================

class TropicalLaurent:
    """A tropical Laurent polynomial: a function ℤ → ℤ ∪ {∞}.

    In the tropical (min-plus) semiring:
    - Tropical addition = pointwise min
    - Tropical multiplication = min-plus convolution
    - ∞ is the additive identity (tropical zero)
    - 0 is the multiplicative identity

    Internally stored as a dict mapping degrees to finite values.
    Missing keys have value ∞.

    Examples:
        >>> f = TropicalLaurent({0: 0})  # The tropical unit: t^0 with coefficient 0
        >>> g = TropicalLaurent({1: 3, -1: 5})  # 3·t + 5·t^{-1} tropically
        >>> (f + g).coeffs  # tropical addition = pointwise min
        {0: 0, 1: 3, -1: 5}
    """

    def __init__(self, coeffs: Optional[dict[int, int]] = None):
        """Initialize with a dict of {degree: value} pairs. Missing = ∞."""
        self.coeffs: dict[int, int] = dict(coeffs) if coeffs else {}

    def __getitem__(self, n: int) -> float:
        """Get the value at degree n (∞ if not in support)."""
        return self.coeffs.get(n, math.inf)

    def __setitem__(self, n: int, v: float):
        if v == math.inf:
            self.coeffs.pop(n, None)
        else:
            self.coeffs[n] = int(v)

    @property
    def support(self) -> set[int]:
        """The tropical support: degrees with finite value."""
        return set(self.coeffs.keys())

    @property
    def span(self) -> int:
        """The tropical span: max(support) - min(support), or 0 if empty.

        This is the key complexity measure. By our main theorem,
        span ≤ 2 * num_crossings for any knot diagram.
        """
        if not self.coeffs:
            return 0
        return max(self.coeffs.keys()) - min(self.coeffs.keys())

    def trop_add(self, other: 'TropicalLaurent') -> 'TropicalLaurent':
        """Tropical addition: pointwise minimum.

        Time complexity: O(|supp(self)| + |supp(other)|)
        """
        result = TropicalLaurent(self.coeffs.copy())
        for n, v in other.coeffs.items():
            if n in result.coeffs:
                result.coeffs[n] = min(result.coeffs[n], v)
            else:
                result.coeffs[n] = v
        return result

    def trop_mul(self, other: 'TropicalLaurent') -> 'TropicalLaurent':
        """Tropical multiplication: min-plus convolution.

        (f ⊙ g)(n) = min_{k} (f(k) + g(n-k))

        Time complexity: O(|supp(self)| · |supp(other)|)
        """
        result = TropicalLaurent()
        for k, vk in self.coeffs.items():
            for j, vj in other.coeffs.items():
                n = k + j
                new_val = vk + vj
                if n in result.coeffs:
                    result.coeffs[n] = min(result.coeffs[n], new_val)
                else:
                    result.coeffs[n] = new_val
        return result

    def shift(self, d: int, w: int = 0) -> 'TropicalLaurent':
        """Shift all degrees by d and add weight w to all values.

        shift(d, w)(n) = self(n - d) + w

        Time complexity: O(|supp(self)|)
        """
        return TropicalLaurent({n + d: v + w for n, v in self.coeffs.items()})

    def __add__(self, other: 'TropicalLaurent') -> 'TropicalLaurent':
        return self.trop_add(other)

    def __mul__(self, other: 'TropicalLaurent') -> 'TropicalLaurent':
        return self.trop_mul(other)

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, TropicalLaurent):
            return False
        return self.coeffs == other.coeffs

    def __repr__(self) -> str:
        if not self.coeffs:
            return "⊤ (tropical zero)"
        terms = []
        for n in sorted(self.coeffs.keys()):
            v = self.coeffs[n]
            terms.append(f"{v}·t^{n}")
        return " ⊕ ".join(terms)


# ============================================================================
# Tropical Jones Invariant
# ============================================================================

def tropical_jones(D: KnotDiagram) -> TropicalLaurent:
    """Compute the tropical Jones invariant of a knot diagram.

    Algorithm: recursive min-plus skein evaluation.
    - Loop: returns the tropical unit δ₀ (value 0 at degree 0)
    - Crossing(D₀, D₁): returns min(shift(tJones(D₀), +1), shift(tJones(D₁), -1))

    The degree shifts ±1 encode the A^{±1} contributions from the Kauffman bracket.

    Time complexity: O(2^c) where c = num_crossings (exponential in worst case,
    but can be memoized to O(c · span) via dynamic programming)

    Space complexity: O(c) for the recursion stack

    Args:
        D: A knot diagram

    Returns:
        The tropical Jones invariant as a TropicalLaurent polynomial

    Examples:
        >>> tropical_jones(KnotDiagram.loop())
        0·t^0
        >>> tropical_jones(KnotDiagram.crossing(KnotDiagram.loop(), KnotDiagram.loop()))
        0·t^-1 ⊕ 0·t^1
    """
    if D.is_loop:
        return TropicalLaurent({0: 0})

    # Recursive computation via skein relation
    tj_left = tropical_jones(D.left)
    tj_right = tropical_jones(D.right)

    # A-resolution: shift degree by +1 (mirroring n-1 → n after shift)
    shifted_left = tj_left.shift(1)
    # B-resolution: shift degree by -1
    shifted_right = tj_right.shift(-1)

    # Tropical addition = pointwise min
    return shifted_left.trop_add(shifted_right)


def tropical_jones_dp(D: KnotDiagram) -> TropicalLaurent:
    """Compute tropical Jones using dynamic programming with memoization.

    This exploits the shortest-path interpretation: each degree n corresponds
    to a target, and we seek the minimum cost path through the crossing tree
    that achieves that degree.

    Time complexity: O(c²) where c = num_crossings
    Space complexity: O(c) for the memoization table

    Args:
        D: A knot diagram

    Returns:
        The tropical Jones invariant (same result as tropical_jones)
    """
    memo: dict[int, TropicalLaurent] = {}

    def _compute(node: KnotDiagram, node_id: int) -> TropicalLaurent:
        if node_id in memo:
            return memo[node_id]

        if node.is_loop:
            result = TropicalLaurent({0: 0})
        else:
            tj_left = _compute(node.left, 2 * node_id + 1)
            tj_right = _compute(node.right, 2 * node_id + 2)
            result = tj_left.shift(1).trop_add(tj_right.shift(-1))

        memo[node_id] = result
        return result

    return _compute(D, 0)


# ============================================================================
# Crossing Number Bounds
# ============================================================================

def tropical_span_bound(D: KnotDiagram) -> tuple[int, int]:
    """Compute the tropical span and the crossing number bound.

    Returns (span, bound) where:
    - span = max(support) - min(support) of tJones(D)
    - bound = 2 * num_crossings(D)

    By our main theorem, span ≤ bound always holds.

    Args:
        D: A knot diagram

    Returns:
        Tuple of (tropical_span, crossing_bound)
    """
    tj = tropical_jones(D)
    return tj.span, 2 * D.num_crossings


def verify_support_bound(D: KnotDiagram) -> bool:
    """Verify the support bound: all degrees n with tJones(D)(n) < ∞ satisfy |n| ≤ c.

    This is a computational verification of Theorem B.

    Args:
        D: A knot diagram

    Returns:
        True if the bound holds (should always be True)
    """
    tj = tropical_jones(D)
    c = D.num_crossings
    for n in tj.support:
        if abs(n) > c:
            return False
    return True


# ============================================================================
# Diagram Simplification
# ============================================================================

def simplify_step(D: KnotDiagram) -> Optional[KnotDiagram]:
    """Perform one simplification step on a knot diagram.

    Resolves the outermost crossing to whichever resolution has fewer crossings.
    Returns None if the diagram is already in normal form (a loop).

    By Theorem C, each step strictly decreases num_crossings,
    so the process terminates in at most c steps.

    Args:
        D: A knot diagram

    Returns:
        Simplified diagram, or None if already in normal form
    """
    if D.is_loop:
        return None

    # Choose the resolution with fewer crossings (greedy simplification)
    if D.left.num_crossings <= D.right.num_crossings:
        return D.left
    else:
        return D.right


def full_simplification(D: KnotDiagram) -> list[KnotDiagram]:
    """Fully simplify a diagram, recording the simplification path.

    Returns the sequence of diagrams from D to the normal form (loop).
    By Theorem C, this always terminates and the final diagram is a loop.

    Time complexity: O(c) steps, each O(c) to compute num_crossings

    Args:
        D: A knot diagram

    Returns:
        List of diagrams from D to the normal form
    """
    path = [D]
    current = D
    while not current.is_loop:
        current = simplify_step(current)
        path.append(current)
    return path


# ============================================================================
# Separation Detection
# ============================================================================

def tropical_profiles_differ(D1: KnotDiagram, D2: KnotDiagram) -> Optional[int]:
    """Check if two diagrams have different tropical state-cost profiles.

    By Theorem D, if the profiles differ, the tropical Jones invariants differ.

    Args:
        D1, D2: Knot diagrams to compare

    Returns:
        A separating degree n where tJones(D1)(n) ≠ tJones(D2)(n),
        or None if the profiles are identical
    """
    tj1 = tropical_jones(D1)
    tj2 = tropical_jones(D2)

    all_degrees = tj1.support | tj2.support
    for n in sorted(all_degrees):
        if tj1[n] != tj2[n]:
            return n
    return None


# ============================================================================
# Standard Diagram Library
# ============================================================================

def make_chain(n: int) -> KnotDiagram:
    """Create a chain of n crossings (left-leaning).

    The chain of n crossings is:
    ×(×(×(...×(○, ○)..., ○), ○), ○)

    This models a sequence of twist crossings.

    Args:
        n: Number of crossings (≥ 0)

    Returns:
        A chain knot diagram with n crossings
    """
    if n == 0:
        return KnotDiagram.loop()
    D = KnotDiagram.crossing(KnotDiagram.loop(), KnotDiagram.loop())
    for _ in range(n - 1):
        D = KnotDiagram.crossing(D, KnotDiagram.loop())
    return D


def make_balanced(n: int) -> KnotDiagram:
    """Create a balanced binary tree of n crossings.

    For n = 2^k - 1, this gives a perfect binary tree.
    This models a "parallel" crossing structure.

    Args:
        n: Number of crossings (≥ 0)

    Returns:
        A balanced knot diagram with approximately n crossings
    """
    if n == 0:
        return KnotDiagram.loop()
    if n == 1:
        return KnotDiagram.crossing(KnotDiagram.loop(), KnotDiagram.loop())
    left_size = (n - 1) // 2
    right_size = n - 1 - left_size
    return KnotDiagram.crossing(make_balanced(left_size), make_balanced(right_size))


def make_alternating_chain(n: int) -> KnotDiagram:
    """Create an alternating chain: crossings alternate between
    left-leaning and right-leaning structures.

    Args:
        n: Number of crossings

    Returns:
        An alternating chain diagram
    """
    if n == 0:
        return KnotDiagram.loop()
    if n == 1:
        return KnotDiagram.crossing(KnotDiagram.loop(), KnotDiagram.loop())
    D = KnotDiagram.crossing(KnotDiagram.loop(), KnotDiagram.loop())
    for i in range(1, n):
        if i % 2 == 0:
            D = KnotDiagram.crossing(D, KnotDiagram.loop())
        else:
            D = KnotDiagram.crossing(KnotDiagram.loop(), D)
    return D


if __name__ == "__main__":
    print("=== Tropical Knot Theory: Algorithm Demonstrations ===\n")

    # Basic examples
    loop = KnotDiagram.loop()
    single = KnotDiagram.crossing(loop, loop)

    print("Unknot (loop):")
    print(f"  tJones = {tropical_jones(loop)}")
    print(f"  crossings = {loop.num_crossings}")

    print("\nSingle crossing:")
    print(f"  tJones = {tropical_jones(single)}")
    print(f"  crossings = {single.num_crossings}")

    # Chain diagrams
    for n in range(1, 7):
        D = make_chain(n)
        tj = tropical_jones(D)
        span, bound = tropical_span_bound(D)
        print(f"\nChain({n}): crossings={D.num_crossings}, span={span}, bound={bound}")
        print(f"  tJones = {tj}")
        print(f"  Support bound verified: {verify_support_bound(D)}")

    # Simplification
    D = make_chain(4)
    print(f"\nSimplification of Chain(4):")
    path = full_simplification(D)
    for i, step in enumerate(path):
        print(f"  Step {i}: {step.num_crossings} crossings")

    # Separation detection
    D1 = make_chain(3)
    D2 = make_balanced(3)
    sep = tropical_profiles_differ(D1, D2)
    print(f"\nSeparation: Chain(3) vs Balanced(3)")
    print(f"  tJones(Chain(3)) = {tropical_jones(D1)}")
    print(f"  tJones(Balanced(3)) = {tropical_jones(D2)}")
    if sep is not None:
        print(f"  Separated at degree {sep}")
    else:
        print(f"  Same tropical profile")
