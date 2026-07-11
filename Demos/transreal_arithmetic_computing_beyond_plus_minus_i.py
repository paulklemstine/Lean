"""
Transreal Arithmetic: Computing Beyond Plus-Minus Infinity
==========================================================

A self-contained reference implementation of Anderson's transreal number
system T = R u {+inf, -inf, Phi}, where Phi ("nullity") is the value of 0/0.

The module implements total addition, multiplication, negation, reciprocal,
and division, then demonstrates the paper's main results numerically:

  * Phi is a global absorbing element for + and *.
  * (T, +, 0) and (T, *, 1) are commutative monoids.
  * The reals embed conservatively.
  * Division is total; 1/0 = +inf and 0/0 = Phi.
  * T is NOT a ring: no additive inverse for +inf, 0*inf = Phi,
    distributivity fails, cancellation fails.
  * T is NOT a wheel: modified distributivity fails, reciprocal
    is not an involution.

Run:  python demo.py
"""

from __future__ import annotations
from dataclasses import dataclass
from enum import Enum
from itertools import product
from typing import List


class Kind(Enum):
    PHI = 0   # nullity, the value of 0/0
    PINF = 1  # +infinity
    NINF = 2  # -infinity
    REAL = 3  # embedded finite real


@dataclass(frozen=True)
class TReal:
    """A transreal number: nullity, +/-infinity, or an embedded real."""
    kind: Kind
    value: float = 0.0  # meaningful only when kind == REAL

    # ---- constructors -------------------------------------------------
    @staticmethod
    def phi() -> "TReal":
        return TReal(Kind.PHI)

    @staticmethod
    def pinf() -> "TReal":
        return TReal(Kind.PINF)

    @staticmethod
    def ninf() -> "TReal":
        return TReal(Kind.NINF)

    @staticmethod
    def real(x: float) -> "TReal":
        return TReal(Kind.REAL, float(x))

    # ---- display ------------------------------------------------------
    def __repr__(self) -> str:
        return {
            Kind.PHI: "Phi",
            Kind.PINF: "+inf",
            Kind.NINF: "-inf",
        }.get(self.kind, f"{self.value:g}")

    # ---- addition -----------------------------------------------------
    def __add__(self, other: "TReal") -> "TReal":
        a, b = self, other
        if a.kind == Kind.PHI or b.kind == Kind.PHI:
            return TReal.phi()
        if a.kind == Kind.PINF:
            return TReal.phi() if b.kind == Kind.NINF else TReal.pinf()
        if a.kind == Kind.NINF:
            return TReal.phi() if b.kind == Kind.PINF else TReal.ninf()
        # a is REAL
        if b.kind == Kind.PINF:
            return TReal.pinf()
        if b.kind == Kind.NINF:
            return TReal.ninf()
        return TReal.real(a.value + b.value)

    # ---- multiplication ----------------------------------------------
    def __mul__(self, other: "TReal") -> "TReal":
        a, b = self, other
        if a.kind == Kind.PHI or b.kind == Kind.PHI:
            return TReal.phi()

        def inf_times(sign_pos: bool, other_t: "TReal") -> "TReal":
            """(+inf if sign_pos else -inf) * other_t."""
            if other_t.kind == Kind.PINF:
                return TReal.pinf() if sign_pos else TReal.ninf()
            if other_t.kind == Kind.NINF:
                return TReal.ninf() if sign_pos else TReal.pinf()
            # other_t is REAL: sign of real factor decides
            if other_t.value == 0.0:
                return TReal.phi()
            pos = other_t.value > 0.0
            result_pos = (sign_pos == pos)
            return TReal.pinf() if result_pos else TReal.ninf()

        if a.kind == Kind.PINF:
            return inf_times(True, b)
        if a.kind == Kind.NINF:
            return inf_times(False, b)
        # a is REAL
        if b.kind in (Kind.PINF, Kind.NINF):
            return inf_times(b.kind == Kind.PINF, a)
        return TReal.real(a.value * b.value)

    # ---- negation -----------------------------------------------------
    def __neg__(self) -> "TReal":
        if self.kind == Kind.PHI:
            return TReal.phi()
        if self.kind == Kind.PINF:
            return TReal.ninf()
        if self.kind == Kind.NINF:
            return TReal.pinf()
        return TReal.real(-self.value)

    # ---- reciprocal and division -------------------------------------
    def recip(self) -> "TReal":
        if self.kind == Kind.PHI:
            return TReal.phi()
        if self.kind in (Kind.PINF, Kind.NINF):
            return TReal.real(0.0)
        if self.value == 0.0:
            return TReal.pinf()
        return TReal.real(1.0 / self.value)

    def __truediv__(self, other: "TReal") -> "TReal":
        return self * other.recip()

    # ---- structural equality -----------------------------------------
    def eq(self, other: "TReal") -> bool:
        if self.kind != other.kind:
            return False
        if self.kind == Kind.REAL:
            return self.value == other.value
        return True


def representative_set() -> List[TReal]:
    """Phi, +/-inf, and one negative/zero/positive real (see Lemma 2.6)."""
    return [
        TReal.phi(), TReal.pinf(), TReal.ninf(),
        TReal.real(-2.0), TReal.real(0.0), TReal.real(3.0),
    ]


# ----------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------
def demo_absorption() -> None:
    print("== Phi is a global absorbing element ==")
    for x in representative_set():
        print(f"  Phi + {x!r:>4} = {TReal.phi() + x!r:>4}    "
              f"Phi * {x!r:>4} = {TReal.phi() * x!r:>4}")


def demo_total_division() -> None:
    print("\n== Total division and Anderson's identity ==")
    one, zero = TReal.real(1.0), TReal.real(0.0)
    print(f"  1 / 0 = {one / zero!r}   (expected +inf)")
    print(f"  0 / 0 = {zero / zero!r}   (expected Phi)")
    print(f"  1 / +inf = {one / TReal.pinf()!r}   (expected 0)")
    print(f"  5 / -inf = {TReal.real(5.0) / TReal.ninf()!r}   (expected 0)")


def demo_monoid_laws() -> None:
    print("\n== Commutative monoid laws hold (exhaustive check) ==")
    S = representative_set()
    add_comm = all((x + y).eq(y + x) for x in S for y in S)
    mul_comm = all((x * y).eq(y * x) for x in S for y in S)
    add_assoc = all(((x + y) + z).eq(x + (y + z))
                    for x, y, z in product(S, repeat=3))
    mul_assoc = all(((x * y) * z).eq(x * (y * z))
                    for x, y, z in product(S, repeat=3))
    ident = all((TReal.real(0.0) + x).eq(x) and (TReal.real(1.0) * x).eq(x)
                for x in S)
    print(f"  additive commutativity : {add_comm}")
    print(f"  additive associativity : {add_assoc}")
    print(f"  mult.   commutativity : {mul_comm}")
    print(f"  mult.   associativity : {mul_assoc}")
    print(f"  identity laws          : {ident}")


def demo_ring_failures() -> None:
    print("\n== The ring axioms collapse ==")
    zero = TReal.real(0.0)
    # No additive inverse for +inf
    has_inv = any((TReal.pinf() + y).eq(zero) for y in representative_set())
    print(f"  exists y with +inf + y = 0 ? {has_inv}   (expected False)")
    # Annihilator
    print(f"  0 * +inf = {(zero * TReal.pinf())!r}   (expected Phi, not 0)")
    # Distributivity
    x, y, z = TReal.real(2.0), TReal.real(-1.0), TReal.pinf()
    lhs, rhs = (x + y) * z, (x * z) + (y * z)
    print(f"  (2 + -1)*inf = {lhs!r}   vs   2*inf + -1*inf = {rhs!r}   "
          f"equal? {lhs.eq(rhs)}")
    # Cancellation
    a = TReal.pinf() + TReal.real(1.0)
    b = TReal.pinf() + TReal.real(2.0)
    print(f"  inf+1 = {a!r}, inf+2 = {b!r} equal? {a.eq(b)} but 1 != 2  "
          f"(cancellation fails)")


def demo_wheel_failures() -> None:
    print("\n== The wheel axioms collapse too ==")
    x, y, z = TReal.real(2.0), TReal.real(3.0), TReal.pinf()
    zero = TReal.real(0.0)
    lhs = (x + y) * z + zero * z          # modified distributive law
    rhs = (x * z) + (y * z)
    print(f"  (2+3)*inf + 0*inf = {lhs!r}   vs   2*inf + 3*inf = {rhs!r}   "
          f"equal? {lhs.eq(rhs)}")
    dbl = TReal.ninf().recip().recip()    # involution law //(-inf)
    print(f"  1/(1/(-inf)) = {dbl!r}   (expected -inf for an involution; "
          f"it is {dbl!r})")


def main() -> None:
    print("Transreal Arithmetic Demonstration")
    print("=" * 40)
    demo_absorption()
    demo_total_division()
    demo_monoid_laws()
    demo_ring_failures()
    demo_wheel_failures()
    print("\nDone.")


if __name__ == "__main__":
    main()
