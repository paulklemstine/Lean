#!/usr/bin/env python3
"""
Proof-Theoretic Depth: Core Algorithms

Implements the ResearchExpr calculus, ordinal depth computation,
innovation scoring, and governance policies.

All algorithms mirror the formally verified definitions in
the accompanying formalization.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import List, Optional, Tuple
from functools import total_ordering


# ─────────────────────────────────────────────────────────
# Ordinal Value Representation
# ─────────────────────────────────────────────────────────

@total_ordering
class OrdinalValue:
    """
    Represents ordinals in Cantor Normal Form (CNF):
        ω^a₁·c₁ + ω^a₂·c₂ + ... + ω^aₙ·cₙ
    where a₁ > a₂ > ... > aₙ and each cᵢ is a positive integer.

    Stored as a list of (exponent, coefficient) pairs in decreasing
    exponent order. The exponents are themselves OrdinalValues,
    enabling representation of ordinals up to ε₀.

    Examples:
        0       → []
        5       → [(0, 5)]
        ω       → [(1, 1)]      where 1 means OrdinalValue for 1
        ω·3     → [(1, 3)]
        ω² + 1  → [(2, 1), (0, 1)]
        ω^ω     → [(ω, 1)]
    """

    def __init__(self, terms: Optional[List[Tuple['OrdinalValue', int]]] = None):
        """Initialize with CNF terms [(exponent, coefficient), ...] in decreasing order."""
        self.terms: List[Tuple[OrdinalValue, int]] = terms or []
        # Normalize: remove zero coefficients
        self.terms = [(e, c) for e, c in self.terms if c > 0]

    @staticmethod
    def zero() -> 'OrdinalValue':
        return OrdinalValue([])

    @staticmethod
    def from_nat(n: int) -> 'OrdinalValue':
        if n == 0:
            return OrdinalValue.zero()
        return OrdinalValue([(OrdinalValue.zero(), n)])

    @staticmethod
    def omega() -> 'OrdinalValue':
        """Returns ω."""
        return OrdinalValue([(OrdinalValue.from_nat(1), 1)])

    @staticmethod
    def omega_power(exp: 'OrdinalValue') -> 'OrdinalValue':
        """Returns ω^exp."""
        if exp == OrdinalValue.zero():
            return OrdinalValue.from_nat(1)
        return OrdinalValue([(exp, 1)])

    def is_zero(self) -> bool:
        return len(self.terms) == 0

    def is_finite(self) -> bool:
        """Check if this ordinal is a natural number (< ω)."""
        if self.is_zero():
            return True
        return len(self.terms) == 1 and self.terms[0][0].is_zero()

    def to_nat(self) -> Optional[int]:
        """Convert to natural number if finite, else None."""
        if self.is_zero():
            return 0
        if self.is_finite():
            return self.terms[0][1]
        return None

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, OrdinalValue):
            return NotImplemented
        if len(self.terms) != len(other.terms):
            return False
        return all(e1 == e2 and c1 == c2
                   for (e1, c1), (e2, c2) in zip(self.terms, other.terms))

    def __lt__(self, other: 'OrdinalValue') -> bool:
        """Lexicographic comparison on CNF terms."""
        for i in range(max(len(self.terms), len(other.terms))):
            if i >= len(self.terms):
                return True  # self has fewer terms → self is smaller
            if i >= len(other.terms):
                return False
            e1, c1 = self.terms[i]
            e2, c2 = other.terms[i]
            if e1 != e2:
                return e1 < e2 if e1 < e2 else False  # noqa
            if e1 < e2:
                return True
            if e2 < e1:
                return False
            if c1 != c2:
                return c1 < c2
        return False

    def __hash__(self) -> int:
        return hash(str(self))

    def successor(self) -> 'OrdinalValue':
        """Returns self + 1."""
        return self + OrdinalValue.from_nat(1)

    def __add__(self, other: 'OrdinalValue') -> 'OrdinalValue':
        """Ordinal addition (not commutative!)."""
        if self.is_zero():
            return other
        if other.is_zero():
            return self

        # Find where other's leading term fits in self's terms
        other_lead_exp = other.terms[0][0]

        # Keep terms of self whose exponent is strictly greater than other's leading exponent
        kept = [(e, c) for e, c in self.terms if e > other_lead_exp]

        # If self has a term with the same exponent as other's leading term,
        # it gets absorbed (ordinal addition: ω^a · m + ω^a · n = ω^a · (m+n) only if a = leading)
        self_same = [(e, c) for e, c in self.terms if e == other_lead_exp]
        if self_same:
            # Add coefficients for the matching exponent
            new_coeff = self_same[0][1] + other.terms[0][1]
            result_terms = kept + [(other_lead_exp, new_coeff)] + other.terms[1:]
        else:
            result_terms = kept + other.terms

        return OrdinalValue(result_terms)

    def __repr__(self) -> str:
        if self.is_zero():
            return "0"
        parts = []
        for exp, coeff in self.terms:
            if exp.is_zero():
                parts.append(str(coeff))
            elif exp == OrdinalValue.from_nat(1):
                if coeff == 1:
                    parts.append("ω")
                else:
                    parts.append(f"ω·{coeff}")
            else:
                exp_str = str(exp)
                if coeff == 1:
                    parts.append(f"ω^{exp_str}")
                else:
                    parts.append(f"ω^{exp_str}·{coeff}")
        return " + ".join(parts)


# ─────────────────────────────────────────────────────────
# Research Expression Syntax
# ─────────────────────────────────────────────────────────

class ResearchExpr:
    """Base class for research expressions."""
    pass


@dataclass
class Atom(ResearchExpr):
    """Atomic statement."""
    n: int


@dataclass
class Compose(ResearchExpr):
    """Sequential composition of two derivations."""
    left: ResearchExpr
    right: ResearchExpr


@dataclass
class Bridge(ResearchExpr):
    """Cross-domain connection (higher complexity)."""
    left: ResearchExpr
    right: ResearchExpr


@dataclass
class Iterate(ResearchExpr):
    """Bounded iteration."""
    count: int
    body: ResearchExpr


@dataclass
class Certify(ResearchExpr):
    """Certification/abstraction step (transfinite jump)."""
    body: ResearchExpr


# ─────────────────────────────────────────────────────────
# Core Algorithms
# ─────────────────────────────────────────────────────────

def ordinal_depth(expr: ResearchExpr) -> OrdinalValue:
    """
    Compute the ordinal depth of a research expression.

    Mirrors the formal definition:
    - atom: 0
    - compose(e₁, e₂): succ(max(depth(e₁), depth(e₂)))
    - bridge(e₁, e₂): succ(succ(max(depth(e₁), depth(e₂))))
    - iterate(n, e): depth(e) + n
    - certify(e): ω ^ depth(e)

    Time complexity: O(|expr| · D) where D is the depth of ordinal arithmetic.
    Space complexity: O(|expr|) for the recursion stack.
    """
    if isinstance(expr, Atom):
        return OrdinalValue.zero()
    elif isinstance(expr, Compose):
        d1 = ordinal_depth(expr.left)
        d2 = ordinal_depth(expr.right)
        return max(d1, d2).successor()
    elif isinstance(expr, Bridge):
        d1 = ordinal_depth(expr.left)
        d2 = ordinal_depth(expr.right)
        return max(d1, d2).successor().successor()
    elif isinstance(expr, Iterate):
        d = ordinal_depth(expr.body)
        return d + OrdinalValue.from_nat(expr.count)
    elif isinstance(expr, Certify):
        d = ordinal_depth(expr.body)
        return OrdinalValue.omega_power(d)
    else:
        raise TypeError(f"Unknown expression type: {type(expr)}")


def structural_depth(expr: ResearchExpr) -> int:
    """
    Compute the natural-number structural depth.

    A computable proxy for ordinal depth that stays in ℕ.

    Time complexity: O(|expr|)
    Space complexity: O(height(expr)) for recursion stack.
    """
    if isinstance(expr, Atom):
        return 0
    elif isinstance(expr, Compose):
        return 1 + max(structural_depth(expr.left), structural_depth(expr.right))
    elif isinstance(expr, Bridge):
        return 2 + max(structural_depth(expr.left), structural_depth(expr.right))
    elif isinstance(expr, Iterate):
        return structural_depth(expr.body) + expr.count
    elif isinstance(expr, Certify):
        return 1 + structural_depth(expr.body)
    else:
        raise TypeError(f"Unknown expression type: {type(expr)}")


def innovation_score(expr: ResearchExpr) -> int:
    """
    Compute the innovation score.

    Counts bridge and certify constructors while ignoring pure composition.
    This is a proxy for cross-domain and abstraction density.

    Time complexity: O(|expr|)
    Space complexity: O(height(expr))
    """
    if isinstance(expr, Atom):
        return 0
    elif isinstance(expr, Compose):
        return max(innovation_score(expr.left), innovation_score(expr.right))
    elif isinstance(expr, Bridge):
        return 1 + max(innovation_score(expr.left), innovation_score(expr.right))
    elif isinstance(expr, Iterate):
        return expr.count + innovation_score(expr.body)
    elif isinstance(expr, Certify):
        return 1 + innovation_score(expr.body)
    else:
        raise TypeError(f"Unknown expression type: {type(expr)}")


def node_count(expr: ResearchExpr) -> int:
    """
    Count total nodes in the syntax tree.

    Time complexity: O(|expr|)
    """
    if isinstance(expr, Atom):
        return 1
    elif isinstance(expr, Compose):
        return 1 + node_count(expr.left) + node_count(expr.right)
    elif isinstance(expr, Bridge):
        return 1 + node_count(expr.left) + node_count(expr.right)
    elif isinstance(expr, Iterate):
        return 1 + node_count(expr.body)
    elif isinstance(expr, Certify):
        return 1 + node_count(expr.body)
    else:
        raise TypeError(f"Unknown expression type: {type(expr)}")


def is_trivial(expr: ResearchExpr) -> bool:
    """
    Check if an expression belongs to the trivial fragment.

    Trivial = atom OR compose of two atoms.

    Time complexity: O(1)
    """
    if isinstance(expr, Atom):
        return True
    if isinstance(expr, Compose):
        return isinstance(expr.left, Atom) and isinstance(expr.right, Atom)
    return False


def cycle_depth(exprs: List[ResearchExpr]) -> OrdinalValue:
    """
    Compute the depth of a research cycle (finite set of expressions).

    Returns the maximum depth among all expressions.

    Time complexity: O(|exprs| · |expr_max|)
    """
    if not exprs:
        return OrdinalValue.zero()
    return max(ordinal_depth(e) for e in exprs)


def should_escalate(theta: OrdinalValue, exprs: List[ResearchExpr]) -> bool:
    """
    Determine if a cycle should be escalated based on threshold θ.

    Returns True if cycleDepth(exprs) < θ, indicating insufficient depth.

    Time complexity: O(|exprs| · |expr_max|)
    """
    return cycle_depth(exprs) < theta


def classify_cycle(theta: OrdinalValue, exprs: List[ResearchExpr]) -> dict:
    """
    Classify a research cycle against a threshold.

    Returns a detailed report including:
    - Individual depths
    - Cycle depth
    - Escalation decision
    - Non-triviality certificates

    Time complexity: O(|exprs| · |expr_max|)
    """
    depths = [(e, ordinal_depth(e)) for e in exprs]
    cd = cycle_depth(exprs)
    escalate = cd < theta

    return {
        "cycle_depth": cd,
        "threshold": theta,
        "escalate": escalate,
        "elements": [
            {
                "depth": d,
                "structural_depth": structural_depth(e),
                "innovation_score": innovation_score(e),
                "is_trivial": is_trivial(e),
                "nontriviality_certified": d >= OrdinalValue.omega(),
                "accepted": d >= theta,
            }
            for e, d in depths
        ]
    }


# ─────────────────────────────────────────────────────────
# Expression Generators (for experiments)
# ─────────────────────────────────────────────────────────

def random_expr(max_depth: int = 5, seed: int = 42) -> ResearchExpr:
    """Generate a random research expression with bounded structural depth."""
    import random
    rng = random.Random(seed)

    def gen(d: int) -> ResearchExpr:
        if d <= 0:
            return Atom(rng.randint(0, 100))
        choice = rng.random()
        if choice < 0.2:
            return Atom(rng.randint(0, 100))
        elif choice < 0.45:
            return Compose(gen(d - 1), gen(d - 1))
        elif choice < 0.65:
            return Bridge(gen(d - 1), gen(d - 1))
        elif choice < 0.85:
            return Iterate(rng.randint(1, 5), gen(d - 1))
        else:
            return Certify(gen(d - 1))

    return gen(max_depth)


def depth_spectrum(n_samples: int = 100, max_depth: int = 6) -> List[Tuple[OrdinalValue, int, int, bool]]:
    """
    Generate a spectrum of expressions and their metrics.

    Returns list of (ordinal_depth, structural_depth, innovation_score, is_trivial).
    """
    results = []
    for seed in range(n_samples):
        expr = random_expr(max_depth=max_depth, seed=seed)
        results.append((
            ordinal_depth(expr),
            structural_depth(expr),
            innovation_score(expr),
            is_trivial(expr),
        ))
    return results


if __name__ == "__main__":
    # Quick self-test
    print("Running algorithm self-tests...")

    # Test ordinal arithmetic
    assert OrdinalValue.zero() < OrdinalValue.from_nat(1)
    assert OrdinalValue.from_nat(5) < OrdinalValue.omega()
    assert OrdinalValue.omega() < OrdinalValue.omega_power(OrdinalValue.from_nat(2))

    # Test depth computation
    a0 = Atom(0)
    a1 = Atom(1)
    assert ordinal_depth(a0) == OrdinalValue.zero()
    assert ordinal_depth(Compose(a0, a1)) == OrdinalValue.from_nat(1)
    assert ordinal_depth(Bridge(a0, a1)) == OrdinalValue.from_nat(2)
    assert ordinal_depth(Certify(Compose(a0, a1))) == OrdinalValue.omega()

    # Test innovation score ≤ structural depth
    for seed in range(50):
        expr = random_expr(max_depth=4, seed=seed)
        assert innovation_score(expr) <= structural_depth(expr), \
            f"Innovation score exceeds structural depth for seed {seed}"

    # Test trivial detection
    assert is_trivial(Atom(0))
    assert is_trivial(Compose(Atom(0), Atom(1)))
    assert not is_trivial(Compose(Compose(Atom(0), Atom(1)), Atom(2)))
    assert not is_trivial(Certify(Atom(0)))

    print("All self-tests passed! ✓")
