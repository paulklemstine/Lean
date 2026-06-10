#!/usr/bin/env python3
"""
Algorithms for Gravitational Orbital Classification

Type-hinted implementations of the core algorithms from the
Goldilocks Theorem research.
"""

import math
from dataclasses import dataclass
from enum import Enum, auto
from fractions import Fraction
from typing import Optional


class OrbitRegime(Enum):
    """Classification of orbital behavior by spatial dimension."""
    UNSTABLE = auto()    # n >= 4: no stable circular orbits
    GOLDILOCKS = auto()  # n = 3: stable, closed, finite escape
    PRECESSING = auto()  # n = 2: stable but never-closing orbits
    INVALID = auto()     # n < 2: not enough dimensions for orbits


@dataclass(frozen=True)
class DimensionAnalysis:
    """Complete orbital analysis for a spatial dimension."""
    dim: int
    force_exponent: int          # alpha = -(n-1)
    apsidal_ratio: Optional[float]  # sqrt(4-n), None if unstable
    is_stable: bool              # 4-n > 0
    is_closed: bool              # apsidal ratio is rational
    finite_escape: bool          # n >= 3
    regime: OrbitRegime
    
    @property
    def is_goldilocks(self) -> bool:
        return self.is_stable and self.is_closed and self.finite_escape


@dataclass(frozen=True)
class BertrandResult:
    """Result of Bertrand classification for a force-law exponent."""
    alpha: Fraction              # Force law exponent
    apsidal_squared: Fraction    # 3 + alpha (exact)
    apsidal_ratio: Optional[float]  # sqrt(3+alpha), None if < 0
    is_rational: bool            # Whether apsidal ratio is rational
    is_stable: bool              # Whether 3+alpha > 0
    reason: str                  # Explanation


def classify_dimension(n: int) -> DimensionAnalysis:
    """
    Classify a spatial dimension for gravitational orbital mechanics.
    
    In n spatial dimensions:
    - Gravity follows F proportional to r^{-(n-1)}
    - Apsidal ratio rho = sqrt(4-n)
    - Orbits are stable iff 4-n > 0 (n <= 3)
    - Orbits close iff rho is rational
    - Escape velocity is finite iff n >= 3
    
    Args:
        n: Number of spatial dimensions (must be >= 1)
    
    Returns:
        DimensionAnalysis with complete orbital classification
    """
    if n < 2:
        return DimensionAnalysis(
            dim=n, force_exponent=-(n-1),
            apsidal_ratio=None, is_stable=False,
            is_closed=False, finite_escape=False,
            regime=OrbitRegime.INVALID
        )
    
    val = 4 - n
    is_stable = val > 0
    finite_escape = n >= 3
    
    if not is_stable:
        return DimensionAnalysis(
            dim=n, force_exponent=-(n-1),
            apsidal_ratio=None if val < 0 else 0.0,
            is_stable=False, is_closed=False,
            finite_escape=finite_escape,
            regime=OrbitRegime.UNSTABLE
        )
    
    rho = math.sqrt(val)
    # val is a positive integer; sqrt(val) is rational iff val is a perfect square
    sqrt_val = int(math.isqrt(val))
    is_closed = (sqrt_val * sqrt_val == val)
    
    if n == 3:
        regime = OrbitRegime.GOLDILOCKS
    elif n == 2:
        regime = OrbitRegime.PRECESSING
    else:
        regime = OrbitRegime.UNSTABLE
    
    return DimensionAnalysis(
        dim=n, force_exponent=-(n-1),
        apsidal_ratio=rho, is_stable=is_stable,
        is_closed=is_closed, finite_escape=finite_escape,
        regime=regime
    )


def is_perfect_rational_square(frac: Fraction) -> bool:
    """
    Check if a non-negative rational number is a perfect square in Q.
    
    A fraction p/q (in lowest terms) is a perfect square iff both
    p and q are perfect squares in Z.
    
    Args:
        frac: A non-negative Fraction
    
    Returns:
        True if frac = (a/b)^2 for some a/b in Q
    """
    if frac < 0:
        return False
    if frac == 0:
        return True
    
    p = abs(frac.numerator)
    q = abs(frac.denominator)
    
    def is_perfect_sq(n: int) -> bool:
        s = int(math.isqrt(n))
        return s * s == n
    
    return is_perfect_sq(p) and is_perfect_sq(q)


def rational_sqrt(frac: Fraction) -> Optional[Fraction]:
    """
    Compute sqrt of a rational number if it's rational.
    
    Returns the exact rational square root if it exists, None otherwise.
    """
    if frac < 0:
        return None
    if frac == 0:
        return Fraction(0)
    
    p = frac.numerator
    q = frac.denominator
    
    sp = int(math.isqrt(p))
    sq = int(math.isqrt(q))
    
    if sp * sp == p and sq * sq == q:
        return Fraction(sp, sq)
    return None


def bertrand_classify(alpha: Fraction) -> BertrandResult:
    """
    Classify a force-law exponent under Bertrand's criterion.
    
    For F(r) = -k*r^alpha, the apsidal ratio is sqrt(3+alpha).
    Orbits close iff this is rational, which happens iff 3+alpha
    is a perfect square of a rational number.
    
    Args:
        alpha: Force-law exponent as exact fraction
    
    Returns:
        BertrandResult with classification
    """
    val = Fraction(3) + alpha
    
    if val < 0:
        return BertrandResult(
            alpha=alpha, apsidal_squared=val,
            apsidal_ratio=None, is_rational=False,
            is_stable=False, reason="3+alpha < 0: orbits unstable"
        )
    
    if val == 0:
        return BertrandResult(
            alpha=alpha, apsidal_squared=val,
            apsidal_ratio=0.0, is_rational=True,
            is_stable=False, reason="3+alpha = 0: degenerate (marginal stability)"
        )
    
    rho_float = math.sqrt(float(val))
    rho_exact = rational_sqrt(val)
    is_rat = rho_exact is not None
    
    if is_rat:
        reason = f"3+alpha = {val} = ({rho_exact})^2: closed orbits"
    else:
        reason = f"3+alpha = {val} is not a perfect rational square: orbits precess"
    
    return BertrandResult(
        alpha=alpha, apsidal_squared=val,
        apsidal_ratio=rho_float, is_rational=is_rat,
        is_stable=True, reason=reason
    )


def find_bertrand_exponents(alpha_min: Fraction, alpha_max: Fraction,
                             denominator_bound: int = 100) -> list[Fraction]:
    """
    Find all rational exponents in [alpha_min, alpha_max] with
    denominator <= denominator_bound that give closed orbits.
    
    These are exactly the alpha such that 3+alpha = (p/q)^2
    for some integers p, q.
    
    Args:
        alpha_min, alpha_max: Range to search
        denominator_bound: Maximum denominator for alpha
    
    Returns:
        Sorted list of qualifying exponents
    """
    results = set()
    
    # Enumerate perfect rational squares (p/q)^2 in range [3+alpha_min, 3+alpha_max]
    val_min = float(Fraction(3) + alpha_min)
    val_max = float(Fraction(3) + alpha_max)
    
    for q in range(1, denominator_bound + 1):
        for p in range(0, int(math.sqrt(val_max) * q) + 2):
            val = Fraction(p * p, q * q)
            alpha = val - 3
            if alpha_min <= alpha <= alpha_max:
                results.add(alpha)
    
    return sorted(results)


def orbit_trajectory(n: int, eccentricity: float = 0.05,
                     num_points: int = 10000) -> list[tuple[float, float]]:
    """
    Compute trajectory of a nearly circular orbit in n dimensions.
    
    Uses the linearized radial equation:
        r(theta) = r0 * (1 + e * cos(rho * theta))
    where rho = sqrt(4-n) and e is the eccentricity.
    
    Args:
        n: Spatial dimension
        eccentricity: Orbital eccentricity (small for linear approximation)
        num_points: Number of trajectory points
    
    Returns:
        List of (x, y) coordinates
    """
    if 4 - n <= 0:
        return []
    
    rho = math.sqrt(4 - n)
    r0 = 1.0
    
    coords = []
    for i in range(num_points):
        theta = 2 * math.pi * i * 20 / num_points  # 20 revolutions
        r = r0 * (1 + eccentricity * math.cos(rho * theta))
        coords.append((r * math.cos(theta), r * math.sin(theta)))
    
    return coords


if __name__ == "__main__":
    # Demo: classify dimensions 1-7
    print("Dimension Classification:")
    for n in range(1, 8):
        result = classify_dimension(n)
        print(f"  n={n}: {result.regime.name}"
              f" | stable={result.is_stable}"
              f" | closed={result.is_closed}"
              f" | escape={result.finite_escape}"
              f" | goldilocks={result.is_goldilocks}")
    
    print("\nBertrand Classification (integer exponents):")
    for alpha in range(-2, 3):
        result = bertrand_classify(Fraction(alpha))
        print(f"  alpha={alpha:+d}: {result.reason}")
    
    print("\nRational Bertrand exponents in [-3, 10] with denom <= 20:")
    exponents = find_bertrand_exponents(Fraction(-3), Fraction(10), 20)
    for a in exponents[:15]:
        print(f"  alpha = {str(a):>8s}  =>  3+alpha = {str(Fraction(3)+a):>8s}")
