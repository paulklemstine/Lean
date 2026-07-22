from fractions import Fraction
from math import exp, log, floor


def enclose_gamma(num_digits: int) -> tuple[Fraction, Fraction]:
    """Return a rational interval [lo, hi] provably containing gamma with
    width < 10^-num_digits, using the exact harmonic-bracket sandwich
    s_n <= gamma <= s'_n and the exact width ln(1 + 1/n)."""
    delta: float = 10.0 ** (-num_digits)
    # ln(1 + 1/n) < delta  <=>  n > 1/(e^delta - 1)
    n: int = floor(1.0 / (exp(delta) - 1.0)) + 1
    h: Fraction = sum((Fraction(1, k) for k in range(1, n + 1)), Fraction(0))
    margin: Fraction = Fraction(1, 10 ** (num_digits + 2))
    ln_np1: Fraction = Fraction(log(n + 1)).limit_denominator(10 ** (num_digits + 4))
    ln_n: Fraction = Fraction(log(n)).limit_denominator(10 ** (num_digits + 4))
    lower: Fraction = h - (ln_np1 + margin)
    upper: Fraction = h - (ln_n - margin)
    return lower, upper
