"""
selftest.py -- written BEFORE the experiment, exits 0 only if all pass.

The quantity this axis claims to measure is a RELATION RATE:
    #{(a,b) in the box : |f(a,b)| is y-smooth} / #cells.
So the self-test has to exercise exactly that, and -- per the brief -- it must
be able to return the NULL answer where null is correct.  Three of the checks
below are null-return controls (S6b, S7, S8); if this harness cannot certify
"no difference", it cannot certify a difference either.

Run:  python3 selftest.py
"""
from __future__ import annotations

import math
import os
import random
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
R48 = os.path.join(os.path.dirname(os.path.dirname(HERE)), "r48")
sys.path.insert(0, os.path.join(R48, "_shared"))
sys.path.insert(0, os.path.join(R48, "exp"))

import core as K  # noqa: E402
import importlib.util as _ilu  # noqa: E402

# r48/exp also contains a file called dickman.py, and it shadows the shared one
# on sys.path.  Load the SHARED harness by absolute path so that the comparison
# in S5 is against r48/_shared/dickman.py and not against a same-named file.
_spec = _ilu.spec_from_file_location("shared_dickman",
                                     os.path.join(R48, "_shared", "dickman.py"))
_sd = _ilu.module_from_spec(_spec)
_spec.loader.exec_module(_sd)
rho, is_smooth, smooth_prob_estimate = _sd.rho, _sd.is_smooth, _sd.smooth_prob_estimate

FAIL = []


def check(name, cond, detail=""):
    tag = "PASS" if cond else "FAIL"
    if not cond:
        FAIL.append(name)
    print(f"  [{tag}] {name}{('  -- ' + detail) if detail else ''}")


def rsa(bits, seed):
    rng = random.Random(seed)
    def prime(n):
        from sympy import isprime
        while True:
            cand = rng.randrange(2 ** (n - 1), 2 ** n) | 1
            if isprime(cand):
                return cand
    p = prime(bits // 2)
    q = prime(bits // 2)
    while q == p:
        q = prime(bits // 2)
    return p * q


# ---------------------------------------------------------------- S1
def s1_poly_valid():
    print("S1  f(m) = N exactly, over a wide m range (the NFS validity condition)")
    N = rsa(44, 1)
    d = 3
    m_lo = int(N ** (1.0 / d)) - 400
    m_hi = int(N ** (1.0 / d))
    bad = 0
    ns = 0
    for m in range(m_lo, m_hi + 1):
        c = K.poly_from_m(N, m, d)
        if K.f_at_m(c, m) != N:
            bad += 1
        if K.eval_poly(c, m) % N != 0:
            bad += 1
        ns += 1
    check("all m: f(m)==N and f(m)==0 mod N", bad == 0,
          f"{ns} values of m, {bad} violations")
    # the round-48 construction, for contrast
    sys.path.insert(0, os.path.join(R48, "exp"))
    import nfs_lattice as NL
    import run_c1_old as R
    m = int(N ** (1.0 / 3))
    while m ** 3 >= N:
        m -= 1
    P = NL.make_poly(N, 3, m)
    fc = R.f_coeffs_of(P)
    r48_fm = K.eval_poly(list(reversed(fc)), m)   # fc is leading-first
    check("r48 make_poly does NOT satisfy f(m)=0 mod N (documented defect)",
          r48_fm % N != 0,
          f"r48 f(m) mod N = {r48_fm % N}")


# ---------------------------------------------------------------- S2
def s2_offset_family():
    print("S2  offset family: same m, f(m)=N preserved, mass moved far off the digits")
    N = rsa(44, 1)
    d = 3
    m = int(N ** (1.0 / 3))
    while m ** 3 >= N:
        m -= 1
    base = K.poly_from_m(N, m, d)
    m0 = K.mass(base)
    ok = True
    masses = []
    for j in (0, 1, 5, -3, 40, -40, 300, -300):
        c = K.poly_offset(N, m, d, j=j)
        if K.f_at_m(c, m) != N:
            ok = False
        masses.append(K.mass(c))
    check("offset family preserves f(m)=N", ok)
    check("offset family spans a wide mass range at fixed m",
          max(masses) > 10 * m0 and min(masses) > 0,
          f"digit mass {m0}, offset masses {masses}")
    return base, m


# ---------------------------------------------------------------- S3
def s3_irreducible():
    print("S3  cubic irreducibility check agrees with sympy (independent implementation)")
    from sympy import Poly, Symbol, factor_list
    x = Symbol('x')
    bad = 0
    tested = 0
    N = rsa(44, 2)
    m0 = int(N ** (1.0 / 3))
    while m0 ** 3 >= N:
        m0 -= 1
    for j in (0, 7, 61, 200, -50):
        for ch in (0, 3, 11, 101):
            c = K.poly_offset(N, m0, 3, j=j, dc2=ch)
            expr = sum(v * x ** i for i, v in enumerate(c))
            _, fac = factor_list(expr, x)
            sym_irred = (len(fac) == 1 and fac[0][1] == 1)
            mine = K.is_irreducible_cubic(c)
            tested += 1
            if sym_irred != mine:
                bad += 1
    check("my cubic test == sympy", bad == 0, f"{tested} polynomials, {bad} mismatches")
    # a known reducible case
    check("known reducible cubic detected",
          not K.is_irreducible_cubic([6, 5, 1, 1]))   # x^3+x^2+5x+6 = (x+1)(x^2+5x+6)?


# ---------------------------------------------------------------- S4
def s4_norm_bruteforce():
    print("S4  norm_values == brute force over ALL (a,b) in a small box")
    print("    (degenerate cells included: a=0, b=0, sign changes, |f|=0, |f|=1)")
    N = rsa(40, 3)
    d = 3
    m = int(N ** (1.0 / 3))
    while m ** d >= N:
        m -= 1
    c = K.poly_from_m(N, m, d)
    c = K.poly_offset(N, m, d, j=3)      # non-trivial coefficients
    B = 7
    aa, bb = [], []
    for a in range(-B, B + 1):           # EVERY pair, including 0 and both signs
        for b in range(-B, B + 1):
            aa.append(a)
            bb.append(b)
    a = np.array(aa, dtype=np.int64)
    b = np.array(bb, dtype=np.int64)
    got = K.norm_values(c, a, b)
    brute = []
    for ai, bi in zip(aa, bb):
        brute.append(sum(c[i] * (ai ** (d - i)) * (bi ** i) for i in range(d + 1)))
    same = all(int(got[i]) == brute[i] for i in range(len(brute)))
    check("vectorised norm == brute force on all (a,b)", same,
          f"{len(brute)} pairs")
    n_zero = sum(1 for v in brute if v == 0)
    check("box really contains degenerate f(a,b)=0 cells", n_zero >= 1,
          f"{n_zero} cells with |f|=0 (only (0,0) here, counted not skipped)")
    n_one = sum(1 for v in brute if abs(v) == 1)
    check("box really contains |f(a,b)|=1 cells", n_one >= 1, f"{n_one} such cells")
    # both arithmetic paths must agree
    o = K._norm_object(c, a, b)
    check("int64 path == object (bignum) path",
          all(int(o[i]) == int(got[i]) for i in range(len(brute))))


# ---------------------------------------------------------------- S5
def s5_smooth_exactness():
    print("S5  count_relations == shared dickman.is_smooth on EVERY cell of a box")
    N = rsa(40, 3)
    d = 3
    m = int(N ** (1.0 / 3))
    while m ** d >= N:
        m -= 1
    c = K.poly_offset(N, m, d, j=5)
    B = 40
    pairs = [(a, b) for a in range(-B, B + 1) for b in range(-B, B + 1)]
    a = np.array([p[0] for p in pairs], dtype=np.int64)
    b = np.array([p[1] for p in pairs], dtype=np.int64)
    res = K.count_relations(c, a, b, y=97, return_norms=True)
    mine = res["smooth"]
    theirs = []
    for i, (ai, bi) in enumerate(pairs):
        v = abs(int(res["norms"][i]))
        if v == 0:
            theirs.append(False)
        else:
            theirs.append(is_smooth(v, 97))
    disagree = sum(1 for i in range(len(pairs)) if bool(mine[i]) != bool(theirs[i]))
    check("exact relation counter == shared is_smooth", disagree == 0,
          f"{len(pairs)} cells, {disagree} disagreements, "
          f"{int(mine.sum())} smooth")
    check("counter found a non-trivial number of relations",
          3 <= int(mine.sum()) <= len(pairs) // 20,
          f"{int(mine.sum())} relations")
    check("zero cells counted separately, not silently dropped", res["n_zero"] == 1,
          f"n_zero={res['n_zero']}")


# ---------------------------------------------------------------- S6
def s6_r48_defect_and_null():
    print("S6  the round-48 counter is inverted, and my counter is not")
    import nfs_lattice as NL
    import run_c1_old as R
    N = rsa(40, 7)
    d = 3
    m = int(N ** (1.0 / 3))
    while m ** d >= N:
        m -= 1
    P = NL.make_poly(N, 3, m)
    fc = R.f_coeffs_of(P)               # LEADING-first, [c_d,...,c_0]
    # split_primes consumes fc as P(x) = sum_i fc[i] * x^i and returns its roots.
    # find_relations sieves norm(a,b) = sum_i fc[i] * a^(d-i) * b^i = a^d * P(b/a).
    # So p | norm  <=>  b/a is a root of P  <=>  b = alpha*a (mod p).
    # The code's mask is (a - alpha*b) % p == 0, i.e. a = alpha*b, the INVERSE
    # ratio.  Cells with a = alpha*b have b/a = alpha^{-1}, which is a root of P
    # only if P is self-reciprocal mod p -- which a generic cubic is not.
    Ppoly = list(fc)
    split = NL.split_primes(fc, 200)
    bad = good = 0
    for pp, roots in split.items():
        for r in roots:
            inv = pow(r, -1, pp) if r % pp else None
            if inv is not None and K.eval_poly(Ppoly, inv) % pp == 0:
                good += 1
            else:
                bad += 1
    check("S6a  r48 mask uses a/b where the sieved norm needs b/a (defect confirmed)",
          bad > 3 * max(good, 1) and bad > 20,
          f"{bad} roots whose INVERSE is not a root (mask selects cells with "
          f"p NOT dividing the norm) vs {good} where it happens to work")

    # quantify: true smooth rate vs what r48 reported
    Amax = Bmax = 300
    a = np.arange(-Amax, Amax, dtype=np.int64)
    b = np.arange(-Amax, Amax + 1, dtype=np.int64)
    A2, B2 = np.meshgrid(a, b, indexing='ij')
    A2 = A2.ravel()
    B2 = B2.ravel()
    mine = K.count_relations(list(fc), A2, B2, y=1000)   # c ascending: c[3]=1
    t0 = time.time()
    rels, tot, npr = R.find_relations(fc, 3, m, N, ymax=1000, Amax=Amax,
                                     Bmax=Amax, need=10 ** 9)
    dt = time.time() - t0
    my_rate = mine["n_smooth"] / mine["n_cells"]
    their_rate = len(rels) / (4 * Amax * Amax)
    check("S6b  r48 counter under-counts the true smooth rate",
          their_rate < 0.5 * my_rate,
          f"r48 {their_rate:.3e} vs true {my_rate:.3e}  ({my_rate/their_rate:.1f}x)")

    print("S7  NULL CONTROL -- a transformation that preserves mass AND the")
    print("    multiset of |f| must give the SAME rate")
    # There is no way to move mass independently of the multiset of |f| inside
    # this family: any coefficient change that alters the mass also alters the
    # values.  The honest null control is therefore the x -> -x isometry.
    #   f~(x) = -f(-x)   =>   f~(a,b) = -f(-a,b)   =>   |f~(a,b)| = |f(-a,b)|
    # It has the same mass and, over a box symmetric in a, the same multiset of
    # absolute norms, so the correct answer is "no difference".
    base_c = K.poly_from_m(N, m, d)
    flip = [(-v if i % 2 == 0 else v) for i, v in enumerate(base_c)]  # -f(-x)
    check("S7a  f~(x) = -f(-x) preserves the mass exactly",
          K.mass(flip) == K.mass(base_c),
          f"{K.mass(base_c)} vs {K.mass(flip)}")
    aa, bbx, _ = K.sample_box(m, 0.25, 120000, seed=99)
    ident = all(
        sum(flip[i] * (int(ai) ** (d - i)) * (int(bi) ** i) for i in range(d + 1))
        == sum(base_c[i] * ((-int(ai)) ** (d - i)) * (int(bi) ** i)
               for i in range(d + 1))
        for ai, bi in zip(aa[:600], bbx[:600]))
    check("S7b  f~(a,b) == f(-a,b) pointwise (so |f| multisets agree)", ident,
          "600 sampled cells")
    r1 = K.count_relations(base_c, aa, bbx, y=700)
    r2 = K.count_relations(flip, aa, bbx, y=700)
    n1, n2 = r1["n_smooth"], r2["n_smooth"]
    z = abs(n1 - n2) / math.sqrt(max(n1 + n2, 1))
    check("S7c  NULL RETURN: mass-preserving isometry gives no difference",
          z < 3.0, f"{n1} vs {n2} relations, {z:.2f} sigma")

    print("S8  NULL CONTROL -- same polynomial, two independent boxes")
    a1, b1, _ = K.sample_box(m, 0.25, 120000, seed=1)
    a2, b2, _ = K.sample_box(m, 0.25, 120000, seed=2)
    n1 = K.count_relations(base_c, a1, b1, y=700)["n_smooth"]
    n2 = K.count_relations(base_c, a2, b2, y=700)["n_smooth"]
    z = abs(n1 - n2) / math.sqrt(max(n1 + n2, 1))
    check("S8  harness noise floor: independent boxes agree", z < 3.0,
          f"{n1} vs {n2}, {z:.2f} sigma")


# ---------------------------------------------------------------- S9
def s9_smoothness_null():
    print("S9  smoothness null: measured Psi/rho factor (NOT recalled)")
    print("    a harness that cannot reproduce the random-integer null cannot")
    print("    be trusted when it reports a deviation on the algebraic side")
    for bits, y in ((44, 2 ** 9), (44, 2 ** 10), (44, 2 ** 11)):
        u = bits / math.log2(y)
        meas = K.smooth_rate_random_uniform(bits, y, 3000, seed=5)
        pred = rho(u)
        ratio = meas / pred if pred > 0 else float('inf')
        se = math.sqrt(max(meas * (1 - meas), 1e-15) / 3000)
        dev = abs(meas - pred) / (se + pred / math.sqrt(3000))
        print(f"    bits={bits} y=2^{int(math.log2(y))} u={u:.2f}: "
              f"measured {meas:.5f}  rho(u) {pred:.5f}  ratio {ratio:.2f}  "
              f"({dev:.1f} sigma from rho)")
        check(f"S9  u={u:.1f}: order-of-magnitude agreement with rho",
              0.3 < ratio < 30.0, f"Psi/rho = {ratio:.2f}")


def main():
    print("=" * 74)
    print("SELF-TEST -- polynomial selection axis (EE)")
    print("=" * 74)
    s1_poly_valid()
    s2_offset_family()
    s3_irreducible()
    s4_norm_bruteforce()
    s5_smooth_exactness()
    s6_r48_defect_and_null()
    s9_smoothness_null()
    print("=" * 74)
    if FAIL:
        print(f"!!! {len(FAIL)} FAILURE(S): {FAIL}")
        print("!!! do NOT report any rate measured with this harness.")
        return 1
    print("ALL SELF-TESTS PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())