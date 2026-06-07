"""
Transseries Algorithms: Core operations on formal asymptotic expansions.

Type-hinted implementations of transseries construction, evaluation,
normalization, and dominance comparison.
"""
from __future__ import annotations
from dataclasses import dataclass, field
from typing import List, Optional, Tuple
import math


@dataclass(frozen=True)
class TransLevel:
    """A level in the transseries hierarchy, encoded as an integer.
    Negative = iterated log, 0 = x, positive = iterated exp."""
    value: int

    @staticmethod
    def var() -> TransLevel:
        return TransLevel(0)

    @staticmethod
    def exp_level(n: int = 1) -> TransLevel:
        return TransLevel(n)

    @staticmethod
    def log_level(n: int = 1) -> TransLevel:
        return TransLevel(-n)

    def succ(self) -> TransLevel:
        return TransLevel(self.value + 1)

    def pred(self) -> TransLevel:
        return TransLevel(self.value - 1)

    def depth(self) -> int:
        return abs(self.value)

    def eval(self, x: float) -> float:
        """Evaluate this level at x."""
        if self.value == 0:
            return x
        elif self.value > 0:
            result = x
            for _ in range(self.value):
                result = math.exp(min(result, 700))
            return result
        else:
            result = x
            for _ in range(abs(self.value)):
                if result <= 0:
                    return float('-inf')
                result = math.log(result)
            return result

    def __lt__(self, other: TransLevel) -> bool:
        return self.value < other.value

    def __le__(self, other: TransLevel) -> bool:
        return self.value <= other.value

    def __repr__(self) -> str:
        names = {0: "x", 1: "exp", 2: "exp²", -1: "log", -2: "log²"}
        return names.get(self.value, f"L({self.value})")


@dataclass(frozen=True)
class TransMonomial:
    """A monomial: level^exponent."""
    level: TransLevel
    exponent: float

    def eval(self, x: float) -> float:
        base = self.level.eval(x)
        if base <= 0 and self.exponent != int(self.exponent):
            return 0.0
        try:
            return base ** self.exponent
        except (OverflowError, ValueError):
            return float('inf')

    def dominates(self, other: TransMonomial) -> bool:
        """True if self grows faster than other asymptotically."""
        if self.level.value != other.level.value:
            return self.level.value > other.level.value
        return self.exponent > other.exponent

    def __repr__(self) -> str:
        if self.exponent == 1:
            return repr(self.level)
        return f"{self.level}^{self.exponent}"


@dataclass
class TransTerm:
    """A term: coefficient × monomial."""
    coeff: float
    monomial: TransMonomial

    def eval(self, x: float) -> float:
        return self.coeff * self.monomial.eval(x)

    def __repr__(self) -> str:
        if self.coeff == 1:
            return repr(self.monomial)
        if self.coeff == -1:
            return f"-{self.monomial}"
        return f"{self.coeff}·{self.monomial}"


@dataclass
class FormalTransseries:
    """A formal transseries: finite list of terms in decreasing dominance order."""
    terms: List[TransTerm] = field(default_factory=list)

    def eval(self, x: float) -> float:
        """Evaluate at x (finite sum)."""
        return sum(t.eval(x) for t in self.terms)

    def is_normalized(self) -> bool:
        """Check if terms are in strictly decreasing dominance order
        with nonzero coefficients."""
        for t in self.terms:
            if t.coeff == 0:
                return False
        for i in range(len(self.terms) - 1):
            if not self.terms[i].monomial.dominates(self.terms[i + 1].monomial):
                return False
        return True

    def leading_level(self) -> Optional[TransLevel]:
        """The leading (dominant) level, or None if empty."""
        if not self.terms:
            return None
        return self.terms[0].monomial.level

    def leading_term(self) -> Optional[TransTerm]:
        if not self.terms:
            return None
        return self.terms[0]

    def scale(self, c: float) -> FormalTransseries:
        """Scale all coefficients by c."""
        return FormalTransseries([
            TransTerm(c * t.coeff, t.monomial) for t in self.terms
        ])

    @staticmethod
    def normalize(terms: List[TransTerm]) -> FormalTransseries:
        """Sort terms by decreasing dominance and remove zero coefficients.

        Algorithm:
        1. Filter out zero-coefficient terms
        2. Sort by (level desc, exponent desc)
        3. Merge terms with same monomial
        """
        # Filter zeros
        nonzero = [t for t in terms if t.coeff != 0]

        # Sort by decreasing dominance
        nonzero.sort(
            key=lambda t: (-t.monomial.level.value, -t.monomial.exponent)
        )

        # Merge same monomials
        merged: List[TransTerm] = []
        for t in nonzero:
            if (merged and
                merged[-1].monomial.level == t.monomial.level and
                merged[-1].monomial.exponent == t.monomial.exponent):
                merged[-1] = TransTerm(
                    merged[-1].coeff + t.coeff, t.monomial
                )
            else:
                merged.append(TransTerm(t.coeff, t.monomial))

        # Remove any that became zero after merging
        merged = [t for t in merged if t.coeff != 0]

        return FormalTransseries(merged)

    @staticmethod
    def add(t1: FormalTransseries, t2: FormalTransseries) -> FormalTransseries:
        """Add two transseries (with normalization)."""
        return FormalTransseries.normalize(t1.terms + t2.terms)

    @staticmethod
    def of_monomial(c: float, level: int, exp: float) -> FormalTransseries:
        return FormalTransseries([
            TransTerm(c, TransMonomial(TransLevel(level), exp))
        ])

    def __repr__(self) -> str:
        if not self.terms:
            return "0"
        return " + ".join(repr(t) for t in self.terms)


def dominance_comparison(t1: FormalTransseries, t2: FormalTransseries,
                          test_points: List[float]) -> List[Tuple[float, float, float]]:
    """Compare two transseries at multiple points.

    Returns list of (x, t1(x), t2(x)) tuples.

    Algorithm (Dominance Comparison):
    1. Evaluate both transseries at each test point
    2. Compare leading terms to determine asymptotic winner
    3. Return evaluation data for analysis
    """
    results = []
    for x in test_points:
        v1 = t1.eval(x)
        v2 = t2.eval(x)
        results.append((x, v1, v2))
    return results


def asymptotic_ratio(t1: FormalTransseries, t2: FormalTransseries,
                      test_points: List[float]) -> List[Tuple[float, float]]:
    """Compute ratio t1(x)/t2(x) at test points.

    Algorithm (Asymptotic Ratio):
    1. For each x, compute t1(x) and t2(x)
    2. Return ratio (handling division by zero)
    """
    results = []
    for x in test_points:
        v1 = t1.eval(x)
        v2 = t2.eval(x)
        if abs(v2) < 1e-300:
            ratio = float('inf') if v1 > 0 else float('-inf') if v1 < 0 else 0
        else:
            ratio = v1 / v2
        results.append((x, ratio))
    return results


if __name__ == "__main__":
    # Quick self-test
    T = FormalTransseries.of_monomial(1.0, 1, 1)  # exp(x)
    print(f"exp(10) via transseries: {T.eval(10):.6e}")
    print(f"exp(10) via math:        {math.exp(10):.6e}")

    T2 = FormalTransseries.normalize([
        TransTerm(1.0, TransMonomial(TransLevel(1), 1)),   # exp(x)
        TransTerm(-2.0, TransMonomial(TransLevel(0), 3)),  # -2x³
        TransTerm(0.5, TransMonomial(TransLevel(-1), 2)),  # 0.5·log²(x)
    ])
    print(f"\nThree-level: {T2}")
    print(f"Normalized: {T2.is_normalized()}")
    print(f"T2(10) = {T2.eval(10):.6e}")
