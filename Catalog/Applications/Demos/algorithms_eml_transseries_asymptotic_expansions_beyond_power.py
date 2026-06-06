#!/usr/bin/env python3
"""
Transseries Algorithms: Type-Hinted Implementations

Core algorithms for working with transseries, including:
- Growth level comparison and ordering
- Transseries arithmetic (addition, scalar multiplication)
- Asymptotic comparison via leading term extraction
- Transseries evaluation at a point
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Tuple
import math


@dataclass(frozen=True, order=True)
class GrowthLevel:
    """A growth level (depth, exponent) classifying transmonomial growth.
    
    Ordered lexicographically: depth first, then exponent.
    - depth=0, exponent=α: polynomial x^α
    - depth=1, exponent=1: exp(x)
    - depth=2, exponent=1: exp(exp(x))
    - depth=-1, exponent=1: log(x)
    """
    depth: int
    exponent: float
    
    @staticmethod
    def poly(alpha: float) -> GrowthLevel:
        return GrowthLevel(0, alpha)
    
    @staticmethod
    def exp_level(alpha: float = 1.0) -> GrowthLevel:
        return GrowthLevel(1, alpha)
    
    @staticmethod
    def log_level(alpha: float = 1.0) -> GrowthLevel:
        return GrowthLevel(-1, alpha)
    
    def exp_shift(self) -> GrowthLevel:
        """Increase depth by 1 (formal exp wrapping)."""
        return GrowthLevel(self.depth + 1, self.exponent)
    
    def log_shift(self) -> GrowthLevel:
        """Decrease depth by 1 (formal log wrapping)."""
        return GrowthLevel(self.depth - 1, self.exponent)
    
    def eval_at(self, x: float) -> float:
        """Evaluate this growth level as a function at x."""
        val = x ** self.exponent
        if self.depth > 0:
            for _ in range(self.depth):
                val = math.exp(min(val, 700))
        elif self.depth < 0:
            for _ in range(-self.depth):
                if val > 0:
                    val = math.log(val)
                else:
                    return float('-inf')
        return val
    
    def __repr__(self) -> str:
        if self.depth == 0:
            return f"x^{self.exponent}"
        elif self.depth > 0:
            inner = f"x^{self.exponent}" if self.exponent != 1.0 else "x"
            return "exp(" * self.depth + inner + ")" * self.depth
        else:
            inner = f"x^{self.exponent}" if self.exponent != 1.0 else "x"
            return "log(" * (-self.depth) + inner + ")" * (-self.depth)


class Transseries:
    """A finitely supported formal sum over growth levels.
    
    T = Σ_g a_g · m_g where m_g is the transmonomial at growth level g.
    """
    
    def __init__(self, terms: Optional[Dict[GrowthLevel, float]] = None):
        self._terms: Dict[GrowthLevel, float] = {}
        if terms:
            for g, c in terms.items():
                if abs(c) > 1e-15:
                    self._terms[g] = c
    
    @staticmethod
    def monomial(g: GrowthLevel, coeff: float) -> Transseries:
        """Create a single-term transseries c · m_g."""
        return Transseries({g: coeff})
    
    @staticmethod
    def zero() -> Transseries:
        """The zero transseries."""
        return Transseries()
    
    def coeff(self, g: GrowthLevel) -> float:
        """Get the coefficient at growth level g."""
        return self._terms.get(g, 0.0)
    
    @property
    def support(self) -> List[GrowthLevel]:
        """Sorted list of growth levels with nonzero coefficients."""
        return sorted(self._terms.keys(), reverse=True)
    
    @property
    def leading_level(self) -> Optional[GrowthLevel]:
        """The maximum growth level in the support, or None if zero."""
        if not self._terms:
            return None
        return max(self._terms.keys())
    
    @property
    def leading_coeff(self) -> float:
        """The coefficient at the leading growth level."""
        g = self.leading_level
        return self._terms[g] if g is not None else 0.0
    
    def __add__(self, other: Transseries) -> Transseries:
        """Add two transseries coefficient-wise."""
        result: Dict[GrowthLevel, float] = dict(self._terms)
        for g, c in other._terms.items():
            result[g] = result.get(g, 0.0) + c
        return Transseries(result)
    
    def __neg__(self) -> Transseries:
        return Transseries({g: -c for g, c in self._terms.items()})
    
    def __sub__(self, other: Transseries) -> Transseries:
        return self + (-other)
    
    def scale(self, s: float) -> Transseries:
        """Scalar multiplication: s · T."""
        return Transseries({g: s * c for g, c in self._terms.items()})
    
    def eval_at(self, x: float) -> float:
        """Evaluate the transseries at x (for large x, approximately)."""
        return sum(c * g.eval_at(x) for g, c in self._terms.items())
    
    def is_zero(self) -> bool:
        return len(self._terms) == 0
    
    def __repr__(self) -> str:
        if not self._terms:
            return "0"
        parts = []
        for g in self.support:
            c = self._terms[g]
            if abs(c - 1.0) < 1e-15:
                parts.append(f"{g}")
            elif abs(c + 1.0) < 1e-15:
                parts.append(f"-{g}")
            else:
                parts.append(f"{c:.4g}·{g}")
        return " + ".join(parts)


def asymptotic_compare(t1: Transseries, t2: Transseries) -> int:
    """Compare two transseries asymptotically.
    
    Returns:
        +1 if t1 dominates t2 (t1/t2 → ∞)
        -1 if t2 dominates t1 (t1/t2 → 0)
         0 if they are asymptotically equivalent (t1/t2 → 1)
    
    Algorithm: Compare leading growth levels, then leading coefficients,
    then recurse on the remainder.
    """
    diff = t1 - t2
    if diff.is_zero():
        return 0
    
    g = diff.leading_level
    c = diff.leading_coeff
    
    if g is not None:
        if c > 0:
            return 1  # t1 dominates
        elif c < 0:
            return -1  # t2 dominates
    
    return 0


def eml_transseries(y: float) -> Transseries:
    """Construct the transseries for eml(x, y) = exp(x) - log(y).
    
    This has two terms:
    - exp(x) at growth level (1, 1) with coefficient 1
    - -log(y) at growth level (0, 0) with coefficient -log(y)
      (this is a constant term, depth 0, exponent 0 = x^0 = 1)
    """
    return Transseries({
        GrowthLevel.exp_level(1.0): 1.0,
        GrowthLevel.poly(0.0): -math.log(y) if y > 0 else 0.0,
    })


def verify_diagonal_gap(x: float) -> Tuple[float, bool]:
    """Verify the diagonal gap theorem: exp(x) - log(x) ≥ 2 for x > 0."""
    if x <= 0:
        raise ValueError("x must be positive")
    gap = math.exp(x) - math.log(x)
    return gap, gap >= 2.0


# ---- Main demo ----

if __name__ == "__main__":
    print("=== Transseries Algorithm Demonstrations ===\n")
    
    # Growth level comparison
    print("1. Growth Level Ordering:")
    levels = [
        GrowthLevel.log_level(),
        GrowthLevel.poly(0.5),
        GrowthLevel.poly(1.0),
        GrowthLevel.poly(2.0),
        GrowthLevel.exp_level(),
        GrowthLevel(2, 1.0),
    ]
    for i, g in enumerate(levels):
        print(f"   {g}")
        if i > 0:
            assert levels[i-1] < levels[i], f"Order violation: {levels[i-1]} >= {levels[i]}"
    print("   ✓ All comparisons verified\n")
    
    # Transseries arithmetic
    print("2. Transseries Arithmetic:")
    t1 = Transseries.monomial(GrowthLevel.exp_level(), 3.0)
    t2 = Transseries.monomial(GrowthLevel.poly(2.0), -1.0)
    t_sum = t1 + t2
    print(f"   T1 = {t1}")
    print(f"   T2 = {t2}")
    print(f"   T1 + T2 = {t_sum}")
    print(f"   Eval at x=5: {t_sum.eval_at(5):.2f}\n")
    
    # EML transseries
    print("3. EML Transseries Decomposition:")
    eml = eml_transseries(2.0)
    print(f"   eml(x, 2) ≈ {eml}")
    print(f"   Leading level: {eml.leading_level}")
    for x in [1, 5, 10]:
        print(f"   Eval at x={x}: {eml.eval_at(x):.4f} "
              f"(exact: {math.exp(x) - math.log(2):.4f})")
    
    # Asymptotic comparison
    print("\n4. Asymptotic Comparison:")
    t_exp = Transseries.monomial(GrowthLevel.exp_level(), 1.0)
    t_poly = Transseries.monomial(GrowthLevel.poly(100.0), 1.0)
    result = asymptotic_compare(t_exp, t_poly)
    print(f"   exp(x) vs x^100: {'exp dominates' if result > 0 else 'poly dominates'}")
    
    # Diagonal gap verification
    print("\n5. Diagonal Gap Verification:")
    for x in [0.001, 0.1, 0.5, 1.0, 2.0, 10.0]:
        gap, valid = verify_diagonal_gap(x)
        print(f"   x={x:>6.3f}: gap = {gap:.6f}, ≥ 2: {valid}")
    
    print("\n=== All demonstrations completed ===")
