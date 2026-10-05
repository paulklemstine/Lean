"""
Lenstra ECM stage 1, self-contained.  Jacobian coordinates on SHORT Weierstrass
y^2 = x^3 + A x + B (a2 is removed by x -> x - a2/3, exact since n is odd, != 3).

WHY THIS FILE EXISTS
--------------------
r112's headline positive is "at n=800 the GIFP lattice recovered p2 3/3 while
PARI factor(N2) ran >4 min without success".  PARI 2.17's factor() has NO ECM
stage (measured in RESULT.md), so that baseline is a strawman.  The correct
generic-factoring baseline is ECM.  This file supplies it.

HARNESS INTEGRITY: the Jacobian formulas are verified against Sage's own
(correct) EC arithmetic in ct_formulas.sage.  A broken formula here would make
every measurement below VOID, so that check runs first.

ECM works on an arbitrary curve y^2 = x^3 + a2 x^2 + a4 x + a6 mod n.  Suyama's
parametrisation supplies such a curve and a point on it.
"""
import random
import time
from gmpy2 import mpz, gcd, invert


# ---------------- Jacobian group law on y^2 = x^3 + A x + B ----------------
def jac_dbl(X, Y, Z, A, n):
    if Y == 0 or Z == 0:
        return 0, 0, 0
    YY = Y * Y % n
    S = 4 * X * YY % n
    ZZ = Z * Z % n
    M = (3 * X * X + A * ZZ % n * ZZ) % n
    Xr = (M * M - 2 * S) % n
    YYYY = YY * YY % n
    Yr = (M * (S - Xr) - 8 * YYYY) % n
    Zr = 2 * Y * Z % n
    return Xr, Yr, Zr


def jac_add(X1, Y1, Z1, X2, Y2, Z2, A, n):
    if Z1 == 0:
        return X2, Y2, Z2
    if Z2 == 0:
        return X1, Y1, Z1
    Z1Z1 = Z1 * Z1 % n
    Z2Z2 = Z2 * Z2 % n
    U1 = X1 * Z2Z2 % n
    U2 = X2 * Z1Z1 % n
    S1 = Y1 * Z2 % n * Z2Z2 % n
    S2 = Y2 * Z1 % n * Z1Z1 % n
    if U1 == U2:
        if S1 != S2:
            return 0, 0, 0            # P + (-P) = O
        return jac_dbl(X1, Y1, Z1, A, n)   # P + P
    H = (U2 - U1) % n
    R = (S2 - S1) % n
    H2 = H * H % n
    H3 = H2 * H % n
    U1H2 = U1 * H2 % n
    Xr = (R * R - H3 - 2 * U1H2) % n
    Yr = (R * (U1H2 - Xr) - S1 * H3) % n
    Zr = H * Z1 % n * Z2 % n
    return Xr, Yr, Zr


def jac_mul(P, k, A, n):
    """P is (X,Y,Z) Jacobian. Returns [k]P."""
    X, Y, Z = P
    if k == 0 or Z == 0:
        return 0, 0, 0
    R = None
    Q = P
    while k:
        if k & 1:
            R = Q if R is None else jac_add(R[0], R[1], R[2], Q[0], Q[1], Q[2], A, n)
        k >>= 1
        if k:
            Q = jac_dbl(Q[0], Q[1], Q[2], A, n)
    return R


# ---------------- ECM ----------------
def _sieve(B1):
    s = bytearray([1]) * (B1 + 1)
    s[0] = s[1] = 0
    for i in range(2, int(B1 ** 0.5) + 1):
        if s[i]:
            s[i * i::i] = bytearray(len(s[i * i::i]))
    return [i for i in range(2, B1 + 1) if s[i]]


_KCACHE = {}


def stage1_scalar(B1):
    """lcm(1, 2, ..., B1) = prod_{p <= B1} p^floor(log_p B1).

    Each prime's power must be computed INDEPENDENTLY.  Constraining the running
    product to stay <= B1 (a natural-looking but wrong reading) yields 2^E only
    and silently reduces stage 1 to a no-op -- caught by the positive control.
    """
    if B1 in _KCACHE:
        return _KCACHE[B1]
    k = 1
    for p in _sieve(B1):
        pe = p
        while pe * p <= B1:
            pe *= p
        k *= pe
    _KCACHE[B1] = k
    return k


def random_curve_point(rng, n):
    """A random curve y^2 = x^3 + A x + B mod n WITH a guaranteed point (x0,y0).

    Choose random A, x0, y0 and solve for B = y0^2 - x0^3 - A*x0.  This is a
    random curve (the standard ECM situation); no Suyama heuristic is used, and
    no Suyama identity is assumed.  Returns (A, B, x0, y0) or None if singular.
    """
    n = int(n)
    for _ in range(8):
        A = int(rng.randrange(2, n - 1))
        x0 = int(rng.randrange(2, n - 1))
        y0 = int(rng.randrange(2, n - 1))
        B = (y0 * y0 - pow(x0, 3, n) - A * x0) % n
        # 4A^3 + 27B^2 == 0  <=>  singular; invertibility of 4,27 is fine (n odd)
        if (4 * pow(A, 3, n) + 27 * B * B) % n == 0:
            continue
        return A % n, B, x0, y0
    return None


def ecm_curve(n, B1, rng):
    """One ECM curve. Returns a nontrivial factor of n, or None."""
    n = int(n)
    got = random_curve_point(rng, n)
    if got is None:
        return None
    A, B, x0, y0 = got
    P = jac_mul((x0, y0, 1), stage1_scalar(B1), A, n)
    if P is None or P[2] == 0:
        return None
    g = int(gcd(mpz(P[2]), mpz(n)))
    if g == n:
        return None
    if g != 1:
        return g
    return None


def factor_ecm(n, B1=2000, ncurves=30, seed=12345, tlimit=None):
    n = int(n)
    for s in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % s == 0:
            return s, 0.0, 0
    rng = random.Random(seed)
    t0 = time.time()
    for c in range(1, ncurves + 1):
        f = ecm_curve(n, B1, rng)
        if f:
            el = time.time() - t0
            return f, el, c
        if tlimit and time.time() - t0 > tlimit:
            return None, time.time() - t0, c
    return None, time.time() - t0, ncurves
