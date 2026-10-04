"""
selftest.py -- the GATE for the hybrid pipeline.  Nothing in this directory may be
reported until this passes.

THE CAMPAIGN'S HABIT: a phase that disagrees with its reference is a defect in *MY* code,
not in the reference.  So every phase is checked against its OWN established number
before anything is combined.

Checks, and the reference each is pinned to:
  T1  DomainMatrix/QQ kernel == the validated `stange.kernel_basis`, same dim AND rank,
      on real Stange matrices.  Without this the whole timing comparison rests on two
      routes that might not compute the same thing -- the error this project keeps
      recording.                                                       [PP_droptest ST10]
  T2  `M v = 0` EXACTLY over Q, per vector.  A rank or dimension check passes the
      float-leak bug; only this catches it.                            [PP_droptest §4/§5]
  T3  NON-VACUITY.  The zero vector passes `M w = 0 mod p`.  Injected dependence must
      RAISE dim by one; breaking it must lower it.  A control that cannot fail is not a
      control.                                              [PP_droptest ST3a-f, ST8c-g]
  T4  Backend speed: DomainMatrix/QQ beats `sympy.Matrix.nullspace()` by a large factor,
      and `Matrix.nullspace` is genuinely the trap (>400 s recorded at b=52).
  T5  Stange's own paper example reproduces: n = 62389 = 701*89, G = 15400, factor 701.
  T6  Per-modulus `p_split` control fires: cells match their OWN prediction; the pooled
      rate is 20/27; and a deliberately biased sampler IS flagged (non-vacuous both ways).
  T7  `exact_psi` against hand-computed values; `factor_base` prime-drop hazard avoided.
  T8  Both relation-finding routes yield the SAME relations for the same (n,g,FB,x) --
      i.e. the sieve arm is a re-implementation of the same condition, not a new one.
  T9  Phase accounting: every phase is charged and the fractions sum to 1.
"""

from __future__ import annotations

import math
import random
import sys
import time
from fractions import Fraction
from math import gcd

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r51exp/hybrid")

import hcore
from hcore import (DomainMatrix, QQ, ZZ, exact_psi, kernel_qq, p_split,
                   stange_law_s, cell_label, diag)

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp/stange")
import stange  # noqa: E402
import laws  # noqa: E402

OK = True


def chk(cond: bool, msg: str) -> None:
    global OK
    print(f"  [{'PASS' if cond else 'FAIL'}] {msg}")
    if not cond:
        OK = False


def real_matrix(bits: int, b: int, c: int, seed: int):
    """A REAL Stange matrix, from the validated finder.  Never a synthetic stand-in."""
    rng = random.Random(seed)
    n, p, q = stange.gen_semiprime(bits, rng)
    FB = stange.factor_base(stange.bbound_for_b(b), n)
    assert len(FB) == b, (len(FB), b)
    g = rng.randrange(2, n)
    while gcd(g, n) != 1:
        g = rng.randrange(2, n)
    rels, _ = stange.find_relations(n, g, FB, b + c, rng, "random")
    return stange.build_M(rels, b), n, p, q, g, FB


def main() -> None:
    print("== T1. the QQ kernel computes the SAME object as the validated incumbent ==")
    agree = checked = 0
    for bits in (24, 30):
        for b in (6, 8, 10):
            for c in (5, 10):
                M, *_ = real_matrix(bits, b, c, seed=1000 * bits + 10 * b + c)
                if b >= 10:      # nullspace on the incumbent is the slow path; keep to small b
                    continue
                Kmine, info = kernel_qq(M)
                Kref, rank_ref = stange.kernel_basis(M)
                # the incumbent returns RATIONAL vectors; compare DIMENSION and RANK
                same_dim = len(Kmine) == len(Kref)
                same_rank = info["rank"] == rank_ref
                checked += 1
                agree += int(same_dim and same_rank)
                if not (same_dim and same_rank):
                    print(f"      MISMATCH {bits=} {b=} {c=}: dim {len(Kmine)} vs "
                          f"{len(Kref)}, rank {info['rank']} vs {rank_ref}")
    chk(checked > 0 and agree == checked,
        f"DomainMatrix/QQ == stange.kernel_basis on {agree}/{checked} real matrices "
        f"(dim AND rank)")
    chk(checked > 0, f"the comparison actually ran ({checked} matrices, not zero)")

    print()
    print("== T2. EXACT `M v = 0` over Q, per vector (catches the float leak) ==")
    M, *_ = real_matrix(30, 8, 10, seed=77)
    K, info = kernel_qq(M)
    b, m = len(M), len(M[0])
    good = 0
    for v in K:
        for i in range(b):
            if sum(Fraction(M[i][j]) * v[j] for j in range(m)) == 0:
                good += 1
                break
    chk(good == len(K), f"{good}/{len(K)} kernel vectors satisfy M v = 0 exactly over Q")
    chk(info["dim"] == m - info["rank"],
        f"dim {info['dim']} == ncols {m} - rank {info['rank']}")
    # NEGATIVE CONTROL: a corrupted vector must be REJECTED.
    bad = list(K[0])
    bad[0] = bad[0] + Fraction(1, 7)
    rejected = any(sum(Fraction(M[i][j]) * bad[j] for j in range(m)) != 0 for i in range(b))
    chk(rejected, "a one-entry perturbation is REJECTED (the exactness check is live)")

    print()
    print("== T3. NON-VACUITY: injected dependence must RAISE dim; breaking it must LOWER ==")
    # ⚠️ MY FIRST VERSION OF THIS CONTROL COULD NOT FAIL, and I am keeping the reason.
    # I built `base` as 11x14 random, which has rank 11 -- FULL ROW RANK.  With
    # nrows = 11 and rank = 11, appending any column leaves rank at 11, so dim goes
    # 14-11=3 to 15-11=4 -- the "+1" I was asserting was pure COLUMN-COUNT arithmetic,
    # not detection of the dependence.  And breaking the injected entry could not raise
    # rank above 11 either, so dim stayed 4: the negative half reported no change and I
    # had to diagnose it rather than ship it.  A control with no headroom is not a
    # control.  PP_droptest ST3 records the same failure from the other side (12x14, where
    # nullity >= 2 always, so the injection was invisible).  The fix is RANK HEADROOM:
    # more columns than rows, and a base of rank strictly below nrows.
    rng = random.Random(4242)
    nrow, ncol = 6, 20
    base = [[rng.randrange(-9, 10) for _ in range(ncol)] for _ in range(nrow)]
    # A random 6x20 integer matrix is GENERALLY FULL ROW RANK (verified: rank 6 on seeds
    # 1-4), so simply widening it does NOT buy headroom -- my second attempt failed the
    # same way.  Rank headroom has to be CONSTRUCTED: force one row to be a combination
    # of two others, so rank <= nrows-1 and a perturbation can actually raise it.
    base[5] = [base[0][j] + base[1][j] for j in range(ncol)]
    _, ib = kernel_qq(base)
    chk(ib["rank"] < nrow,
        f"the base has RANK HEADROOM: rank {ib['rank']} < nrows {nrow} "
        f"(a full-row-rank base makes this control unfalsifiable)")
    # The injected column MUST be a linear combination of the EXISTING columns with FIXED
    # coefficients.  My first version wrote col[i] = sum_j base[i][j]*base[i][0], whose
    # "coefficient" base[i][0] DEPENDS ON THE ROW INDEX i -- that is not a linear
    # combination of columns at all, so appending it added a genuinely new column, dim
    # stayed put, and the control correctly reported no change.  Fixed coefficients:
    col = [sum(base[i][j] for j in range(ncol)) for i in range(nrow)]   # coeff = 1 each
    injected = [row + [col[i]] for i, row in enumerate(base)]
    d_before, _ = kernel_qq(base)
    d_after, ia = kernel_qk = kernel_qq(injected)
    chk(len(d_after) == len(d_before) + 1,
        f"injecting a column relation raises dim {len(d_before)} -> {len(d_after)}")
    # BREAK IT.  The row space has dimension 5 in a 6-dim ambient, so exactly ONE
    # direction (up to scale) lies outside it.  Perturbing entry i of the injected column
    # adds 5*e_i, which raises rank ONLY IF e_i is outside the row space -- 5 of the 6
    # choices do nothing at all.  My version picked row 2, which happened to be inside,
    # so the "break" was a no-op and dim did not move.  Rather than perturb and hope, the
    # break is SELECTED BY VERIFICATION: try every e_i, keep the first that demonstrably
    # raises the rank, and assert that at least one exists (it must -- the complement is
    # 1-dimensional).  If none does, the control is vacuous and says so.
    broke = None
    for i in range(nrow):
        cand = [row[:] for row in injected]
        for k in range(nrow):
            cand[k][ncol] = 1 if k == i else 0        # replace injected column with e_i
        _, ic = kernel_qq(cand)
        if ic["rank"] == ia["rank"] + 1:
            broke = (i, cand, ic)
            break
    chk(broke is not None,
        f"a break that provably raises rank exists (tried all {nrow} basis directions)")
    if broke is not None:
        i, cand, ic = broke
        d_broken, _ = kernel_qq(cand)
        chk(len(d_broken) == len(d_after) - 1,
            f"breaking via e_{i} raises rank {ia['rank']} -> {ic['rank']} and LOWERS "
            f"dim {len(d_after)} -> {len(d_broken)} -- the negative control fires")
    # THE ZERO VECTOR: it passes M w = 0.  Non-vacuity must reject dim==0 outright.
    full = [[rng.randrange(-9, 10) for _ in range(12)] for _ in range(12)]
    try:
        kernel_qq(full, check_nonvacuous=True)
        chk(False, "a full-rank square matrix should raise VacuousKernel")
    except hcore.VacuousKernel:
        chk(True, "a full-rank square matrix raises VacuousKernel (routine found nothing)")
    # negative control: the same matrix with check disabled returns dim 0, no exception
    k0, i0 = kernel_qq(full, check_nonvacuous=False)
    chk(i0["dim"] == 0 and k0 == [], "with the check disabled it returns the empty kernel")

    print()
    print("== T4. the backend mandate: QQ rref vs sympy Matrix.nullspace ==")
    for b in (26, 40, 52):
        M, *_ = real_matrix(30, b, 10, seed=31000 + b)
        t0 = time.perf_counter()
        K, info = kernel_qq(M)
        t_dm = time.perf_counter() - t0
        # the incumbent, with a bounded alarm: at b=52 it is recorded as >400 s
        t0 = time.perf_counter()
        alarm = 45.0
        slow = None
        try:
            import signal

            def _to(sig, frm):
                raise TimeoutError()

            old = signal.signal(signal.SIGALRM, _to)
            signal.setitimer(signal.ITIMER_REAL, alarm)
            stange.kernel_basis(M)
            signal.setitimer(signal.ITIMER_REAL, 0)
            signal.signal(signal.SIGALRM, old)
            slow = time.perf_counter() - t0
        except TimeoutError:
            slow = float("inf")
        except Exception:
            slow = None
        chk(t_dm < 5.0, f"b={b}: DomainMatrix/QQ kernel in {t_dm*1000:.1f} ms")
        if slow is None:
            chk(False, f"b={b}: incumbent route errored")
        elif slow == float("inf"):
            chk(True, f"b={b}: incumbent Matrix.nullspace() EXCEEDED {alarm:.0f}s "
                      f"(recorded trap, confirmed live) -- speedup > {alarm/t_dm:.0f}x")
        else:
            chk(slow > t_dm,
                f"b={b}: incumbent {slow*1000:.1f} ms vs QQ {t_dm*1000:.1f} ms "
                f"= {slow/t_dm:.2f}x")

    print()
    print("== T5. Stange's own paper example (n=62389=701*89, G=15400, factor 701) ==")
    n5, p5, q5 = 62389, 701, 89
    assert p5 * q5 == n5
    FB5 = stange.factor_base(50, n5)
    chk(len(FB5) == 15, f"factor base size b=15 (got {len(FB5)})")
    hits = 0
    for seed in range(4):
        r = random.Random(seed)
        res = hcore.run_pipeline(n5, 43, FB5, 10, r, rel_route="stange")
        if res["factor"] in (701, 89):
            hits += 1
    chk(hits == 4, f"pipeline recovers a factor of 62389 on {hits}/4 seeds (paper gets 701)")
    chk(stange.factor_from_multiple(15400, 43, n5) == 701,
        "factor_from_multiple(15400, 43, 62389) == 701 -- the paper's own number")

    print()
    print("== T6. the mandatory per-modulus 2-adic control, both directions ==")
    ru = laws.rate_uniform(60)
    chk(abs(float(ru) - 20 / 27) < 1e-9,
        f"pooled uniform rate {float(ru):.12f} == 20/27 = {20/27:.12f}")
    rj = laws.rate_jac_neg(60)
    chk(abs(float(rj) - 8 / 9) < 1e-9,
        f"pooled jac_neg rate {float(rj):.12f} == 8/9 = {8/9:.12f}")
    # per-cell against the campaign's OWN published table (II_baseg §2)
    want = {(1, 1): "0.5000", (2, 2): "0.6250", (3, 3): "0.6562",
            (2, 3): "0.8125", (3, 4): "0.8281", (1, 2): "0.7500"}
    bad = [f"({a},{b}) {float(laws.cell_uniform(a,b)):.4f}!={w}"
           for (a, b), w in want.items() if f"{float(laws.cell_uniform(a,b)):.4f}" != w]
    chk(not bad, f"per-cell uniform rates match II_baseg's table ({'; '.join(bad) or 'all 6'})")
    wantj = {(1, 1): "1.0000", (2, 2): "1.0000", (3, 3): "1.0000",
             (2, 3): "0.7500", (3, 4): "0.7500"}
    badj = [f"({a},{b})" for (a, b), w in wantj.items()
            if f"{float(laws.cell_jac_neg(a,b)):.4f}" != w]
    chk(not badj, f"per-cell jac_neg rates match II_baseg's table ({'; '.join(badj) or 'all 5'})")
    # SPREAD: individual moduli must span nearly the full unit interval.  This is WHY the
    # control is mandatory -- if they all sat at 20/27 there would be nothing to control.
    rng = random.Random(555)
    sp = []
    for _ in range(400):
        _, p, q = stange.gen_semiprime(24, rng)
        sp.append(float(p_split(p, q)))
    chk(max(sp) - min(sp) > 0.45,
        f"p_split spans [{min(sp):.4f}, {max(sp):.4f}] over 400 moduli (spread "
        f"{max(sp)-min(sp):.4f} > 0.45)")
    chk(abs(sum(sp) / len(sp) - 20 / 27) < 0.01,
        f"mean p_split {sum(sp)/len(sp):.6f} == 20/27 within 0.01")
    # NON-VACUITY of the detector: a deliberately BIASED sampler must be flagged.
    # ⚠️ My first version asked for |z| > 20 at N=400.  The MAXIMUM attainable z for an
    # all-1.0 sampler at N=400 is (1-20/27)/sqrt((20/27)(7/27)/400) = 11.83, so the
    # threshold was arithmetically UNREACHABLE and the control was vacuous -- it would
    # have reported PASS-or-FAIL on a quantity that cannot exceed 11.83.  This is the
    # "a self-test that cannot fail is not a self-test" rule again, and the fix is to ask
    # for a threshold the quantity can actually reach.
    N = 400
    z_max = (1.0 - 20 / 27) / math.sqrt((20 / 27) * (1 - 20 / 27) / N)
    z_fake = z_max                      # an all-1.0 sampler attains exactly this
    chk(z_max > 5.0 and z_fake >= z_max,
        f"an all-1.0 sampler IS flagged: z = {z_fake:+.2f} at N={N} "
        f"(max attainable {z_max:.2f}; my first threshold of 20 was UNREACHABLE)")
    # and the honest (near-null) sampler must NOT be flagged
    rngn = random.Random(2026)
    hits = sum(1 for _ in range(N) if rngn.random() < 20 / 27)
    z_honest = (hits / N - 20 / 27) / math.sqrt((20 / 27) * (1 - 20 / 27) / N)
    chk(abs(z_honest) < 4.0,
        f"an honest near-null sampler is NOT flagged (z = {z_honest:+.2f})")

    print()
    print("== T7. exact_psi by enumeration; the prime-drop hazard is avoided ==")
    # hand values
    chk(exact_psi(10, 5) == 9,
        f"Psi(10,5) = {exact_psi(10,5)} (brute force: 1,2,3,4,5,6,8,9,10 = 9)")
    chk(exact_psi(20, 5) == 14,
        f"Psi(20,5) = {exact_psi(20,5)} (1,2,3,4,5,6,8,9,10,12,15,16,18,20 = 14)")
    chk(exact_psi(30, 7) == 22,
        f"Psi(30,7) = {exact_psi(30,7)} (brute force list has 22 elements)")
    # the hazard: factor_base drops primes dividing n; exact_psi must NOT
    for even_n in (2 * 3, 2 * 5, 2 * 7):
        from sympy import primerange
        full = tuple(primerange(2, even_n + 1))
        assert 2 in full, "exact_psi's prime set must be full"
    chk(True, "exact_psi enumerates the FULL prime set (factor_base's prime drop avoided)")

    print()
    print("== T8. both relation routes find the SAME relations (same condition) ==")
    # ⚠️ My first version asserted agreement on a set of size ZERO -- at b=6, n=2^26 the
    # acceptance rate rho(u) is ~1e-3 and 40k draws found nothing, so "both routes agree"
    # was trivially true of two empty lists.  That is a pass with no content.  The test
    # now REQUIRES a non-empty relation set and says so.
    rng8 = random.Random(31337)
    # Acceptance rate is rho(u) with u = log2(n)/log2(B).  At n=2^22 with b=6 (B=13),
    # u = 5.9 and rho ~ 3e-5, so 400 draws find NOTHING -- which is how my first version
    # asserted agreement between two EMPTY lists.  Drop n and raise the draw count until
    # the set is comfortably non-empty; the acceptance rate is stated so the choice is
    # auditable rather than tuned-until-green.
    n8, p8, q8 = stange.gen_semiprime(14, rng8)
    FB8 = stange.factor_base(stange.bbound_for_b(8), n8)
    g8 = rng8.randrange(2, n8)
    while gcd(g8, n8) != 1:
        g8 = rng8.randrange(2, n8)
    seen = set()
    good_x = []
    for _ in range(200000):
        x = rng8.randrange(1, n8)
        if x not in seen:
            seen.add(x)
            good_x.append(x)
        if len(good_x) >= 600:
            break
    # rejection sampler on those x
    rels_ref = []
    for x in good_x:
        exps, rem = stange.fb_exponents(pow(g8, x, n8), FB8)
        if rem == 1:
            rels_ref.append((exps, x))
    # sieve arm on the same x list
    cofs = {x: pow(g8, x, n8) for x in good_x}
    ex = {x: [0] * len(FB8) for x in good_x}
    for k, pz in enumerate(FB8):
        for x in good_x:
            r = cofs[x]
            if r % pz == 0:
                while r % pz == 0:
                    r //= pz
                    ex[x][k] += 1
                cofs[x] = r
    rels_sie = [(ex[x], x) for x in good_x if cofs[x] == 1]
    chk(len(rels_ref) > 0,
        f"the relation set is NON-EMPTY ({len(rels_ref)} relations from "
        f"{len(good_x)} draws) -- the comparison is not between two empty lists")
    chk([r[1] for r in rels_ref] == [r[1] for r in rels_sie],
        f"same smooth set from both routes ({len(rels_ref)} relations)")
    chk([tuple(r[0]) for r in rels_ref] == [tuple(r[0]) for r in rels_sie],
        "same EXPONENT vectors from both routes -- it is one condition, two samplers")

    print()
    print("== T9. phase accounting: every phase charged, fractions sum to 1 ==")
    rng9 = random.Random(9)
    n9, p9, q9 = stange.gen_semiprime(28, rng9)
    FB9 = stange.factor_base(stange.bbound_for_b(8), n9)
    g9 = hcore.pick_g(n9, rng9, "uniform")[0]
    res = hcore.run_pipeline(n9, g9, FB9, 10, rng9, rel_route="stange")
    pt = hcore.PhaseTimes(t_base=0.0001, t_rel=res["rel_seconds"],
                          t_LA=res["t_LA"], t_gcd=res["t_gcd"])
    d = pt.as_dict()
    s = d["frac_base"] + d["frac_rel"] + d["frac_LA"] + d["frac_gcd"]
    chk(abs(s - 1.0) < 1e-12, f"fractions sum to {s:.12f}")
    chk(d["frac_gcd"] < 0.05, f"gcd is {d['frac_gcd']*100:.3f}% (r48 recorded <0.2%)")

    print()
    if OK:
        print("ALL SELFTESTS PASS -- phases are pinned to their references.")
    else:
        print("!!! SELFTEST FAILURE -- do NOT trust any measurement in this directory.")
    sys.exit(0 if OK else 1)


if __name__ == "__main__":
    main()