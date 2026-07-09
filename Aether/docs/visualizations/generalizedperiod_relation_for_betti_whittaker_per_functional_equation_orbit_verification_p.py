from typing import List, Iterable

def period_exp(lam: List[int]) -> int:
    n = len(lam)
    return sum((2 * i + 1 - n) * lam[i] for i in range(n))

def dual(lam: List[int]) -> List[int]:
    n = len(lam)
    return [-lam[n - 1 - i] for i in range(n)]

def twist(k: int, lam: List[int]) -> List[int]:
    return [x + k for x in lam]

def verify_fe(lam: List[int], ks: Iterable[int]) -> bool:
    """Certify e(dual(twist k L)) = e(L) for all k in ks."""
    base = period_exp(lam)
    return all(period_exp(dual(twist(k, lam))) == base for k in ks)
