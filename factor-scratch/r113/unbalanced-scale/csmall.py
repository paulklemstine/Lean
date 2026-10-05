#!/usr/bin/env python3
"""Small-root recovery for f(x) = x + a (linear, monic) mod a factor of N.

Written from the primary construction (Howgrave-Graham 1997; the lattice Sage
documents as May's PhD-thesis algorithm).  NOT reused from r110-r112.

SET-UP.  N = p*q, p has pb bits.  Attacker knows the top (pb - unk) bits of p:
p = a + x0 with a = (p >> unk) << unk and 0 <= x0 < X = 2^unk.  So x0 is an
integer root of f(x) = x + a modulo p (hence modulo N), with |x0| < X.

LATTICE.  dim = m + t.  For k = 0..m-1 take the shifts
      x^i * f(x)^k * N^(m-k)      i = 0..dim-1-k
and the top shifts
      x^i * f(x)^m                 i = 0..t-1.
Every shift vanishes mod N^m at x0 (since f(x0) = 0 mod N, each x^i f^k N^{m-k}
is divisible by N^{m-k} * N^k = N^m).  Column i is scaled by X^i so the norm
measures |h(x0/X)|.  A reduced vector short enough that |h(x0)| < N^m is
exactly zero over Z, so x0 is an integer root of it.

VERIFICATION.  Every candidate factor is checked by cand * (N // cand) == N and
cand > 1.  Arithmetic ground truth only -- it never certifies the attack did
the work (see the trivial-baseline discipline in the brief).
"""
import time
from fpylll import IntegerMatrix, LLL


def polymul(a, b):
    out = [0] * (len(a) + len(b) - 1)
    for i, x in enumerate(a):
        if x:
            for j, y in enumerate(b):
                if y:
                    out[i + j] += x * y
    return out


def polypow(f, k):
    r = [1]
    for _ in range(k):
        r = polymul(r, f)
    return r


def trim(p):
    p = list(p)
    while len(p) > 1 and p[-1] == 0:
        p.pop()
    return p or [0]


def peval(p, x):
    r = 0
    for c in reversed(p):
        r = r * x + c
    return r


def integer_roots(p, lo, hi):
    """All integer roots of p in [lo, hi], exact (sympy ground_roots)."""
    from sympy import Poly, Symbol, ZZ
    p = trim(p)
    if len(p) <= 1:
        return []
    v = Symbol("_v_")
    P = Poly([int(c) for c in reversed(p)], v, domain=ZZ)
    if P.degree() < 1:
        return []
    try:
        gr = P.ground_roots()
    except Exception:
        return []
    out = []
    try:
        items = list(gr.items())          # {root: multiplicity}
    except AttributeError:
        items = []
    for item in items:
        r = item[0] if isinstance(item, tuple) else item
        try:
            rr = int(r)
        except Exception:
            continue
        if lo <= rr <= hi and peval(p, rr) == 0:
            out.append(rr)
    return out


def build_lattice(f, N, X, m, t):
    """Return (rows, scale): dim x dim rows, column i pre-multiplied by X^i.

    dim = m + t.  We take the standard Howgrave-Graham shift family

        g_{k,i}(x) = x^i * f(x)^k * N^(m-k)     k = 0..m-1, 0 <= i < dim-k
        h_i(x)     = x^i * f(x)^m               i = 0..t-1

    Each vanishes mod N^m at the root x0 (f(x0) = 0 mod N and N^(m-k)*N^k).
    We keep ONE shift per degree 0..dim-1, preferring the one carrying the
    largest power of N (k smallest); one vector per distinct degree is
    automatically linearly independent, which keeps the lattice full rank.
    Column i is scaled by X^i so the norm measures |h(x0/X)|.
    """
    dim = m + t
    scale = [1] * dim
    for i in range(1, dim):
        scale[i] = scale[i - 1] * X
    fpow = [polypow(f, k) for k in range(m + 1)]

    bydeg = {}
    # Iterate k from HIGH to LOW and do NOT overwrite an already-filled degree.
    # Preferred row for degree d carries the SMALLEST N power N^(m-k), i.e. the
    # largest k with d-k >= 0.  (Preferring small k would make every row a
    # multiple of N^m, leaving a huge common factor and a no-op LLL.)
    for k in range(m - 1, -1, -1):
        for i in range(0, dim - k):
            g = polymul([0] * i + [1], fpow[k])
            d = len(g) - 1
            if d >= dim or d in bydeg:
                continue
            bydeg[d] = [c * (N ** (m - k)) for c in g]
    for i in range(t):                       # top shifts x^i f^m
        g = [0] * i + fpow[m]
        d = len(g) - 1
        if d < dim and d not in bydeg:
            bydeg[d] = list(g)
    # fill any missing degree with the pure monomial x^d * N^m
    for d in range(dim):
        if d not in bydeg:
            bydeg[d] = [0] * d + [N ** m]

    rows = []
    for d in range(dim):
        g = bydeg[d]                        # g has length d+1, coefficients low->high
        v = g + [0] * (dim - 1 - d)        # degree d occupies columns 0..d
        rows.append([v[j] * scale[j] for j in range(dim)])
    return rows, scale


def reduce_rows(rows, delta=0.99):
    B = IntegerMatrix(len(rows), len(rows[0]))
    for i, r in enumerate(rows):
        for j, v in enumerate(r):
            B[i, j] = v
    LLL.reduction(B, delta=delta)
    return [[int(B[i, j]) for j in range(B.ncols)] for i in range(B.nrows)]


def recover(N, p, unk, grid, maxvec=4, budget_s=None, delta=0.99):
    if unk <= 0 or unk >= p.bit_length():
        return dict(unk=unk, found=False, err="range")
    a = (p >> unk) << unk
    x0 = p - a
    assert 0 <= x0 < (1 << unk), "alignment defect"
    f = trim([a, 1])
    X = 1 << unk
    t0 = time.time()
    tried = []
    for (m, t) in grid:
        if budget_s and time.time() - t0 > budget_s:
            return dict(unk=unk, found=False, budget_out=True, tried=tried,
                        seconds=round(time.time() - t0, 1))
        dim = m + t
        rows, scale = build_lattice(f, N, X, m, t)
        assert len(rows) == dim, (len(rows), dim)
        R = reduce_rows(rows, delta=delta)
        tried.append((m, t))
        for row in R[:maxvec]:
            if budget_s and time.time() - t0 > budget_s:
                return dict(unk=unk, found=False, budget_out=True, tried=tried,
                            seconds=round(time.time() - t0, 1))
            pv = [row[c] // scale[c] for c in range(dim)]
            for r in integer_roots(pv, -X, X):
                cand = a + r
                if cand > 1 and N % cand == 0 and cand * (N // cand) == N:
                    return dict(unk=unk, found=True, factor=cand, x0=r, dim=dim,
                                mm=(m, t), seconds=round(time.time() - t0, 1))
    return dict(unk=unk, found=False, seconds=round(time.time() - t0, 1), tried=tried)
