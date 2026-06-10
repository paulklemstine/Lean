"""
Algorithms for Transseries Computation

Type-hinted implementations of the core algorithms used in transseries theory.
"""

from dataclasses import dataclass
from typing import List, Tuple, Callable, Optional
import math


@dataclass
class TransMonomial:
    """A transmonomial: a formal growth rate with a level and exponent.

    Level 0, exponent α: x^α (polynomial growth)
    Level 1, exponent α: exp(α·x) (exponential growth)
    Level -1, exponent α: log(x)^α (logarithmic growth)
    Level k > 0: exp^(k)(x)^α (k-fold iterated exponential)
    Level k < 0: log^(|k|)(x)^α (|k|-fold iterated logarithm)
    """
    level: int
    exponent: float

    def __lt__(self, other: 'TransMonomial') -> bool:
        """Dominance ordering: lexicographic on (level, exponent)."""
        if self.level != other.level:
            return self.level < other.level
        return self.exponent < other.exponent

    def evaluate(self, x: float) -> float:
        """Evaluate the transmonomial at x > 1."""
        if x <= 1:
            raise ValueError("x must be > 1")
        base = x
        if self.level == 0:
            return x ** self.exponent
        elif self.level > 0:
            for _ in range(self.level):
                base = math.exp(min(base, 500))
            return base ** self.exponent
        else:
            for _ in range(-self.level):
                if base <= 0:
                    return 0.0
                base = math.log(base)
            return base ** self.exponent if base > 0 else 0.0

    def apply_exp(self) -> 'TransMonomial':
        """Apply exp shift: raise growth level by 1."""
        return TransMonomial(self.level + 1, self.exponent)

    def apply_log(self) -> 'TransMonomial':
        """Apply log shift: lower growth level by 1."""
        return TransMonomial(self.level - 1, self.exponent)


@dataclass
class TransseriesTerm:
    """A single term in a transseries: coefficient * transmonomial."""
    coefficient: float
    monomial: TransMonomial

    def evaluate(self, x: float) -> float:
        return self.coefficient * self.monomial.evaluate(x)


class FiniteTransseries:
    """A finite transseries: sum of terms sorted by dominance."""

    def __init__(self, terms: Optional[List[TransseriesTerm]] = None):
        self.terms = sorted(terms or [], key=lambda t: t.monomial, reverse=True)
        # Remove zero coefficients
        self.terms = [t for t in self.terms if abs(t.coefficient) > 1e-15]

    def evaluate(self, x: float) -> float:
        """Evaluate the transseries at x > 1."""
        return sum(t.evaluate(x) for t in self.terms)

    def leading_term(self) -> Optional[TransseriesTerm]:
        """Return the leading (dominant) term."""
        return self.terms[0] if self.terms else None

    def growth_rate(self) -> Optional[int]:
        """Return the growth level of the leading term."""
        lt = self.leading_term()
        return lt.monomial.level if lt else None

    def __repr__(self) -> str:
        if not self.terms:
            return "0"
        parts = []
        for t in self.terms:
            sign = "+" if t.coefficient > 0 else "-"
            coeff = abs(t.coefficient)
            level = t.monomial.level
            exp = t.monomial.exponent
            if level == 0:
                parts.append(f"{sign} {coeff:.2f}·x^{exp:.1f}")
            elif level > 0:
                parts.append(f"{sign} {coeff:.2f}·exp^({level})(x)^{exp:.1f}")
            else:
                parts.append(f"{sign} {coeff:.2f}·log^({-level})(x)^{exp:.1f}")
        return " ".join(parts).lstrip("+ ")


def exponential_growth_rate_estimate(
    f: Callable[[float], float],
    x_max: float = 1000.0,
    n_points: int = 100
) -> float:
    """Estimate the exponential growth rate of f.

    Returns lim_{x→∞} log(f(x))/x, estimated numerically.
    """
    x_values = [x_max * (i + 1) / n_points for i in range(n_points)]
    rates = []
    for x in x_values[-20:]:  # Use the largest x values
        fx = f(x)
        if fx > 0:
            rates.append(math.log(fx) / x)
    return sum(rates) / len(rates) if rates else 0.0


def compare_exponential_sums(
    b: List[float],
    c1: List[float],
    c2: List[float],
    x_test: List[float]
) -> Tuple[bool, float]:
    """Test the comparison theorem: do two exponential sums agree?

    Returns (are_equal, max_difference).
    """
    max_diff = 0.0
    for x in x_test:
        sum1 = sum(c * math.exp(bi * x) for c, bi in zip(c1, b))
        sum2 = sum(c * math.exp(bi * x) for c, bi in zip(c2, b))
        max_diff = max(max_diff, abs(sum1 - sum2))
    return max_diff < 1e-10, max_diff


def dominance_filtration_level(
    f: Callable[[float], float],
    x_test: float = 100.0
) -> int:
    """Estimate the dominance filtration level of a function.

    Level 0: polynomial growth (log(f(x))/x → 0)
    Level 1: exponential growth (log(f(x))/x → c > 0)
    Level 2: doubly-exponential (log(log(f(x)))/x → c > 0)
    Level -1: logarithmic (f(x)/x^ε → 0 for all ε > 0)
    """
    fx = f(x_test)
    if fx <= 0:
        return -2  # below logarithmic

    # Check if super-exponential
    log_fx = math.log(fx)
    if log_fx > x_test:
        log_log = math.log(log_fx)
        rate = log_log / x_test
        if rate > 0.1:
            return 2
        return 1

    # Check exponential vs polynomial
    rate = log_fx / x_test
    if rate > 0.01:
        return 1
    elif rate > -0.01:
        # Polynomial level - check if sub-polynomial
        if log_fx < math.log(x_test) * 0.5:
            return -1
        return 0
    return -1


def eml_transseries_expansion(y: float) -> FiniteTransseries:
    """Compute the two-level transseries expansion of eml(x, y) = exp(x) - log(y).

    Returns the transseries: 1·exp(x) + (-log(y))·1
    """
    exp_term = TransseriesTerm(1.0, TransMonomial(level=1, exponent=1.0))
    const_term = TransseriesTerm(-math.log(y), TransMonomial(level=0, exponent=0.0))
    return FiniteTransseries([exp_term, const_term])


if __name__ == "__main__":
    # Test the algorithms
    print("Testing TransMonomial evaluation:")
    m1 = TransMonomial(level=0, exponent=2.0)  # x^2
    m2 = TransMonomial(level=1, exponent=1.0)  # exp(x)
    m3 = TransMonomial(level=-1, exponent=1.0)  # log(x)

    x = 10.0
    print(f"  x^2 at x={x}: {m1.evaluate(x)}")
    print(f"  exp(x) at x={x}: {m2.evaluate(x):.2f}")
    print(f"  log(x) at x={x}: {m3.evaluate(x):.4f}")

    print(f"\nDominance: {m3} < {m1} < {m2}: {m3 < m1 < m2}")

    print("\nEML transseries expansion:")
    ts = eml_transseries_expansion(2.0)
    print(f"  eml(x, 2) ≈ {ts}")
    print(f"  At x=5: transseries = {ts.evaluate(5.0):.4f}, "
          f"exact = {math.exp(5) - math.log(2):.4f}")

    print("\nGrowth rate estimation:")
    print(f"  v(exp(2x)) ≈ {exponential_growth_rate_estimate(lambda x: math.exp(2*x)):.4f}")
    print(f"  v(x^5) ≈ {exponential_growth_rate_estimate(lambda x: x**5):.4f}")

    print("\nComparison theorem test:")
    b = [1.0, 2.0, 3.0]
    c1 = [0.5, -1.0, 2.0]
    c2 = [0.5, -1.0, 2.0]
    c3 = [0.5, -1.0, 2.1]
    x_test = [0.1 * i for i in range(1, 20)]
    eq1, diff1 = compare_exponential_sums(b, c1, c2, x_test)
    eq2, diff2 = compare_exponential_sums(b, c1, c3, x_test)
    print(f"  c1 == c2: {eq1} (diff = {diff1:.2e})")
    print(f"  c1 == c3: {eq2} (diff = {diff2:.2e})")
