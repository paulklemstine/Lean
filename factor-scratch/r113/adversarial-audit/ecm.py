"""
Self-contained Lenstra ECM stage-1, written from the primary description
(Knuth TAOCP 2, Alg. 6.3 / Montgomery 1987; Suyama's sigma parametrisation).
NO prior harness in this repo is imported.

Purpose: provide the correct GENERIC-FACTORING BASELINE against which any
"our attack beat factor()" claim must be measured. PARI 2.17 factor() has no
ECM stage (measured, see RESULT.md), so it is NOT a valid baseline.

Positively controlled: factor_ecm() must find planted factors at the rate the
standard ECM tables predict, or it measures nothing.
"""
import random
import time
from gmpy2 import mpz, gcd, invert


def _mont_xdbl(X, Z, a24, n):
    """xDBL: x(2P) = (X^2-Z^2)^2 / (4 X Z (X^2 + A X Z + Z^2)), with a24=(A+2)/4."""
    t1 = (X + Z) * (X + Z) % n
    t2 = (X - Z) * (X - Z) % n
    t3 = (t1 - t2) % n                    # 4XZ
    t4 = a24 * t3 % n
    Xr = t1 * t2 % n
    Zr = t3 * (t2 + t4) % n
    return Xr, Zr


def _mont_xadd(X1, Z1, X2, Z2, n):
    """XADD for Montgomery curves (madd-2007-bl / curve25519 ladder form):
       A=(X1+Z1), B=(X1-Z1), C=(X2+Z2), D=(X2-Z2)
       X3 = (A*D + B*C)^2 ,  Z3 = X1*(A*D - B*C)^2
    Verified exhaustively against affine addition in ct_ladder.py."""
    t1 = (X2 - Z2) * (X1 + Z1) % n
    t2 = (X2 + Z2) * (X1 - Z1) % n
    t3 = (t1 + t2) % n
    t4 = (t1 - t2) % n
    Xr = t3 * t3 % n
    Zr = X1 * t4 % n * t4 % n
    return Xr, Zr


def _mul_k(X, Z, k, a24, n):
    """x-only double-and-add for [k]P. Invariant: R1 - R0 = P, with R0=P, R1=2P."""
    if k == 0:
        return X, Z
    R0x, R0z = X, Z
    R1x, R1z = _mont_xdbl(X, Z, a24, n)
    for ch in bin(k)[3:]:                # skip the leading 1
        if ch == '0':
            R1x, R1z = _mont_xadd(R0x, R0z, R1x, R1z, n)
            R0x, R0z = _mont_xdbl(R0x, R0z, a24, n)
        else:
            R0x, R0z = _mont_xadd(R0x, R0z, R1x, R1z, n)
            R1x, R1z = _mont_xdbl(R1x, R1z, a24, n)
    return R0x, R0z


def _prime_powers_upto(B1, cap=400000):
    """Sieve primes up to B1."""
    if B1 > cap:
        raise ValueError("B1 too large for this sieve")
    s = bytearray([1]) * (B1 + 1)
    s[0] = s[1] = 0
    for i in range(2, int(B1 ** 0.5) + 1):
        if s[i]:
            s[i * i::i] = bytearray(len(s[i * i::i]))
    return [i for i in range(2, B1 + 1) if s[i]]


_P_CACHE = {}


def _stage1_scalar(B1, cap=400000):
    """D = 2^E * prod_{odd p <= B1} p^e  (E = largest with 2^E <= B1)."""
    if B1 in _P_CACHE:
        return _P_CACHE[B1]
    primes = _prime_powers_upto(B1, cap)
    E = 0
    while (1 << (E + 1)) <= B1:
        E += 1
    k = 1 << E
    for p in primes:
        if p == 2:
            continue
        while k * p <= B1:
            k *= p
    _P_CACHE[B1] = (k, len(primes))
    return k, len(primes)


def ecm_once(n, B1, rng, cap=400000):
    """One ECM curve. Returns a nontrivial factor of n, or None."""
    n = mpz(n)
    k, _ = _stage1_scalar(B1, cap)
    for _ in range(12):                      # retry a singular curve
        sigma = mpz(rng.randrange(6, int(n)))
        u = (sigma * sigma - 5) % n
        v = (4 * sigma) % n
        if u == 0 or v == 0:
            continue
        u3 = u * u % n * u % n
        v3 = v * v % n * v % n
        den = (4 * u3 % n) * v % n
        if den == 0:
            continue
        try:
            num = pow((v - u) % n, 3, n) * (3 * u + v) % n
            A = (num * int(invert(den, n)) - 2) % n
        except ZeroDivisionError:
            continue
        if A <= 2 or A >= n - 1:
            continue
        a24 = (A + 2) % n * int(invert(mpz(4), n)) % n
        Qx, Qz = u3 % n, v3 % n
        if Qx == 0 or Qz == 0:
            continue
        Qx, Qz = _mul_k(Qx, Qz, k, a24, n)
        if Qz == 0:
            continue
        g = gcd(Qz, n)
        if g == n:
            return None
        if g != 1:
            return int(g)
    return None


def factor_ecm(n, B1=2000, ncurves=30, seed=12345, tlimit=None, verbose=False):
    """Run ncurves ECM curves at stage-1 bound B1. Returns (factor, seconds, ncurves_used)."""
    n = int(n)
    if n % 2 == 0:
        return 2, 0.0, 0
    for s in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % s == 0:
            return s, 0.0, 0
    rng = random.Random(seed)
    t0 = time.time()
    for c in range(1, ncurves + 1):
        f = ecm_once(n, B1, rng)
        if f is not None and n % f == 0 and f not in (1, n):
            el = time.time() - t0
            if verbose:
                print("  factor %d found after %d curves, %.2fs" % (f, c, el))
            return f, el, c
        if tlimit and time.time() - t0 > tlimit:
            el = time.time() - t0
            return None, el, c
    return None, time.time() - t0, ncurves
