"""
r113 / recombination-depth -- genuine relation generator (written from the
algebra; NOT imported from any r110-r112 harness).

RELATION FORM.  Integers (x, y) with

        x^2 == y  (mod N),        y  B-smooth,

verified EXACTLY for every relation before acceptance.  This is the NFS
recombination invariant: a subset S with all total exponents even has
y_S = prod_{i in S} y_i an EXACT integer square z_S^2, and
x_S = prod_{i in S} x_i satisfies x_S^2 == z_S^2 (mod N), so
N | (x_S - z_S)(x_S + z_S) and gcd(x_S - z_S, N) is a proper factor unless
the two square roots of z_S^2 coincide mod N.

SOURCE.  Put kN = s^2 + rem (s = isqrt(kN), exact integer root).  For m >= 1,
x = s + m gives

        y := x^2 - kN = 2 s m + m^2 - rem,

an integer of size ~ 2 sqrt(kN) m, and x^2 == y (mod N) identically.  So any
m whose y is B-smooth is a genuine relation.  Smoothness is EXACT trial
division.

DEFECT FOUND AND FIXED WHILE WRITING THIS (recorded, not hidden): an earlier
version pre-filtered candidates with a logarithm sieve that adds log(q) ONCE
per distinct prime dividing y.  Since log y = sum_q v_q(y) log q counts
MULTIPLICITIES, that filter REJECTS every non-squarefree smooth value -- it is
a filter for squarefree-smooth, not for smooth.  Measured: 31 of 31 true
B-smooth values in [1,120000] were rejected by it (a positive control that
FAILED and exposed the bug).  The filter is therefore DELETED, not tightened;
exact trial division is now the only test.
"""
import math
import numpy as np


def sieve_primes(B):
    s = np.ones(B + 1, dtype=bool); s[0:2] = False
    for i in range(2, int(B ** 0.5) + 1):
        if s[i]:
            s[i * i::i] = False
    return np.flatnonzero(s)


def sqrt_mod(n, q):
    n %= q
    if q == 2: return n
    if n == 0: return 0
    if pow(n, (q - 1) // 2, q) != 1: return None
    if q % 4 == 3: return pow(n, (q + 1) // 4, q)
    return _tonelli(n, q)


def _tonelli(n, q):
    s, t = 0, q - 1
    while t % 2 == 0:
        t //= 2; s += 1
    z = 2
    while pow(z, (q - 1) // 2, q) != q - 1:
        z += 1
    m, c = s, pow(z, t, q)
    tt, R = pow(n, t, q), pow(n, (t + 1) // 2, q)
    while tt != 1:
        i, tt2 = 0, tt
        while tt2 != 1:
            tt2 = (tt2 * tt2) % q; i += 1
        b = pow(c, 1 << (m - i - 1), q)
        m, c = i, (b * b) % q
        tt = (tt * c) % q; R = (R * b) % q
    return R


def vals_for(N, k, m_lo, m_hi):
    """x = isqrt(k*N) + m,  y = x^2 - k*N.  Exact, returned as int64."""
    s = math.isqrt(k * N)
    m = np.arange(m_lo, m_hi + 1, dtype=np.int64)
    x = s + m
    y = x * x - k * N
    return x, y


def smooth_mask(y, primes):
    """Fully VECTORISED exact trial division.  Returns (rest, exp_matrix)
    where exp_matrix[i, t] is the exponent of primes[t] in y[i]."""
    n = len(y)
    w = y.astype(np.int64).copy()
    E = np.zeros((n, len(primes)), dtype=np.int16)
    top = int(w.max())
    for t, q in enumerate(primes):
        qi = int(q)
        if qi * qi > top:
            break
        mask = (w % qi) == 0
        if not mask.any():
            continue
        idx = np.flatnonzero(mask)
        while True:
            sub = (w[idx] % qi) == 0
            if not sub.any():
                break
            sel = idx[sub]
            w[sel] //= qi
            E[sel, t] += 1
            idx = sel
    return w, E


def gen_relations(N, B, J, want, k=1, verbose=True):
    """Collect up to `want` relations from m in [1, J] at multiplier k."""
    primes = sieve_primes(B)
    ps = [int(q) for q in primes]
    a = math.isqrt(N)
    top = 2 * (a + J) * J + J * J          # upper bound on y
    if top >= 2 ** 62:
        raise ValueError("y would overflow int64; lower J or k")
    rels = []
    m = 1
    scanned = 0
    while m <= J and len(rels) < want:
        hi = min(J, m + (1 << 19) - 1)
        x, y = vals_for(N, k, m, hi)
        y = np.where(y > 1, y, 1)
        rest, E = smooth_mask(y, ps)
        good = np.flatnonzero(rest == 1)
        for gidx in good:
            v = int(y[gidx]); xv = int(x[gidx]) % N
            if (xv * xv - v) % N != 0:
                raise AssertionError("invariant violated")
            exps = [(t, int(E[gidx, t])) for t in range(len(ps))
                    if E[gidx, t] > 0]
            rels.append((xv, v, exps))
            if len(rels) >= want:
                break
        scanned += hi - m + 1
        m = hi + 1
    info = dict(N=N, B=int(B), J=int(J), k=k, nprimes=len(ps),
                found=len(rels), scanned=int(scanned),
                yield_=len(rels) / float(max(1, J)))
    if verbose:
        print("  relations: B=%d J=%d k=%d primes=%d scanned=%d found=%d "
              "yield=%.2e" % (B, J, k, len(ps), scanned, len(rels),
                              info['yield_']), flush=True)
    return rels, info, ps
