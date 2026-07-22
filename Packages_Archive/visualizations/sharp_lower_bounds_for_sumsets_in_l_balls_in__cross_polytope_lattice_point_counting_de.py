from __future__ import annotations
import math

def l1_ball_cardinality(d: int, m: int) -> int:
    """|B_d(m)| = sum_k 2^k C(d,k) C(m,k), the lattice cross-polytope count.

    Choose k nonzero coordinates (C(d,k)), assign each a sign (2^k), and
    distribute a positive budget among them (C(m,k)).
    Complexity: O(min(d,m)) binomial evaluations.
    """
    return sum((2 ** k) * math.comb(d, k) * math.comb(m, k)
               for k in range(min(d, m) + 1))

def dilated_ratio_exponent(d: int, n: int, m: int) -> float:
    """Candidate d-dependent exponent p_d = n log|B_d(m)| / log|B_d(nm)|."""
    return n * math.log(l1_ball_cardinality(d, m)) / \
        math.log(l1_ball_cardinality(d, n * m))
