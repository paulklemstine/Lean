from typing import Tuple, List

def fib_pair_mod(k: int, m: int) -> Tuple[int, int]:
    def fd(n: int) -> Tuple[int, int]:
        if n == 0:
            return (0 % m, 1 % m)
        a, b = fd(n >> 1)
        c = (a * ((2 * b - a) % m)) % m
        d = (a * a + b * b) % m
        return (d, (c + d) % m) if (n & 1) else (c, d)
    return fd(k)

def prime_factors(n: int) -> List[int]:
    ps, d = [], 2
    while d * d <= n:
        if n % d == 0:
            ps.append(d)
            while n % d == 0:
                n //= d
        d += 1
    if n > 1:
        ps.append(n)
    return ps

def verify_pisano_period(m: int, P: int) -> bool:
    """Certify that P == pi(m) using the period-return duality (Thm 3.3):
    (i) P is an apparition-return: F_P = 0 and F_{P+1} = 1 (mod m);
    (ii) minimality: for every prime q | P, P/q fails the same test.
    O(omega(P) * log P) ring operations via fast doubling."""
    fk, fk1 = fib_pair_mod(P, m)
    if not (fk == 0 % m and fk1 == 1 % m):
        return False                       # P is not even a multiple of pi(m)
    for q in prime_factors(P):
        gk, gk1 = fib_pair_mod(P // q, m)
        if gk == 0 % m and gk1 == 1 % m:
            return False                   # P/q already works -> P not minimal
    return True
