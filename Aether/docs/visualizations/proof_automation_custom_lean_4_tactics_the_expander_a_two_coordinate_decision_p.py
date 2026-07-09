from functools import lru_cache
from typing import Tuple


@lru_cache(maxsize=None)
def fib(n: int) -> int:
    """n-th Fibonacci number, F_0 = 0, F_1 = 1."""
    if n < 2:
        return n
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b


def fib_ring_decide(coeffs_lhs: dict[int, int],
                    coeffs_rhs: dict[int, int]) -> bool:
    """Decide a single-base LINEAR Fibonacci shift identity.

    `coeffs_lhs` / `coeffs_rhs` map a shift s to a coefficient c, encoding the
    expression sum_s c * F_{n+s}. The expander rewrites each F_{n+s} into the
    two-coordinate basis (F_{n+0}, F_{n+1}) using F_{n+s} = F_{s-1} F_n +
    F_s F_{n+1}, then compares the two basis vectors. Equality of the basis
    vectors is equivalent to the identity holding for ALL n.
    """
    def to_basis(coeffs: dict[int, int]) -> Tuple[int, int]:
        c0, c1 = 0, 0           # coefficient of F_n and F_{n+1}
        for s, c in coeffs.items():
            if s == 0:
                c0 += c
            else:
                c0 += c * fib(s - 1)
                c1 += c * fib(s)
        return (c0, c1)
    return to_basis(coeffs_lhs) == to_basis(coeffs_rhs)


def fib_fast_doubling(n: int) -> int:
    """Compute F_n in O(log n) multiplications via the doubling formulas
    F_{2k} = F_k (2 F_{k+1} - F_k) and F_{2k+1} = F_k^2 + F_{k+1}^2."""
    def pair(m: int) -> Tuple[int, int]:
        if m == 0:
            return (0, 1)
        a, b = pair(m >> 1)
        c = a * (2 * b - a)
        d = a * a + b * b
        return (d, c + d) if (m & 1) else (c, d)
    return pair(n)[0]
