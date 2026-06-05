#!/usr/bin/env python3
"""
Transseries Growth Scale: Algorithms

Type-hinted implementations of the core algorithms from the
transseries growth scale formalization.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import List, Optional, Callable, Tuple
import math


@dataclass(frozen=True)
class GrowthLevel:
    """A growth level in the transseries hierarchy.
    
    Attributes:
        depth: The exponential depth (positive = exponential, negative = logarithmic)
        exponent: The power within that depth level
    """
    depth: int
    exponent: float

    def __lt__(self, other: GrowthLevel) -> bool:
        """Lexicographic ordering (corresponds to asymptotic dominance)."""
        if self.depth < other.depth:
            return True
        if self.depth == other.depth and self.exponent < other.exponent:
            return True
        return False

    def __le__(self, other: GrowthLevel) -> bool:
        return self < other or self == other

    def __gt__(self, other: GrowthLevel) -> bool:
        return other < self

    def __ge__(self, other: GrowthLevel) -> bool:
        return other <= self

    def exp_shift(self) -> GrowthLevel:
        """Apply exponential shift: raises depth by 1."""
        return GrowthLevel(self.depth + 1, self.exponent)

    def log_shift(self) -> GrowthLevel:
        """Apply logarithmic shift: lowers depth by 1."""
        return GrowthLevel(self.depth - 1, self.exponent)

    def iter_exp_shift(self, n: int) -> GrowthLevel:
        """Apply n-fold exponential shift."""
        return GrowthLevel(self.depth + n, self.exponent)

    def __repr__(self) -> str:
        return f"GL(depth={self.depth}, exp={self.exponent})"

    def to_math_notation(self) -> str:
        """Convert to readable mathematical notation."""
        d, a = self.depth, self.exponent
        if d == 0:
            if a == 1:
                return "x"
            elif a == int(a):
                return f"x^{int(a)}"
            else:
                return f"x^{a}"
        elif d > 0:
            base = "x" if a == 1 else f"x^{a}"
            for _ in range(d):
                base = f"exp({base})"
            return base
        else:
            base = "x" if a == 1 else f"x^{a}"
            for _ in range(-d):
                base = f"log({base})"
            return base


@dataclass
class TransseriesTerm:
    """A single term in a transseries: coefficient × transmonomial."""
    coeff: float
    level: GrowthLevel

    def evaluate(self, x: float) -> float:
        """Evaluate this term at x."""
        return self.coeff * _eval_transmonomial(self.level, x)


def _eval_transmonomial(g: GrowthLevel, x: float) -> float:
    """Evaluate the canonical transmonomial at growth level g."""
    if x <= 0:
        return 0.0
    d, alpha = g.depth, g.exponent
    if d == 0:
        return x ** alpha
    elif d > 0:
        val = x ** alpha
        for _ in range(d):
            if val > 700:
                return float('inf')
            val = math.exp(val)
        return val
    else:  # d < 0
        val = x
        for _ in range(-d):
            if val <= 0:
                return 0.0
            val = math.log(val)
        return max(val, 1e-300) ** alpha


@dataclass
class Transseries:
    """A simplified transseries: finite sum of terms sorted by decreasing growth level."""
    terms: List[TransseriesTerm] = field(default_factory=list)

    def __post_init__(self) -> None:
        # Ensure terms are sorted by decreasing growth level
        self.terms.sort(key=lambda t: (t.level.depth, t.level.exponent), reverse=True)

    def evaluate(self, x: float) -> float:
        """Evaluate the transseries at x."""
        return sum(t.evaluate(x) for t in self.terms)

    @property
    def leading_term(self) -> Optional[TransseriesTerm]:
        """The leading (dominant) term."""
        return self.terms[0] if self.terms else None

    @property
    def leading_level(self) -> Optional[GrowthLevel]:
        """The growth level of the leading term."""
        lt = self.leading_term
        return lt.level if lt else None


def eml_growth_op(g1: GrowthLevel, g2: GrowthLevel) -> GrowthLevel:
    """EML growth level operation.
    
    Combines exponential shift of g1 with logarithmic shift of g2,
    selecting the dominant contribution.
    
    Theorem: This always raises the growth level (result.depth >= g1.depth).
    Theorem: For polynomial inputs (depth 0), the result has depth 1.
    """
    e = g1.exp_shift()
    l = g2.log_shift()
    if e.depth > l.depth:
        return e
    elif l.depth > e.depth:
        return l
    elif e.exponent >= l.exponent:
        return e
    else:
        return l


def classify_growth_level(expr: str) -> GrowthLevel:
    """Classify a simple mathematical expression by its growth level.
    
    Algorithm (simplified):
    - Constants → GrowthLevel(0, 0) 
    - x^α → GrowthLevel(0, α)
    - exp(f) → exp_shift(classify(f))
    - log(f) → log_shift(classify(f))
    - f + g → max(classify(f), classify(g))
    - f * g → combine depths and exponents
    
    This is a simplified version; the full algorithm handles all
    closed-form expressions.
    """
    expr = expr.strip()
    
    if expr == 'x':
        return GrowthLevel(0, 1.0)
    
    if expr.startswith('exp(') and expr.endswith(')'):
        inner = expr[4:-1]
        return classify_growth_level(inner).exp_shift()
    
    if expr.startswith('log(') and expr.endswith(')'):
        inner = expr[4:-1]
        return classify_growth_level(inner).log_shift()
    
    if '^' in expr:
        base, exp_str = expr.split('^', 1)
        if base.strip() == 'x':
            try:
                alpha = float(exp_str.strip())
                return GrowthLevel(0, alpha)
            except ValueError:
                pass
    
    # Default: constant
    try:
        float(expr)
        return GrowthLevel(0, 0.0)
    except ValueError:
        return GrowthLevel(0, 0.0)


def compare_growth_rates(
    f_level: GrowthLevel, 
    g_level: GrowthLevel
) -> str:
    """Compare two growth rates and return a human-readable description."""
    if f_level < g_level:
        return f"{f_level.to_math_notation()} ≪ {g_level.to_math_notation()} (g dominates)"
    elif f_level > g_level:
        return f"{f_level.to_math_notation()} ≫ {g_level.to_math_notation()} (f dominates)"
    else:
        return f"{f_level.to_math_notation()} ~ {g_level.to_math_notation()} (same growth level)"


def depth_filtration(levels: List[GrowthLevel]) -> dict[int, List[float]]:
    """Decompose a set of growth levels by depth.
    
    Returns a dictionary mapping each depth d to the list of
    exponents at that depth, sorted in increasing order.
    
    Theorem: This decomposition is exhaustive and each layer
    is order-isomorphic to ℝ.
    """
    filtration: dict[int, List[float]] = {}
    for g in levels:
        if g.depth not in filtration:
            filtration[g.depth] = []
        filtration[g.depth].append(g.exponent)
    
    for d in filtration:
        filtration[d].sort()
    
    return filtration


# ============================================================
# Self-test
# ============================================================
if __name__ == "__main__":
    # Test growth level ordering
    assert GrowthLevel(0, 1) < GrowthLevel(1, 1)
    assert GrowthLevel(0, 1) < GrowthLevel(0, 2)
    assert GrowthLevel(-1, 5) < GrowthLevel(0, 0.1)
    
    # Test exp-log cancellation
    g = GrowthLevel(3, 2.5)
    assert g.exp_shift().log_shift() == g
    assert g.log_shift().exp_shift() == g
    
    # Test iterated shift
    assert g.iter_exp_shift(0) == g
    assert g.iter_exp_shift(2).iter_exp_shift(3) == g.iter_exp_shift(5)
    
    # Test EML growth operation
    result = eml_growth_op(GrowthLevel(0, 1), GrowthLevel(0, 1))
    assert result.depth == 1, f"Expected depth 1, got {result.depth}"
    
    # Test classification
    assert classify_growth_level("x") == GrowthLevel(0, 1.0)
    assert classify_growth_level("x^2") == GrowthLevel(0, 2.0)
    assert classify_growth_level("exp(x)") == GrowthLevel(1, 1.0)
    assert classify_growth_level("log(x)") == GrowthLevel(-1, 1.0)
    assert classify_growth_level("exp(exp(x))") == GrowthLevel(2, 1.0)
    
    # Test depth filtration
    levels = [GrowthLevel(0, 1), GrowthLevel(0, 2), GrowthLevel(1, 1), 
              GrowthLevel(-1, 0.5), GrowthLevel(1, 3)]
    filt = depth_filtration(levels)
    assert filt[-1] == [0.5]
    assert filt[0] == [1.0, 2.0]
    assert filt[1] == [1.0, 3.0]
    
    print("All self-tests passed! ✓")
