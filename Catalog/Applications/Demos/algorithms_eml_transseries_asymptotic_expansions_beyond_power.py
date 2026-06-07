"""
Transseries Algorithms

Type-hinted implementations of key algorithms for transseries manipulation.
"""

from dataclasses import dataclass
from typing import List, Optional, Tuple
import math


@dataclass(frozen=True, order=True)
class GrowthLevel:
    """Growth level (depth, exponent) with lexicographic ordering."""
    depth: int
    exponent: float

    def exp_shift(self) -> 'GrowthLevel':
        """Raise depth by 1 (composition with exp)."""
        return GrowthLevel(self.depth + 1, self.exponent)

    def log_shift(self) -> 'GrowthLevel':
        """Lower depth by 1 (composition with log)."""
        return GrowthLevel(self.depth - 1, self.exponent)

    def neg(self) -> 'GrowthLevel':
        """Negate the exponent (reciprocal of transmonomial)."""
        return GrowthLevel(self.depth, -self.exponent)

    def evaluate(self, x: float) -> float:
        """Evaluate the transmonomial at x > 0."""
        try:
            if self.depth == 0:
                return x ** self.exponent
            elif self.depth == 1:
                return math.exp(self.exponent * x)
            elif self.depth == -1:
                return math.log(x) ** self.exponent if x > 1 else 0.0
            elif self.depth == 2:
                return math.exp(self.exponent * math.exp(x))
            elif self.depth == -2:
                lx = math.log(x) if x > 1 else 1.0
                return math.log(lx) ** self.exponent if lx > 1 else 0.0
            else:
                return x ** self.exponent
        except (OverflowError, ValueError):
            return float('inf')

    def display(self) -> str:
        """Human-readable representation."""
        a = self.exponent
        if self.depth == 0:
            return f"x^{a}" if a != 1 else "x"
        elif self.depth == 1:
            return f"exp({a}x)" if a != 1 else "exp(x)"
        elif self.depth == -1:
            return f"log(x)^{a}" if a != 1 else "log(x)"
        elif self.depth == 2:
            return f"exp({a}·exp(x))" if a != 1 else "exp(exp(x))"
        return f"m({self.depth},{a})"


@dataclass
class TransTerm:
    """A single term: coefficient × transmonomial."""
    coeff: float
    level: GrowthLevel

    def evaluate(self, x: float) -> float:
        return self.coeff * self.level.evaluate(x)


@dataclass
class Transseries:
    """Finite formal sum of transmonomial terms."""
    terms: List[TransTerm]

    # ---- Algebraic Operations ----

    def add(self, other: 'Transseries') -> 'Transseries':
        """Add two transseries (concatenation of terms)."""
        return Transseries(self.terms + other.terms)

    def scalar_mul(self, c: float) -> 'Transseries':
        """Multiply all coefficients by c."""
        return Transseries([TransTerm(c * t.coeff, t.level) for t in self.terms])

    def negate(self) -> 'Transseries':
        """Negate all coefficients."""
        return self.scalar_mul(-1)

    # ---- Depth Operations ----

    def depth_shift_up(self) -> 'Transseries':
        """Apply exp_shift to all transmonomials."""
        return Transseries([TransTerm(t.coeff, t.level.exp_shift()) for t in self.terms])

    def depth_shift_down(self) -> 'Transseries':
        """Apply log_shift to all transmonomials."""
        return Transseries([TransTerm(t.coeff, t.level.log_shift()) for t in self.terms])

    def filter_depth(self, d: int) -> 'Transseries':
        """Keep only terms at depth ≤ d."""
        return Transseries([t for t in self.terms if t.level.depth <= d])

    def component_at(self, d: int) -> 'Transseries':
        """Keep only terms at depth exactly d."""
        return Transseries([t for t in self.terms if t.level.depth == d])

    # ---- Classification ----

    def is_power_series(self) -> bool:
        return all(t.level.depth == 0 for t in self.terms)

    def is_purely_exponential(self) -> bool:
        return all(t.level.depth > 0 for t in self.terms)

    def is_purely_logarithmic(self) -> bool:
        return all(t.level.depth < 0 for t in self.terms)

    def classify(self) -> str:
        if not self.terms:
            return "zero"
        if self.is_power_series():
            return "power_series"
        if self.is_purely_exponential():
            return "purely_exponential"
        if self.is_purely_logarithmic():
            return "purely_logarithmic"
        return "mixed"

    # ---- Evaluation ----

    def evaluate(self, x: float) -> float:
        return sum(t.evaluate(x) for t in self.terms)

    # ---- Analysis ----

    def leading_level(self) -> Optional[GrowthLevel]:
        """The dominant growth level (highest in lexicographic order)."""
        if not self.terms:
            return None
        return max(t.level for t in self.terms)

    def leading_coeff(self) -> float:
        """Coefficient of the leading term."""
        ll = self.leading_level()
        if ll is None:
            return 0.0
        return sum(t.coeff for t in self.terms if t.level == ll)

    def max_depth(self) -> int:
        """Maximum depth among all terms."""
        if not self.terms:
            return 0
        return max(t.level.depth for t in self.terms)

    def depth_spectrum(self) -> List[int]:
        """Sorted list of distinct depths present."""
        return sorted(set(t.level.depth for t in self.terms))


# ============================================================
# Algorithm 1: Transseries Comparison
# ============================================================

def compare_transseries(S: Transseries, T: Transseries) -> str:
    """
    Compare two transseries asymptotically.

    Returns:
        'S_dominates' if S(x)/T(x) → ∞
        'T_dominates' if T(x)/S(x) → ∞
        'equivalent' if S(x)/T(x) → c ≠ 0
        'both_zero' if both are empty
    """
    if not S.terms and not T.terms:
        return 'both_zero'
    if not S.terms:
        return 'T_dominates'
    if not T.terms:
        return 'S_dominates'

    ls = S.leading_level()
    lt = T.leading_level()

    if ls is None:
        return 'T_dominates'
    if lt is None:
        return 'S_dominates'

    if ls > lt:
        return 'S_dominates'
    elif lt > ls:
        return 'T_dominates'
    else:
        cs = S.leading_coeff()
        ct = T.leading_coeff()
        if abs(cs) > abs(ct):
            return 'S_dominates'
        elif abs(ct) > abs(cs):
            return 'T_dominates'
        else:
            return 'equivalent'


# ============================================================
# Algorithm 2: Depth Filtration Decomposition
# ============================================================

def depth_decompose(T: Transseries) -> dict:
    """
    Decompose a transseries by depth level.

    Returns:
        Dictionary mapping depth d → Transseries at that depth.
    """
    result = {}
    for d in T.depth_spectrum():
        result[d] = T.component_at(d)
    return result


# ============================================================
# Algorithm 3: Asymptotic Ratio Computation
# ============================================================

def asymptotic_ratio_sequence(
    S: Transseries, T: Transseries,
    x_values: List[float]
) -> List[Tuple[float, float]]:
    """
    Compute the ratio S(x)/T(x) at given x values.

    Returns:
        List of (x, ratio) pairs showing convergence behavior.
    """
    results = []
    for x in x_values:
        s_val = S.evaluate(x)
        t_val = T.evaluate(x)
        if abs(t_val) < 1e-300:
            ratio = float('inf') if s_val > 0 else float('-inf')
        else:
            ratio = s_val / t_val
        results.append((x, ratio))
    return results


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    # Example: Compare exp(x) + x² vs 2·exp(x)
    S = Transseries([
        TransTerm(1, GrowthLevel(1, 1)),
        TransTerm(1, GrowthLevel(0, 2))
    ])
    T = Transseries([
        TransTerm(2, GrowthLevel(1, 1))
    ])

    print(f"S = exp(x) + x²")
    print(f"T = 2·exp(x)")
    print(f"Comparison: {compare_transseries(S, T)}")
    print(f"S classification: {S.classify()}")
    print(f"T classification: {T.classify()}")

    print("\nDepth decomposition of S:")
    for d, comp in depth_decompose(S).items():
        terms_str = ", ".join(f"{t.coeff}·{t.level.display()}" for t in comp.terms)
        print(f"  depth {d}: {terms_str}")

    print("\nAsymptotic ratios S(x)/T(x):")
    ratios = asymptotic_ratio_sequence(S, T, [1, 5, 10, 50, 100, 500])
    for x, r in ratios:
        print(f"  x = {x:>5}: S/T = {r:.6f}")
    print(f"  Expected limit: 0.5 (since leading terms have ratio 1/2)")
