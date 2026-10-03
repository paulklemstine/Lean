"""Fast exact SVP/Minkowski reference, vectorized.  Written to replace the
pure-python enumeration in lll_self_test.py after it proved too slow."""
import itertools
import numpy as np


def svp_box_radius(B):
    """Sound certified box radius for the coefficient of a shortest vector.

    B is a (r, n) matrix of r row-generators of an r-dimensional lattice in R^n
    (square r = n is the usual case).  Any lattice vector is v = c B with
    c in Z^r; for full row rank c = v B^+ = v (B^T B)^{-1} B^T, so
        |c_i| = |<v, row_i(B^+)>| <= ||v|| * ||row_i(B^+)||.
    Every shortest vector has ||v|| <= m := min_j ||b_j||, hence
        R = ceil(m * max_i ||row_i(B^+)||)
    is guaranteed to contain the coefficient vector of every shortest vector.
    """
    B = B.astype(float)
    Binv = np.linalg.pinv(B)          # (n, r); row_i(B^+) is Binv[i, :]
    row = np.linalg.norm(Binv, axis=1)
    m = min(np.linalg.norm(B, axis=1))
    return int(np.ceil(m * row.max())) + 1


def enumerate_svp(B, R=None, cap=4_000_000):
    """Exact squared length of the shortest vector and a witness vector.

    B is (r, n): r row-generators, so the coefficient vector c is in Z^r.
    Enumerates all c in [-R,R]^r \\ {0}.  Returns None if the box exceeds
    `cap` points, so the caller can never silently get a wrong answer from a
    truncated search.
    """
    B = B.astype(float)
    r = B.shape[0]
    if R is None:
        R = svp_box_radius(B)
        if (2 * R + 1) ** r > cap:
            return None
    npts = (2 * R + 1) ** r
    if npts > cap:
        return None
    grid = np.array(list(itertools.product(range(-R, R + 1), repeat=r)), float)
    keep = np.any(grid != 0.0, axis=1)
    grid = grid[keep]
    V = grid @ B
    s = np.einsum('ij,ij->i', V, V)
    i = int(np.argmin(s))
    # return the EXACT integer coefficient vector too, so callers never have to
    # re-derive it in floating point (which would silently perturb the lattice)
    return float(s[i]), V[i], grid[i].astype(int)


def enumerate_bkz_tour(S, cap=2_000_000):
    """Exact shortest vector in the span of S (a square basis block)."""
    return enumerate_svp(S, cap=cap)
