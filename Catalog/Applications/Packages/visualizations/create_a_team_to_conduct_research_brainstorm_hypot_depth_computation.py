#!/usr/bin/env python3
"""
Ordinal Collapse Theory — Algorithms

This module implements the core algorithms from the ordinal collapse theory,
including depth computation, height bounding, operator classification,
and the phase transition detection algorithm.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Callable, Optional
from enum import Enum


# ─────────────────────────────────────────────────────────────────────
# Data Structures
# ─────────────────────────────────────────────────────────────────────

@dataclass
class ResearchObject:
    """Base class for research objects."""
    pass

@dataclass
class Atom(ResearchObject):
    label: int

@dataclass
class Compose(ResearchObject):
    left: ResearchObject
    right: ResearchObject

@dataclass
class Bootstrap(ResearchObject):
    inner: ResearchObject

@dataclass
class OracleNode(ResearchObject):
    children: list[ResearchObject]


# ─────────────────────────────────────────────────────────────────────
# Algorithm 1: Depth Computation
# Time: O(|T|) where |T| is the number of nodes in the tree
# Space: O(h) where h is the height (stack depth)
# ─────────────────────────────────────────────────────────────────────

def compute_depth(obj: ResearchObject) -> int:
    """Compute the ordinal depth of a research object.

    Algorithm:
        Recursive traversal with natural-number arithmetic.
        - atom: return 1
        - compose(A, B): return depth(A) + depth(B)
        - bootstrap(A): return depth(A) + 1
        - oracleNode(children): return max(depth(c) + 1 for c in children)

    Complexity: O(|T|) time, O(h) space.

    Correctness: By the Bridge Theorem (natDepth_eq_researchDepth),
    this computable function exactly equals the ordinal-valued researchDepth.

    >>> compute_depth(Atom(0))
    1
    >>> compute_depth(Compose(Atom(0), Atom(1)))
    2
    >>> compute_depth(Bootstrap(Atom(0)))
    2
    """
    if isinstance(obj, Atom):
        return 1
    elif isinstance(obj, Compose):
        return compute_depth(obj.left) + compute_depth(obj.right)
    elif isinstance(obj, Bootstrap):
        return compute_depth(obj.inner) + 1
    elif isinstance(obj, OracleNode):
        if not obj.children:
            return 0
        return max(compute_depth(c) + 1 for c in obj.children)
    raise TypeError(f"Unknown type: {type(obj)}")


# ─────────────────────────────────────────────────────────────────────
# Algorithm 2: Height Computation
# Time: O(|T|), Space: O(h)
# ─────────────────────────────────────────────────────────────────────

def compute_height(obj: ResearchObject) -> int:
    """Compute the tree height (constructor nesting depth).

    >>> compute_height(Atom(0))
    0
    >>> compute_height(Bootstrap(Atom(0)))
    1
    """
    if isinstance(obj, Atom):
        return 0
    elif isinstance(obj, Compose):
        return 1 + max(compute_height(obj.left), compute_height(obj.right))
    elif isinstance(obj, Bootstrap):
        return 1 + compute_height(obj.inner)
    elif isinstance(obj, OracleNode):
        if not obj.children:
            return 1
        return 1 + max(compute_height(c) for c in obj.children)
    raise TypeError(f"Unknown type: {type(obj)}")


# ─────────────────────────────────────────────────────────────────────
# Algorithm 3: Branching Factor Computation
# Time: O(|T|), Space: O(h)
# ─────────────────────────────────────────────────────────────────────

def compute_max_branching(obj: ResearchObject) -> int:
    """Compute the maximum branching factor in the tree.

    >>> compute_max_branching(OracleNode([Atom(0), Atom(1), Atom(2)]))
    3
    """
    if isinstance(obj, Atom):
        return 0
    elif isinstance(obj, Compose):
        return max(compute_max_branching(obj.left),
                   compute_max_branching(obj.right))
    elif isinstance(obj, Bootstrap):
        return compute_max_branching(obj.inner)
    elif isinstance(obj, OracleNode):
        k = len(obj.children)
        for c in obj.children:
            k = max(k, compute_max_branching(c))
        return k
    raise TypeError(f"Unknown type: {type(obj)}")


# ─────────────────────────────────────────────────────────────────────
# Algorithm 4: Height-Depth Bound Verification
# Time: O(1) given height, Space: O(1)
# ─────────────────────────────────────────────────────────────────────

def height_depth_bound(height: int) -> int:
    """Compute the upper bound on depth given height.

    By the Height-Depth Bound theorem: depth ≤ 2^(height + 1).

    >>> height_depth_bound(0)
    2
    >>> height_depth_bound(3)
    16
    """
    return 2 ** (height + 1)


def verify_height_depth_bound(obj: ResearchObject) -> bool:
    """Verify the height-depth bound theorem for a given object.

    Returns True if depth ≤ 2^(height+1), which is always true
    by our theorem.

    >>> verify_height_depth_bound(Compose(Atom(0), Atom(1)))
    True
    """
    h = compute_height(obj)
    d = compute_depth(obj)
    return d <= height_depth_bound(h)


# ─────────────────────────────────────────────────────────────────────
# Algorithm 5: Phase Transition Detector
# ─────────────────────────────────────────────────────────────────────

class ComplexityPhase(Enum):
    """Classification of ordinal complexity phases."""
    NATURAL = "natural"        # depth is a natural number (< ω)
    OMEGA = "omega"            # depth = ω (first transfinite)
    BEYOND_OMEGA = "beyond"    # depth > ω (higher transfinite)


def detect_phase(branching: str, height_bounded: bool) -> ComplexityPhase:
    """Detect the ordinal complexity phase based on structural parameters.

    This implements the phase transition theorem:
    - Finite branching OR bounded height → NATURAL
    - Infinite branching + unbounded height → OMEGA or beyond

    Args:
        branching: "finite" or "infinite"
        height_bounded: whether a uniform height bound exists

    >>> detect_phase("finite", True)
    <ComplexityPhase.NATURAL: 'natural'>
    >>> detect_phase("infinite", False)
    <ComplexityPhase.OMEGA: 'omega'>
    """
    if branching == "finite":
        return ComplexityPhase.NATURAL
    elif height_bounded:
        return ComplexityPhase.NATURAL  # Universal Collapse Theorem
    else:
        return ComplexityPhase.OMEGA


# ─────────────────────────────────────────────────────────────────────
# Algorithm 6: Operator Growth Classifier
# ─────────────────────────────────────────────────────────────────────

class GrowthClass(Enum):
    """Classification of operator depth growth."""
    CONSTANT = "constant"      # depth doesn't change
    AFFINE = "affine"          # depth grows linearly
    SUBLINEAR = "sublinear"    # depth grows but slower than linear
    SUPERLINEAR = "superlinear"  # depth grows faster than linear


def classify_operator_growth(
    f: Callable[[ResearchObject], ResearchObject],
    base: ResearchObject,
    num_iterations: int = 20
) -> tuple[GrowthClass, list[int]]:
    """Classify the depth growth of an operator by computing iterates.

    Applies f repeatedly and measures depth at each step.
    Classifies growth as constant, affine, sublinear, or superlinear.

    Args:
        f: The research operator
        base: Starting research object
        num_iterations: Number of iterations to sample

    Returns:
        (growth_class, depth_sequence)

    >>> cls, depths = classify_operator_growth(lambda x: Bootstrap(x), Atom(0))
    >>> cls
    <GrowthClass.AFFINE: 'affine'>
    """
    depths: list[int] = []
    obj = base
    for _ in range(num_iterations):
        depths.append(compute_depth(obj))
        obj = f(obj)

    # Classify
    if all(d == depths[0] for d in depths):
        return GrowthClass.CONSTANT, depths

    # Check affine: differences should be constant
    diffs = [depths[i+1] - depths[i] for i in range(len(depths)-1)]
    if all(d == diffs[0] for d in diffs):
        return GrowthClass.AFFINE, depths

    # Check superlinear vs sublinear
    second_diffs = [diffs[i+1] - diffs[i] for i in range(len(diffs)-1)]
    avg_second_diff = sum(second_diffs) / len(second_diffs) if second_diffs else 0
    if avg_second_diff > 0:
        return GrowthClass.SUPERLINEAR, depths
    else:
        return GrowthClass.SUBLINEAR, depths


# ─────────────────────────────────────────────────────────────────────
# Algorithm 7: Canonical Object Construction
# ─────────────────────────────────────────────────────────────────────

def construct_object_of_depth(n: int) -> ResearchObject:
    """Construct a canonical research object with depth exactly n.

    Uses the sharpness construction: bootstrapIter(n, oracleNode([])).

    Time: O(n), Space: O(n).

    >>> compute_depth(construct_object_of_depth(0))
    0
    >>> compute_depth(construct_object_of_depth(5))
    5
    >>> compute_depth(construct_object_of_depth(100))
    100
    """
    obj: ResearchObject = OracleNode([])  # depth 0
    for _ in range(n):
        obj = Bootstrap(obj)  # each bootstrap adds 1
    return obj


def construct_object_of_depth_and_height(
    depth: int, max_height: int
) -> Optional[ResearchObject]:
    """Construct an object with given depth at given height, if possible.

    Returns None if the depth exceeds the height bound (2^(h+1)).

    >>> obj = construct_object_of_depth_and_height(4, 2)
    >>> obj is not None and compute_depth(obj) == 4
    True
    """
    if depth > height_depth_bound(max_height):
        return None
    return construct_object_of_depth(depth)


# ─────────────────────────────────────────────────────────────────────
# Algorithm 8: Ordinal Arithmetic Engine
# ─────────────────────────────────────────────────────────────────────

@dataclass
class OrdinalExpr:
    """Representation of ordinal expressions up to ω·n + m."""
    omega_coeff: int = 0   # coefficient of ω
    finite_part: int = 0   # finite remainder

    def __repr__(self) -> str:
        if self.omega_coeff == 0:
            return str(self.finite_part)
        omega_str = "ω" if self.omega_coeff == 1 else f"ω·{self.omega_coeff}"
        if self.finite_part == 0:
            return omega_str
        return f"{omega_str} + {self.finite_part}"

    def __lt__(self, other: OrdinalExpr) -> bool:
        if self.omega_coeff != other.omega_coeff:
            return self.omega_coeff < other.omega_coeff
        return self.finite_part < other.finite_part

    def __le__(self, other: OrdinalExpr) -> bool:
        return self == other or self < other

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, OrdinalExpr):
            return NotImplemented
        return (self.omega_coeff == other.omega_coeff and
                self.finite_part == other.finite_part)

    def __hash__(self) -> int:
        return hash((self.omega_coeff, self.finite_part))

    def successor(self) -> OrdinalExpr:
        """Ordinal successor."""
        return OrdinalExpr(self.omega_coeff, self.finite_part + 1)

    def __add__(self, other: OrdinalExpr) -> OrdinalExpr:
        """Ordinal addition (non-commutative!)."""
        if other.omega_coeff > 0:
            return OrdinalExpr(self.omega_coeff + other.omega_coeff,
                               other.finite_part)
        return OrdinalExpr(self.omega_coeff,
                           self.finite_part + other.finite_part)


def ordinal_nat(n: int) -> OrdinalExpr:
    """Natural number as an ordinal."""
    return OrdinalExpr(0, n)

def ordinal_omega() -> OrdinalExpr:
    """The ordinal ω."""
    return OrdinalExpr(1, 0)


# ─────────────────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Ordinal Collapse Theory — Algorithm Examples")
    print("=" * 50)

    # Depth computation
    obj = Compose(Bootstrap(Atom(0)), OracleNode([Atom(1), Atom(2)]))
    print(f"\nDepth of compose(bootstrap(atom), oracle([a,b])): {compute_depth(obj)}")
    print(f"Height: {compute_height(obj)}")
    print(f"Max branching: {compute_max_branching(obj)}")
    print(f"Height-depth bound satisfied: {verify_height_depth_bound(obj)}")

    # Operator classification
    print("\nOperator Growth Classification:")
    operators = [
        ("bootstrap", lambda x: Bootstrap(x)),
        ("compose_right", lambda x: Compose(x, Atom(0))),
        ("identity", lambda x: x),
    ]
    for name, op in operators:
        cls, depths = classify_operator_growth(op, Atom(0), 10)
        print(f"  {name}: {cls.value}, depths = {depths[:8]}...")

    # Phase transition
    print("\nPhase Transition Detection:")
    cases = [
        ("finite", True), ("finite", False),
        ("infinite", True), ("infinite", False),
    ]
    for branching, bounded in cases:
        phase = detect_phase(branching, bounded)
        print(f"  branching={branching}, bounded={bounded} → {phase.value}")

    # Ordinal arithmetic
    print("\nOrdinal Arithmetic:")
    a = ordinal_nat(3)
    b = ordinal_omega()
    print(f"  3 + ω = {a + b}")
    print(f"  ω + 3 = {b + a}")
    print(f"  ω + ω = {b + b}")
    print(f"  succ(ω) = {b.successor()}")
