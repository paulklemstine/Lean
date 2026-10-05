#!/usr/bin/env python3
"""
Exact rational LLL (Gram-Schmidt, Fraction arithmetic), matching Sage's
dense_matrix().LLL() over QQ. This is ESSENTIAL: the GIFP recovery reads p2 from
the DENOMINATOR of a reduced polynomial coefficient, and denominators only
appear when LLL is performed over QQ (as the authors' Sage code does). An
integer LLL destroys them.

Small dimensions (the GIFP lattice is ~15x25), so exact Fraction LLL is fast.
"""
from fractions import Fraction as F

def gram_schmidt(B):
    n = len(B)
    Bstar = [[F(b) for b in row] for row in B]
    mu = [[F(0)]*n for _ in range(n)]
    norm = [F(0)]*n
    for i in range(n):
        for j in range(i):
            num = sum(Bstar[i][k]*Bstar[j][k] for k in range(len(B[i])))
            den = norm[j]
            mu[i][j] = num/den if den != 0 else F(0)
        v = list(Bstar[i])
        for j in range(i):
            mj = mu[i][j]
            if mj != 0:
                for k in range(len(B[i])):
                    v[k] -= mj*Bstar[j][k]
        Bstar[i] = v
        norm[i] = sum(x*x for x in Bstar[i])
    return Bstar, mu, norm

def lll_reduce(B, delta=F(3,4)):
    """LLL-reduce rows of B (list of int lists) over QQ. Returns reduced rows (QQ)."""
    B = [list(map(F, row)) for row in B]
    n = len(B); mcols = len(B[0])
    k = 1
    def gs():
        return gram_schmidt(B)
    while k < n:
        Bstar, mu, norm = gs()
        for j in range(k-1, -1, -1):
            q = round_f(mu[k][j])
            if q != 0:
                for c in range(mcols):
                    B[k][c] -= q*B[j][c]
                Bstar, mu, norm = gs()
        # Lovasz
        if norm[k] < (delta - mu[k][k-1]**2)*norm[k-1]:
            B[k], B[k-1] = B[k-1], B[k]
            k = max(k-1, 1)
        else:
            for j in range(k+1, n):
                q = round_f(mu[j][k])
                if q != 0:
                    for c in range(mcols):
                        B[j][c] -= q*B[k][c]
            k += 1
    return B

def round_f(fr):
    # nearest integer
    n = fr.numerator; d = fr.denominator
    if d == 0: return F(0)
    q, r = divmod(n, d)
    if 2*r >= d: q += 1
    return F(q)
