from fractions import Fraction
from math import comb, gcd

def interval_number(m: int, n: int) -> Fraction:
    """Int_m(n) = (m+1)/(n*(m*n+1)) * C((m+1)^2 n + m, n-1), exact rational."""
    top = comb((m + 1) ** 2 * n + m, n - 1)
    return Fraction(m + 1) * Fraction(top, n * (m * n + 1))

def integrality_report(m: int, n: int) -> dict[str, bool]:
    """Diagnose why (or whether) Int_m(n) is an integer.

    Uses gcd(n, m*n+1) = 1 to split the denominator n*(m*n+1) into coprime
    factors, then tests divisibility of the numerator by each factor.
    """
    numerator = (m + 1) * comb((m + 1) ** 2 * n + m, n - 1)
    return {
        "coprime": gcd(n, m * n + 1) == 1,
        "n_factor_ok": numerator % n == 0,
        "mn1_factor_ok": numerator % (m * n + 1) == 0,
        "is_integer": interval_number(m, n).denominator == 1,
    }
