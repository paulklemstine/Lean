from fractions import Fraction
from typing import List, Sequence

def fixed_space_is_trivial(sigma: List[List[Fraction]]) -> bool:
    """Decide ker(sigma - I) = {0} by exact Gaussian elimination over Q.
    Returns True iff sigma fixes only the origin."""
    d = len(sigma)
    rows = [[sigma[i][j] - (Fraction(1) if i == j else Fraction(0))
             for j in range(d)] for i in range(d)]
    rank, r, col = 0, 0, 0
    while r < d and col < d:
        piv = next((k for k in range(r, d) if rows[k][col] != 0), None)
        if piv is None:
            col += 1
            continue
        rows[r], rows[piv] = rows[piv], rows[r]
        inv = rows[r][col]
        rows[r] = [v / inv for v in rows[r]]
        for k in range(d):
            if k != r and rows[k][col] != 0:
                f = rows[k][col]
                rows[k] = [a - f * b for a, b in zip(rows[k], rows[r])]
        rank += 1; r += 1; col += 1
    return rank == d

def certified_by_symmetry(points, weights,
                          sigma: List[List[Fraction]],
                          perm: Sequence[int]) -> bool:
    """Matsushima-type certificate: if (sigma, perm) is a symmetry of the datum
    (weights preserved, sigma(p_i) = p_{perm(i)}) and sigma fixes only the
    origin, then the moment vector is forced to be zero, so a Kahler-Einstein
    metric exists -- WITHOUT computing the moment vector."""
    def apply(s, x):
        return tuple(sum(s[i][j] * x[j] for j in range(len(x)))
                     for i in range(len(s)))
    is_sym = all(weights[perm[i]] == weights[i]
                 and apply(sigma, points[i]) == points[perm[i]]
                 for i in range(len(points)))
    return is_sym and fixed_space_is_trivial(sigma)
