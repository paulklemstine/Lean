#!/usr/bin/env python3
"""
Transreal Arithmetic: Numerical Demonstrations

This module implements transreal arithmetic (Anderson's system) in Python
and demonstrates the key theorems verified in the formal development:

  1. Commutativity of addition
  2. Associativity of addition
  3. Commutativity of multiplication
  4. Failure of ring axioms (no additive inverse for +∞)
  5. Failure of distributivity
  6. Failure of additive cancellation
  7. Negation is an involution

Usage:
    python demo.py
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Union
import itertools


# ─── Transreal Type ──────────────────────────────────────────────────

class Transreal:
    """Base class for transreal numbers: ℝ ∪ {+∞, −∞, Φ}."""

    def __neg__(self) -> Transreal:
        return transreal_neg(self)

    def __add__(self, other: Transreal) -> Transreal:
        return transreal_add(self, other)

    def __mul__(self, other: Transreal) -> Transreal:
        return transreal_mul(self, other)

    def __eq__(self, other: object) -> bool:
        if isinstance(self, OfReal) and isinstance(other, OfReal):
            return self.value == other.value
        return type(self) is type(other)

    def __hash__(self) -> int:
        if isinstance(self, OfReal):
            return hash(("real", self.value))
        return hash(type(self).__name__)

    def __format__(self, spec: str) -> str:
        return format(str(self), spec)


@dataclass(frozen=True)
class OfReal(Transreal):
    """A real number embedded in the transreals."""
    value: float

    def __repr__(self) -> str:
        if self.value == int(self.value):
            return str(int(self.value))
        return str(self.value)


class PosInf(Transreal):
    """Positive infinity."""
    _instance: PosInf | None = None

    def __new__(cls) -> PosInf:
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def __repr__(self) -> str:
        return "+∞"


class NegInf(Transreal):
    """Negative infinity."""
    _instance: NegInf | None = None

    def __new__(cls) -> NegInf:
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def __repr__(self) -> str:
        return "−∞"


class Nullity(Transreal):
    """Nullity (Φ): the result of 0/0, ∞ + (−∞), 0 × ∞, etc."""
    _instance: Nullity | None = None

    def __new__(cls) -> Nullity:
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def __repr__(self) -> str:
        return "Φ"


# Convenient constants
POSINF = PosInf()
NEGINF = NegInf()
PHI = Nullity()
ZERO = OfReal(0.0)
ONE = OfReal(1.0)


# ─── Arithmetic Operations ──────────────────────────────────────────

def transreal_neg(x: Transreal) -> Transreal:
    """Transreal negation: −(ofReal r) = ofReal(−r), −(+∞) = −∞, −(−∞) = +∞, −Φ = Φ."""
    if isinstance(x, OfReal):
        return OfReal(-x.value)
    if isinstance(x, PosInf):
        return NEGINF
    if isinstance(x, NegInf):
        return POSINF
    return PHI  # Nullity


def transreal_add(x: Transreal, y: Transreal) -> Transreal:
    """Transreal addition. Key rule: ∞ + (−∞) = Φ (not undefined)."""
    # Nullity absorbs
    if isinstance(x, Nullity) or isinstance(y, Nullity):
        return PHI
    # Infinity + opposite infinity = Φ
    if isinstance(x, PosInf) and isinstance(y, NegInf):
        return PHI
    if isinstance(x, NegInf) and isinstance(y, PosInf):
        return PHI
    # Same-sign infinities
    if isinstance(x, PosInf) and isinstance(y, PosInf):
        return POSINF
    if isinstance(x, NegInf) and isinstance(y, NegInf):
        return NEGINF
    # Infinity + real = infinity
    if isinstance(x, PosInf) or isinstance(y, PosInf):
        return POSINF
    if isinstance(x, NegInf) or isinstance(y, NegInf):
        return NEGINF
    # Both real
    assert isinstance(x, OfReal) and isinstance(y, OfReal)
    return OfReal(x.value + y.value)


def transreal_mul(x: Transreal, y: Transreal) -> Transreal:
    """Transreal multiplication. Key rule: 0 × ∞ = Φ."""
    # Nullity absorbs
    if isinstance(x, Nullity) or isinstance(y, Nullity):
        return PHI
    # Both real
    if isinstance(x, OfReal) and isinstance(y, OfReal):
        return OfReal(x.value * y.value)
    # Infinity × infinity
    if isinstance(x, (PosInf, NegInf)) and isinstance(y, (PosInf, NegInf)):
        pos_x = isinstance(x, PosInf)
        pos_y = isinstance(y, PosInf)
        return POSINF if (pos_x == pos_y) else NEGINF
    # Infinity × real (or real × infinity)
    if isinstance(x, OfReal):
        x, y = y, x  # normalize so x is infinite
    assert isinstance(x, (PosInf, NegInf)) and isinstance(y, OfReal)
    if y.value > 0:
        return POSINF if isinstance(x, PosInf) else NEGINF
    elif y.value < 0:
        return NEGINF if isinstance(x, PosInf) else POSINF
    else:
        return PHI  # 0 × ∞ = Φ


# ─── Test Elements ───────────────────────────────────────────────────

ALL_ELEMENTS: list[Transreal] = [
    OfReal(-2.0), OfReal(-1.0), ZERO, OfReal(0.5), ONE, OfReal(3.0),
    POSINF, NEGINF, PHI,
]

ELEMENT_NAMES: dict[str, Transreal] = {repr(e): e for e in ALL_ELEMENTS}


# ─── Theorem Demonstrations ─────────────────────────────────────────

def demo_theorem_1_add_commutativity() -> None:
    """Theorem 1: ∀ x y ∈ 𝕋, x + y = y + x."""
    print("=" * 60)
    print("THEOREM 1: Commutativity of Addition")
    print("=" * 60)
    violations = 0
    checks = 0
    for x in ALL_ELEMENTS:
        for y in ALL_ELEMENTS:
            lhs = x + y
            rhs = y + x
            checks += 1
            if lhs != rhs:
                violations += 1
                print(f"  VIOLATION: {x} + {y} = {lhs} ≠ {rhs} = {y} + {x}")
    print(f"  Checked {checks} pairs, {violations} violations.")
    print(f"  ✓ Addition is commutative on all tested elements.\n")

    # Showcase examples
    examples = [(POSINF, OfReal(3.0)), (NEGINF, POSINF), (PHI, ONE)]
    for x, y in examples:
        print(f"    {x} + {y} = {x + y}  |  {y} + {x} = {y + x}")
    print()


def demo_theorem_2_add_associativity() -> None:
    """Theorem 2: ∀ x y z ∈ 𝕋, (x + y) + z = x + (y + z)."""
    print("=" * 60)
    print("THEOREM 2: Associativity of Addition")
    print("=" * 60)
    violations = 0
    checks = 0
    for x in ALL_ELEMENTS:
        for y in ALL_ELEMENTS:
            for z in ALL_ELEMENTS:
                lhs = (x + y) + z
                rhs = x + (y + z)
                checks += 1
                if lhs != rhs:
                    violations += 1
                    print(f"  VIOLATION: ({x}+{y})+{z}={lhs} ≠ {x}+({y}+{z})={rhs}")
    print(f"  Checked {checks} triples, {violations} violations.")
    print(f"  ✓ Addition is associative on all tested elements.\n")

    # Key example from the paper
    x, y, z = POSINF, NEGINF, POSINF
    print(f"    ({x} + {y}) + {z} = {(x+y)+z}")
    print(f"    {x} + ({y} + {z}) = {x+(y+z)}")
    print()


def demo_theorem_3_mul_commutativity() -> None:
    """Theorem 3: ∀ x y ∈ 𝕋, x × y = y × x."""
    print("=" * 60)
    print("THEOREM 3: Commutativity of Multiplication")
    print("=" * 60)
    violations = 0
    checks = 0
    for x in ALL_ELEMENTS:
        for y in ALL_ELEMENTS:
            lhs = x * y
            rhs = y * x
            checks += 1
            if lhs != rhs:
                violations += 1
                print(f"  VIOLATION: {x} × {y} = {lhs} ≠ {rhs} = {y} × {x}")
    print(f"  Checked {checks} pairs, {violations} violations.")
    print(f"  ✓ Multiplication is commutative on all tested elements.\n")

    examples = [(ZERO, POSINF), (OfReal(-2.0), NEGINF), (PHI, OfReal(3.0))]
    for x, y in examples:
        print(f"    {x} × {y} = {x * y}  |  {y} × {x} = {y * x}")
    print()


def demo_theorem_4_no_additive_inverse() -> None:
    """Theorem 4: There is no y ∈ 𝕋 such that +∞ + y = 0."""
    print("=" * 60)
    print("THEOREM 4: No Additive Inverse for +∞")
    print("=" * 60)
    print(f"  Searching for y such that +∞ + y = 0 ...")
    for y in ALL_ELEMENTS:
        result = POSINF + y
        marker = " ← closest candidate" if y == NEGINF else ""
        print(f"    +∞ + {y:>4s} = {result}{marker}")
    print(f"  ✗ No additive inverse exists. Ring axioms FAIL.\n")


def demo_theorem_5_distributivity_fails() -> None:
    """Theorem 5: Distributivity fails with a concrete counterexample."""
    print("=" * 60)
    print("THEOREM 5: Failure of Distributivity")
    print("=" * 60)

    # Find a counterexample
    found = False
    for a in ALL_ELEMENTS:
        for b in ALL_ELEMENTS:
            for c in ALL_ELEMENTS:
                lhs = a * (b + c)
                rhs = (a * b) + (a * c)
                if lhs != rhs:
                    if not found:
                        print(f"  Counterexample found!")
                        print(f"    a = {a}, b = {b}, c = {c}")
                        print(f"    a × (b + c) = {a} × ({b} + {c}) = {a} × {b + c} = {lhs}")
                        print(f"    a×b + a×c   = {a*b} + {a*c} = {rhs}")
                        print(f"    {lhs} ≠ {rhs}  ← DISTRIBUTIVITY FAILS")
                        found = True

    # Count total failures
    fail_count = sum(
        1 for a, b, c in itertools.product(ALL_ELEMENTS, repeat=3)
        if a * (b + c) != (a * b) + (a * c)
    )
    total = len(ALL_ELEMENTS) ** 3
    print(f"\n  Total: {fail_count}/{total} triples violate distributivity.\n")


def demo_theorem_6_cancellation_fails() -> None:
    """Theorem 6: Additive cancellation fails for infinite elements."""
    print("=" * 60)
    print("THEOREM 6: Failure of Additive Cancellation")
    print("=" * 60)
    x, y, z = OfReal(1.0), OfReal(2.0), POSINF
    print(f"  x = {x}, y = {y}, z = {z}")
    print(f"  x + z = {x} + {z} = {x + z}")
    print(f"  y + z = {y} + {z} = {y + z}")
    print(f"  x + z = y + z?  {x + z == y + z}  (both are +∞)")
    print(f"  x = y?           {x == y}  (1 ≠ 2)")
    print(f"  ✗ Cancellation FAILS: x + z = y + z but x ≠ y.\n")


def demo_theorem_7_negation_involution() -> None:
    """Theorem 7: ∀ x ∈ 𝕋, −(−x) = x."""
    print("=" * 60)
    print("THEOREM 7: Negation is an Involution")
    print("=" * 60)
    for x in ALL_ELEMENTS:
        neg_x = -x
        neg_neg_x = -neg_x
        status = "✓" if neg_neg_x == x else "✗"
        print(f"  {status}  −(−({x})) = −({neg_x}) = {neg_neg_x}")
    print()


def demo_nullity_absorption() -> None:
    """Demonstrate that Φ absorbs under both addition and multiplication."""
    print("=" * 60)
    print("BONUS: Nullity Absorption (Φ is the 'black hole')")
    print("=" * 60)
    for x in ALL_ELEMENTS:
        add_result = PHI + x
        mul_result = PHI * x
        print(f"  Φ + {x:>4s} = {add_result:>4s}  |  Φ × {x:>4s} = {mul_result:>4s}")
    print()


def demo_multiplication_table() -> None:
    """Print the full transreal multiplication table for special elements."""
    print("=" * 60)
    print("BONUS: Multiplication Table (special elements)")
    print("=" * 60)
    specials: list[Transreal] = [OfReal(-1.0), ZERO, ONE, POSINF, NEGINF, PHI]
    header = "  ×    | " + " | ".join(f"{s!s:>4s}" for s in specials)
    print(header)
    print("  " + "-" * (len(header) - 2))
    for x in specials:
        row = f"  {x!s:>4s} | " + " | ".join(
            f"{x * y!s:>4s}" for y in specials
        )
        print(row)
    print()


def demo_conservativity() -> None:
    """Demonstrate that real arithmetic is preserved in the transreal embedding."""
    print("=" * 60)
    print("BONUS: Conservativity — Real Arithmetic is Preserved")
    print("=" * 60)
    pairs = [(3.0, 5.0), (-2.0, 7.0), (0.5, 0.5), (0.0, 42.0)]
    for a, b in pairs:
        ta, tb = OfReal(a), OfReal(b)
        print(f"  {a} + {b} = {a + b:>8g}  |  ofReal({a}) + ofReal({b}) = {ta + tb}")
        print(f"  {a} × {b} = {a * b:>8g}  |  ofReal({a}) × ofReal({b}) = {ta * tb}")
        print()


# ─── Main ────────────────────────────────────────────────────────────

def main() -> None:
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   TRANSREAL ARITHMETIC: NUMERICAL DEMONSTRATIONS        ║")
    print("║   Computing Beyond Plus-Minus Infinity                  ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_theorem_1_add_commutativity()
    demo_theorem_2_add_associativity()
    demo_theorem_3_mul_commutativity()
    demo_theorem_4_no_additive_inverse()
    demo_theorem_5_distributivity_fails()
    demo_theorem_6_cancellation_fails()
    demo_theorem_7_negation_involution()
    demo_nullity_absorption()
    demo_multiplication_table()
    demo_conservativity()

    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
