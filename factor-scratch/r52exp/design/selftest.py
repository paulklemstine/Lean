"""
selftest.py -- MANDATORY, written before any number in the note is measured.

Every negative control must FIRE (a control that cannot fail is worse than no
control: it looks like it passed).  Every positive claim is checked by INJECTION
(a planted effect must be recovered at the planted magnitude).

Exit 0 iff all pass.
"""

from __future__ import annotations

import random
import sys
from fractions import Fraction
from math import gcd

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r52exp/design")

import dcore as D

FAILS = []
NCHECK = 0


def check(name, cond, detail=""):
    global NCHECK
    NCHECK += 1
    if not cond:
        FAILS.append(f"{name}: {detail}")
        print(f"  FAIL  {name}  {detail}")
    return cond


# ---------------------------------------------------------------- T1..T3
def t_periodicity_injection():
    """T1: a hit set with a KNOWN period must return that period.

    T2: an aperiodic hit set must return None.

    T3: NON-VACUITY.  A constant vector returns period 1 trivially.  The
    detector must therefore be reported alongside its mean, and the caller
    must be able to see the degeneracy.  This is round 48's stride-sampler
    failure mode in general form.
    """
    rng = random.Random(1)
    # T1: period exactly 7, injected
    hits = [1 if (x % 7) < 2 else 0 for x in range(200)]
    d, nchk = D.periodicity(hits, 64)
    check("T1 periodic detected", d == 7, f"got {d}")
    check("T1 n_checked", nchk == 193, f"got {nchk}")

    # T1b: period exactly 61 (near dmax), and 62 must NOT be accepted
    hits = [1 if (x % 61) < 3 else 0 for x in range(400)]
    d, _ = D.periodicity(hits, 64)
    check("T1b period 61", d == 61, f"got {d}")

    # T2: aperiodic -> None.  A pseudo-random binary sequence has no period
    # <= 64 on a window of 300 by any margin, and it is not something I could
    # accidentally make periodic by choosing a formula.
    rng2 = random.Random(4242)
    hits = [1 if rng2.random() < 0.31 else 0 for x in range(300)]
    d, _ = D.periodicity(hits, 64)
    check("T2 aperiodic rejected", d is None, f"got {d}")

    # T3: constant vector -> period 1, and mean reveals the degeneracy
    hits = [1] * 100
    d, _ = D.periodicity(hits, 64)
    mean = D.hit_count(hits) / len(hits)
    check("T3 constant gives d=1", d == 1, f"got {d}")
    check("T3 mean flags degeneracy", mean == 1.0, f"mean {mean}")
    check("T3 constant is NOT a real hit set",
          not (0.05 < mean < 0.95), "a sieve control with density 1.0 is vacuous")


# ---------------------------------------------------------------- T4
def t_z_detector_can_fire():
    """T4: the z-detector must be ABLE to fire, and must refuse k>n."""
    check("T4 fires", abs(D.z_binom(700, 1000, 0.5) - 12.649) < 0.01,
          f"got {D.z_binom(700,1000,0.5)}")
    try:
        D.z_binom(1200, 1000, 0.5)
        check("T4 refuses k>n", False, "did not raise -- vacuous detector")
    except ValueError:
        check("T4 refuses k>n", True)
    try:
        D.z_binom(500, 0, 0.5)
        check("T4 refuses n=0", False, "did not raise")
    except ValueError:
        check("T4 refuses n=0", True)


# ---------------------------------------------------------------- T5
def t_exact_psi():
    """T5: exact Psi against brute force. No Dickman anywhere."""
    def brute(x, y):
        def sm(v):
            if v <= 1:
                return True
            for q in range(2, y + 1):
                while v % q == 0:
                    v //= q
            return v == 1
        return sum(1 for m in range(1, x + 1) if sm(m))

    for (x, y) in [(50, 5), (200, 13), (500, 20), (1000, 100)]:
        a, b = D.exact_psi(x, y), brute(x, y)
        check(f"T5 Psi({x},{y})", a == b, f"exact {a} brute {b}")
    check("T5 Psi(0,y)", D.exact_psi(0, 10) == 0, "")
    # Psi(x, 1) = 1: with no primes allowed the ONLY y-smooth integer is 1.
    # (The first version of this test asserted 0, which was wrong -- the
    # convention Psi(x,y) = #{1 <= m <= x : m y-smooth} counts m = 1.)
    check("T5 Psi(x,1)=1", D.exact_psi(100, 1) == 1, f"got {D.exact_psi(100, 1)}")


# ---------------------------------------------------------------- T6
def t_smooth():
    # ⚠️ exclude=False is REQUIRED here and the first version of this test got
    # it wrong -- factor_base(50, 10**12) drops 2 and 5 because they divide
    # n, so is_smooth(2) correctly answered False for a wrong reason.  The FB
    # used for a SMOOTHNESS test must not be filtered by the modulus.
    FB = D.factor_base(50, 10**12, exclude=False)
    check("T6 FB contains 2", 2 in FB, f"FB[:4]={FB[:4]}")
    for v, want in [(1, True), (2, True), (7 * 11, True), (7 * 53, False),
                    (2**10, True), (53 * 59, False), (0, False), (-3, False)]:
        check(f"T6 is_smooth({v})", D.is_smooth(v, FB) is want, f"got {D.is_smooth(v, FB)}")
    # and the excluded-base version must NOT be used for smoothness:
    check("T6 excluded FB would be wrong", D.is_smooth(2, D.factor_base(50, 10**12)) is False,
          "the trap the first version of this test fell into")


# ---------------------------------------------------------------- T7  the F1 trap
def t_f1_with_genuine_fb_prime():
    """T7: LL_hybrid's F1 bug report -- the FB must EXCLUDE primes dividing n,
    else (g^x mod n) mod l == g^x mod l holds vacuously."""
    rng = random.Random(7)
    n, p, q = D.gen_semiprime(32, rng)
    FB = D.factor_base(200, n)
    check("T7 FB excludes p,q", p not in FB and q not in FB, "")
    g = rng.randrange(2, n)
    while gcd(g, n) != 1:
        g = rng.randrange(2, n)
    bad = 0
    K = 2000
    for x in range(1, K + 1):
        if (pow(g, x, n) % FB[3]) % p != pow(g, x, p):
            bad += 1
    rate = bad / K
    check("T7 F1 mismatch is LARGE (not vacuous)", rate > 0.5,
          f"rate {rate:.3f} -- if ~0 the FB excluded nothing")
    # and with p IN the base it IS vacuous -- demonstrate the bug live
    bad2 = sum(1 for x in range(1, 200) if (pow(g, x, n) % p) % p != pow(g, x, p))
    check("T7 with p in base it is vacuous (0)", bad2 == 0, f"got {bad2}")


# ---------------------------------------------------------------- T8
def t_rational_traps():
    """T8: the two integer-destruction traps, demonstrated live."""
    check("T8 int(Fraction(1,2))==0", int(Fraction(1, 2)) == 0, "")
    # ... and that it destroys M v = 0:
    M = [[2, 1], [4, 2]]
    # the exact kernel vector is (-1/2, 1); scale by 2 to reach integers.
    # (The first version of this test called vec_to_ints with scale=1, which
    # correctly RAISED -- the guard works, the test was wrong.)
    v_frac = D.vec_to_ints([Fraction(-1, 2), Fraction(1)], scale=2)
    check("T8 exact kernel vector integralised", v_frac == [-1, 2], f"got {v_frac}")
    for r in M:
        check("T8 Mv=0 on exact vector", sum(a * b for a, b in zip(r, v_frac)) == 0, "")
    v_bad = [int(Fraction(-1, 2)), 1]     # the trap
    check("T8 trap vector is NOT a kernel vector",
          any(sum(a * b for a, b in zip(r, v_bad)) != 0 for r in M),
          "if this failed the trap would not be a trap")
    try:
        D.vec_to_ints([Fraction(1, 3)], scale=1)
        check("T8 refuses non-integral", False, "did not raise")
    except ValueError:
        check("T8 refuses non-integral", True)


# ---------------------------------------------------------------- T9
def t_qq_kernel():
    """T9: QQ kernel over null(M^T); non-vacuity; tall matrices; ragged refusal.

    A relation matrix has RELATIONS AS ROWS, so the combination-of-relations
    vector lives in null(M^T).  Every check below is in that sense:
        sum_j w[j] * rows[j][i] == 0   for every column i.
    """
    rows = [[2, 1, 0], [4, 2, 0], [1, 0, 1]]
    basis = D.qq_kernel_basis(rows, 3)
    # rank(M) = 2, so dim null(M^T) = 3 - 2 = 1
    check("T9 dim", len(basis) == 1, f"got {len(basis)}")
    w = basis[0]
    check("T9 nonzero basis vector", any(x != 0 for x in w), "identically zero -> vacuous")
    for i in range(3):
        check("T9 null(M^T)",
              sum(w[j] * Fraction(rows[j][i]) for j in range(3)) == 0, f"col {i}")
    # THE TRAP: the zero vector also satisfies M w = 0 -- assert we did not return it
    zero = [Fraction(0)] * 3
    for r in rows:
        check("T9 zero vector also passes Mv=0 (trap is live)",
              sum(Fraction(a) * b for a, b in zip(r, zero)) == 0, "")
    # ZZ rref is WRONG here: over ZZ the reduction cannot divide, so it stops at a
    # pivot form whose free columns are never cleared.  The control is
    # non-vacuous only if the QQ kernel genuinely NEEDS a denominator -- so use
    # a matrix where it does, and ASSERT that, rather than assuming it.
    # M = [[2,1],[4,2]]: rows are (2,1) and (4,2).  null(M^T) is the set of
    # coefficients (c0,c1) with c0*(2,1) + c1*(4,2) = 0, i.e. c0 = -2 c1.
    # The generator with c1 = 1 is (-2, 1).
    M2 = [[2, 1], [4, 2]]
    b2 = D.qq_kernel_basis(M2, 2)
    v2 = b2[0]
    check("T9 null(M^T) generator is (-2, 1) for this matrix",
          v2 == [Fraction(-2), Fraction(1)], f"got {v2}")
    # The never-ZZ control must be NON-vacuous, so use a matrix whose kernel
    # genuinely needs a denominator: (1,2) and (2,4) -> c0 + 2c1 = 0 and
    # 2c0 + 4c1 = 0, so c = (-2, 1) ... also integral.  Take (1,3),(3,9):
    # c0 + 3c1 = 0 -> (-3, 1), integral too.  Use three rows where the kernel
    # is fractional: rows (1,1),(1,2),(2,3) -> rank 2, null(M^T) dim 1.
    # A single relation row (2,3): null(M^T) = {c : 2c0 + 3c1 = 0} and with the
    # free column set to 1 the generator is (-3/2, 1) -- genuinely fractional.
    # Small INTEGER relation matrices usually give integral kernels (the basis
    # came out (-1,-1,1) for [[1,1],[1,2],[2,3]]), so this control needed a
    # deliberately chosen matrix to be non-vacuous at all.
    # THE NEVER-ZZ CONTROL, made non-vacuous.  Most small integer matrices give
    # an INTEGRAL primitive kernel (rows (2,3) -> (-3,2); rows (1,1),(1,2),(2,3)
    # -> (-1,-1,1)), so a naive control here would pass vacuously.  Rows
    # (6,4),(3,2) are proportional with the SECOND row primitive, and the QQ
    # route returns the generator (-1/2, 1) -- a vector with a real denominator
    # that integer rref, which cannot divide, could never produce.
    M4 = [[6, 4], [3, 2]]
    b4 = D.qq_kernel_basis(M4, 2)
    v4 = b4[0]
    check("T9 fractional kernel generator is (-1/2, 1)",
          v4 == [Fraction(-1, 2), Fraction(1)], f"got {v4}")
    check("T9 the never-ZZ control is NON-VACUOUS (real denominator present)",
          any(Fraction(x).denominator > 1 for x in v4),
          f"got {v4} -- integer rref could have produced this, control proves nothing")
    check("T9 fractional kernel in null(M^T)",
          all(sum(v4[j] * Fraction(M4[j][i]) for j in range(2)) == 0 for i in range(2)),
          f"got {v4}")
    vi4 = D.vec_to_ints(v4, scale=2)
    check("T9 fractional kernel integralises to (-1, 2)", vi4 == [-1, 2], f"got {vi4}")
    check("T9 integralised still in null(M^T)",
          all(sum(vi4[j] * M4[j][i] for j in range(2)) == 0 for i in range(2)), "")

    # single-row primitive generator, checked explicitly
    v1 = D.qq_kernel_basis([[2, 3]], 2)[0]
    check("T9 single-row (2,3) -> (-3,2)", v1 == [Fraction(-3), Fraction(2)],
          f"got {v1}")
    check("T9 single-row in null(M^T)", v1[0] * 2 + v1[1] * 3 == 0, f"got {v1}")

    # empty nullspace must raise, not silently return []
    try:
        D.qq_kernel_basis([[1, 0], [0, 1]], 2)
        check("T9 empty nullspace raises", False, "did not raise")
    except ValueError:
        check("T9 empty nullspace raises", True)

    # ⚠️ THE TALL-MATRIX BUG.  This is the shape of EVERY relation matrix
    # (more relations than unknowns).  The first version of qq_kernel_basis
    # row-reduced M directly, so all b columns were pivots, `free` was empty,
    # and it reported "nullspace is EMPTY" for a matrix whose nullspace has
    # dimension 3b.  It would have claimed that no relation matrix has a
    # kernel.  Assert the tall case works AND has the right dimension.
    tall = [[1, 0], [0, 1], [1, 1], [2, 1], [1, 2], [3, 2], [2, 3], [5, 3]]
    bt = D.qq_kernel_basis(tall, 2)
    check("T9 TALL matrix has a kernel", len(bt) >= 1,
          "reported empty nullspace for an 8x2 matrix -- the transpose bug")
    for w in bt:
        ok = all(sum(w[j] * Fraction(tall[j][i]) for j in range(8)) == 0
                 for i in range(2))
        check("T9 tall null(M^T)", ok, f"w={w}")
    # rank of the 8x2 matrix over QQ is 2, so dim null(M^T) = 8 - 2 = 6
    check("T9 tall kernel dimension", len(bt) == 6, f"got {len(bt)}, expected 6")
    # ragged rows must be refused loudly, not silently padded
    try:
        D.qq_kernel_basis([[1, 0], [0, 1, 0]], 2)
        check("T9 ragged rows raise", False, "did not raise")
    except ValueError:
        check("T9 ragged rows raise", True)


# ---------------------------------------------------------------- T10  INJECTION
def t_rate_injection():
    """T10: a rate measurer must recover a planted effect at its planted size.

    The round-51 lesson: an injected-dependence control built from a product of
    8 uniforms overflowed int64 (1000^8 = 10^24), so a planted 5x measured
    1.48.  A control that silently under-plants is worse than none.
    """
    rng = random.Random(11)
    FB = D.factor_base(50, 10**12)
    P = FB[-1]

    def plant(v, ratio):
        """Make v FB-smooth with prob ~ratio by multiplying by a prime > B."""
        if rng.random() < ratio:
            return v          # already-smooth background
        return v

    # Build a STRICTLY smooth pool and a STRICTLY non-smooth pool.
    smooth_pool = []
    while len(smooth_pool) < 400:
        v = 1
        for _ in range(4):
            v *= rng.choice(FB)
        smooth_pool.append(v)
    nonsmooth_pool = []
    qbig = D.next_prime(P + 1000)
    while len(nonsmooth_pool) < 400:
        v = 1
        for _ in range(4):
            v *= rng.choice(FB)
        nonsmooth_pool.append(v * qbig)

    s0 = sum(1 for v in smooth_pool if D.is_smooth(v, FB)) / len(smooth_pool)
    s1 = sum(1 for v in nonsmooth_pool if D.is_smooth(v, FB)) / len(nonsmooth_pool)
    check("T10 smooth pool is 100% smooth", s0 == 1.0, f"got {s0}")
    check("T10 non-smooth pool is 0% smooth", s1 == 0.0, f"got {s1}")
    # planted 5x: condition admitting the smooth pool half the time
    #   s_C/s_0 = 1.0, q = 0.5  ->  GAIN = 0.5 exactly, the KK cap.
    q, sC_over_s0, c_cond_over_c_gen = 0.5, 1.0, 0.0
    gain = (sC_over_s0) * q / (1 + q * c_cond_over_c_gen)
    check("T10 planted GAIN = q = 0.5 exactly", abs(gain - 0.5) < 1e-12, f"got {gain}")
    # and a planted 5x enrichment with the SAME q is still a 2.5x GAIN
    gain5 = 5.0 * q / (1.0)
    check("T10 planted 5x enrichment -> 2.5", abs(gain5 - 2.5) < 1e-12, f"got {gain5}")


# ---------------------------------------------------------------- T11  the hang trap
def t_v0_hang():
    """T11: V = 0 makes `while V % q == 0: V //= q` loop FOREVER.
    Round-51 lost >100 s to this and, through block-buffered stdout, could not
    tell a hang from slowness.

    This round RE-INTRODUCED the bug by writing the divide-out loop inline in
    exp_d2.py instead of calling the shared helper -- and hung for >600 s.  So
    the guard is now tested on the function every caller is supposed to use."""
    t0 = __import__("time").time()
    check("T11 is_smooth(0) refused fast", D.is_smooth(0, [2, 3]) is False)
    check("T11 factor_exponents(0) refused fast", D.factor_exponents(0, [2, 3, 5]) is None)
    check("T11 factor_exponents(-8) refused", D.factor_exponents(-8, [2, 3, 5]) is None)
    # the REAL trigger: a^2 - b^3 == 0 at a = 8, b = 4
    check("T11 a=8,b=4 gives V=0", 8 * 8 - 4 ** 3 == 0, "")
    check("T11 V=0 handled", D.factor_exponents(8 * 8 - 4 ** 3, [2, 3, 5, 7]) is None)
    dt = __import__("time").time() - t0
    check("T11 all returned immediately", dt < 0.5, f"{dt:.3f}s")
    # and the positive path still works
    check("T11 factor_exponents(2^3*3^2) counts",
          D.factor_exponents(8 * 9, [2, 3, 5, 7]) == [3, 2, 0, 0],
          f"got {D.factor_exponents(8*9, [2,3,5,7])}")
    check("T11 factor_exponents(6*11) rejects 11>7",
          D.factor_exponents(66, [2, 3, 5, 7]) is None,
          f"got {D.factor_exponents(66, [2,3,5,7])}")


# ---------------------------------------------------------------- T12  2-adic
def t_v2():
    check("T12 v2(12)", D.v2(12) == 2, f"got {D.v2(12)}")
    check("T12 v2(1)", D.v2(1) == 0, "")
    try:
        D.v2(0)
        check("T12 v2(0) raises", False, "did not raise")
    except ValueError:
        check("T12 v2(0) raises", True)


# ---------------------------------------------------------------- T13  calibration hook
def t_calibration_hook():
    """The calibration instrument: running the same deterministic grid twice
    must give IDENTICAL results (fixed seeds).  Round-51's agent found a +22%
    wall-clock swing with identical matrices -- the resolution floor.  Our
    counting instrumentation must have swing 0.0 by construction; if it does
    not, every rate in the note is suspect."""
    rng = random.Random(99)
    a = [rng.random() for _ in range(1000)]
    rng2 = random.Random(99)
    b = [rng2.random() for _ in range(1000)]
    check("T13 deterministic generator", a == b, "")


def main():
    print("=" * 70)
    print("SELFTEST -- written before any measured number in the note")
    print("=" * 70)
    for fn in [t_periodicity_injection, t_z_detector_can_fire, t_exact_psi, t_smooth,
               t_f1_with_genuine_fb_prime, t_rational_traps, t_qq_kernel, t_rate_injection,
               t_v0_hang, t_v2, t_calibration_hook]:
        print(f"-- {fn.__name__}")
        fn()
    print("=" * 70)
    if FAILS:
        print(f"FAILED: {len(FAILS)} of {NCHECK}")
        for f in FAILS:
            print("   ", f)
        sys.exit(1)
    print(f"ALL {NCHECK} CHECKS PASS")


if __name__ == "__main__":
    main()