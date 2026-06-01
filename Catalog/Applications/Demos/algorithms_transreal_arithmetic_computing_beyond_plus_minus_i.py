"""
Transreal Arithmetic: Algorithms and Implementations
=====================================================

Type-hinted Python implementations of transreal arithmetic operations,
classification, and analysis tools.
"""

from enum import Enum
from typing import Optional, Union
from dataclasses import dataclass


class TransrealClass(Enum):
    """Classification of transreal numbers."""
    FINITE = "finite"
    INFINITE = "infinite"
    INDETERMINATE = "indeterminate"


@dataclass(frozen=True)
class Transreal:
    """
    A transreal number: either a finite real, +∞, -∞, or Φ (nullity = 0/0).

    Anderson's transreal number system extends the reals with three special
    values to make all arithmetic operations total.
    """
    kind: str  # "real", "posInf", "negInf", "nullity"
    value: Optional[float] = None

    def __post_init__(self):
        if self.kind == "real" and self.value is None:
            raise ValueError("Real transreal numbers must have a value")
        if self.kind not in ("real", "posInf", "negInf", "nullity"):
            raise ValueError(f"Invalid kind: {self.kind}")

    @staticmethod
    def of_real(x: float) -> 'Transreal':
        return Transreal("real", x)

    @staticmethod
    def pos_inf() -> 'Transreal':
        return Transreal("posInf")

    @staticmethod
    def neg_inf() -> 'Transreal':
        return Transreal("negInf")

    @staticmethod
    def phi() -> 'Transreal':
        """Nullity (Φ = 0/0)."""
        return Transreal("nullity")

    def classify(self) -> TransrealClass:
        """Classify this transreal number."""
        if self.kind == "real":
            return TransrealClass.FINITE
        elif self.kind in ("posInf", "negInf"):
            return TransrealClass.INFINITE
        else:
            return TransrealClass.INDETERMINATE

    def is_finite(self) -> bool:
        return self.kind == "real"

    def __repr__(self) -> str:
        if self.kind == "real":
            return f"Transreal({self.value})"
        elif self.kind == "posInf":
            return "+∞"
        elif self.kind == "negInf":
            return "-∞"
        else:
            return "Φ"

    def __neg__(self) -> 'Transreal':
        if self.kind == "real":
            return Transreal.of_real(-self.value)
        elif self.kind == "posInf":
            return Transreal.neg_inf()
        elif self.kind == "negInf":
            return Transreal.pos_inf()
        else:
            return Transreal.phi()

    def __add__(self, other: 'Transreal') -> 'Transreal':
        return transreal_add(self, other)

    def __mul__(self, other: 'Transreal') -> 'Transreal':
        return transreal_mul(self, other)

    def __sub__(self, other: 'Transreal') -> 'Transreal':
        return self + (-other)


def transreal_add(a: Transreal, b: Transreal) -> Transreal:
    """
    Transreal addition following Anderson's rules.

    Key rules:
    - finite + finite = finite (standard)
    - finite + ∞ = ∞, finite + (-∞) = -∞
    - ∞ + ∞ = ∞, (-∞) + (-∞) = -∞
    - ∞ + (-∞) = Φ (nullity)
    - Φ + anything = Φ (absorption)
    """
    if a.kind == "nullity" or b.kind == "nullity":
        return Transreal.phi()

    if a.kind == "real" and b.kind == "real":
        return Transreal.of_real(a.value + b.value)

    if a.kind == "real":
        return b  # real + inf = inf
    if b.kind == "real":
        return a  # inf + real = inf

    # Both are infinities
    if a.kind == b.kind:
        return a  # same sign infinity
    return Transreal.phi()  # opposite signs → nullity


def transreal_mul(a: Transreal, b: Transreal) -> Transreal:
    """
    Transreal multiplication following Anderson's rules.

    Key rules:
    - finite * finite = finite (standard)
    - positive * ∞ = ∞, negative * ∞ = -∞, 0 * ∞ = Φ
    - ∞ * ∞ = ∞, (-∞) * (-∞) = ∞, ∞ * (-∞) = -∞
    - Φ * anything = Φ (absorption)
    """
    if a.kind == "nullity" or b.kind == "nullity":
        return Transreal.phi()

    if a.kind == "real" and b.kind == "real":
        return Transreal.of_real(a.value * b.value)

    # At least one is infinite
    def sign_of(x: Transreal) -> int:
        if x.kind == "real":
            if x.value > 0:
                return 1
            elif x.value < 0:
                return -1
            else:
                return 0
        elif x.kind == "posInf":
            return 1
        else:  # negInf
            return -1

    sa, sb = sign_of(a), sign_of(b)

    if sa == 0 or sb == 0:
        return Transreal.phi()

    product_sign = sa * sb
    if product_sign > 0:
        return Transreal.pos_inf()
    else:
        return Transreal.neg_inf()


def transreal_div(a: Transreal, b: Transreal) -> Transreal:
    """Transreal division a/b."""
    if b.kind == "nullity" or a.kind == "nullity":
        return Transreal.phi()
    if b.kind == "real" and b.value == 0:
        if a.kind == "real":
            if a.value > 0:
                return Transreal.pos_inf()
            elif a.value < 0:
                return Transreal.neg_inf()
            else:
                return Transreal.phi()  # 0/0 = Φ
        else:
            return Transreal.phi()  # ∞/0 = Φ (by convention)
    if b.kind in ("posInf", "negInf"):
        if a.kind == "real":
            return Transreal.of_real(0.0)  # finite/∞ = 0
        else:
            return Transreal.phi()  # ∞/∞ = Φ
    # b is finite nonzero
    if a.kind == "real":
        return Transreal.of_real(a.value / b.value)
    elif a.kind == "posInf":
        return Transreal.pos_inf() if b.value > 0 else Transreal.neg_inf()
    else:  # negInf
        return Transreal.neg_inf() if b.value > 0 else Transreal.pos_inf()


def nullity_pair_count(vals: list[Transreal]) -> int:
    """Count nullity-producing addition pairs."""
    count = 0
    for a in vals:
        for b in vals:
            if (a + b).kind == "nullity":
                count += 1
    return count


def additive_defect(x: Transreal) -> Transreal:
    """Compute x + (-x), the additive defect."""
    return x + (-x)


def wheel_identity_check(x: Transreal) -> bool:
    """Check if the wheel identity x + 0*x = x holds."""
    zero = Transreal.of_real(0.0)
    return (x + zero * x) == x


def classify_operation_table(vals: list[Transreal],
                              op: str = "add") -> dict[str, int]:
    """
    Classify all pairwise operation results.

    Returns counts of each TransrealClass in the output.
    """
    counts: dict[str, int] = {"finite": 0, "infinite": 0, "indeterminate": 0}
    operation = transreal_add if op == "add" else transreal_mul
    for a in vals:
        for b in vals:
            result = operation(a, b)
            counts[result.classify().value] += 1
    return counts


def nullity_fragility_index(vals: list[Transreal]) -> float:
    """
    Compute the nullity fragility index: ratio of nullity-producing
    pairs to total pairs under addition.
    """
    total = len(vals) ** 2
    if total == 0:
        return 0.0
    return nullity_pair_count(vals) / total
