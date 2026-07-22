from __future__ import annotations

from math import gcd


def squarefree_part(n: int) -> int:
    n = abs(n)
    if n in (0, 1):
        return n
    result, d, m, seen = 1, 2, n, set()
    while d * d <= m:
        while m % d == 0:
            if d not in seen:
                result *= d
                seen.add(d)
            m //= d
        d += 1
    if m > 1 and m not in seen:
        result *= m
    return result


def fixpoint_meet(a: int, b: int) -> int:
    """Inherited meet in the fixed-point lattice (Lemma closed_sInf): gcd."""
    return gcd(a, b)


def fixpoint_join(a: int, b: int) -> int:
    """Re-closed join in the fixed-point lattice (Proposition coe_sSup):
    take the ambient join (ideal sum (a)+(b)=(gcd(a,b)) in a PID), then apply
    the closure (radical).  Complexity dominated by one factorization."""
    ambient = gcd(a, b)
    return squarefree_part(ambient)
