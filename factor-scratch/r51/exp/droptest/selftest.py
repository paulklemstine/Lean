"""
Self-test for the drop-in test.  EVERY check that could pass vacuously has a
matching NEGATIVE control that must FAIL.

The project's standing lesson (see MM_sparse §3 and round 48) is that a
null-space routine can return the correct rank and the correct dimension and
still return the WRONG VECTORS.  A rank check passes all of those bugs.  So the
primary assertion here is not "does the route work" but "does the route's own
correctness detector reject a corrupted answer".
"""
from __future__ import annotations

import math
import random
import sys
from fractions import Fraction

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r51/exp/droptest")
import dtcore as D  # noqa: E402

FAIL = []


def check(name, cond, msg=""):
    if cond:
        print(f"  PASS  {name}")
    else:
        print(f"  FAIL  {name}  {msg}")
        FAIL.append(name)


def expect_raises(name, fn, exc=Exception):
    """A control that MUST raise.  If it does not, the real check it guards is
    vacuous -- exactly the failure this project has recorded repeatedly."""
    try:
        fn()
    except exc:
        print(f"  PASS  {name} (control fired)")
        return True
    print(f"  FAIL  {name} -- control did NOT fire: the guarded check is VACUOUS")
    FAIL.append(name)
    return False


def rand_matrix(b, ncols, rng, rank_target=None):
    """A random integer matrix with a KNOWN, INJECTED dependence of dimension d."""
    A = [[0] * ncols for _ in range(b)]
    for i in range(b):
        for _ in range(rng.randrange(1, 4)):
            j = rng.randrange(ncols)
            A[i][j] += rng.randrange(1, 9)
    d = 1 if rank_target is None else rank_target
    # INJECT d known dependencies: for each, pick d columns, and force the
    # dependence by writing the last one's entries as the difference.
    for t in range(d):
        js = rng.sample(range(ncols), d + 1)
        for i in range(b):
            A[i][js[-1]] = sum(A[i][j] for j in js[:-1]) % 7
    return A


def inject_dependence(A, w):
    """Rewrite column j* of A so that A w = 0 EXACTLY, with INTEGER entries.

    Requires w[j*] == -1 and every other w[j] an integer, so that
        A[:, j*] := -sum_{j != j*} A[:, j] * w[j] / w[j*]
    stays integral.  Returns the modified matrix.

    ⚠️ My first version tried to do this by fixing ONE row and got the algebra
    wrong (setting A[0][j] = -sum_i A[i][j] w[j] does NOT give
    sum_j A[0][j] w[j] = -S when w has several nonzero entries).  The exact
    assertion caught it immediately.  The correct construction is a COLUMN
    relation, which makes every row orthogonal to w at once.
    """
    nc = len(A[0])
    supp = [j for j in range(nc) if w[j] != 0]
    assert len(supp) >= 2, "need at least two nonzeros for a real dependence"
    jstar = [j for j in supp if w[j] == -1]
    assert jstar, "w must have a -1 entry for the integer construction"
    jstar = jstar[0]
    others = [j for j in supp if j != jstar]
    B = [r[:] for r in A]
    for i in range(len(A)):
        B[i][jstar] = sum(B[i][j] * w[j] for j in others)
    return B


def main():
    rng = random.Random(20260903)
    print("=" * 78)
    print("ST1 -- the M v = 0 detector REJECTS wrong vectors (negative control)")
    print("=" * 78)
    n, p, q = D.stange.gen_semiprime(30, rng)
    g = D.rand_g(n, rng)
    rels, _ = D.make_relations(n, g, 16, 1, rng, "seq")
    M = D.build_M(rels, 16)
    res = D.kernel_dense_DM(M)
    basis = res["basis"]
    check("ST1a a real kernel exists", len(basis) >= 1, f"dim={len(basis)}")

    good = [D.to_frac(x) for x in basis[0]]
    D.assert_Mv_zero(M, good)
    check("ST1b true vector accepted", True)

    # negative control 1: perturb one entry
    bad = list(good)
    bad[0] = bad[0] + 1
    expect_raises("ST1c control: one-entry perturbation",
                  lambda: D.assert_Mv_zero(M, bad), AssertionError)
    # negative control 2: truncated
    expect_raises("ST1d control: truncated vector",
                  lambda: D.assert_Mv_zero(M, good[:-1]), AssertionError)
    # negative control 3: a DIFFERENT genuine kernel vector.  Each copy
    # individually IS in the kernel, so only the multiplicity check can
    # catch it -- this is why dimension must be checked too.
    if len(basis) >= 2:
        dup = [D.to_frac(x) for x in basis[1]]
        D.assert_Mv_zero(M, dup)
        check("ST1e two independent vectors each individually valid", True)
        # scaling a vector leaves it in the kernel: catches nothing by itself
        D.assert_Mv_zero(M, [2 * x for x in dup])
        check("ST1f scaling preserves membership (so membership != identity)",
              True)

    print()
    print("=" * 78)
    print("ST2 -- INJECTED dependence is found, and routes AGREE on dimension")
    print("=" * 78)
    ok_agree = True
    found = []
    dm_skipped = 0
    for trial in range(12):
        b = rng.randrange(5, 14)
        nc = b + 1
        A = rand_matrix(b, nc, rng)
        # DM leaks floats on rank-deficient matrices (ST6), so it is excluded
        # here; the benchmark in exp_D2 only runs DM on REAL Stange matrices,
        # where the leak was measured absent (0/4) and is checked per-matrix.
        try:
            r1 = D.kernel_dense_DM(A, "tDM")
            d1 = r1["dim"]
        except TypeError:
            d1 = None
            dm_skipped += 1
        r2 = D.kernel_dense_F(A, "tF")
        r3 = D.kernel_sparse_Q(A, "tSQ")
        ds = [x for x in (d1, r2["dim"], r3["dim"]) if x is not None]
        if len(set(ds)) != 1:
            ok_agree = False
            print(f"    mismatch trial {trial}: {ds}")
        found.append(r2["dim"])
    check("ST2a exact routes agree on dimension, 12 random matrices",
          ok_agree, str(found))
    check("ST2b at least one trial had dim >= 1 (not all trivial)",
          max(found) >= 1, str(found))
    print(f"    (DM skipped on {dm_skipped}/12 rank-deficient matrices: float leak)")

    print()
    print("=" * 78)
    print("ST3 -- the detector is not vacuous: INJECT a dependence MIGHT miss")
    print("=" * 78)
    # Build A with a guaranteed kernel vector w (nonzero, chosen first), then
    # CORRUPT one row so the dependence is destroyed.  The routes must now
    # report the dependence is GONE (dimension drops).  If dimension does not
    # change, the route is insensitive to the data and the measurement is a
    # pigeonhole.
    # SQUARE, so that nullity is 0 generically.  My first version used b=12,
    # nc=14, where nullity >= 2 ALWAYS (nc - b = 2), so the injected dependence
    # was invisible in the dimension and the negative control below was
    # unfalsifiable -- dim read 2 before and 2 after, for the trivial reason.
    # A self-test that cannot fail is not a self-test.
    b = 12
    nc = 12
    w = [0] * nc
    w[0], w[3], w[7] = 1, 2, -1
    A0 = [[0] * nc for _ in range(b)]
    for i in range(b):
        for j in range(nc):
            A0[i][j] = rng.randrange(-5, 6)
    A = inject_dependence(A0, w)
    D.assert_Mv_zero(A, w)
    check("ST3a injected w really satisfies A w = 0", True)
    d_base = D.kernel_dense_F(A0, "base")["dim"]
    check("ST3b BEFORE injection the square matrix is generically non-singular",
          d_base == 0, f"dim={d_base}")
    d_before = D.kernel_dense_F(A, "inj")["dim"]
    check("ST3c injected dependence is DETECTED (dim >= 1)", d_before >= 1,
          f"dim={d_before}")

    A2 = [r[:] for r in A]
    A2[0] = [x + 1 for x in A2[0]]           # break the column relation
    d_after = D.kernel_dense_F(A2, "inj2")["dim"]
    check("ST3d NEGATIVE control: breaking the row REMOVES the dependence",
          d_after == d_before - 1,
          f"dim before={d_before} after={d_after} (expected {d_before-1})")

    # And the sparse route must see the same injected dependence.
    d_sp = D.kernel_sparse_Q(A, "injSQ")["dim"]
    check("ST3e sparse route detects the same injected dimension",
          d_sp == d_before, f"{d_sp} vs {d_before}")
    d_sp2 = D.kernel_sparse_Q(A2, "injSQ2")["dim"]
    check("ST3f sparse route also loses it when broken",
          d_sp2 == d_after, f"{d_sp2} vs {d_after}")

    print()
    print("=" * 78)
    print("ST4 -- rref must be over QQ, not ZZ (MM_sparse §4 trap)")
    print("=" * 78)
    from sympy import ZZ, QQ
    from sympy.polys.matrices import DomainMatrix as _DM2

    # ⚠️ HONEST RESULT: the trap as RECORDED does NOT reproduce in this
    # environment.  MM_sparse §4 reports that sympy's DomainMatrix.rref() over
    # ZZ leaves free columns uncleared, and its own 4x5 example was used to
    # show it.  On sympy 1.13.1 that example gives IDENTICAL ZZ and QQ output,
    # and a 3000-case random search for ANY (matrix, free column) where the ZZ
    # form differs from the QQ form found ZERO.  So I cannot re-demonstrate
    # that specific claim here, and I do not repeat it as fact.
    #
    # What that does and does not license: it is a reason to PREFER QQ and not
    # a reason to rely on the trap as an active hazard on this version.  The
    # route below therefore tests the guarantee that actually matters -- that
    # the pivot/free-column extraction is self-consistent and exact -- rather
    # than asserting a library bug I could not reproduce.
    Ex = [[1, 2, 3, 4, 5], [2, 4, 6, 8, 10], [1, 1, 1, 1, 1], [3, 3, 3, 3, 3]]
    Zz = _DM2(Ex, (4, 5), ZZ).rref()[0].to_list()
    Qq = _DM2(Ex, (4, 5), QQ).rref()[0].to_list()
    same = all(str(Zz[i][j]) == str(Qq[i][j]) for i in range(4) for j in range(5))
    print(f"    ZZ vs QQ rref on the recorded example: "
          f"{'IDENTICAL (trap does not reproduce here)' if same else 'DIFFER'}")
    check("ST4a recorded ZZ trap NOT reproducible on sympy 1.13.1 "
          "(reported, not asserted)", True)

    # The guarantee that matters: on 40 random matrices of many ranks, the
    # QQ-rref kernel extraction is EXACT and its dimension matches two
    # independent Fraction-based routes.
    okx = True
    dims = []
    for _ in range(40):
        m = rng.randrange(3, 8)
        nc = m + rng.randrange(0, 3)
        A = [[rng.randrange(-5, 6) for _ in range(nc)] for _ in range(m)]
        try:
            rr = D.kernel_dense_DM(A, "zzQQ")
        except TypeError:
            continue                      # float leak (ST6), not a ZZ issue
        rf = D.kernel_dense_F(A, "zzF")
        rs = D.kernel_sparse_Q(A, "zzSQ")
        if not (rr["dim"] == rf["dim"] == rs["dim"]):
            okx = False
        dims.append(rr["dim"])
    check("ST4b QQ-rref, Fraction and sparse routes agree on 40 random matrices",
          okx, str(sorted(set(dims))))
    check("ST4c the sweep covered a range of dimensions (not all one value)",
          len(set(dims)) >= 2, str(sorted(set(dims))))

    print()
    print("=" * 78)
    print("ST5 -- the defect detector is not vacuous")
    print("=" * 78)
    st = D.incidence(M)
    check("ST5a defect > 0 on a real Stange matrix", st["defect"] > 0)
    d0, dl = D.defect_under_permutations(M, trials=10, rng=rng)
    check("ST5b defect invariant under 10 row+col permutations",
          all(x == d0 for x in dl), f"{d0} vs {dl}")
    # negative control: the DETECTOR must be able to SEE a different defect.
    # A dense control matrix has defect = ncols, so the invariance claim is not
    # an artifact of always returning the same number.
    Dn = [[1] * len(M[0]) for _ in range(len(M))]
    stn = D.incidence(Dn)
    check("ST5c NEGATIVE control: a dense matrix has a DIFFERENT (larger) defect",
          stn["defect"] != d0, f"dense={stn['defect']} stange={d0}")
    dn_inv, _ = D.defect_under_permutations(Dn, trials=5, rng=rng)
    check("ST5d dense matrix also permutation-invariant",
          dn_inv == stn["defect"])

    print()
    print("=" * 78)
    print("ST6 -- the FLOAT leak from sympy's QQ rref, and its strict handling")
    print("=" * 78)
    from sympy import QQ as _QQ
    from sympy.polys.matrices import DomainMatrix as _DM
    # Prove the leak is REAL, on rank-deficient integer matrices.
    nleak = 0
    for _ in range(20):
        b = rng.randrange(5, 14)
        Ad = rand_matrix(b, b + 1, rng)
        Lz = _DM(Ad, (b, b + 1), _QQ).rref()[0].to_list()
        if any(isinstance(x, float) for row in Lz for x in row):
            nleak += 1
    check("ST6a QQ rref leaks python floats on rank-deficient matrices",
          nleak >= 15, f"{nleak}/20 leaked")
    # The leaked values are NOT all 1.0 -- genuine rounding error is present.
    # Find one and show it is not exactly representable.
    found_bad = None
    for _ in range(50):
        b = rng.randrange(5, 14)
        Ad = rand_matrix(b, b + 1, rng)
        Lz = _DM(Ad, (b, b + 1), _QQ).rref()[0].to_list()
        for row in Lz:
            for x in row:
                if isinstance(x, float) and x != 1.0 and x != 0.0:
                    found_bad = x
                    break
            if found_bad is not None:
                break
        if found_bad is not None:
            break
    check("ST6b a leaked float carries REAL rounding error (not just 1.0)",
          found_bad is not None, f"found {found_bad!r}")
    # STRICT handling: any float in an exact route is rejected.
    expect_raises("ST6c control: to_frac rejects a float",
                  lambda: D.to_frac(0.5), TypeError)
    expect_raises("ST6d control: assert_Mv_zero rejects a float component",
                  lambda: D.assert_Mv_zero([[1, 1]], [1.0, 1.0]), (TypeError,
                                                                    AssertionError))
    expect_raises("ST6e control: an INEXACT float entry is REJECTED",
                  lambda: D.assert_Mv_zero([[3, 3]], [float(1 / 3), 0.0]),
                  (AssertionError, TypeError))
    # And the pure-Fraction routes are immune: they never touch that library.
    k = D.kernel_dense_F([[1, 1, 1]], "k")["basis"][0]
    check("ST6f a Fraction-only route produces exact rational entries",
          all(isinstance(x, Fraction) for x in k))
    check("ST6g Fraction and int accepted unchanged",
          D.to_frac(Fraction(1, 2)) == Fraction(1, 2) and D.to_frac(3) == Fraction(3))
    # The full 2x2 cross-check: routes agree where DM does not leak.
    ok = True
    for _ in range(10):
        b = rng.randrange(5, 12)
        Ad = rand_matrix(b, b + 1, rng)
        r1 = D.kernel_dense_F(Ad, "xF")
        r3 = D.kernel_sparse_Q(Ad, "xSQ")
        if r1["dim"] != r3["dim"]:
            ok = False
    check("ST6h Fraction and sparse-dict routes agree on 10 more matrices", ok)

    print()
    print("=" * 78)
    print("ST7 -- the 2-adic control: p_split is exact, not the 20/27 average")
    print("=" * 78)
    # known average over moduli is 20/27; a single modulus must NOT be 20/27
    vals = []
    for _ in range(400):
        nn, pp, qq = D.stange.gen_semiprime(24, rng)
        ps, mp_, mq_ = D.p_split(pp, qq)
        vals.append(ps)
    mean = sum(vals) / len(vals)
    check("ST7a mean p_split over 400 moduli ~ 20/27 = 0.7407",
          abs(mean - 20 / 27) < 0.03, f"mean={mean:.4f}")
    check("ST7b individual moduli VARY (never report the average)",
          max(vals) - min(vals) > 0.3, f"min={min(vals):.3f} max={max(vals):.3f}")
    # normalization: P(split) + P(same) = 1
    nn, pp, qq = D.stange.gen_semiprime(24, rng)
    ps, mp_, mq_ = D.p_split(pp, qq)
    check("ST7c p_split in [0,1]", 0.0 <= ps <= 1.0, f"{ps}")
    # Monte-Carlo confirmation of one modulus's p_split, at the SIZE the
    # control is actually used at (2^30 moduli, not 2^20).
    nn, pp, qq = D.stange.gen_semiprime(30, rng)
    ps, mp_, mq_ = D.p_split(pp, qq)
    hits = tot = 0
    for _ in range(3000):
        gg = D.rand_g(nn, rng)
        hits += (D.v2(D.stange.n_order(gg, pp))
                 != D.v2(D.stange.n_order(gg, qq)))
        tot += 1
    mc = hits / tot
    check("ST7d Monte-Carlo p_split agrees with the closed form (2^30 modulus)",
          abs(mc - ps) < 0.05, f"MC={mc:.4f} formula={ps:.4f} "
                               f"(v2(p-1)={mp_}, v2(q-1)={mq_})")
    # The baseline must be verified against REAL primes across v2 patterns,
    # not just one modulus: the whole control rests on it being right.
    from sympy import nextprime
    rs = random.Random(1234)
    ok7 = True
    det = []
    for _ in range(3):
        pbig = int(nextprime(rs.randrange(10 ** 6, 2 * 10 ** 6))) | 1
        qbig = int(nextprime(rs.randrange(2 * 10 ** 6, 4 * 10 ** 6))) | 1
        if pbig == qbig:
            continue
        frm, _, _ = D.p_split(pbig, qbig)
        h = t = 0
        for _ in range(1500):
            gbig = D.rand_g(pbig * qbig, rs)
            h += (D.v2(D.stange.n_order(gbig, pbig))
                  != D.v2(D.stange.n_order(gbig, qbig)))
            t += 1
        det.append((frm, h / t))
        if abs(h / t - frm) > 0.05:
            ok7 = False
    check("ST7e p_split closed form verified on 3 large random prime pairs",
          ok7 and len(det) == 3, str([(round(a, 4), round(b, 4)) for a, b in det]))

    print()
    print("=" * 78)
    print("ST8 -- the black-box route's T-power reconstruction")
    print("=" * 78)
    nb = 0
    tot_b = 0
    for trial in range(6):
        nn2 = n
        rels2, _ = D.make_relations(nn2, D.rand_g(nn2, rng), 14, 1, rng, "seq")
        M2 = D.build_M(rels2, 14)
        tot_b += 1
        if D.blackbox_kernel(M2) is not None:
            nb += 1
    check("ST8a black-box returns a VERIFIED kernel vector", nb >= 5,
          f"{nb}/{tot_b}")
    # negative control: the WRONG (undivided) reconstruction must be rejected.
    # Demonstrate directly on one matrix by rebuilding w with power[jj+1].
    rels2, _ = D.make_relations(n, D.rand_g(n, rng), 14, 1, rng, "seq")
    M2 = D.build_M(rels2, 14)
    rd = [dict((j, int(x)) for j, x in enumerate(r) if x) for r in M2]
    pr_ = D.PRIMES[0]
    r2 = random.Random(4242)
    v = [r2.randrange(1, pr_) for _ in range(len(M2[0]))]
    power = [v]
    cur = v
    for _ in range(len(M2) + 1):
        t1, _ = D._spmv_dict(rd, cur, pr_)
        t2, _ = D._spmv_dict_T(rd, t1, pr_, len(M2[0]))
        power.append(t2)
        cur = t2
    L = len(power) - 1
    A = [[power[j][i] % pr_ for j in range(1, L + 1)] for i in range(len(M2[0]))]
    Lam = D._dense_null_vec_modp(A, pr_)
    check("ST8b a dependence was found (Lam is not None)", Lam is not None)
    if Lam:
        # ⚠️ MECHANISM CORRECTED.  I first asserted that the UNDIVIDED
        # reconstruction would produce a WRONG NONZERO vector, and the control
        # correctly refused to fire.  The truth is more interesting and more
        # dangerous:
        #   sum_{j=1..L} lam_j T^j v  IS the dependence equation, so it is
        #   IDENTICALLY ZERO -- the trivial answer.  And because T = M^T M
        #   satisfies M T = M M^T M, any T-multiple of a kernel vector is again
        #   a kernel vector, so the zero vector "passes" M w = 0 mod p.
        # So an undivided reconstruction is NOT caught by a membership check
        # at all: it is rejected only by the separate all-zero test, which is
        # why my first version of the route returned None on every candidate.
        # This is the concrete sense in which a kernel routine can pass its
        # own correctness test and still be useless.
        w_wrong = [0] * len(M2[0])
        for jj, lj in enumerate(Lam):
            if lj:
                for i in range(len(M2[0])):
                    w_wrong[i] = (w_wrong[i] + lj * power[jj + 1][i]) % pr_
        check("ST8c UNDIVIDED reconstruction is IDENTICALLY ZERO "
              "(so membership alone would NOT catch it)",
              all(x == 0 for x in w_wrong))
        D.assert_Mv_zero_mod(M2, w_wrong, pr_)
        check("ST8d ...and a membership check ACCEPTS it anyway -> vacuous",
              True)
        expect_raises("ST8e control: only the all-zero test rejects it",
                      lambda: (_ for _ in ()).throw(AssertionError("zero"))
                      if all(x == 0 for x in w_wrong) else None,
                      AssertionError)
        # RIGHT: divide out one power of T -> a genuine NONZERO kernel vector
        w_right = [0] * len(M2[0])
        for jj, lj in enumerate(Lam):
            if lj:
                for i in range(len(M2[0])):
                    w_right[i] = (w_right[i] + lj * power[jj][i]) % pr_
        check("ST8f CORRECT (divided) reconstruction is NONZERO",
              any(x != 0 for x in w_right))
        D.assert_Mv_zero_mod(M2, w_right, pr_)
        check("ST8g CORRECT (divided) reconstruction is ACCEPTED", True)

    print()
    print("=" * 78)
    print("ST10 -- the RECOMMENDED backend (DM) is equivalent to the incumbent (F)")
    print("=" * 78)
    # §2.1 recommends swapping sympy's QQ rref in for r50's Fraction
    # Gauss-Jordan. That recommendation is only sound if the two compute the
    # SAME thing, so pin it on REAL Stange matrices (the synthetic ones skip DM
    # because of the float leak, ST6).
    agree = tot = 0
    dims = set()
    for bits in (30, 40):
        for b in (26, 40, 52):
            for s in range(2):
                rng2 = random.Random(771000 + s * 31 + b + bits)
                nn, pp, qq = D.stange.gen_semiprime(bits, rng2)
                gg = D.rand_g(nn, rng2)
                rels2, _ = D.make_relations(nn, gg, b, 1, rng2, "seq")
                M2 = D.build_M(rels2, b)
                d1 = D.kernel_dense_DM(M2, "st10DM")
                d2 = D.kernel_dense_F(M2, "st10F")
                tot += 1
                if d1["dim"] == d2["dim"] and d1["rank"] == d2["rank"]:
                    agree += 1
                dims.add(d1["dim"])
    check("ST10a DM and F agree on dim AND rank on real Stange matrices",
          agree == tot and tot >= 12, f"{agree}/{tot} cells, dims seen {sorted(dims)}")
    check("ST10b the sweep covered >1 dimension (not a degenerate all-equal case)",
          len(dims) >= 2, str(sorted(dims)))

    print()
    print("=" * 78)
    print("ST9 -- degenerate shapes")
    print("=" * 78)
    Z = [[0, 0, 0], [0, 0, 0]]
    r = D.kernel_dense_DM(Z, "zero")
    check("ST9a all-zero matrix -> FULL kernel (dim == ncols)",
          r["dim"] == 3, f"dim={r['dim']}")
    for v in r["basis"]:
        D.assert_Mv_zero(Z, v)
    I4 = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
    r = D.kernel_dense_DM(I4, "ident")
    check("ST9b identity -> EMPTY kernel", r["dim"] == 0, f"dim={r['dim']}")

    print()
    print("=" * 78)
    if FAIL:
        print(f"*** {len(FAIL)} FAILURES: {FAIL}")
        return 1
    print("ALL PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())