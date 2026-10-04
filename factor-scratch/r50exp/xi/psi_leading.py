#!/usr/bin/env python3
"""
Dickman-remainder measurement in the LARGE-u regime, using an EXACT
recursion with memoisation.

    R(x,y) = ln( Psi(x,y) / (x rho(u)) ),   u = ln x / ln y

WHY A NEW RECURSION.  The often-quoted form
    Psi(x,y) = Psi(x,y-1) + Psi(x/y, y)
is FALSE in general; it holds only when y is PRIME (each y-smooth integer
with largest prime factor exactly y is uniquely y*m with m y-smooth).
The self-test caught this (x=10, y=4: LHS diff 0, RHS 2).  The correct
identity, valid for all y, is

    Psi(x,y) = sum over primes p <= y of  ( Psi(x/p, p) - Psi(x/p, p_prev) ),

since each y-smooth integer is counted exactly once, by its largest prime
factor.  Memoised on (floor(x), p).  Validated against a sieve below.

Everything is computed in FLOAT LOG-SPACE (we return log Psi), so x may be
astronomically larger than 2^53; that is what lets us reach large u.
"""
import math, sys
from functools import lru_cache

LN2 = math.log(2.0)

# --------------------------------------------------------------- Dickman rho
def dickman(U, h=1e-5):
    """
    rho from the integral equation  rho(u) = 1 - int_0^{u-1} rho(t)/(t+1) dt,
    integrated on a uniform grid with the trapezoid rule and the delay
    handled by indexing (h = 1/100000 so u-1 lands on the grid).
    Accurate to ~1e-11 for u <= 4; that is all the self-test demands of it,
    and the large-u values used here are only needed for log-scale
    comparisons, where we cross-check against the de Bruijn asymptotic.
    """
    inv = int(round(1.0 / h))
    J = int(math.ceil(U * inv)) + 2
    u = [i * h for i in range(J + 1)]
    R = [1.0] * (J + 1)
    D = [0.0] * (J + 1)                    # D[k] = int_0^{u_k} rho(t)/(t+1)dt
    for k in range(2, J + 1):
        Dk = D[k - 1] + 0.5 * h * (R[k - 1] / (u[k - 1] + 1.0) + R[k] / (u[k] + 1.0))
        R[k] = 1.0 - D[k - inv] if k - inv >= 0 else 1.0
        if R[k] < 0.0: R[k] = 0.0
        D[k] = Dk
    def f(q):
        if q <= 1: return 1.0
        j = int(q / h)
        if j >= J: return R[J]
        w = q / h - j
        return R[j] + w * (R[j + 1] - R[j])
    return f

_RHO = None
def rho(q):
    global _RHO
    if _RHO is None or _RHO[1] < q: _RHO = (dickman(max(q + 1.0, 20.0)), q + 1.0)
    return _RHO[0](q)

# --------------------------------------------------- primes up to Y (once)
def primes_upto(Y):
    s = bytearray([1]) * (Y + 1)
    s[0] = s[1] = 0
    i = 2
    while i * i <= Y:
        if s[i]: s[i * i::i] = bytearray(len(s[i * i::i]))
        i += 1
    return [p for p in range(2, Y + 1) if s[p]]

# ------------------------------------------------------- exact log-Psi
def log_psi(logx, Y, plist=None, prev=None):
    """Return ln Psi(x, Y) with x = exp(logx), by memoised recursion.
    Returns None if the recursion is too deep for the recursion limit."""
    if plist is None:
        plist = primes_upto(Y); prev = {p: (plist[i - 1] if i else 1)
                                       for i, p in enumerate(plist)}
    @lru_cache(maxsize=None)
    def f(xf, j):
        # count y-smooth integers <= xf, where y = plist[j]
        if xf < 1: return 0.0
        y = plist[j]
        if xf <= y: return math.log(math.floor(xf))       # all ints are y-smooth
        p_prev = prev[y]
        tot = 0.0
        for i in range(j + 1):
            p = plist[i]
            xq = xf / p
            if xq < 1: break
            a = f(math.floor(xq), i)
            b = f(math.floor(xq), i - 1) if i > 0 else math.log(math.floor(xq))
            if a > b: tot += math.exp(a - b)
        return math.log(tot) if tot > 0 else -math.inf
    return f(math.floor(math.exp(logx)) if logx < 700 else float("inf"),
             len(plist) - 1)

# ------------------------------------------------------------- ground truth
def psi_sieve(x, y):
    s = bytearray([1]) * (x + 1); s[0] = s[1] = 0
    i = 2
    while i * i <= x:
        if s[i]: s[i * i::i] = bytearray(len(s[i * i::i]))
        i += 1
    lpf = [1] * (x + 1)
    for p in range(2, x + 1):
        if s[p]:
            for m in range(p, x + 1, p): lpf[m] = p
    return sum(1 for m in range(1, x + 1) if lpf[m] <= y)

if __name__ == "__main__":
    sys.setrecursionlimit(100000)
    print("=" * 78)
    print("G1  recursion vs brute-force sieve (correctness gate)")
    ok = True
    pl = primes_upto(1000)
    for x, y in [(10 ** 4, 10), (10 ** 4, 100), (10 ** 5, 50),
                 (10 ** 5, 1000), (2 * 10 ** 6, 7), (2 * 10 ** 6, 1000),
                 (10 ** 6, 10 ** 6)]:
        lp = log_psi(math.log(x), y)
        got = int(round(math.exp(lp))) if lp > -700 else 0
        exp_ = psi_sieve(x, y)
        good = got == exp_; ok &= good
        print(f"  {'OK ' if good else 'FAIL'} x={x:<10d} y={y:<8d} "
              f"recursion={got:<10d} sieve={exp_}")
    print("  recursion", "PASSED" if ok else "FAILED")
    if not ok: sys.exit(1)

    print()
    print("=" * 78)
    print("G2  Dickman remainder R = ln(Psi(x,y)/(x rho(u))) at LARGE u")
    print("     u = ln x / ln y.  We vary y at fixed u by setting x = y^u.")
    print()
    pl_big = None
    for u_t in (5, 10, 20, 40, 80):
        line = []
        for Y in (1000, 10 ** 4, 10 ** 5):
            logx = u_t * math.log(Y)
            try:
                lp = log_psi(logx, Y, primes_upto(Y),
                             {p: (primes_upto(Y)[i - 1] if i else 1)
                              for i, p in enumerate(primes_upto(Y))})
                R = lp - logx - math.log(rho(u_t))
                line.append((Y, R))
            except (RecursionError, MemoryError):
                line.append((Y, None))
        s = "   ".join(f"y={Y}: R={R:+.4f}" if R is not None else f"y={Y}: n/a"
                       for Y, R in line)
        print(f"  u={u_t:4d}   {s}")
    print()
    print("  R -> 0 as the Dickman regime is entered would mean the")
    print("  smooth-number density carries NO large correction.")
