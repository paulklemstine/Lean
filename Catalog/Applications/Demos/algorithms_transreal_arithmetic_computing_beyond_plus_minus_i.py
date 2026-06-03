"""
Transreal Arithmetic: Type-hinted implementations of all operations.

Implements Anderson's transreal number system ℝ ∪ {+∞, -∞, Φ}
with total division and nullity absorption.
"""

from __future__ import annotations
from enum import Enum, auto
from typing import Union
import math


class TransrealKind(Enum):
    REAL = auto()
    POS_INF = auto()
    NEG_INF = auto()
    NULLITY = auto()


class Transreal:
    """A transreal number: real, +∞, -∞, or Φ (nullity = 0/0)."""

    def __init__(self, kind: TransrealKind, value: float = 0.0):
        self.kind = kind
        self.value = value if kind == TransrealKind.REAL else 0.0

    @staticmethod
    def real(x: float) -> Transreal:
        return Transreal(TransrealKind.REAL, x)

    @staticmethod
    def pos_inf() -> Transreal:
        return Transreal(TransrealKind.POS_INF)

    @staticmethod
    def neg_inf() -> Transreal:
        return Transreal(TransrealKind.NEG_INF)

    @staticmethod
    def nullity() -> Transreal:
        return Transreal(TransrealKind.NULLITY)

    def is_finite(self) -> bool:
        return self.kind == TransrealKind.REAL

    def is_determinate(self) -> bool:
        return self.kind != TransrealKind.NULLITY

    def __repr__(self) -> str:
        if self.kind == TransrealKind.REAL:
            return f"Transreal({self.value})"
        elif self.kind == TransrealKind.POS_INF:
            return "Transreal(+∞)"
        elif self.kind == TransrealKind.NEG_INF:
            return "Transreal(-∞)"
        else:
            return "Transreal(Φ)"

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Transreal):
            return NotImplemented
        if self.kind != other.kind:
            return False
        if self.kind == TransrealKind.REAL:
            return self.value == other.value
        return True

    def __neg__(self) -> Transreal:
        """Negation: -∞ ↔ +∞, -Φ = Φ"""
        if self.kind == TransrealKind.REAL:
            return Transreal.real(-self.value)
        elif self.kind == TransrealKind.POS_INF:
            return Transreal.neg_inf()
        elif self.kind == TransrealKind.NEG_INF:
            return Transreal.pos_inf()
        else:
            return Transreal.nullity()

    def __add__(self, other: Transreal) -> Transreal:
        """Transreal addition with nullity absorption and ∞ + (-∞) = Φ."""
        if self.kind == TransrealKind.NULLITY or other.kind == TransrealKind.NULLITY:
            return Transreal.nullity()

        if self.kind == TransrealKind.REAL and other.kind == TransrealKind.REAL:
            return Transreal.real(self.value + other.value)

        if self.kind == TransrealKind.REAL:
            return Transreal(other.kind)  # real + inf = inf
        if other.kind == TransrealKind.REAL:
            return Transreal(self.kind)  # inf + real = inf

        # Both infinite
        if self.kind == other.kind:
            return Transreal(self.kind)  # +∞ + +∞ = +∞
        else:
            return Transreal.nullity()  # +∞ + -∞ = Φ

    def __mul__(self, other: Transreal) -> Transreal:
        """Transreal multiplication with sign-dependent infinite products."""
        if self.kind == TransrealKind.NULLITY or other.kind == TransrealKind.NULLITY:
            return Transreal.nullity()

        if self.kind == TransrealKind.REAL and other.kind == TransrealKind.REAL:
            return Transreal.real(self.value * other.value)

        def _sign_mul(sign_a: int, kind_b: TransrealKind) -> Transreal:
            """Multiply a sign (+1, -1, 0) by an infinite element."""
            if sign_a == 0:
                return Transreal.nullity()
            if kind_b == TransrealKind.POS_INF:
                return Transreal.pos_inf() if sign_a > 0 else Transreal.neg_inf()
            else:  # NEG_INF
                return Transreal.neg_inf() if sign_a > 0 else Transreal.pos_inf()

        def _real_sign(x: float) -> int:
            if x > 0: return 1
            if x < 0: return -1
            return 0

        def _inf_sign(k: TransrealKind) -> int:
            return 1 if k == TransrealKind.POS_INF else -1

        if self.kind == TransrealKind.REAL:
            return _sign_mul(_real_sign(self.value), other.kind)
        if other.kind == TransrealKind.REAL:
            return _sign_mul(_real_sign(other.value), self.kind)

        # Both infinite
        s = _inf_sign(self.kind) * _inf_sign(other.kind)
        return Transreal.pos_inf() if s > 0 else Transreal.neg_inf()

    def __truediv__(self, other: Transreal) -> Transreal:
        """Total transreal division. 0/0 = Φ, r/0 = ±∞."""
        if self.kind == TransrealKind.NULLITY or other.kind == TransrealKind.NULLITY:
            return Transreal.nullity()

        if other.kind in (TransrealKind.POS_INF, TransrealKind.NEG_INF):
            if self.kind == TransrealKind.REAL:
                return Transreal.real(0.0)
            else:
                return Transreal.nullity()  # ∞/∞ = Φ

        if other.kind == TransrealKind.REAL and other.value == 0:
            if self.kind == TransrealKind.REAL:
                if self.value > 0:
                    return Transreal.pos_inf()
                elif self.value < 0:
                    return Transreal.neg_inf()
                else:
                    return Transreal.nullity()  # 0/0 = Φ
            else:
                return Transreal.nullity()  # ∞/0 = Φ

        if self.kind == TransrealKind.REAL and other.kind == TransrealKind.REAL:
            return Transreal.real(self.value / other.value)

        # inf / nonzero real
        if self.kind in (TransrealKind.POS_INF, TransrealKind.NEG_INF):
            if other.value > 0:
                return Transreal(self.kind)
            else:
                return -Transreal(self.kind)

        return Transreal.nullity()


def verify_ring_axiom_failure() -> dict[str, bool]:
    """Verify which ring axioms hold and which fail for transreals."""
    results: dict[str, bool] = {}

    # Test additive commutativity (should hold)
    test_elems = [Transreal.real(1), Transreal.real(-2), Transreal.pos_inf(),
                  Transreal.neg_inf(), Transreal.nullity()]
    comm_holds = all(a + b == b + a for a in test_elems for b in test_elems)
    results["additive_commutativity"] = comm_holds

    # Test additive associativity (should hold)
    assoc_holds = all(
        (a + b) + c == a + (b + c)
        for a in test_elems for b in test_elems for c in test_elems
    )
    results["additive_associativity"] = assoc_holds

    # Test multiplicative commutativity (should hold)
    mul_comm = all(a * b == b * a for a in test_elems for b in test_elems)
    results["multiplicative_commutativity"] = mul_comm

    # Test multiplicative associativity (should hold)
    mul_assoc = all(
        (a * b) * c == a * (b * c)
        for a in test_elems for b in test_elems for c in test_elems
    )
    results["multiplicative_associativity"] = mul_assoc

    # Test distributivity (should fail)
    dist_holds = all(
        a * (b + c) == a * b + a * c
        for a in test_elems for b in test_elems for c in test_elems
    )
    results["distributivity"] = dist_holds

    # Test additive inverses (should fail for non-reals)
    zero = Transreal.real(0)
    has_inverses = all(
        any(a + b == zero for b in test_elems)
        for a in test_elems
    )
    results["all_additive_inverses_exist"] = has_inverses

    return results


def find_distributivity_counterexample() -> tuple[Transreal, Transreal, Transreal] | None:
    """Find a specific counterexample to distributivity."""
    test_elems = [Transreal.real(1), Transreal.real(-1), Transreal.real(0),
                  Transreal.pos_inf(), Transreal.neg_inf(), Transreal.nullity()]
    for a in test_elems:
        for b in test_elems:
            for c in test_elems:
                if a * (b + c) != a * b + a * c:
                    return (a, b, c)
    return None


if __name__ == "__main__":
    print("=" * 60)
    print("Transreal Arithmetic: Ring Axiom Verification")
    print("=" * 60)

    results = verify_ring_axiom_failure()
    for axiom, holds in results.items():
        status = "✓ HOLDS" if holds else "✗ FAILS"
        print(f"  {axiom}: {status}")

    print()
    ce = find_distributivity_counterexample()
    if ce:
        a, b, c = ce
        lhs = a * (b + c)
        rhs = a * b + a * c
        print(f"Distributivity counterexample:")
        print(f"  a = {a}, b = {b}, c = {c}")
        print(f"  a*(b+c) = {lhs}")
        print(f"  a*b + a*c = {rhs}")
