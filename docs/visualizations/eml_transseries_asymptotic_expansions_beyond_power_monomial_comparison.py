#!/usr/bin/env python3
"""
Transseries Algorithms: Core computational tools for asymptotic analysis.

Implements:
1. Monomial evaluation and comparison
2. Simple transseries arithmetic
3. Asymptotic dominance testing
4. EML chain growth analysis
"""

from dataclasses import dataclass, field
from typing import List, Tuple, Optional
import math


@dataclass(frozen=True)
class TransseriesMonomial:
    """A first-level transseries monomial: x^α · exp(β·x) · log(x)^γ.

    The dominance ordering is lexicographic on (β, α, γ):
    - Higher β (exponential rate) dominates
    - At equal β, higher α (polynomial degree) dominates
    - At equal β and α, higher γ (log power) dominates
    """
    poly_exp: float = 0.0   # α: power of x
    exp_coeff: float = 0.0  # β: coefficient in exp(β·x)
    log_exp: float = 0.0    # γ: power of log(x)

    def evaluate(self, x: float) -> float:
        """Evaluate the monomial at x > 1."""
        if x <= 0:
            raise ValueError("Monomial evaluation requires x > 0")
        result = 1.0
        if self.poly_exp != 0:
            result *= x ** self.poly_exp
        if self.exp_coeff != 0:
            result *= math.exp(self.exp_coeff * x)
        if self.log_exp != 0:
            result *= math.log(x) ** self.log_exp
        return result

    def dominates(self, other: 'TransseriesMonomial') -> bool:
        """Returns True if self grows strictly faster than other."""
        if self.exp_coeff > other.exp_coeff:
            return True
        if self.exp_coeff == other.exp_coeff and self.poly_exp > other.poly_exp:
            return True
        if (self.exp_coeff == other.exp_coeff and
            self.poly_exp == other.poly_exp and
            self.log_exp > other.log_exp):
            return True
        return False

    def equivalent(self, other: 'TransseriesMonomial') -> bool:
        """Returns True if self and other have the same growth rate."""
        return (self.exp_coeff == other.exp_coeff and
                self.poly_exp == other.poly_exp and
                self.log_exp == other.log_exp)

    def valuation(self) -> Tuple[float, float, float]:
        """The tropical valuation: (β, α, γ)."""
        return (self.exp_coeff, self.poly_exp, self.log_exp)

    def __repr__(self) -> str:
        parts = []
        if self.poly_exp != 0:
            if self.poly_exp == 1:
                parts.append("x")
            else:
                parts.append(f"x^{self.poly_exp}")
        if self.exp_coeff != 0:
            if self.exp_coeff == 1:
                parts.append("exp(x)")
            else:
                parts.append(f"exp({self.exp_coeff}·x)")
        if self.log_exp != 0:
            if self.log_exp == 1:
                parts.append("log(x)")
            else:
                parts.append(f"log(x)^{self.log_exp}")
        return "·".join(parts) if parts else "1"


@dataclass
class SimpleTrans:
    """A simple transseries: a finite sum of coefficient × monomial pairs.

    Represents f(x) = Σ cᵢ · mᵢ(x) where mᵢ are transseries monomials.
    """
    terms: List[Tuple[float, TransseriesMonomial]] = field(default_factory=list)

    def evaluate(self, x: float) -> float:
        """Evaluate the transseries at x."""
        return sum(c * m.evaluate(x) for c, m in self.terms)

    def leading_term(self) -> Optional[Tuple[float, TransseriesMonomial]]:
        """Return the asymptotically dominant term."""
        if not self.terms:
            return None
        return max(self.terms, key=lambda t: t[1].valuation())

    def add(self, other: 'SimpleTrans') -> 'SimpleTrans':
        """Add two transseries (term-by-term, no simplification)."""
        return SimpleTrans(self.terms + other.terms)

    def scale(self, c: float) -> 'SimpleTrans':
        """Scale all coefficients by c."""
        return SimpleTrans([(c * coeff, m) for coeff, m in self.terms])

    def simplify(self) -> 'SimpleTrans':
        """Combine terms with equivalent monomials."""
        combined: dict = {}
        for coeff, mono in self.terms:
            key = mono.valuation()
            combined[key] = combined.get(key, 0) + coeff
        result = []
        for (beta, alpha, gamma), coeff in combined.items():
            if abs(coeff) > 1e-15:
                result.append((coeff, TransseriesMonomial(alpha, beta, gamma)))
        return SimpleTrans(sorted(result, key=lambda t: t[1].valuation(), reverse=True))


def compare_monomials(m1: TransseriesMonomial,
                      m2: TransseriesMonomial) -> str:
    """Compare two monomials: returns '≻', '≡', or '≺'."""
    if m1.dominates(m2):
        return '≻'
    elif m2.dominates(m1):
        return '≺'
    else:
        return '≡'


def asymptotic_ratio(f, g, x_values: List[float]) -> List[float]:
    """Compute f(x)/g(x) for a sequence of x values to test asymptotic equivalence."""
    return [f(x) / g(x) if g(x) != 0 else float('inf') for x in x_values]


def iter_exp(n: int, x: float) -> float:
    """n-fold iterated exponential."""
    result = x
    for _ in range(n):
        if result > 700:
            return float('inf')
        result = math.exp(result)
    return result


def iter_log(n: int, x: float) -> float:
    """n-fold iterated logarithm."""
    result = x
    for _ in range(n):
        if result <= 0:
            return float('-inf')
        result = math.log(result)
    return result


def eml_diag(z: float) -> float:
    """EML diagonal: exp(z) - log(z)."""
    if z <= 0:
        raise ValueError("eml_diag requires z > 0")
    return math.exp(z) - math.log(z)


def eml_diag_iter(n: int, z: float) -> float:
    """Iterated EML diagonal."""
    result = z
    for _ in range(n):
        if result > 700:
            return float('inf')
        result = eml_diag(result)
    return result


def growth_classification(f, x_test: float = 100.0) -> str:
    """Classify the growth rate of f by comparing against standard scales."""
    try:
        val = f(x_test)
    except (OverflowError, ValueError):
        return "super-exponential"

    if val == float('inf'):
        return "super-exponential"

    scales = [
        ("constant", 1.0),
        ("logarithmic", math.log(x_test)),
        ("polynomial(1)", x_test),
        ("polynomial(2)", x_test**2),
        ("polynomial(5)", x_test**5),
        ("exponential", math.exp(x_test) if x_test < 700 else float('inf')),
    ]

    for name, scale in scales:
        if scale == float('inf'):
            continue
        ratio = abs(val) / scale if scale > 0 else float('inf')
        if 0.01 < ratio < 100:
            return name
    return "super-polynomial"


if __name__ == "__main__":
    # Example usage
    m1 = TransseriesMonomial(poly_exp=2, exp_coeff=1)  # x^2·exp(x)
    m2 = TransseriesMonomial(poly_exp=5)                 # x^5
    m3 = TransseriesMonomial(exp_coeff=2)                # exp(2x)

    print("Monomial comparisons:")
    print(f"  {m1} vs {m2}: {compare_monomials(m1, m2)}")
    print(f"  {m1} vs {m3}: {compare_monomials(m1, m3)}")
    print(f"  {m2} vs {m3}: {compare_monomials(m2, m3)}")

    # Build a simple transseries
    t = SimpleTrans([
        (1.0, TransseriesMonomial(exp_coeff=1)),
        (-1.0, TransseriesMonomial(log_exp=1)),
    ])
    print(f"\nTransseries f(x) = exp(x) - log(x)")
    print(f"  Leading term: {t.leading_term()}")
    for x in [1, 5, 10, 50]:
        print(f"  f({x}) = {t.evaluate(x):.6f}")
