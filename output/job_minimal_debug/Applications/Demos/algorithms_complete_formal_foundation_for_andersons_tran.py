"""
Transreal Arithmetic and Absorbing Extensions — Algorithms

Type-hinted Python implementations of the core algebraic constructions
formalized in Lean 4.
"""

from __future__ import annotations
from typing import Optional, Callable, TypeVar, Generic
from enum import Enum
from dataclasses import dataclass


# ============================================================
# Transreal Arithmetic
# ============================================================

class TransrealKind(Enum):
    REAL = "real"
    POS_INF = "+∞"
    NEG_INF = "-∞"
    NULLITY = "Φ"


@dataclass(frozen=True)
class Transreal:
    """A transreal number: real, +∞, -∞, or Φ (nullity)."""
    kind: TransrealKind
    value: float = 0.0  # only meaningful when kind == REAL

    @staticmethod
    def of_real(r: float) -> Transreal:
        return Transreal(TransrealKind.REAL, r)

    @staticmethod
    def pos_inf() -> Transreal:
        return Transreal(TransrealKind.POS_INF)

    @staticmethod
    def neg_inf() -> Transreal:
        return Transreal(TransrealKind.NEG_INF)

    @staticmethod
    def nullity() -> Transreal:
        return Transreal(TransrealKind.NULLITY)

    def __repr__(self) -> str:
        if self.kind == TransrealKind.REAL:
            return f"Transreal({self.value})"
        return f"Transreal({self.kind.value})"

    def __str__(self) -> str:
        if self.kind == TransrealKind.REAL:
            return str(self.value)
        return self.kind.value

    def is_finite(self) -> bool:
        return self.kind == TransrealKind.REAL

    def is_nullity(self) -> bool:
        return self.kind == TransrealKind.NULLITY


def real_sign(r: float) -> Transreal:
    """Map a real number to its signed infinity, or nullity if zero."""
    if r > 0:
        return Transreal.pos_inf()
    elif r < 0:
        return Transreal.neg_inf()
    else:
        return Transreal.nullity()


def neg_infinite(t: Transreal) -> Transreal:
    """Flip the sign of an infinite element."""
    if t.kind == TransrealKind.POS_INF:
        return Transreal.neg_inf()
    elif t.kind == TransrealKind.NEG_INF:
        return Transreal.pos_inf()
    return t


def transreal_add(a: Transreal, b: Transreal) -> Transreal:
    """Transreal addition with nullity absorption and ∞ + (-∞) = Φ."""
    if a.kind == TransrealKind.NULLITY or b.kind == TransrealKind.NULLITY:
        return Transreal.nullity()
    if a.kind == TransrealKind.POS_INF and b.kind == TransrealKind.NEG_INF:
        return Transreal.nullity()
    if a.kind == TransrealKind.NEG_INF and b.kind == TransrealKind.POS_INF:
        return Transreal.nullity()
    if a.kind == TransrealKind.POS_INF:
        return Transreal.pos_inf()
    if b.kind == TransrealKind.POS_INF:
        return Transreal.pos_inf()
    if a.kind == TransrealKind.NEG_INF:
        return Transreal.neg_inf()
    if b.kind == TransrealKind.NEG_INF:
        return Transreal.neg_inf()
    return Transreal.of_real(a.value + b.value)


def transreal_mul(a: Transreal, b: Transreal) -> Transreal:
    """Transreal multiplication with sign rules for infinities."""
    if a.kind == TransrealKind.NULLITY or b.kind == TransrealKind.NULLITY:
        return Transreal.nullity()
    # Both infinities
    inf_pairs = {
        (TransrealKind.POS_INF, TransrealKind.POS_INF): Transreal.pos_inf(),
        (TransrealKind.POS_INF, TransrealKind.NEG_INF): Transreal.neg_inf(),
        (TransrealKind.NEG_INF, TransrealKind.POS_INF): Transreal.neg_inf(),
        (TransrealKind.NEG_INF, TransrealKind.NEG_INF): Transreal.pos_inf(),
    }
    if (a.kind, b.kind) in inf_pairs:
        return inf_pairs[(a.kind, b.kind)]
    # Infinity × real
    if a.kind == TransrealKind.POS_INF:
        return real_sign(b.value)
    if b.kind == TransrealKind.POS_INF:
        return real_sign(a.value)
    if a.kind == TransrealKind.NEG_INF:
        return neg_infinite(real_sign(b.value))
    if b.kind == TransrealKind.NEG_INF:
        return neg_infinite(real_sign(a.value))
    # Both real
    return Transreal.of_real(a.value * b.value)


def transreal_div(a: Transreal, b: Transreal) -> Transreal:
    """Transreal division — total, with 0/0 = Φ."""
    if a.kind == TransrealKind.NULLITY or b.kind == TransrealKind.NULLITY:
        return Transreal.nullity()
    # Inf / Inf = Φ
    if a.kind in (TransrealKind.POS_INF, TransrealKind.NEG_INF) and \
       b.kind in (TransrealKind.POS_INF, TransrealKind.NEG_INF):
        return Transreal.nullity()
    # Real / 0
    if b.kind == TransrealKind.REAL and b.value == 0:
        if a.kind == TransrealKind.REAL:
            return real_sign(a.value)
        return Transreal.nullity()
    # Real / Inf = 0
    if a.kind == TransrealKind.REAL and b.kind in (TransrealKind.POS_INF, TransrealKind.NEG_INF):
        return Transreal.of_real(0.0)
    # Inf / real
    if a.kind == TransrealKind.POS_INF and b.kind == TransrealKind.REAL:
        return Transreal.pos_inf() if b.value >= 0 else Transreal.neg_inf()
    if a.kind == TransrealKind.NEG_INF and b.kind == TransrealKind.REAL:
        return Transreal.neg_inf() if b.value >= 0 else Transreal.pos_inf()
    # Real / Real (b != 0)
    return Transreal.of_real(a.value / b.value)


def transreal_neg(a: Transreal) -> Transreal:
    """Transreal negation."""
    if a.kind == TransrealKind.REAL:
        return Transreal.of_real(-a.value)
    if a.kind == TransrealKind.POS_INF:
        return Transreal.neg_inf()
    if a.kind == TransrealKind.NEG_INF:
        return Transreal.pos_inf()
    return Transreal.nullity()


# ============================================================
# Absorbing Extension
# ============================================================

T = TypeVar('T')


def absorbing_extension(
    partial_op: Callable[[T, T], Optional[T]]
) -> Callable[[Optional[T], Optional[T]], Optional[T]]:
    """
    Construct the absorbing extension of a partial binary operation.

    Given a partial operation f: T × T → T? (returning None when undefined),
    returns a total operation on Optional[T] where None is the absorber:
    - None ∘ x = x ∘ None = None
    - Some(a) ∘ Some(b) = f(a, b) (which may be None if undefined)

    This is the general construction that produces transreal-like behavior.
    """
    def total_op(a: Optional[T], b: Optional[T]) -> Optional[T]:
        if a is None or b is None:
            return None  # absorber
        return partial_op(a, b)  # may return None if undefined
    return total_op


def check_absorber_uniqueness(
    op: Callable[[Optional[T], Optional[T]], Optional[T]],
    elements: list[Optional[T]]
) -> list[Optional[T]]:
    """
    Find all left-absorbing elements: those x such that op(x, y) = x for all y.
    By the uniqueness theorem, this should return at most [None].
    """
    absorbers = []
    for x in elements:
        if all(op(x, y) == x for y in elements):
            absorbers.append(x)
    return absorbers


def check_idempotents(
    op: Callable[[T, T], T],
    elements: list[T]
) -> list[T]:
    """Find all idempotent elements: those x such that op(x, x) = x."""
    return [x for x in elements if op(x, x) == x]


# ============================================================
# Verification Algorithms
# ============================================================

def verify_commutativity(
    op: Callable[[T, T], T],
    elements: list[T]
) -> tuple[bool, Optional[tuple[T, T]]]:
    """Check commutativity of op on given elements. Returns (True, None) or (False, counterexample)."""
    for a in elements:
        for b in elements:
            if op(a, b) != op(b, a):
                return False, (a, b)
    return True, None


def verify_associativity(
    op: Callable[[T, T], T],
    elements: list[T]
) -> tuple[bool, Optional[tuple[T, T, T]]]:
    """Check associativity. Returns (True, None) or (False, counterexample)."""
    for a in elements:
        for b in elements:
            for c in elements:
                if op(op(a, b), c) != op(a, op(b, c)):
                    return False, (a, b, c)
    return True, None


def verify_distributivity(
    add_op: Callable[[T, T], T],
    mul_op: Callable[[T, T], T],
    elements: list[T]
) -> tuple[bool, Optional[tuple[T, T, T]]]:
    """Check left distributivity: a*(b+c) = a*b + a*c."""
    for a in elements:
        for b in elements:
            for c in elements:
                lhs = mul_op(a, add_op(b, c))
                rhs = add_op(mul_op(a, b), mul_op(a, c))
                if lhs != rhs:
                    return False, (a, b, c)
    return True, None


if __name__ == "__main__":
    # Quick self-test
    zero = Transreal.of_real(0)
    one = Transreal.of_real(1)
    pinf = Transreal.pos_inf()
    ninf = Transreal.neg_inf()
    phi = Transreal.nullity()

    print("=== Transreal Arithmetic Self-Test ===")
    print(f"0/0 = {transreal_div(zero, zero)}")
    print(f"1/0 = {transreal_div(one, zero)}")
    print(f"Φ + 5 = {transreal_add(phi, Transreal.of_real(5))}")
    print(f"∞ + (-∞) = {transreal_add(pinf, ninf)}")
    print(f"∞ * 0 = {transreal_mul(pinf, zero)}")

    # Verify absorber uniqueness
    specials = [zero, one, Transreal.of_real(-1), pinf, ninf, phi]
    absorbers = check_absorber_uniqueness(transreal_add, specials)
    print(f"\nAdditive absorbers: {absorbers}")

    # Verify idempotents
    idem = check_idempotents(transreal_add, specials)
    print(f"Additive idempotents: {idem}")
