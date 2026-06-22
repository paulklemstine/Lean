import math
from fractions import Fraction
from typing import Callable, List, Sequence, Tuple

def p_adic_valuation(p: int) -> Callable[[Fraction], float]:
    def v(x: Fraction) -> float:
        if x == 0:
            return math.inf
        x = Fraction(x); num, den = abs(x.numerator), x.denominator
        def order(m: int) -> int:
            c = 0
            while m % p == 0:
                m //= p; c += 1
            return c
        return float(order(num) - order(den))
    return v

def certify_bound(a: Sequence[Fraction], b: Sequence[Fraction], p: int,
                  n_max: int) -> List[Tuple[int, float, float, float]]:
    v = p_adic_valuation(p)
    ua = [v(Fraction(x)) for x in a]
    ub = [v(Fraction(x)) for x in b]
    report: List[Tuple[int, float, float, float]] = []
    for n in range(n_max + 1):
        lhs = min(ua[k] + ub[n - k] for k in range(n + 1))
        c_n = sum((Fraction(a[k]) * Fraction(b[n - k]) for k in range(n + 1)), Fraction(0))
        rhs = v(c_n)
        assert lhs <= rhs, f"violated at n={n}"
        gap = math.inf if rhs == math.inf else rhs - lhs
        report.append((n, lhs, rhs, gap))
    return report
