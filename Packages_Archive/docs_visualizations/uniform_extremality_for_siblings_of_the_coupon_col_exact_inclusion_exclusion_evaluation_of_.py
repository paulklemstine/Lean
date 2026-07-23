from fractions import Fraction
from itertools import combinations
from typing import Sequence


def expected_empty_exact(p: Sequence[Fraction], j: int) -> Fraction:
    """Exact E_p[U_j^N] via inclusion-exclusion.

    E_p[U_j^N] = sum_i sum_{S subseteq [N]\\{i}} (-1)^|S|
                   (p_i / (p_i + sum_{s in S} p_s))^j

    Returns an exact rational (no sampling error).
    """
    n: int = len(p)
    total: Fraction = Fraction(0)
    for i in range(n):
        competitors = [k for k in range(n) if k != i]
        for r in range(len(competitors) + 1):
            for subset in combinations(competitors, r):
                q_s = sum((p[s] for s in subset), Fraction(0))
                ratio = p[i] / (p[i] + q_s)
                total += Fraction((-1) ** r) * ratio ** j
    return total
