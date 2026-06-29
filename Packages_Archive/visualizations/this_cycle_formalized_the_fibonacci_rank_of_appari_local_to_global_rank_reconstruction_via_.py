from math import gcd
from functools import reduce
from typing import Dict, List

def _lcm(a: int, b: int) -> int:
    return 0 if a == 0 or b == 0 else a // gcd(a, b) * b

def factorize(n: int) -> Dict[int, int]:
    f: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            f[d] = f.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        f[n] = f.get(n, 0) + 1
    return f

def fib_rank_factored(n: int) -> int:
    if n == 1:
        return 1
    ranks: List[int] = [fib_rank_direct(p ** e)
                        for p, e in factorize(n).items()]
    return reduce(_lcm, ranks, 1)
