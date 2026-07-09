from decimal import Decimal, getcontext

getcontext().prec = 60

SQRT5 = Decimal(5).sqrt()
PHI = (Decimal(1) + SQRT5) / Decimal(2)


def best_numerator(q: int) -> int:
    """Numerator p = round(q * phi) of the best fraction with denominator q."""
    return int((Decimal(q) * PHI).to_integral_value(rounding="ROUND_HALF_UP"))


def approximation_score(p: int, q: int) -> Decimal:
    """Scale-invariant approximation quality q^2 * |phi - p/q|.

    The badly-approximable theorem guarantees this is always >= 1/3; empirically
    it descends toward the sharp Hurwitz constant 1/sqrt(5) ~ 0.4472 along the
    Fibonacci convergents.
    """
    return (Decimal(q) ** 2) * abs(PHI - Decimal(p) / Decimal(q))


def verify_lower_bound(q_max: int) -> Decimal:
    """Check q^2|phi - p/q| >= 1/3 for all 1 <= q <= q_max; return the minimum."""
    third = Decimal(1) / Decimal(3)
    best = None
    for q in range(1, q_max + 1):
        s = approximation_score(best_numerator(q), q)
        assert s >= third, f"lower bound violated at q={q}"
        best = s if best is None or s < best else best
    return best
