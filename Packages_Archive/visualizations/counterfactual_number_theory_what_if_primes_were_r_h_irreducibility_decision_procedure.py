from __future__ import annotations


def in_H(n: int) -> bool:
    """Membership in the Hilbert monoid H = {n : n = 1 (mod 4)}."""
    return n % 4 == 1


def is_H_irreducible(n: int) -> bool:
    """Decide whether n is an H-irreducible (counterfactual prime).

    n must be >= 2, lie in H, and admit no factorization a*b = n with
    a, b > 1 both in H. Runs in O(sqrt(n)) via a divisor scan.
    """
    if n < 2 or not in_H(n):
        return False
    a = 1
    while a * a <= n:
        if n % a == 0:
            b = n // a
            if a > 1 and b > 1 and in_H(a) and in_H(b):
                return False
        a += 1
    return True
