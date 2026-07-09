from fractions import Fraction
from typing import List

def rowsum_via_differences(n: int, s: Fraction) -> Fraction:
    """Row sum computed as (Delta^{n+1} Q)(0); provably equals n!."""
    Q: List[Fraction] = [Fraction(0)] * (n + 2)
    for t in range(1, n + 2):
        Q[t] = Q[t - 1] + (Fraction(t) - s) ** n  # (t-s)^n = ((t-1)+1-s)^n
    D = list(Q)
    for _ in range(n + 1):
        D = [D[j + 1] - D[j] for j in range(len(D) - 1)]
    return D[0]
