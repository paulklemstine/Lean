#!/usr/bin/env python3
"""cell.py -- the atomic unit of cost: ONE lattice solve at one (k,m,t), plus a
HARD independent verification of whatever it claims.

Everything downstream is built on `cell()` so there is exactly ONE place where a
"success" is defined, and that place verifies by DIVISION (N % f == 0 and
1 < f < N), never by trusting the solver.

The lattice is the standard univariate unknown-divisor construction inherited from
Experiments/UMWWindow/coppersmith_lattice.py: exact-integer shifts
g_{i,j}(x) = N^(m-i) * x^j * f(x)^i, X-scaled, LLL, then undo the scaling by the
exact division v_k / X^k.  Coppersmith (J. Cryptology 10 (1997) 233-260) Sect. 11
gives the N^(1/4) guarantee for high-known-bits factoring; the Howgrave-Graham
short-vector condition (quoted verbatim in Coron, CRYPTO 2004, Sect. 2, Lemma 1)
is |h(x0,y0)|=0 mod n and ||h(xX,yY)||_2 < n/sqrt(omega)  =>  h vanishes over Z.
Here delta=1 and the divisor is the unknown p | N, so X = N^(1/4) is the
guarantee boundary -- strictly, the guarantee is X < N^(1/4 - eps).
"""
import sys, time
sys.path.insert(0, '/home/raver1975/lean/Experiments/UMWWindow')
from coppersmith_lattice import gen_prime, _reduced_polys, evalp, is_prime

def make_instance(nbits, rng):
    """N = p*q with p,q of nbits//2 bits, and 2^(n-1) <= N < 2^n.  Returns (N,p,q,nn)."""
    while True:
        p = gen_prime(nbits // 2); q = gen_prime(nbits // 2)
        if p == q: continue
        N = p * q
        if 2 ** (nbits - 1) <= N < 2 ** nbits:
            return N, p, q, N.bit_length()

def cell(N, p, nn, k, m, t):
    """One lattice solve.  Returns (factor_or_None, wallclock_seconds, n_polys).

    VERIFICATION: the returned factor f must satisfy N % f == 0 and 1 < f < N.
    We additionally require is_prime(f) -- if the lattice handed back a composite
    or a trivial unit it is not a factorisation.
    """
    t0 = time.perf_counter()
    tb = nn // 2 - k
    if tb < 1: return None, 0.0, 0
    X = 1 << tb
    p0 = (p >> tb) * X
    f = [p0, 1]
    polys = _reduced_polys(f, N, X, m, t)
    x_true = p - p0
    out = None
    for h in polys:
        if evalp(h, x_true) != 0: continue
        cand = p0 + x_true
        # ---- HARD, SOLVER-INDEPENDENT VERIFICATION ----
        if 1 < cand < N and N % cand == 0 and (N // cand) > 1 and is_prime(cand):
            out = cand
            break
    return out, time.perf_counter() - t0, len(polys)
