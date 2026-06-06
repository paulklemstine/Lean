#!/usr/bin/env python3
"""
Type-hinted implementations of core transseries algorithms.
"""

from dataclasses import dataclass, field
from typing import Dict, List, Optional, Tuple
import math


@dataclass(frozen=True, order=True)
class LogExpMonomial:
    """
    A log-exp monomial representing exp(c*x) * x^a * (log x)^b.
    Ordered lexicographically: (exp_coeff, poly_exp, log_exp).
    """
    exp_coeff: int  # c in exp(cx)
    poly_exp: int   # a in x^a
    log_exp: int    # b in (log x)^b
    
    def __mul__(self, other: 'LogExpMonomial') -> 'LogExpMonomial':
        """Group operation: componentwise addition of exponents."""
        return LogExpMonomial(
            self.exp_coeff + other.exp_coeff,
            self.poly_exp + other.poly_exp,
            self.log_exp + other.log_exp
        )
    
    def inv(self) -> 'LogExpMonomial':
        """Group inverse: negation of exponents."""
        return LogExpMonomial(-self.exp_coeff, -self.poly_exp, -self.log_exp)
    
    @property
    def depth(self) -> int:
        """GDA depth grading: |exp_coeff|."""
        return abs(self.exp_coeff)
    
    def evaluate(self, x: float) -> float:
        """Evaluate at x > 0. Returns inf on overflow."""
        try:
            val = 1.0
            if self.exp_coeff != 0:
                val *= math.exp(self.exp_coeff * x)
            if self.poly_exp != 0:
                val *= x ** self.poly_exp
            if self.log_exp != 0:
                val *= math.log(x) ** self.log_exp
            return val
        except (OverflowError, ValueError):
            return float('inf') if self.exp_coeff > 0 else 0.0
    
    def __str__(self) -> str:
        parts = []
        if self.exp_coeff != 0:
            parts.append(f"exp({self.exp_coeff}x)")
        if self.poly_exp != 0:
            parts.append(f"x^{self.poly_exp}")
        if self.log_exp != 0:
            parts.append(f"(log x)^{self.log_exp}")
        return "·".join(parts) if parts else "1"


# Standard monomials
ONE = LogExpMonomial(0, 0, 0)


def compare_monomials(m1: LogExpMonomial, m2: LogExpMonomial) -> int:
    """
    Lexicographic comparison of monomials.
    Returns -1, 0, or 1.
    
    Algorithm:
        1. Compare exp_coeff
        2. If equal, compare poly_exp
        3. If equal, compare log_exp
    
    Time: O(1)
    """
    if m1.exp_coeff != m2.exp_coeff:
        return -1 if m1.exp_coeff < m2.exp_coeff else 1
    if m1.poly_exp != m2.poly_exp:
        return -1 if m1.poly_exp < m2.poly_exp else 1
    if m1.log_exp != m2.log_exp:
        return -1 if m1.log_exp < m2.log_exp else 1
    return 0


def depth_subadditive(m1: LogExpMonomial, m2: LogExpMonomial) -> bool:
    """Verify depth subadditivity: depth(m1*m2) <= depth(m1) + depth(m2)."""
    return (m1 * m2).depth <= m1.depth + m2.depth


@dataclass
class Transseries:
    """
    Finitely-supported formal sum of LogExpMonomials with real coefficients.
    Implements addition, subtraction, leading term extraction, and depth computation.
    """
    terms: Dict[LogExpMonomial, float] = field(default_factory=dict)
    
    def _clean(self) -> None:
        """Remove zero coefficients."""
        self.terms = {m: c for m, c in self.terms.items() if abs(c) > 1e-15}
    
    def __add__(self, other: 'Transseries') -> 'Transseries':
        """
        Transseries addition: pointwise addition of coefficients.
        Time: O(|supp(self)| + |supp(other)|)
        """
        result = dict(self.terms)
        for m, c in other.terms.items():
            result[m] = result.get(m, 0.0) + c
        ts = Transseries(result)
        ts._clean()
        return ts
    
    def __neg__(self) -> 'Transseries':
        return Transseries({m: -c for m, c in self.terms.items()})
    
    def __sub__(self, other: 'Transseries') -> 'Transseries':
        return self + (-other)
    
    def scale(self, r: float) -> 'Transseries':
        """Scalar multiplication by r."""
        if abs(r) < 1e-15:
            return Transseries()
        return Transseries({m: r * c for m, c in self.terms.items()})
    
    def leading_monomial(self) -> Optional[LogExpMonomial]:
        """
        Extract the leading (dominant) monomial.
        Time: O(|support|)
        """
        if not self.terms:
            return None
        return max(self.terms.keys())
    
    def leading_coeff(self) -> float:
        """Leading coefficient."""
        m = self.leading_monomial()
        return self.terms.get(m, 0.0) if m else 0.0
    
    def exp_depth(self) -> int:
        """
        Exponential depth: max |exp_coeff| over support.
        Time: O(|support|)
        """
        if not self.terms:
            return 0
        return max(m.depth for m in self.terms)
    
    def is_purely_polynomial(self) -> bool:
        """Check if all monomials have exp_coeff = 0."""
        return all(m.exp_coeff == 0 for m in self.terms)
    
    def is_purely_logarithmic(self) -> bool:
        """Check if all monomials have exp_coeff = 0 and poly_exp = 0."""
        return all(m.exp_coeff == 0 and m.poly_exp == 0 for m in self.terms)
    
    def evaluate(self, x: float) -> float:
        """Evaluate the transseries at x > 0."""
        return sum(c * m.evaluate(x) for m, c in self.terms.items())
    
    def coeff(self, m: LogExpMonomial) -> float:
        """Get coefficient of monomial m."""
        return self.terms.get(m, 0.0)
    
    @staticmethod
    def const(r: float) -> 'Transseries':
        """Constant transseries."""
        return Transseries({ONE: r}) if abs(r) > 1e-15 else Transseries()
    
    @staticmethod
    def mono(m: LogExpMonomial) -> 'Transseries':
        """Unit monomial transseries."""
        return Transseries({m: 1.0})
    
    def __str__(self) -> str:
        if not self.terms:
            return "0"
        parts = []
        for m in sorted(self.terms.keys(), reverse=True):
            c = self.terms[m]
            if abs(c - 1.0) < 1e-10:
                parts.append(str(m))
            elif abs(c + 1.0) < 1e-10:
                parts.append(f"-{m}")
            else:
                parts.append(f"{c:.4g}·{m}")
        return " + ".join(parts)


def convolution_product(f: Transseries, g: Transseries) -> Transseries:
    """
    Convolution product of two transseries:
    (f * g)(m) = Σ_{m1*m2=m} f(m1) * g(m2)
    
    For finitely-supported transseries, this is a finite sum.
    Time: O(|supp(f)| * |supp(g)|)
    """
    result: Dict[LogExpMonomial, float] = {}
    for m1, c1 in f.terms.items():
        for m2, c2 in g.terms.items():
            m_prod = m1 * m2
            result[m_prod] = result.get(m_prod, 0.0) + c1 * c2
    ts = Transseries(result)
    ts._clean()
    return ts


def asymptotic_compare(f: Transseries, g: Transseries) -> int:
    """
    Compare two transseries asymptotically.
    Returns -1 if f < g, 0 if f = g, 1 if f > g (as x -> infinity).
    
    Algorithm:
        1. Compute difference h = f - g
        2. If h = 0, they are equal
        3. Otherwise, the sign of h is determined by its leading coefficient
    
    Time: O(|supp(f)| + |supp(g)|)
    """
    h = f - g
    if not h.terms:
        return 0
    lc = h.leading_coeff()
    return -1 if lc < 0 else 1


def verify_comparison_theorem(f: Transseries, g: Transseries) -> bool:
    """
    Verify the Asymptotic Comparison Theorem:
    f = g iff coeff(f, m) = coeff(g, m) for all m in support(f) ∪ support(g).
    """
    all_monomials = set(f.terms.keys()) | set(g.terms.keys())
    coeffs_match = all(abs(f.coeff(m) - g.coeff(m)) < 1e-15 for m in all_monomials)
    structurally_equal = (not (f - g).terms)
    return coeffs_match == structurally_equal


if __name__ == "__main__":
    # Quick self-test
    m1 = LogExpMonomial(1, 2, 0)
    m2 = LogExpMonomial(0, 3, 1)
    print(f"Monomial comparison: {m1} vs {m2} -> {compare_monomials(m1, m2)}")
    print(f"Depth subadditivity: {depth_subadditive(m1, m2)}")
    
    f = Transseries.mono(m1) + Transseries.const(3.0)
    g = Transseries.mono(m2).scale(2.0) + Transseries.const(-1.0)
    print(f"f = {f}")
    print(f"g = {g}")
    print(f"f + g = {f + g}")
    print(f"f * g = {convolution_product(f, g)}")
    print(f"Comparison theorem holds: {verify_comparison_theorem(f, f)}")
    print(f"Comparison theorem holds: {verify_comparison_theorem(f, g)}")
