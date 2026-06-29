from fractions import Fraction
from typing import Dict, Tuple

HodgeNumbers = Dict[Tuple[int, int], int]


def epolynomial_coeff_table(n: int, h: HodgeNumbers) -> Dict[Tuple[int, int], int]:
    """Coefficient table of E(X;u,v) = sum (-1)^(p+q) h^{p,q} u^p v^q.

    Returns {(p, q): signed_coefficient} over 0 <= p,q <= n.  O(n^2).
    """
    table: Dict[Tuple[int, int], int] = {}
    for p in range(n + 1):
        for q in range(n + 1):
            c = h.get((p, q), 0)
            if c:
                table[(p, q)] = c * (-1 if (p + q) % 2 else 1)
    return table


def euler_characteristic(n: int, h: HodgeNumbers) -> int:
    """chi(X) = E(X;1,1) = sum of all signed coefficients.  O(n^2)."""
    return sum(epolynomial_coeff_table(n, h).values())


def epoly_eval(n: int, h: HodgeNumbers, u: Fraction, v: Fraction) -> Fraction:
    """Evaluate E(X;u,v) at a field point (u, v)."""
    total = Fraction(0)
    for (p, q), coeff in epolynomial_coeff_table(n, h).items():
        total += coeff * (u ** p) * (v ** q)
    return total
