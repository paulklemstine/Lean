from math import gcd
from typing import List

def euler_totient(n: int) -> int:
    """phi(n) = #(Z/nZ)^x = [Q(zeta_n):Q], via the prime-factorization formula."""
    result, m, p = n, n, 2
    while p * p <= m:
        if m % p == 0:
            while m % p == 0:
                m //= p
            result -= result // p
        p += 1
    if m > 1:
        result -= result // m
    return result

def cyclotomic_degree(n: int) -> int:
    """Degree of the n-th cyclotomic field over the rationals."""
    return euler_totient(n)
