from math import gcd
from typing import Tuple

def fib_rank(m: int) -> int:
    """Rank of apparition: least k>0 with m | F(k); O(pisano period) <= O(m)."""
    if m == 0:
        return 0
    a, b = 0 % m, 1 % m            # (F(0), F(1)) mod m
    k = 0
    while True:
        k += 1
        a, b = b, (a + b) % m      # shift T(a,b) = (b, a+b)
        if a == 0:                 # a == F(k) mod m
            return k

def divides_fib(m: int, n: int) -> bool:
    """Decide m | F(n) WITHOUT computing F(n), via the Law of Apparition."""
    if m == 0:
        return n == 0
    r = fib_rank(m)
    return n % r == 0

def adjunction_meet_join(a: int, b: int) -> Tuple[bool, bool]:
    """Verify the two capstones for indices/moduli a, b (a,b > 0)."""
    def fib(n: int) -> int:
        x, y = 0, 1
        for _ in range(n):
            x, y = y, x + y
        return x
    def lcm(p: int, q: int) -> int:
        return 0 if p == 0 or q == 0 else p // gcd(p, q) * q
    meet_ok = fib(gcd(a, b)) == gcd(fib(a), fib(b))
    join_ok = fib_rank(lcm(a, b)) == lcm(fib_rank(a), fib_rank(b))
    return meet_ok, join_ok
