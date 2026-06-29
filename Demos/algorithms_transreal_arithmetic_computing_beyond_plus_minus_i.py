#!/usr/bin/env python3
"""
Transreal Arithmetic: Type-hinted implementations of core algorithms.

Implements Anderson's transreal number system with defect computation,
regularity classification, and wheel distributivity verification.
"""

from __future__ import annotations
from dataclasses import dataclass
from enum import Enum, auto
from typing import Optional, Tuple, List


class Kind(Enum):
    """Classification of a transreal element."""
    REAL = auto()
    POS_INF = auto()
    NEG_INF = auto()
    NULLITY = auto()


@dataclass(frozen=True)
class Transreal:
    """
    A transreal number: ℝ ∪ {+∞, -∞, Φ}.

    Algorithm: Arithmetic with Three-Way Sign Dispatch

    Pseudocode for multiplication:
        if either operand is Φ: return Φ
        if both are real: return real(a * b)
        if both are ±∞: return +∞ if same sign else -∞
        if one is ±∞ and other is real r:
            if r > 0: return same sign as ∞ operand
            if r < 0: return opposite sign
            if r = 0: return Φ  (the key case: 0 · ∞ = Φ)
    """
    kind: Kind
    value: Optional[float] = None

    @staticmethod
    def real(x: float) -> Transreal:
        return Transreal(Kind.REAL, x)

    @staticmethod
    def pos_inf() -> Transreal:
        return Transreal(Kind.POS_INF)

    @staticmethod
    def neg_inf() -> Transreal:
        return Transreal(Kind.NEG_INF)

    @staticmethod
    def nullity() -> Transreal:
        return Transreal(Kind.NULLITY)

    def __repr__(self) -> str:
        if self.kind == Kind.REAL:
            return f"{self.value}"
        return {Kind.POS_INF: "+∞", Kind.NEG_INF: "-∞", Kind.NULLITY: "Φ"}[self.kind]

    def is_regular(self) -> bool:
        """Check if element has zero defect (is a real number)."""
        return self.kind == Kind.REAL

    def is_singular(self) -> bool:
        """Check if element has nullity defect (∞ or Φ)."""
        return self.kind != Kind.REAL

    def defect(self) -> Transreal:
        """
        Compute the defect: 0 · x.

        The defect function stratifies transreals into two levels:
        - Level 0 (regular): defect = 0, element is a real number
        - Level 1 (singular): defect = Φ, element is ±∞ or Φ
        """
        return transreal_mul(Transreal.real(0), self)

    def negate(self) -> Transreal:
        """Transreal negation."""
        if self.kind == Kind.REAL:
            return Transreal.real(-self.value)
        elif self.kind == Kind.POS_INF:
            return Transreal.neg_inf()
        elif self.kind == Kind.NEG_INF:
            return Transreal.pos_inf()
        else:
            return Transreal.nullity()


def transreal_add(a: Transreal, b: Transreal) -> Transreal:
    """
    Transreal addition following Anderson's axioms.

    Algorithm:
    1. If either operand is Φ, return Φ (absorption)
    2. If both are ±∞, return ∞ if same sign, Φ if opposite
    3. If one is ±∞ and other is real, return the ±∞
    4. If both are real, return real(a + b)

    Complexity: O(1)
    """
    # Nullity absorbs
    if a.kind == Kind.NULLITY or b.kind == Kind.NULLITY:
        return Transreal.nullity()

    # Infinity + Infinity
    if a.kind == Kind.POS_INF:
        if b.kind == Kind.POS_INF:
            return Transreal.pos_inf()
        elif b.kind == Kind.NEG_INF:
            return Transreal.nullity()  # ∞ + (-∞) = Φ
        else:
            return Transreal.pos_inf()

    if a.kind == Kind.NEG_INF:
        if b.kind == Kind.POS_INF:
            return Transreal.nullity()
        elif b.kind == Kind.NEG_INF:
            return Transreal.neg_inf()
        else:
            return Transreal.neg_inf()

    # a is real
    if b.kind == Kind.POS_INF:
        return Transreal.pos_inf()
    if b.kind == Kind.NEG_INF:
        return Transreal.neg_inf()

    return Transreal.real(a.value + b.value)


def transreal_mul(a: Transreal, b: Transreal) -> Transreal:
    """
    Transreal multiplication with three-way sign dispatch.

    The key insight: when ∞ · 0 arises, the result is Φ (not 0 or ∞).
    This is what creates the wheel structure.

    Complexity: O(1)
    """
    # Nullity absorbs
    if a.kind == Kind.NULLITY or b.kind == Kind.NULLITY:
        return Transreal.nullity()

    # Both real
    if a.kind == Kind.REAL and b.kind == Kind.REAL:
        return Transreal.real(a.value * b.value)

    # Both infinity
    if a.kind in (Kind.POS_INF, Kind.NEG_INF) and b.kind in (Kind.POS_INF, Kind.NEG_INF):
        same_sign = (a.kind == b.kind)
        return Transreal.pos_inf() if same_sign else Transreal.neg_inf()

    # One infinity, one real — dispatch on sign
    if a.kind == Kind.REAL:
        return transreal_mul(b, a)  # Commutative

    r = b.value
    pos_inf_factor = (a.kind == Kind.POS_INF)

    if r > 0:
        return Transreal.pos_inf() if pos_inf_factor else Transreal.neg_inf()
    elif r < 0:
        return Transreal.neg_inf() if pos_inf_factor else Transreal.pos_inf()
    else:
        return Transreal.nullity()  # ∞ · 0 = Φ — the critical case


def verify_wheel_distributivity(a: Transreal, b: Transreal, c: Transreal) -> bool:
    """
    Verify the wheel distributive law: a(b+c) + 0·a = ab + ac + 0·a.

    This modified distributivity replaces standard distributivity in wheel algebras.
    The correction term 0·a (the defect) absorbs pathological cases.
    """
    d = a.defect()
    lhs = transreal_add(transreal_mul(a, transreal_add(b, c)), d)
    rhs = transreal_add(transreal_mul(a, b), transreal_add(transreal_mul(a, c), d))
    return lhs == rhs


def classify_element(x: Transreal) -> Tuple[str, str]:
    """
    Classify a transreal element by its defect level and algebraic role.

    Returns (level, description) where level is "regular" or "singular".
    """
    d = x.defect()
    if d == Transreal.real(0):
        return ("regular", f"Ring-like element with value {x.value}")
    else:
        roles = {
            Kind.POS_INF: "Positive infinity — positive absorber",
            Kind.NEG_INF: "Negative infinity — negative absorber",
            Kind.NULLITY: "Nullity — universal absorber (0/0)",
        }
        return ("singular", roles.get(x.kind, "Unknown"))


def find_additive_idempotents(test_reals: List[float]) -> List[Transreal]:
    """
    Find all additive idempotents (x + x = x) among given test values
    and the three special transreal elements.

    In a ring, only 0 is idempotent. The transreals have exactly four:
    {0, +∞, -∞, Φ}.
    """
    candidates = [Transreal.real(r) for r in test_reals]
    candidates.extend([Transreal.pos_inf(), Transreal.neg_inf(), Transreal.nullity()])

    return [x for x in candidates if transreal_add(x, x) == x]


def check_cancellation(a: Transreal, b: Transreal, c: Transreal) -> bool:
    """
    Check if cancellation holds: does a + c = b + c imply a = b?
    Returns True if cancellation holds (or sums differ), False if it fails.
    """
    sum_ac = transreal_add(a, c)
    sum_bc = transreal_add(b, c)
    if sum_ac == sum_bc:
        return a == b  # Cancellation holds iff a = b when sums equal
    return True  # Sums differ, cancellation not applicable


if __name__ == "__main__":
    # Exhaustive wheel distributivity verification
    elements = [Transreal.real(0), Transreal.real(1), Transreal.real(-1),
                Transreal.real(2), Transreal.pos_inf(), Transreal.neg_inf(),
                Transreal.nullity()]

    print("Verifying wheel distributivity for all combinations...")
    total = 0
    passed = 0
    for a in elements:
        for b in elements:
            for c in elements:
                total += 1
                if verify_wheel_distributivity(a, b, c):
                    passed += 1
                else:
                    print(f"  FAILED: a={a}, b={b}, c={c}")

    print(f"Wheel distributivity: {passed}/{total} passed")

    print("\nAdditive idempotents:")
    test_vals = [0, 1, -1, 2, -2, 0.5, 100, -100]
    idempotents = find_additive_idempotents(test_vals)
    for x in idempotents:
        print(f"  {x}")

    print("\nCancellation failures:")
    for c in elements:
        for a in elements:
            for b in elements:
                if a != b and not check_cancellation(a, b, c):
                    print(f"  {a} + {c} = {b} + {c}, but {a} ≠ {b}")
