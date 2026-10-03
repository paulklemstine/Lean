"""Shared primitives for the supply audit.  Every function here has a self-test in
01_selftest.py that asks "can this return FALSE / ZERO where false is correct?" --
because round 48 shipped two harnesses whose smoothness predicates called
everything smooth, which inflates every rate toward 1 and never errors.

The arithmetic under audit (verbatim from ~/factor47/V3/skeptic/analytic.py and
~/factor47/V4/Mscan2.py):

    l(m,c,u,v) = 4u^4 + 8 m u^3 v - 4 c u v^3 + c v^4 m
               = L*m + K,   L = 8 u^3 v + c v^4,   K = 4 u^4 - 4 c u v^3

A "relation" is an (m,c) instance for which l is a perfect square, for some coprime
(u,v) with 1<=v<=H, -H<=u<=H, (u,v)!=(0,1).

chi_P(w,p,q) = -1  iff  w is a quadratic NON-residue mod p AND mod q
              = +1  iff  w is a quadratic     residue mod p AND mod q
              (undefined if w is divisible by p or q)
"""
from __future__ import annotations

import math
import random
from math import gcd, isqrt

import numpy as np

# ---------------------------------------------------------------------------
# constants copied verbatim from the audited code
# ---------------------------------------------------------------------------
CPOOL = (2, 3, 5, 6, 7, 10, 11, 13, 14, 17, 19, 22, 23, 26, 29, 31)
H = 40


def coprime_pairs(H):
    """IDENTICAL to analytic.coprime_pairs / Mscan2.coprime_pairs."""
    out = []
    for v in range(1, H + 1):
        for u in range(-H, H + 1):
            if u == 0 and v == 1:
                continue
            if gcd(abs(u), v) != 1:
                continue
            out.append((u, v))
    return out


PAIRS = coprime_pairs(H)
NP = len(PAIRS)
U = np.array([p[0] for p in PAIRS], dtype=np.int64)
V = np.array([p[1] for p in PAIRS], dtype=np.int64)
U3V = 8 * U.astype(object) ** 3 * V.astype(object)          # = 8 u^3 v
U4 = 4 * U.astype(object) ** 4                             # = 4 u^4
UV3 = 4 * U.astype(object) * V.astype(object) ** 3         # = 4 u v^3
V4 = V.astype(object) ** 4                                 # = v^4
for _n in ("U3V", "U4", "UV3", "V4"):
    globals()[_n] = np.array([int(x) for x in globals()[_n]], dtype=np.int64)
U3V_l = U3V.tolist(); U4_l = U4.tolist()
UV3_l = UV3.tolist(); V4_l = V4.tolist()

# ---------------------------------------------------------------------------
# the exact-square filter.
#
# A necessary condition for l to be a perfect square is that l mod M be a quadratic
# residue mod M.  We use M = 2^6 * 3 * 5 * 7 * 11 * 13 = 960960, whose QR density is
# (1/6)*(1/2)^5 = 1/192.  That is a pure SPEED device: the survivors are re-checked
# with exact Python integers and math.isqrt.  It can only ever discard true relations
# if the QR table is wrong, which 01_selftest.py checks against brute force.
# ---------------------------------------------------------------------------
_QRMOD = 2 ** 6 * 3 * 5 * 7 * 11 * 13


def _build_qr_table(M):
    """t[x] = True iff x is a square mod M, for M = 2^6*3*5*7*11*13.

    Built by BRUTE FORCE over the prime-power moduli (64 entries, then 3,5,7,11,13)
    and lifted.  The first version of this function derived the 2-adic pattern
    analytically and was WRONG at v2 = 4: at modulus 2^6 the odd part of x only
    matters mod 4, not mod 8, so the analytic rule over-restricted and silently
    discarded true relations.  The self-test caught it.  Brute force cannot err.
    """
    t = np.ones(M, dtype=bool)
    for pp in (64, 3, 5, 7, 11, 13):
        qr = np.zeros(pp, dtype=bool)
        for y in range(pp):
            qr[(y * y) % pp] = True      # includes y = 0, so 0 is a residue
        bad = np.nonzero(~qr)[0]
        t[bad[:, None] + pp * np.arange(M // pp, dtype=np.int64)[None, :]] = False
    return t


_QRTAB = _build_qr_table(_QRMOD)


def icbrt_floor(n):
    x = 1 << ((n.bit_length() + 2) // 3)
    while True:
        y = (2 * x + n // (x * x)) // 3
        if y >= x:
            break
        x = y
    while x ** 3 > n:
        x -= 1
    while (x + 1) ** 3 <= n:
        x += 1
    return x


# ---------------------------------------------------------------------------
# the relation counter
# ---------------------------------------------------------------------------
def rels_scalar(m, c, pairs=None):
    """EXACT relation count for one (m,c) instance.  Pure Python ints + isqrt."""
    if pairs is None:
        pairs = PAIRS
    L4, L3, LC, LK = U4_l, U3V_l, UV3_l, V4_l
    n = 0
    for i in range(len(pairs)):
        lm = L4[i] + m * (L3[i] + c * LK[i]) - c * LC[i]
        if lm <= 0:
            continue
        w = isqrt(lm)
        if w * w == lm:
            n += 1
    return n


def rels_batch(ms, cs, collect=False):
    """Vectorised exact relation count for a list of (m,c) instances.

    Returns (counts list, relations) where relations is a list of
    (m, c, u, v, w) -- only when collect=True.

    The filter stage is int64; the survivor stage is exact Python ints.
    """
    ms = [int(x) for x in ms]
    cs = [int(x) for x in cs]
    counts = [0] * len(ms)
    rels = []
    CH = 512                                  # instances per chunk (memory bound)
    for s in range(0, len(ms), CH):
        mb = ms[s:s + CH]
        cb = cs[s:s + CH]
        Mm = np.array(mb, dtype=np.int64)
        Cc = np.array(cb, dtype=np.int64)
        Lm = (U3V[None, :] + Cc[:, None] * V4[None, :]) % _QRMOD   # L mod M
        Km = (U4[None, :] - Cc[:, None] * UV3[None, :]) % _QRMOD   # K mod M
        resid = (Lm * Mm[:, None] + Km) % _QRMOD
        ii, jj = np.nonzero(_QRTAB[resid])
        for a, b in zip(ii.tolist(), jj.tolist()):
            m = mb[a]; c = cb[a]
            lm = U4_l[b] + m * (U3V_l[b] + c * V4_l[b]) - c * UV3_l[b]
            if lm <= 0:
                continue
            w = isqrt(lm)
            if w * w == lm:
                counts[s + a] += 1
                if collect:
                    rels.append((m, c, int(U[b]), int(V[b]), w))
    return counts, rels


# ---------------------------------------------------------------------------
# chi_P
# ---------------------------------------------------------------------------
def chiP(w, p, q):
    """-1 if w is a QNR mod both p and q; +1 if QR mod both; 0 if undefined
    (p | w or q | w).  Copied verbatim from V4/CHI_BOXSCAN.py."""
    wp = w % p
    wq = w % q
    if not wp or not wq:
        return 0
    a = pow(wp, (p - 1) // 2, p)
    b = pow(wq, (q - 1) // 2, q)
    if a == p - 1 and b == q - 1:
        return -1
    if a == 1 and b == 1:
        return 1
    return 0


# ---------------------------------------------------------------------------
# semiprimes with p = q = 3 (mod 4)  -- PARITY IS MATCHED to CEIL3.py, which is the
# code that produced the scan's own reported chi_P fraction.
# ---------------------------------------------------------------------------
def prime_3mod4(lo, hi):
    out = []
    for k in range(lo | 1, hi + 1):
        if k % 4 != 3 or k < 3:
            continue
        if all(k % d for d in range(2, int(k ** 0.5) + 1)):
            out.append(k)
    return out


_SMALL_PS = {}


def make_semiprime(bits, rng=None):
    """N = p*q, p,q primes = 3 mod 4, 2^(bits-1) <= N < 2^bits.  Random unless the
    prime cache for this size already holds a list (then we cycle through it, which
    is what gives us many independent N at one size)."""
    if bits in _SMALL_PS and rng is not None and getattr(rng, "_cycle_small", False):
        lst = _SMALL_PS[bits]
        p, q = lst[next(_SMALL_ITER[bits]) % len(lst)]
        return p * q, p, q
    half = bits // 2
    lo, hi = 1 << (half - 1), 1 << half
    if bits not in _SMALL_PS:
        ps = [x for x in prime_3mod4(lo | 1, hi) if x > 2]
        if not ps:
            raise RuntimeError("no primes at %d bits" % half)
        _SMALL_PS[bits] = [(p, q) for p in ps for q in ps if p < q
                           and (1 << (bits - 1)) <= p * q < (1 << bits)]
    lst = _SMALL_PS[bits]
    if not lst:
        raise RuntimeError("no semiprimes at %d bits" % bits)
    if rng is None:
        p, q = lst[0]
        return p * q, p, q
    p, q = lst[rng.randrange(len(lst))]
    return p * q, p, q


_SMALL_ITER = {}


def cycle_semiprimes(bits):
    """Enable round-robin over all cached (p,q) at this size -- many distinct N."""
    _SMALL_ITER[bits] = 0
    return len(_SMALL_PS[bits])
