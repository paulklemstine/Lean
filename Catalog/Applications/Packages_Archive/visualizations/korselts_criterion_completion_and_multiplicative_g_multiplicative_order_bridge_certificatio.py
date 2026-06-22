from math import gcd
from typing import Dict, List, Tuple

def factorize(n: int) -> Dict[int, int]:
    factors: Dict[int, int] = {}
    d, m = 2, n
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors

def units_mod(n: int) -> List[int]:
    return [a for a in range(1, n) if gcd(a, n) == 1]

def all_units_killed_by(n: int, e: int) -> bool:
    """The bridge hypothesis: u^e = 1 (mod n) for every unit u."""
    return all(pow(u, e, n) == 1 for u in units_mod(n))

def verify_bridge(n: int) -> List[Tuple[int, bool]]:
    """Given squarefree n with the killing hypothesis u^(n-1)=1, certify the
    bridge conclusion (p-1) | (n-1) for each prime factor p.
    Returns a list of (p, holds) pairs."""
    assert all(e == 1 for e in factorize(n).values()), "n must be squarefree"
    assert all_units_killed_by(n, n - 1), "bridge hypothesis must hold"
    return [(p, (n - 1) % (p - 1) == 0) for p in factorize(n)]
