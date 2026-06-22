from typing import Callable, List

def prime_factors(v: int) -> List[int]:
    out: List[int] = []
    d = 2
    while d * d <= v:
        if v % d == 0:
            out.append(d)
            while v % d == 0:
                v //= d
        d += 1
    if v > 1:
        out.append(v)
    return out

def seq_rank(u: Callable[[int], int], m: int, bound: int = 5000):
    for k in range(1, bound + 1):
        if u(k) % m == 0:
            return k
    return None

def primitive_divisors(u: Callable[[int], int], n: int, bound: int = 5000) -> List[int]:
    return [p for p in prime_factors(u(n)) if seq_rank(u, p, bound) == n]
