#!/usr/bin/env python3
"""
Algorithms for Transseries Arithmetic and Asymptotic Comparison

This module implements:
1. Transseries term representation and arithmetic
2. Asymptotic comparison of transseries terms
3. Leading coefficient extraction
4. Transseries normalization (sorting by dominance)
"""

import math
from dataclasses import dataclass, field
from enum import IntEnum
from typing import List, Optional, Tuple, Callable


class ScaleLevel(IntEnum):
    """Levels in the transseries hierarchy, ordered by growth rate."""
    LOG_LOG = 0      # log(log(x))
    LOG = 1          # log(x)
    POLY = 2         # x^α
    EXP = 3          # exp(x)
    EXP_EXP = 4      # exp(exp(x))


@dataclass
class TransseriesMonomial:
    """A single monomial in a transseries expansion.
    
    Represents: coeff * (scale_function(x))
    where scale_function is determined by the level and parameter.
    
    Examples:
      - 3.0 * exp(x)         → TransseriesMonomial(3.0, EXP, 1.0)
      - -2.0 * x^1.5         → TransseriesMonomial(-2.0, POLY, 1.5)
      - 1.0 * log(x)         → TransseriesMonomial(1.0, LOG, 1.0)
      - 0.5 * exp(exp(x))    → TransseriesMonomial(0.5, EXP_EXP, 1.0)
    """
    coeff: float
    level: ScaleLevel
    param: float = 1.0  # exponent for POLY, multiplier for EXP
    
    def evaluate(self, x: float) -> float:
        """Evaluate this monomial at x."""
        if self.level == ScaleLevel.LOG_LOG:
            return self.coeff * math.log(math.log(x)) if x > 1 else 0.0
        elif self.level == ScaleLevel.LOG:
            return self.coeff * (math.log(x) ** self.param) if x > 0 else 0.0
        elif self.level == ScaleLevel.POLY:
            return self.coeff * (x ** self.param)
        elif self.level == ScaleLevel.EXP:
            return self.coeff * math.exp(self.param * x)
        elif self.level == ScaleLevel.EXP_EXP:
            try:
                return self.coeff * math.exp(math.exp(self.param * x))
            except OverflowError:
                return float('inf') if self.coeff > 0 else float('-inf')
        return 0.0
    
    def dominates(self, other: 'TransseriesMonomial') -> bool:
        """Check if self asymptotically dominates other.
        
        Returns True if other/self → 0 as x → ∞.
        
        Algorithm (Asymptotic Comparison):
          1. Compare scale levels: higher level always dominates.
          2. Within same level, compare parameters:
             - POLY: higher exponent dominates
             - EXP: higher multiplier dominates
             - LOG: higher power dominates
        """
        if self.level != other.level:
            return self.level > other.level
        # Same level: compare parameters
        return self.param > other.param
    
    def __repr__(self) -> str:
        level_names = {
            ScaleLevel.LOG_LOG: "log(log(x))",
            ScaleLevel.LOG: f"log(x)^{self.param}",
            ScaleLevel.POLY: f"x^{self.param}",
            ScaleLevel.EXP: f"exp({self.param}x)",
            ScaleLevel.EXP_EXP: f"exp(exp({self.param}x))",
        }
        return f"{self.coeff} · {level_names[self.level]}"


@dataclass
class Transseries:
    """A finite transseries: a sum of monomials sorted by dominance.
    
    The canonical form has monomials sorted in decreasing order of
    asymptotic growth rate. The leading term determines the asymptotic
    behavior of the entire series.
    
    Algorithm (Transseries Normalization):
      1. Sort terms by (level, param) in decreasing order
      2. Merge terms with identical (level, param) by summing coefficients
      3. Remove zero-coefficient terms
    """
    terms: List[TransseriesMonomial] = field(default_factory=list)
    
    def normalize(self) -> 'Transseries':
        """Sort terms by dominance and merge duplicates.
        
        Complexity: O(n log n) where n = len(terms)
        """
        # Sort by (level, param) descending
        sorted_terms = sorted(
            self.terms,
            key=lambda t: (t.level, t.param),
            reverse=True
        )
        # Merge duplicates
        merged: List[TransseriesMonomial] = []
        for term in sorted_terms:
            if merged and merged[-1].level == term.level and merged[-1].param == term.param:
                merged[-1] = TransseriesMonomial(
                    merged[-1].coeff + term.coeff,
                    term.level,
                    term.param
                )
            else:
                merged.append(TransseriesMonomial(term.coeff, term.level, term.param))
        # Remove zeros
        return Transseries([t for t in merged if abs(t.coeff) > 1e-15])
    
    def evaluate(self, x: float) -> float:
        """Evaluate the transseries at x."""
        return sum(t.evaluate(x) for t in self.terms)
    
    def leading_term(self) -> Optional[TransseriesMonomial]:
        """Extract the leading (dominant) term.
        
        By the Uniqueness Theorem (leading_coeff_unique), this coefficient
        is uniquely determined by the asymptotic behavior of the function.
        """
        normalized = self.normalize()
        return normalized.terms[0] if normalized.terms else None
    
    def __add__(self, other: 'Transseries') -> 'Transseries':
        """Add two transseries."""
        return Transseries(self.terms + other.terms).normalize()
    
    def __sub__(self, other: 'Transseries') -> 'Transseries':
        """Subtract two transseries."""
        neg_terms = [TransseriesMonomial(-t.coeff, t.level, t.param) for t in other.terms]
        return Transseries(self.terms + neg_terms).normalize()
    
    def scalar_mul(self, c: float) -> 'Transseries':
        """Multiply by a scalar."""
        return Transseries([TransseriesMonomial(c * t.coeff, t.level, t.param) for t in self.terms])
    
    def __repr__(self) -> str:
        if not self.terms:
            return "0"
        return " + ".join(repr(t) for t in self.normalize().terms)


def eml_transseries(x_series: Transseries, y_series: Transseries) -> Transseries:
    """Compute the EML transseries: exp(x_series) - log(y_series).
    
    For the leading-term approximation:
    - exp(a·exp(x) + ...) has leading term exp(a·exp(x))  (EXP_EXP level)
    - log(b·x^α + ...) has leading term α·log(x) + log(b) (LOG level)
    
    The EML operation promotes the argument from level L to level L+1
    (via exp) and demotes it from level L to level L-1 (via log).
    
    This simplified version computes the leading-term EML.
    """
    x_lead = x_series.leading_term()
    y_lead = y_series.leading_term()
    
    result_terms: List[TransseriesMonomial] = []
    
    # exp part: promotes one level
    if x_lead:
        if x_lead.level == ScaleLevel.POLY:
            # exp(c * x^α) → EXP level when α=1, otherwise complex
            if abs(x_lead.param - 1.0) < 1e-10:
                result_terms.append(TransseriesMonomial(1.0, ScaleLevel.EXP, x_lead.coeff))
            else:
                result_terms.append(TransseriesMonomial(1.0, ScaleLevel.EXP, x_lead.coeff))
        elif x_lead.level == ScaleLevel.EXP:
            result_terms.append(TransseriesMonomial(1.0, ScaleLevel.EXP_EXP, x_lead.param))
    
    # -log part: demotes one level  
    if y_lead:
        if y_lead.level == ScaleLevel.POLY:
            result_terms.append(TransseriesMonomial(-y_lead.param, ScaleLevel.LOG, 1.0))
        elif y_lead.level == ScaleLevel.EXP:
            result_terms.append(TransseriesMonomial(-y_lead.param, ScaleLevel.POLY, 1.0))
    
    return Transseries(result_terms).normalize()


def asymptotic_compare(f: Callable[[float], float],
                       g: Callable[[float], float],
                       test_points: Optional[List[float]] = None) -> str:
    """Numerically determine the asymptotic relationship between f and g.
    
    Algorithm (Numerical Asymptotic Comparison):
      1. Evaluate f(x)/g(x) at increasingly large x values
      2. If ratio → 0: f = o(g)
      3. If ratio → ∞: g = o(f)  
      4. If ratio → c ≠ 0: f ~ c·g
    
    Returns a string describing the relationship.
    """
    if test_points is None:
        test_points = [10.0, 100.0, 1000.0, 10000.0, 100000.0]
    
    ratios = []
    for x in test_points:
        try:
            fx, gx = f(x), g(x)
            if abs(gx) > 1e-300:
                ratios.append(fx / gx)
            else:
                ratios.append(float('inf') if fx > 0 else float('-inf'))
        except (OverflowError, ValueError):
            ratios.append(float('inf'))
    
    # Analyze trend
    if all(abs(r) < 1e-6 for r in ratios[-3:]):
        return "f = o(g)  [f is negligible compared to g]"
    elif all(abs(r) > 1e6 for r in ratios[-3:]):
        return "g = o(f)  [g is negligible compared to f]"
    elif len(ratios) >= 3:
        last_ratios = ratios[-3:]
        if all(abs(last_ratios[i] - last_ratios[0]) < abs(last_ratios[0]) * 0.01 for i in range(3)):
            return f"f ~ {last_ratios[-1]:.4f} · g  [asymptotically proportional]"
    
    return f"Inconclusive (ratios: {[f'{r:.4e}' for r in ratios]})"


def extract_leading_coefficient(f: Callable[[float], float],
                                 basis: Callable[[float], float],
                                 test_points: Optional[List[float]] = None) -> float:
    """Extract the leading coefficient c such that f ~ c · basis.
    
    By the Uniqueness Theorem, if such c exists, it is unique.
    
    Algorithm:
      1. Compute f(x) / basis(x) at large x values
      2. Take the limit (approximate as the last stable ratio)
    
    Returns the estimated leading coefficient.
    """
    if test_points is None:
        test_points = [100.0, 1000.0, 10000.0, 100000.0]
    
    ratios = []
    for x in test_points:
        try:
            bx = basis(x)
            if abs(bx) > 1e-300:
                ratios.append(f(x) / bx)
        except (OverflowError, ValueError):
            pass
    
    if not ratios:
        return 0.0
    return ratios[-1]  # Best approximation


if __name__ == "__main__":
    print("=== Transseries Arithmetic Demo ===\n")
    
    # Build: 3·exp(x) + 2·x² - 5·log(x)
    ts = Transseries([
        TransseriesMonomial(3.0, ScaleLevel.EXP),
        TransseriesMonomial(2.0, ScaleLevel.POLY, 2.0),
        TransseriesMonomial(-5.0, ScaleLevel.LOG),
    ]).normalize()
    
    print(f"Transseries: {ts}")
    print(f"Leading term: {ts.leading_term()}")
    print(f"Value at x=5: {ts.evaluate(5.0):.4f}")
    print(f"Value at x=10: {ts.evaluate(10.0):.4f}")
    
    print("\n=== EML Transseries Demo ===\n")
    
    # EML(x, x) = exp(x) - log(x)
    x_ts = Transseries([TransseriesMonomial(1.0, ScaleLevel.POLY, 1.0)])
    eml_ts = eml_transseries(x_ts, x_ts)
    print(f"EML({x_ts}, {x_ts}) leading terms: {eml_ts}")
    
    print("\n=== Asymptotic Comparison Demo ===\n")
    
    comparisons = [
        ("x²", "exp(x)", lambda x: x**2, lambda x: math.exp(x)),
        ("exp(x)", "exp(exp(x))", lambda x: math.exp(x), 
         lambda x: math.exp(math.exp(min(x, 700)))),
        ("log(x)", "x^0.1", lambda x: math.log(x), lambda x: x**0.1),
        ("exp(x)-log(x)", "exp(x)", lambda x: math.exp(x) - math.log(x),
         lambda x: math.exp(x)),
    ]
    
    for name_f, name_g, f, g in comparisons:
        result = asymptotic_compare(f, g)
        print(f"  {name_f}  vs  {name_g}:  {result}")
    
    print("\n=== Leading Coefficient Extraction ===\n")
    
    # f(x) = 7·exp(x) + x³ has leading coefficient 7 w.r.t. exp(x)
    c = extract_leading_coefficient(
        lambda x: 7 * math.exp(x) + x**3,
        lambda x: math.exp(x)
    )
    print(f"  f(x) = 7·exp(x) + x³, basis = exp(x)")
    print(f"  Extracted leading coefficient: {c:.6f} (expected: 7.0)")
