"""
r113 / recombination-depth  --  recombination core with the CORRECT invariant.

THE INVARIANT (and why r112's was a pigeonhole)
----------------------------------------------
Relations (x_i, y_i) with x_i^2 == y_i (mod N), y_i B-smooth.
A subset S with all total exponents even gives y_S = prod y_i = z_S^2 EXACTLY
(integer square root), and x_S = prod x_i satisfies x_S^2 == z_S^2 (mod N).

The SPLIT TEST is on the VALUE, not on the exponent-parity pattern:

        g1 = gcd(x_S - z_S, N),   g2 = gcd(x_S + z_S, N)

A split is 1 < g < N for either.  r112 hashed the set of primes with ODD
total exponent; for a GF(2) nullspace vector that set is EMPTY BY
CONSTRUCTION, so its "collision rate" was identically 1 -- a pigeonhole, not
a measurement.  Here the hashed object is x_S - z_S mod N, which is not
forced to collide.

WHY THE BASE RATE IS ~1 (this kills the per-candidate framing up front).
x_S^2 == z_S^2 (mod N) forces x_S == +-z_S mod p and mod q INDEPENDENTLY.
Testing both gcds splits unless the two signs agree, so P(split) = 1 - 2/N.
The standard method therefore already succeeds on its FIRST nullspace vector;
there is no per-candidate success-rate headroom to exploit.  What IS left is
the COST of a candidate, which is |S| modular multiplications -- i.e. the
WEIGHT of the nullspace vector.  The experiment measures that, plus whether
any structural feature predicts the residual degenerate case.
"""
import math
from math import gcd, isqrt

def gf2_left_nullspace(rows, ncols):
    """Basis of {v in GF(2)^m : sum_{i: v_i=1} rows[i] == 0} -- the LEFT
    nullspace over RELATIONS, i.e. the subsets whose combined exponent vector
    is all-zero mod 2.  rows are integer bitmasks over ncols.
    Reduced to RREF while tracking the row operations on an m x m identity.
    """
    m = len(rows)
    A = [rows[i] | (1 << (ncols + i)) for i in range(m)]
    r = 0
    for c in range(ncols):
        pr = None
        for i in range(r, m):
            if (A[i] >> c) & 1:
                pr = i; break
        if pr is None: continue
        A[r], A[pr] = A[pr], A[r]
        top = A[r]
        for i in range(m):
            if i != r and ((A[i] >> c) & 1):
                A[i] ^= top
        r += 1
        if r == m: break
    basis = [A[i] >> ncols for i in range(r, m)]
    return [b for b in basis if b], r

def subset_from_mask(mask):
    out = []
    i = 0
    while mask:
        if mask & 1: out.append(i)
        mask >>= 1; i += 1
    return out

def combine(rels, idx, N, primes):
    """Exact integer combination.  Returns (x_S mod N, z_S, expsum) or None if
    the total exponent vector is not all-even."""
    x = 1
    tot = {}
    for i in idx:
        xi, yi, ei = rels[i]
        x = (x * xi) % N
        for pi, e in ei:
            tot[pi] = tot.get(pi, 0) + e
    for v in tot.values():
        if v & 1:
            return None
    z = 1
    for pi, v in tot.items():
        z *= pow(int(primes[pi]), v // 2)
    return x, z, tot

def split_test(x, z, N):
    """Return (split?, g, kind).  Tests BOTH gcds."""
    g1 = gcd(x - z, N)
    if 1 < g1 < N:
        return True, g1, 'minus'
    g2 = gcd(x + z, N)
    if 1 < g2 < N:
        return True, g2, 'plus'
    return False, (g1 if g1 != N else g2), ('degN' if g1 == N else ('deg1' if g2 == N else 'deg1'))
