from math import gcd
from typing import List

def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

def proper_divisors(n: int) -> List[int]:
    return [d for d in range(1, n) if n % d == 0]

def primitive_part_certificate(n: int) -> int:
    """
    GCD 'strip the imprimitive part' certificate.
    Returns Pi_n = F_n / gcd(F_n, prod over proper divisors d of F_d-content),
    computed by repeatedly dividing out gcd contributions of F_d for d | n, d < n.
    Pi_n > 1 certifies that F_n has a primitive prime divisor.
    Complexity: O(d(n)) gcds on integers of size O(n) bits.
    """
    Fn = fib(n)
    if Fn <= 1:
        return Fn
    pi = Fn
    for d in proper_divisors(n):
        g = gcd(pi, fib(d))
        while g > 1:
            pi //= g
            g = gcd(pi, fib(d))
    return pi
