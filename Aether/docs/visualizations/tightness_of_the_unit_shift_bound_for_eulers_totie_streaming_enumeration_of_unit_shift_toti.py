from typing import List
from math import gcd

def totient(n: int) -> int:
    if n == 1:
        return 1
    r, m, p = n, n, 2
    while p * p <= m:
        if m % p == 0:
            while m % p == 0:
                m //= p
            r -= r // p
        p += 1
    if m > 1:
        r -= r // m
    return r

def enumerate_collisions(x: int) -> List[int]:
    """
    All unit-shift collisions n <= x: phi(n) = phi(n+1).
    Streaming single-pass evaluation, O(x sqrt(x)) total.
    Returns the witness list whose length is S1phi(x).
    """
    out: List[int] = []
    prev = totient(1)
    for n in range(1, x + 1):
        cur = totient(n + 1)
        if prev == cur:
            out.append(n)
        prev = cur
    return out
