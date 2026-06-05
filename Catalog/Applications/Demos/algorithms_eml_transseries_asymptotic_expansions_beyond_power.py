"""
Transseries Algorithms: Type-Hinted Implementations

Core algorithms for working with transseries:
1. Growth level comparison
2. Transmonomial evaluation
3. Transseries arithmetic (addition, scalar multiplication)
4. Leading term extraction
5. Asymptotic comparison
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional
import math


@dataclass(frozen=True, order=True)
class GrowthLevel:
    """A growth level (depth, exponent) with lexicographic ordering.
    
    The depth represents the number of iterated exponentials:
    - depth -1: logarithmic (log(x)^α)
    - depth  0: polynomial (x^α)
    - depth  1: exponential (exp(αx))
    - depth  2: double exponential (exp(α·exp(x)))
    
    The exponent is the leading coefficient within each depth stratum.
    """
    depth: int
    exponent: float

    def exp_shift(self) -> GrowthLevel:
        """Shift depth up by 1 (apply exponential)."""
        return GrowthLevel(self.depth + 1, self.exponent)

    def log_shift(self) -> GrowthLevel:
        """Shift depth down by 1 (apply logarithm)."""
        return GrowthLevel(self.depth - 1, self.exponent)

    def evaluate(self, x: float) -> float:
        """Evaluate the transmonomial at x."""
        if self.depth == -1:
            return math.log(x) ** self.exponent if x > 0 else 0.0
        elif self.depth == 0:
            return x ** self.exponent if x > 0 else 0.0
        elif self.depth == 1:
            val = self.exponent * x
            return math.exp(val) if val < 700 else float('inf')
        elif self.depth == 2:
            inner = self.exponent * math.exp(x)
            return math.exp(inner) if inner < 700 else float('inf')
        return 0.0

    def dominates(self, other: GrowthLevel) -> bool:
        """Check if self asymptotically dominates other."""
        return self > other

    def __repr__(self) -> str:
        depth_names = {-1: "log", 0: "poly", 1: "exp", 2: "exp²"}
        name = depth_names.get(self.depth, f"d{self.depth}")
        return f"GL({name}, {self.exponent})"


@dataclass
class TransseriesTerm:
    """A single term: coefficient × transmonomial at a growth level."""
    coeff: float
    level: GrowthLevel

    def evaluate(self, x: float) -> float:
        """Evaluate coefficient × transmonomial(x)."""
        return self.coeff * self.level.evaluate(x)


@dataclass
class FormalTransseries:
    """A finite formal sum of transseries terms.
    
    Maintains the invariant that terms are sorted by decreasing growth level
    and no two terms share the same growth level.
    """
    terms: list[TransseriesTerm] = field(default_factory=list)

    def __post_init__(self) -> None:
        """Sort terms and merge duplicates."""
        self._normalize()

    def _normalize(self) -> None:
        """Sort by decreasing growth level and merge duplicates."""
        level_map: dict[GrowthLevel, float] = {}
        for t in self.terms:
            level_map[t.level] = level_map.get(t.level, 0.0) + t.coeff
        self.terms = [
            TransseriesTerm(c, g)
            for g, c in sorted(level_map.items(), reverse=True)
            if abs(c) > 1e-15  # Remove zero coefficients
        ]

    @staticmethod
    def zero() -> FormalTransseries:
        """The zero transseries."""
        return FormalTransseries([])

    @staticmethod
    def single(level: GrowthLevel, coeff: float) -> FormalTransseries:
        """A single-term transseries."""
        return FormalTransseries([TransseriesTerm(coeff, level)])

    @property
    def support(self) -> list[GrowthLevel]:
        """The set of growth levels with nonzero coefficients."""
        return [t.level for t in self.terms]

    @property
    def leading_level(self) -> Optional[GrowthLevel]:
        """The dominant growth level."""
        return self.terms[0].level if self.terms else None

    @property
    def leading_coeff(self) -> float:
        """The coefficient at the leading level."""
        return self.terms[0].coeff if self.terms else 0.0

    def coeff_at(self, level: GrowthLevel) -> float:
        """Get the coefficient at a specific growth level."""
        for t in self.terms:
            if t.level == level:
                return t.coeff
        return 0.0

    def evaluate(self, x: float) -> float:
        """Evaluate the transseries at x."""
        return sum(t.evaluate(x) for t in self.terms)

    def add(self, other: FormalTransseries) -> FormalTransseries:
        """Add two transseries."""
        return FormalTransseries(self.terms + other.terms)

    def smul(self, c: float) -> FormalTransseries:
        """Scalar multiplication."""
        return FormalTransseries([
            TransseriesTerm(c * t.coeff, t.level) for t in self.terms
        ])

    def truncate_above(self, cutoff: GrowthLevel) -> FormalTransseries:
        """Remove all terms above the cutoff growth level."""
        return FormalTransseries([
            t for t in self.terms if t.level <= cutoff
        ])

    def depth_set(self) -> set[int]:
        """The set of depths appearing in this transseries."""
        return {t.level.depth for t in self.terms}

    def support_at_depth(self, d: int) -> list[TransseriesTerm]:
        """Terms at a specific depth."""
        return [t for t in self.terms if t.level.depth == d]

    def __repr__(self) -> str:
        if not self.terms:
            return "0"
        parts = []
        for t in self.terms:
            sign = "+" if t.coeff > 0 else "-"
            parts.append(f"{sign}{abs(t.coeff):.2f}·{t.level}")
        return " ".join(parts).lstrip("+")


def compare_transmonomials(g1: GrowthLevel, g2: GrowthLevel) -> int:
    """Compare two transmonomials. Returns -1, 0, or 1.
    
    Algorithm (O(1)):
    1. Compare depths: higher depth dominates.
    2. Same depth: compare exponents.
    """
    if g1.depth != g2.depth:
        return -1 if g1.depth < g2.depth else 1
    if g1.exponent != g2.exponent:
        return -1 if g1.exponent < g2.exponent else 1
    return 0


def asymptotic_ratio(f_level: GrowthLevel, g_level: GrowthLevel,
                      x_values: list[float]) -> list[float]:
    """Compute f(x)/g(x) for a sequence of x values.
    
    Used to verify asymptotic dominance numerically.
    """
    ratios = []
    for x in x_values:
        f_val = f_level.evaluate(x)
        g_val = g_level.evaluate(x)
        if g_val != 0 and math.isfinite(f_val) and math.isfinite(g_val):
            ratios.append(f_val / g_val)
        else:
            ratios.append(float('inf'))
    return ratios


def verify_depth_separation(depth_low: int, depth_high: int,
                             x_values: list[float]) -> list[float]:
    """Numerically verify that higher depth dominates lower depth.
    
    Uses unit exponent (α=1) at both depths.
    """
    g_low = GrowthLevel(depth_low, 1.0)
    g_high = GrowthLevel(depth_high, 1.0)
    return asymptotic_ratio(g_high, g_low, x_values)


def iter_exp_shift(n: int, g: GrowthLevel) -> GrowthLevel:
    """Apply exp_shift n times.
    
    Result has depth g.depth + n and same exponent.
    """
    result = g
    for _ in range(n):
        result = result.exp_shift()
    return result


def eml_transseries(a_coeff: float = 1.0, b_coeff: float = 1.0) -> FormalTransseries:
    """Construct the transseries for eml(a,b) = exp(a) - log(b).
    
    Decomposes as a depth-1 term minus a depth-(-1) term.
    """
    return FormalTransseries([
        TransseriesTerm(a_coeff, GrowthLevel(1, 1)),    # exp(x) part
        TransseriesTerm(-b_coeff, GrowthLevel(-1, 1)),  # -log(x) part
    ])


if __name__ == "__main__":
    # Example: verify growth hierarchy
    print("Growth Level Hierarchy Test")
    levels = [
        GrowthLevel(-1, 1),
        GrowthLevel(0, 2),
        GrowthLevel(1, 1),
        GrowthLevel(2, 1),
    ]
    for i in range(len(levels)):
        for j in range(i + 1, len(levels)):
            print(f"  {levels[i]} < {levels[j]}: {levels[i] < levels[j]}")

    # Example: transseries arithmetic
    print("\nTransseries Arithmetic")
    T1 = FormalTransseries.single(GrowthLevel(1, 1), 3.0)
    T2 = FormalTransseries.single(GrowthLevel(0, 2), -2.0)
    T = T1.add(T2)
    print(f"  T = {T}")
    print(f"  T(10) = {T.evaluate(10.0):.4e}")
    print(f"  Leading level: {T.leading_level}")

    # Example: EML connection
    print("\nEML Connection")
    eml_T = eml_transseries()
    print(f"  eml transseries: {eml_T}")
    print(f"  eml(5) = {eml_T.evaluate(5.0):.4f}")
    print(f"  exp(5) - log(5) = {math.exp(5) - math.log(5):.4f}")
