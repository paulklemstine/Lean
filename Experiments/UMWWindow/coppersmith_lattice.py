#!/usr/bin/env python3
"""
Coppersmith small-root lattice — IMPLEMENTATION STATUS: NOT YET VALIDATED.

This file is a WORKING SCAFFOLD and an HONEST NEGATIVE RESULT, not a validated
tool. Round 97c flagged a validated univariate Coppersmith lattice as the
prerequisite for any quantitative claim about the multivariate sub-N^(1/4) gap.
I attempted to build it here and could NOT get it to pass its own known-root
validation. Per the record's rule (5) ("never trust a test that has never
failed"), NO claim is made and this lattice is NOT used downstream.

WHAT WORKS: the shift-polynomial + LLL skeleton runs fast (fpylll). The
"hangs" encountered while building this were a slow trial-division is_prime(),
not the lattice; with Miller-Rabin primality it is instant.

WHAT FAILS: for f(x) = x - x0 (linear) or f(x) = (x-x0)(x-x1) (quadratic) with
KNOWN small roots x0, and X well inside the Coppersmith bound X < N^{beta^2/d},
the reduced basis contains NO row with h(x0) = 0, across a sweep of (m, t) and
scales. That should NOT happen for a correct Howgrave-Graham construction, so
there is an unresolved bug in the scaling (candidates: the X^{D-k} row weighting,
the N^{m-i} placement, the monic reduction, or the required m,t ~ N^{beta/d}
scaling) that I did not isolate.

The lattice SHOULD produce a short vector whose evaluation is divisible by N^m;
the fact that it does not recover the known root is the signal that the
construction is mis-scaled here.

CONCLUSION. The multivariate sub-N^(1/4) question (round 97c) remains open, its
"split the leak" family is already excluded (round 97b, verified), and the
quantitative lattice attack is BLOCKED on building a validated Coppersmith
implementation. This file documents the scaffold and the failure so the next
attempt starts from a known, diagnosed state rather than repeating the debugging.
"""

# ---- (kept for reference; NOT a validated solver) ----
import random, time
from fpylll import IntegerMatrix, LLL

def is_prime(n):
    if n < 2: return False
    for p in [2,3,5,7,11,13,17,19,23,29,31,37]:
        if n % p == 0: return n == p
    d = n - 1; r = 0
    while d % 2 == 0: d //= 2; r += 1
    for a in [2,3,5,7,11,13,17,19,23,29,31,37]:
        x = pow(a, d, n)
        if x in (1, n - 1): continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1: break
        else: return False
    return True

def gen_prime(bits):
    while True:
        p = random.getrandbits(bits) | (1 << (bits - 1)) | 1
        if is_prime(p): return p

def polymul(u, v, mod):
    r = [0] * (len(u) + len(v) - 1)
    for a, ua in enumerate(u):
        ua %= mod
        if ua == 0: continue
        for b, vb in enumerate(v): r[a + b] = (r[a + b] + ua * vb) % mod
    return r

def evalp(c, x):
    v = 0
    for a in reversed(c): v = v * x + a
    return v

def build_lattice(f, N, X, m, t):
    """Shift-polynomial rows, X^{D-k} weighted. SKELETON -- known buggy."""
    fpow = [[1]]
    for i in range(m + 1): fpow.append(polymul(fpow[-1], f, N))
    Npow = [1]
    for i in range(m + 1): Npow.append(Npow[-1] * N)
    rows = []
    for i in range(m + 1):
        base = fpow[i]; w = Npow[m - i] if i < m else 1
        for j in range(t):
            g = [0] * j + [(c * w) % N for c in base]
            while g and g[-1] == 0: g.pop()
            if not g: g = [0]
            D = len(g) - 1
            rows.append([(c % N) * pow(X, D - k, N) for k, c in enumerate(g)])
    return rows

def known_root_recovery(N, X, m, t, x0, degree=1):
    """Returns how many reduced rows vanish at the KNOWN root x0. A correct
    Howgrave-Graham lattice must return >0 for X inside the bound."""
    if degree == 1:
        f = [(-x0) % N, 1]
    else:
        f = [(x0 * (x0 + 1)) % N, (-(2 * x0 + 1)) % N, 1]
    rows = build_lattice(f, N, X, m, t)
    md = max(len(r) for r in rows); dim = len(rows)
    B = IntegerMatrix(dim, md)
    for r in range(dim):
        for c in range(md): B[r, c] = int(rows[r][c] if c < len(rows[r]) else 0)
    LLL.reduction(B)
    hits = 0
    for r in range(dim):
        coeff = [int(B[r, c]) for c in range(md)]
        while coeff and coeff[-1] == 0: coeff.pop()
        if len(coeff) > 1 and evalp(coeff, x0) == 0: hits += 1
    return hits

def main():
    random.seed(0)
    print("KNOWN-ROOT VALIDATION (a correct lattice must return >0):")
    print("linear f=x-x0:")
    for bits, X, mt in [(24, 64, [(1,3),(2,4),(3,6)]),
                        (32, 128, [(1,3),(2,4),(3,6),(4,8)])]:
        N = gen_prime(bits); x0 = random.randrange(1, 20)
        line = [f"m={m},t={t}:{known_root_recovery(N,X,m,t,x0,1)}" for m, t in mt]
        print(f"  N={bits}b X={X}: " + "  ".join(line))
    print("quadratic f=(x-x0)(x-x1):")
    for bits, X, mt in [(24, 64, [(1,4),(2,6),(3,8)]),
                        (32, 256, [(2,6),(3,8),(4,10)])]:
        N = gen_prime(bits); x0 = random.randrange(1, 20)
        line = [f"m={m},t={t}:{known_root_recovery(N,X,m,t,x0,2)}" for m, t in mt]
        print(f"  N={bits}b X={X}: " + "  ".join(line))
    print("\nRESULT: all zeros => construction NOT validated (see docstring).")
    print("No quantitative claim is made; the multivariate sub-N^(1/4) gap stays open.")

if __name__ == "__main__":
    main()