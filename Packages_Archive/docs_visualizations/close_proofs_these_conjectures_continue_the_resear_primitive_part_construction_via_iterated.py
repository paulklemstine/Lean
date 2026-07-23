from math import gcd
from typing import List

def strip_all_aux(r: int, m: int, fuel: int) -> int:
    """Divide r by gcd(r, m) repeatedly until coprime (mirrors stripAllAux)."""
    while fuel > 0:
        fuel -= 1
        if m <= 1:
            return r
        g = gcd(r, m)
        if g <= 1:
            return r
        r //= g
    return r

def prop_divs(n: int) -> List[int]:
    return [d for d in range(1, n) if n % d == 0]

def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

def prim_part(n: int) -> int:
    """Primitive part of F(n) (mirrors primPart): strip from F(n) all primes
    shared with F(d) for each proper divisor d of n."""
    r = fib(n)
    for d in prop_divs(n):
        r = strip_all_aux(r, fib(d), r)
    return r
