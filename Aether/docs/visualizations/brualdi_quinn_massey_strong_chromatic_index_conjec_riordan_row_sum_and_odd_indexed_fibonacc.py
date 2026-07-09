from math import comb


def riordan_A(n: int) -> int:
    """Steep-diagonal row sum A(n) = sum_{k=0}^{n} C(n+k, 2k)."""
    return sum(comb(n + k, 2 * k) for k in range(n + 1))


def fib(n: int) -> int:
    """n-th Fibonacci number, F_0 = 0, F_1 = 1."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def verify_row_sum_identity(n_max: int) -> bool:
    """Certify A(n) = F_{2n+1} for 0 <= n <= n_max (Theorem pascalRiordanA_eq_fib)."""
    return all(riordan_A(n) == fib(2 * n + 1) for n in range(n_max + 1))
