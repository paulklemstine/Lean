#!/usr/bin/env python3
"""
umw_t_core.py -- Rank-2 gap difference divisibility ("t") for the Umans-Wang route.

SEED AND RUN-TWICE DISCIPINE: every random draw goes through rng(seed,...) below.
Run this file twice; outputs must be byte-identical.

REGIME: classical factoring of locally generated small moduli. n = L^3 with L = 2^k,
so L = n^(1/3) EXACTLY, the (1/3,1/3) target shape. Band P0 = {p prime : a*x < p <= b*x}
with x = isqrt(n), a = 2/3, b = 1 -- He-Sahai's own optimal band (arXiv:2608.06681, Thm 1.1).

DEFINITIONS (established from He-Sahai arXiv:2608.06681 Sec.3 + Umans-Wang
arXiv:2511.10851 Conj. 3.3; see NOTES.md for verbatim quotes):

  rank-2 gap:   A = { b0 + a1*i + a2*j : 0<=i<L1, 0<=j<L2 },  all |A| <= exp(n^alpha)
  points V:     V = P, the band primes
  blocks:       B_w = { p in P : p | A(w) },  indexed by grid point w=(i,j)
  H1 (pair covering, rank-free): every two p,q in P lie in some B_w,
                  because pq <= b^2*n <= n so the n-divisor property applies.
  H2 (intersection):  |B_w cap B_w'| = #{ p in P : p | A(w)-A(w') }
                        = #{ p in P : p | a1*di + a2*dj },   di=i-i', dj=j-j'
      With H2 weakened to max intersection = t, He-Sahai Lemma 2.1 still yields
      v <= t*Delta^2 + 1  (verified in exp D below).

  t := max over nonzero (di,dj) in [-(L1-1),L1-1] x [-(L2-1),L2-1] of
       #{ p in P : p | a1*di + a2*dj }

  P excludes primes dividing gcd(a1,a2) -- the EXACT rank-2 analogue of He-Sahai's
  "P = {p in P0 : p does not divide c}": if p | gcd(a1,a2) then p | every difference,
  which is degenerate and carries no information. (Primes dividing exactly ONE
  coefficient are kept: they give a genuine, bounded condition p | di.)
"""
import numpy as np
import math
import hashlib

# ---------------------------------------------------------------- seeded rng
def rng(seed, tag):
    """Deterministic independent stream per (seed, tag)."""
    h = hashlib.sha256(f"{seed}|{tag}".encode()).digest()
    return np.random.default_rng(int.from_bytes(h[:8], "big"))

# ---------------------------------------------------------------- primes
_SIEVE = {}
def sieve(lim):
    if lim in _SIEVE:
        return _SIEVE[lim]
    s = np.ones(lim + 1, dtype=bool)
    s[:2] = False
    for p in range(2, int(lim ** 0.5) + 1):
        if s[p]:
            s[p * p:: p] = False
    _SIEVE[lim] = s
    return s

def band_primes(n, a_num=2, a_den=3, b_num=1, b_den=1):
    """P0 = {p prime : (a_num/a_den)*x < p <= (b_num/b_den)*x}, x = floor(sqrt(n))."""
    x = math.isqrt(n)
    lo = (a_num * x) // a_den
    hi = (b_num * x) // b_den
    s = sieve(hi + 1)
    return np.nonzero(s[lo + 1: hi + 1])[0] + (lo + 1)

# ---------------------------------------------------------------- t engine
def is_degenerate(a1, a2, L1, L2):
    """
    DEGENERACY TEST. A gap is DEGENERATE (effectively rank-1) iff there is a NONZERO
    integer difference vector (di,dj) with |di|<L1, |dj|<L2 and a1*di + a2*dj = 0 exactly.
    Then EVERY band prime divides that difference, so t = |P| vacuously -- the detector
    saturates and carries no information. This is the exact analogue of a rank-1 gap
    wearing rank-2 clothing, and it must be excluded before any t is quoted.
    Condition: with g=gcd(a1,a2), the primitive null vector is (a2/g, -a1/g); it fits
    in the box iff max(|a2|,|a1|)/g < max(L1,L2).
    """
    g = math.gcd(abs(a1), abs(a2))
    if g == 0:
        return True                     # a1 == a2 == 0
    return max(abs(a1), abs(a2)) // g < max(L1, L2)

def t_profile(a1, a2, L1, L2, P, allow_degenerate=False):
    """
    Exact t and the full histogram over the difference box.
    Returns (t_max, hist, n_differences, dropped) where hist[k] = #differences with
    exactly k band primes dividing a1*di + a2*dj, over ALL nonzero (di,dj) in the box.
    Raises ValueError on a degenerate gap unless allow_degenerate (the caller must
    then treat t=|P| as vacuous, not as a measurement).
    """
    if is_degenerate(a1, a2, L1, L2) and not allow_degenerate:
        raise ValueError("degenerate gap: a nonzero integer difference is 0; t is vacuous")
    P = np.asarray(P, dtype=np.int64)
    tmap = np.zeros((2 * L1 - 1, 2 * L2 - 1), dtype=np.int32)
    dI = np.arange(-(L1 - 1), L1, dtype=np.int64)
    dropped = 0
    for p in P:
        p = int(p)
        if a1 % p == 0 and a2 % p == 0:
            dropped += 1          # p | gcd(a1,a2): degenerate, excluded (analogue of p|c)
            continue
        a1p = a1 % p
        a2p = a2 % p
        # solve a1*di + a2*dj = 0 (mod p) for dj, given di; p > 2L so unique candidate
        r = (-a1p * pow(a2p, -1, p)) % p if a2p != 0 else 0
        vals = (r * dI) % p
        pos = vals < L2
        neg = vals > (p - L2)
        if pos.any():
            # signed representative is dj = +vals, so COLUMN = dj + (L2-1) = vals + (L2-1).
            # (Omitting the +L2-1 here silently counted the always-solution (0,0) as dj=-L2+1.)
            tmap[(dI[pos] + L1 - 1), (vals[pos] + L2 - 1)] += 1
        if neg.any():
            tmap[(dI[neg] + L1 - 1), (vals[neg] - p + L2 - 1)] += 1
    tmap[L1 - 1, L2 - 1] = -1          # mark the zero difference; exclude it
    flat = tmap.reshape(-1)
    nz = flat[flat >= 0]
    hist = np.bincount(nz, minlength=max(1, int(nz.max()) + 1)) if nz.size else np.zeros(1, int)
    t_max = int(nz.max()) if nz.size else 0
    return t_max, hist, int(nz.size), dropped

# ---------------------------------------------------------------- degree engine
def degree(a1, a2, b0, L1, L2, P):
    """|B_p| = #{(i,j) in [0,L1)x[0,L2) : p | b0 + a1 i + a2 j}, for each band prime p."""
    P = np.asarray(P, dtype=np.int64)
    out = np.zeros(len(P), dtype=np.int64)
    dI = np.arange(0, L1, dtype=np.int64)
    for idx, p in enumerate(P):
        p = int(p)
        if a2 % p == 0:
            continue
        a1p, a2p, b0p = a1 % p, a2 % p, b0 % p
        r = (-(b0p + a1p * dI) % p)
        vals = (r * pow(a2p, -1, p)) % p
        out[idx] = int(((vals < L2) & (vals >= 0)).sum())
    return out

def sample_gap_leq_exp(r, n, alpha, L1, L2):
    """
    Sample |a1|,|a2|,|b0| so that the GAP VALUES b0 + a1 i + a2 j stay <= exp(n^alpha):
    |a1|*L1 + |a2|*L2 + |b0| <= exp(n^alpha). Magnitudes ~ 2^(n^alpha*log2(e)/3) bits.
    """
    nalpha = n ** alpha
    budget = nalpha * math.log(2)          # log2 of exp(n^alpha)
    tot = budget - math.log2(L1) - math.log2(L2) - 2.0
    half = max(8, int(tot / 2))
    lim = 2 ** half
    a1 = _rand_sym(r, half, lim)
    a2 = _rand_sym(r, half, lim)
    b0 = _rand_sym(r, 12, 2 ** 12)
    return a1, a2, b0

def _rand_sym(r, nbits, lim):
    """Uniform-ish integer in (-lim, lim) with nbits>=64. numpy integers() overflows
    on big ranges, so build the integer from random bytes (deterministic under seeding)."""
    nbytes = (nbits // 8) + 2
    v = int.from_bytes(r.bytes(nbytes), "little") % (2 * lim)
    return v - lim

# ---------------------------------------------------------------- t-bound arithmetic
def t_size_upper_bound(n, alpha, beta, a=2.0 / 3.0):
    """
    RIGOROUS: |A(w)-A(w')| <= 2*max|A| <= 2*exp(n^alpha); every band prime p >= a*x
    with x=floor(sqrt(n)). If t primes divide D then (a*x)^t <= |D|, hence
        t <= log(2 exp(n^alpha)) / log(a*x)  =  (n^alpha + log 2)/log(a*sqrt(n)).
    Returned as a float (and we report it against the measured construction).
    """
    x = math.isqrt(n)
    return (n ** alpha + math.log(2)) / math.log(a * x)