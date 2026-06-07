"""
Transseries Growth Hierarchy — Algorithms

Type-hinted implementations of the key algorithms from the formalization.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional
import math


@dataclass(frozen=True, order=False)
class GrowthLevel:
    """A growth level (level, exponent) in the transseries hierarchy.

    Lexicographically ordered: first by level (int), then by exponent (float).
    """
    level: int
    exponent: float

    def __lt__(self, other: GrowthLevel) -> bool:
        return (self.level, self.exponent) < (other.level, other.exponent)

    def __le__(self, other: GrowthLevel) -> bool:
        return (self.level, self.exponent) <= (other.level, other.exponent)

    def __repr__(self) -> str:
        if self.level > 0:
            base = f"exp{'(' * self.level}x{')'* self.level}"
        elif self.level == 0:
            base = "x"
        else:
            base = f"log{'(' * (-self.level)}x{')' * (-self.level)}"
        if self.exponent == 1.0:
            return base
        return f"({base})^{self.exponent}"

    def exp_shift(self) -> GrowthLevel:
        """Apply exponential shift: raise level by 1."""
        return GrowthLevel(self.level + 1, self.exponent)

    def log_shift(self) -> GrowthLevel:
        """Apply logarithmic shift: lower level by 1."""
        return GrowthLevel(self.level - 1, self.exponent)

    def depth(self) -> int:
        """Absolute nesting depth."""
        return abs(self.level)

    def formal_deriv(self) -> GrowthLevel:
        """Formal derivative level.

        Exponentials (level > 0) are fixed points.
        Polynomials/logarithms decrease exponent by 1.
        """
        if self.level > 0:
            return self
        return GrowthLevel(self.level, self.exponent - 1)

    def eval_at(self, x: float) -> float:
        """Evaluate the growth level monomial at x."""
        base = x
        if self.level > 0:
            for _ in range(self.level):
                base = math.exp(min(base, 700))
        elif self.level < 0:
            for _ in range(-self.level):
                if base > 0:
                    base = math.log(base)
                else:
                    return 0.0
        try:
            return base ** self.exponent
        except (OverflowError, ValueError):
            return float('inf') if base > 0 else 0.0


@dataclass(frozen=True)
class TransTerm:
    """A term in a transseries: coefficient × growth level."""
    coeff: float
    gl: GrowthLevel

    def eval_at(self, x: float) -> float:
        return self.coeff * self.gl.eval_at(x)


@dataclass
class Transseries:
    """A leveled transseries: finite list of terms in decreasing order."""
    terms: list[TransTerm]

    @staticmethod
    def zero() -> Transseries:
        return Transseries([])

    @staticmethod
    def monomial(c: float, gl: GrowthLevel) -> Transseries:
        return Transseries([TransTerm(c, gl)])

    def eval_at(self, x: float) -> float:
        return sum(t.eval_at(x) for t in self.terms)

    def scale(self, c: float) -> Transseries:
        return Transseries([TransTerm(c * t.coeff, t.gl) for t in self.terms])

    def growth_valuation(self) -> Optional[int]:
        """Non-archimedean growth valuation: leading level or None (⊥)."""
        if not self.terms:
            return None
        return self.terms[0].gl.level

    def leading_sign(self) -> int:
        """Sign of the leading coefficient: -1, 0, or 1."""
        if not self.terms:
            return 0
        c = self.terms[0].coeff
        if c > 0:
            return 1
        elif c < 0:
            return -1
        return 0

    def depth_spectrum(self) -> set[int]:
        """Set of depths appearing in the transseries."""
        return {t.gl.depth() for t in self.terms}

    def complexity(self) -> int:
        """Complexity measure: length + sum of depths."""
        return len(self.terms) + sum(t.gl.depth() for t in self.terms)

    def is_well_ordered(self) -> bool:
        """Check if growth levels are in strictly decreasing order."""
        for i in range(len(self.terms) - 1):
            if not (self.terms[i + 1].gl < self.terms[i].gl):
                return False
        return True

    def is_normalized(self) -> bool:
        """Check well-ordered and all coefficients nonzero."""
        return self.is_well_ordered() and all(t.coeff != 0 for t in self.terms)

    def has_level_gap(self) -> bool:
        """Check if consecutive terms have different integer levels."""
        for i in range(len(self.terms) - 1):
            if self.terms[i].gl.level == self.terms[i + 1].gl.level:
                return False
        return True


def compare_transseries(t1: Transseries, t2: Transseries) -> int:
    """Compare two normalized transseries.

    Returns:
        -1 if t1 < t2 asymptotically
         0 if they are equal
         1 if t1 > t2 asymptotically

    Algorithm: Compare leading terms lexicographically.
    """
    i = 0
    while i < len(t1.terms) and i < len(t2.terms):
        g1, g2 = t1.terms[i].gl, t2.terms[i].gl
        c1, c2 = t1.terms[i].coeff, t2.terms[i].coeff

        if g1.level != g2.level:
            return 1 if g1.level > g2.level else -1
        if g1.exponent != g2.exponent:
            return 1 if g1.exponent > g2.exponent else -1
        if c1 != c2:
            return 1 if c1 > c2 else -1
        i += 1

    if len(t1.terms) > len(t2.terms):
        return 1 if t1.terms[i].coeff > 0 else -1
    elif len(t2.terms) > len(t1.terms):
        return -1 if t2.terms[i].coeff > 0 else 1
    return 0


def formal_differentiate(ts: Transseries) -> Transseries:
    """Formal differentiation of a transseries.

    Applies the formal derivative level map to each term:
    - Exponential terms (level > 0): unchanged
    - Polynomial/log terms: exponent decreases by 1, coeff scaled by exponent
    """
    new_terms = []
    for t in ts.terms:
        if t.gl.level > 0:
            new_terms.append(t)
        else:
            new_coeff = t.coeff * t.gl.exponent
            new_gl = t.gl.formal_deriv()
            if new_coeff != 0:
                new_terms.append(TransTerm(new_coeff, new_gl))
    return Transseries(new_terms)


def iter_exp_shift(n: int, g: GrowthLevel) -> GrowthLevel:
    """Apply n exponential shifts."""
    result = g
    for _ in range(n):
        result = result.exp_shift()
    return result


def iter_formal_deriv(k: int, g: GrowthLevel) -> GrowthLevel:
    """Apply k formal derivatives to a growth level."""
    result = g
    for _ in range(k):
        result = result.formal_deriv()
    return result


if __name__ == "__main__":
    # Quick self-test
    g = GrowthLevel(0, 2)
    assert g.exp_shift().log_shift() == g
    assert g.log_shift().exp_shift() == g

    g_exp = GrowthLevel(1, 1)
    for k in range(10):
        assert iter_formal_deriv(k, g_exp) == g_exp, "Exp fixpoint failed!"

    g_poly = GrowthLevel(0, 5)
    assert iter_formal_deriv(3, g_poly) == GrowthLevel(0, 2)

    ts = Transseries([
        TransTerm(1.0, GrowthLevel(1, 1)),
        TransTerm(2.0, GrowthLevel(0, 2)),
    ])
    assert ts.growth_valuation() == 1
    assert ts.is_well_ordered()
    assert ts.complexity() == 3

    print("All self-tests passed!")
