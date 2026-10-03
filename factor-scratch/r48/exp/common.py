"""
r48 / AXIS C -- the smoothness assumption in GNFS.

Shared utilities: Dickman rho, exact B-smoothness sieve, NFS box sampler.
"""
import numpy as np
from math import log, isqrt


# ---------------------------------------------------------------- Dickman rho
_H = 1e-6
_UMAX = 12.0          # rho(12) ~ 1e-19; below any measurable rate for n < 1e12


def _build_rho():
    """Solve the Dickman delay ODE  rho'(u) = -rho(u-1)/u,  rho=1 on [0,1].

    rho(u) = 1 - int_1^u rho(t-1)/t dt = 1 - int_0^{u-1} rho(s)/(s+1) ds.

    Block-vectorised: for u in [m, m+1] the integrand only needs rho(s) for
    s <= u-1 < m, i.e. only the PREVIOUS block.  K = 1/_H.
    """
    n = int(_UMAX / _H)
    K = int(1.0 / _H)
    ug = np.arange(n + 1) * _H
    g = np.zeros(n + 1)
    g[:K + 1] = 1.0                       # rho(u) = 1 exactly on [0,1]
    for m in range(1, int(_UMAX)):
        lo, hi = m * K, min((m + 1) * K, n)          # indices of this block
        if lo >= n:
            break
        # integrand rho(s)/(s+1) is only needed for s <= u-1 < lo, and g[:lo]
        # is final, so the prefix cumsum may be rebuilt each block.
        w = _H * g[:lo] / (ug[:lo] + 1.0)
        C = np.concatenate(([0.0], np.cumsum(w)))      # C[j+1] = sum_{k<=j} w[k]
        j = np.arange(lo, hi) - K                     # top integration index
        j = np.clip(j, 0, None)
        g[lo:hi] = np.maximum(0.0, 1.0 - C[j])
    return ug, g


_UG, _G = _build_rho()


def rho(u):
    """Dickman rho(u) = P(uniform integer <= x is y-smooth), u = log x / log y."""
    if u <= 0:
        return 1.0
    return float(np.interp(u, _UG, _G, left=1.0, right=0.0))


def rho_closed(u):
    """Closed form rho(u) = 1 - log(u) for 1 <= u <= 2.  Independent of the
    ODE integrator; used as a cross-check in STEP 0."""
    return 1.0 - log(u)


# ------------------------------------------------------------- smoothness sieve
def sieve_primes(n):
    """Primes <= n, ascending."""
    if n < 2:
        return []
    s = bytearray([1]) * (n + 1)
    s[0:2] = b'\x00\x00'
    for p in range(2, isqrt(n) + 1):
        if s[p]:
            s[p * p::p] = bytearray(len(s[p * p::p]))
    return [i for i in range(2, n + 1) if s[i]]


def smooth_sieve(M, B):
    """Boolean array S[0..M]; S[n] = True iff n is B-smooth (all prime factors <= B).

    Multiplicative closure.  S[1]=True; for each prime p <= B ascending,
    repeatedly  S[p::p] |= S[1:M//p+1]  until fixed point, which closes the
    p^k chains.  After processing primes <= p, S[n] is True iff n is
    (primes <= p)-smooth.
    """
    S = np.zeros(M + 1, dtype=bool)
    S[1] = True
    lp = log
    for p in sieve_primes(B):
        if p > M:
            break
        L = M // p
        iters = int(lp(M) / lp(p)) + 1
        for _ in range(iters):
            S[p::p] |= S[1:L + 1]
    return S


# ----------------------------------------------------------------- NFS sampler
def nfs_values(A, Bmax, sign=-1):
    """All values of |a^2 - b^3| (sign=-1) or a^2+b^3 (sign=+1) over the NFS
    rectangle 1<=a<=A, 1<=b<=Bmax.  Returns a flat int64 array, a-major."""
    a = np.arange(1, A + 1, dtype=np.int64)
    b = np.arange(1, Bmax + 1, dtype=np.int64)
    Aa = a[:, None]
    Bb = b[None, :]
    V = Aa * Aa - Bb * Bb * Bb if sign < 0 else Aa * Aa + Bb * Bb * Bb
    return V.reshape(-1)


def strata(V, lo_pow=-8, hi_pow=40):
    """Bucket a value array by dyadic magnitude strata [2^j, 2^{j+1}).

    Returns dict j -> boolean mask, plus the count per stratum."""
    n = np.arange(1, V.size + 1)
    av = np.abs(V)
    j = np.zeros(av.size, dtype=np.int64)
    nz = av > 0
    j[nz] = np.floor(np.log2(av[nz].astype(np.float64))).astype(np.int64)
    out = {}
    for jj in range(lo_pow, hi_pow):
        m = (j == jj) & nz
        c = int(m.sum())
        if c:
            out[jj] = m
    return out