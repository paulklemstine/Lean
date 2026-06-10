#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Growth Regime Trichotomy

Implements the core algorithms from the research paper:
1. Type State Bound computation (tsb)
2. Growth regime classification
3. Arrow promotion (dominance transformation)
4. Balanced arrow tree construction
5. Tropical semiring mapping φ(T) = log₂(tsb(T))
"""

import math
from dataclasses import dataclass
from typing import Optional, List, Tuple


# ──────────────────────────────────────────────────────────────────────
# Type representation
# ──────────────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class Ty:
    """
    Algebraic type in the enriched STLC type system.

    Constructors:
    - 'base': atomic type with 1 state
    - 'arrow': function type A → B with (tsb(A)+1)*(tsb(B)+1) states
    - 'prod': product type A × B with tsb(A)*tsb(B) states
    - 'sum': sum type A + B with tsb(A)+tsb(B) states
    """
    kind: str
    left: Optional['Ty'] = None
    right: Optional['Ty'] = None

    def __repr__(self) -> str:
        if self.kind == 'base':
            return 'B'
        symbols = {'arrow': '→', 'prod': '×', 'sum': '+'}
        return f'({self.left} {symbols[self.kind]} {self.right})'


BASE = Ty('base')


# ──────────────────────────────────────────────────────────────────────
# Algorithm 1: Type State Bound (tsb)
# ──────────────────────────────────────────────────────────────────────

def tsb(t: Ty) -> int:
    """
    Compute the type state bound.

    The +1 regularization in the arrow case is the key mechanism that
    drives double-exponential growth. Without it, arrows would give
    only exponential growth (like products).

    Time complexity: O(n) where n = number of type constructors.
    Space complexity: O(d) where d = nesting depth (recursion stack).

    Examples:
        >>> tsb(BASE)
        1
        >>> tsb(Ty('arrow', BASE, BASE))
        4
        >>> tsb(Ty('prod', BASE, BASE))
        1
        >>> tsb(Ty('sum', BASE, BASE))
        2
    """
    if t.kind == 'base':
        return 1
    elif t.kind == 'arrow':
        return (tsb(t.left) + 1) * (tsb(t.right) + 1)
    elif t.kind == 'prod':
        return tsb(t.left) * tsb(t.right)
    elif t.kind == 'sum':
        return tsb(t.left) + tsb(t.right)
    raise ValueError(f"Unknown type kind: {t.kind}")


# ──────────────────────────────────────────────────────────────────────
# Algorithm 2: Growth Regime Classifier
# ──────────────────────────────────────────────────────────────────────

def has_arrow(t: Ty) -> bool:
    """Check if type contains any arrow constructor."""
    if t.kind == 'base':
        return False
    if t.kind == 'arrow':
        return True
    return has_arrow(t.left) or has_arrow(t.right)


def has_prod(t: Ty) -> bool:
    """Check if type contains any product constructor."""
    if t.kind == 'base':
        return False
    if t.kind == 'prod':
        return True
    return has_prod(t.left) or has_prod(t.right)


def classify_growth_regime(t: Ty) -> str:
    """
    Classify a type's growth regime.

    Returns one of:
    - 'linear': no arrows, no products (sum-only)
    - 'exponential': no arrows, has products
    - 'double-exponential': has arrows

    This is a certified classifier: the correctness theorem
    (classify_correct) guarantees that the classification matches
    the type's constructor content.

    Time complexity: O(n) where n = number of constructors.

    Examples:
        >>> classify_growth_regime(BASE)
        'linear'
        >>> classify_growth_regime(Ty('sum', BASE, BASE))
        'linear'
        >>> classify_growth_regime(Ty('prod', BASE, BASE))
        'exponential'
        >>> classify_growth_regime(Ty('arrow', BASE, BASE))
        'double-exponential'
    """
    if has_arrow(t):
        return 'double-exponential'
    elif has_prod(t):
        return 'exponential'
    else:
        return 'linear'


# ──────────────────────────────────────────────────────────────────────
# Algorithm 3: Arrow Promotion (Dominance Transformation)
# ──────────────────────────────────────────────────────────────────────

def promote(t: Ty) -> Ty:
    """
    Replace all products and sums with arrows.

    The Arrow Dominance theorem guarantees: tsb(T) ≤ tsb(promote(T))
    for all types T. This establishes arrows as the maximal-growth
    constructor.

    Time complexity: O(n) where n = number of constructors.

    Examples:
        >>> promote(Ty('prod', BASE, BASE))
        Ty(kind='arrow', left=Ty(kind='base'), right=Ty(kind='base'))
    """
    if t.kind == 'base':
        return t
    return Ty('arrow', promote(t.left), promote(t.right))


# ──────────────────────────────────────────────────────────────────────
# Algorithm 4: Balanced Arrow Tree Construction
# ──────────────────────────────────────────────────────────────────────

def balanced_arrow(n: int) -> Ty:
    """
    Construct the balanced binary arrow tree of depth n.

    These canonical types achieve doubly exponential growth:
    tsb(balancedArrow(n)) ≥ 2^(2^n) for n ≥ 1.

    The recurrence is: tsb(bal(n+1)) = (tsb(bal(n)) + 1)²

    Time complexity: O(2^n) for construction (tree has 2^n leaves).

    Examples:
        >>> tsb(balanced_arrow(0))
        1
        >>> tsb(balanced_arrow(1))
        4
        >>> tsb(balanced_arrow(2))
        25
        >>> tsb(balanced_arrow(3))
        676
    """
    if n == 0:
        return BASE
    sub = balanced_arrow(n - 1)
    return Ty('arrow', sub, sub)


# ──────────────────────────────────────────────────────────────────────
# Algorithm 5: Tropical Semiring Mapping
# ──────────────────────────────────────────────────────────────────────

def tropical_phi(t: Ty) -> float:
    """
    Compute the tropical image φ(T) = log₂(tsb(T)).

    Under this map:
    - Products map to addition: φ(A × B) = φ(A) + φ(B)
    - Sums map to tropical max (approximately): φ(A + B) ≈ max(φ(A), φ(B))
    - Arrows map to regularized addition: φ(A → B) = log₂(tsb(A)+1) + log₂(tsb(B)+1)

    The +1 regularization in the arrow case prevents polynomial degeneration
    and is responsible for the double-exponential growth regime.

    Examples:
        >>> tropical_phi(BASE)
        0.0
        >>> tropical_phi(Ty('prod', Ty('sum', BASE, BASE), Ty('sum', BASE, BASE)))
        2.0
    """
    val = tsb(t)
    if val <= 0:
        return float('-inf')
    return math.log2(val)


# ──────────────────────────────────────────────────────────────────────
# Algorithm 6: Auxiliary Measures
# ──────────────────────────────────────────────────────────────────────

def arrow_depth(t: Ty) -> int:
    """Arrow nesting depth of a type."""
    if t.kind == 'base':
        return 0
    elif t.kind == 'arrow':
        return max(arrow_depth(t.left), arrow_depth(t.right)) + 1
    else:
        return max(arrow_depth(t.left), arrow_depth(t.right))


def type_size(t: Ty) -> int:
    """Total number of constructors in a type."""
    if t.kind == 'base':
        return 1
    return type_size(t.left) + type_size(t.right) + 1


def leaf_count(t: Ty) -> int:
    """Number of base type leaves."""
    if t.kind == 'base':
        return 1
    return leaf_count(t.left) + leaf_count(t.right)


# ──────────────────────────────────────────────────────────────────────
# Usage examples
# ──────────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("=== Algorithm Examples ===\n")

    # Balanced arrow trees
    print("Balanced Arrow Trees (double-exponential witnesses):")
    for n in range(7):
        t = balanced_arrow(n)
        print(f"  n={n}: tsb = {tsb(t):>12}, φ = {tropical_phi(t):.3f}, "
              f"arrowDepth = {arrow_depth(t)}")

    # Classification examples
    print("\nGrowth Regime Classification:")
    examples = [
        ("B", BASE),
        ("B + B", Ty('sum', BASE, BASE)),
        ("B + (B + B)", Ty('sum', BASE, Ty('sum', BASE, BASE))),
        ("B × B", Ty('prod', BASE, BASE)),
        ("(B+B) × (B+B)", Ty('prod', Ty('sum', BASE, BASE), Ty('sum', BASE, BASE))),
        ("B → B", Ty('arrow', BASE, BASE)),
        ("(B→B) → (B→B)", Ty('arrow', Ty('arrow', BASE, BASE), Ty('arrow', BASE, BASE))),
    ]
    for name, t in examples:
        print(f"  {name:>20}:  regime={classify_growth_regime(t):>20}, "
              f"tsb={tsb(t):>6}")

    # Arrow dominance
    print("\nArrow Dominance (tsb(T) ≤ tsb(promote(T))):")
    for name, t in examples:
        p = promote(t)
        print(f"  {name:>20}:  tsb={tsb(t):>6}  ≤  tsb(promote)={tsb(p):>6}  "
              f"{'✓' if tsb(t) <= tsb(p) else '✗'}")
