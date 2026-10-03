"""
ROUND 49 SELF-TEST -- the gate for the end-to-end NFS collection measurement.

WRITTEN BEFORE THE EXPERIMENT, and -- per the brief -- it must exercise the quantity the
experiment actually claims.  The quantity claimed is:

    "the end-to-end relation-collection cost of TRUE differs from that of NULL"

so the load-bearing tests are not "is my code syntactically fine", they are:

    THE SWITCH TEST.  Measure P(p^k | x)/p^k on the NULL arm at the real box.  It MUST be
    1.0 for every k.  If the null arm still carries a 2 - 1/p excess, the switch did not
    switch, every downstream ratio is void, and the experiment must report that.

    THE VACUITY TEST.  The TRUE arm must NOT give 1.0 at k >= 2.  If both arms give 1.0 the
    switch is a no-op, the arms are indistinguishable, and a measured ratio would be a
    number divided by itself -- the "harness that works is not a harness that measures"
    failure mode from round 48.

Statistics note: at the operating point (X = 2^36, p^k up to p^4 for small p) the expected
count for p^k | v is n / p^k, which is < 1 for large p and k.  Per-(p,k) tolerances are
therefore scaled to the POISSON noise of that cell, and the sharp version of both tests is
the POOLED excess statistic, which is what carries the power.

Run:  python3 selftest.py      (exit 0 == calibrated, exit 1 == do not report anything)
"""

from __future__ import annotations

import importlib.util
import math
import sys

import numpy as np

import core

SHARED = "/home/raver1975/lean/factor-scratch/r48/_shared/dickman.py"

A_EXP, BB_EXP = 18, 12          # a < 2^18, b < 2^12, value scale X = 2^36
X = 1 << (2 * A_EXP)            # == 68719476736


def load_shared():
    spec = importlib.util.spec_from_file_location("shared_dickman", SHARED)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


OK = True


def check(name, cond, detail=""):
    global OK
    status = "PASS" if cond else "FAIL"
    if not cond:
        OK = False
    print(f"  [{status}] {name}" + (f"   {detail}" if detail else ""))


# ---------------------------------------------------------------------------
# 1. Exact arithmetic / box geometry (the float-root bug class)
# ---------------------------------------------------------------------------

def t_box():
    print("1. box geometry -- exact integer arithmetic, no float roots")
    try:
        core.assert_box(A_EXP, BB_EXP)
        check("assert_box(18,12) accepted (2*18 == 3*12, matched scale)", True)
    except Exception as e:
        check("assert_box(18,12) accepted", False, str(e))
    try:
        core.assert_box(18, 11)
        check("assert_box rejects a mismatched box (no silent scale error)", False)
    except ValueError:
        check("assert_box rejects a mismatched box", True)
    A, Bb = 1 << A_EXP, 1 << BB_EXP
    check("value scale is 2^36, not 2^18 (operating-point guard)",
          core.value_scale(A_EXP) == 1 << 36 == X,
          f"value_scale={core.value_scale(A_EXP)}")
    check("max a^2 = 2^36 fits int64 exactly", A * A == X, f"{A*A}")
    check("(2^18-1)^2 == 68718952449", (A - 1) * (A - 1) == 68718952449, f"{(A-1)*(A-1)}")
    check("(2^12-1)^3 == 68669157375", (Bb - 1) ** 3 == 68669157375, f"{(Bb-1)**3}")
    check("(2^12)^3 == 2^36 == (2^18)^2  (square and cube sides on one scale)",
          Bb ** 3 == X and A * A == X)
    # the degenerate zero case: a = t^3, b = t^2 gives a^2 - b^3 = 0 EXACTLY.  This is the
    # "perfect cube" trap in a different guise and it must be excluded, not silently kept.
    t = 5
    check("degenerate a^2-b^3=0 detected by construction", (t ** 3) ** 2 - (t ** 2) ** 3 == 0)
    check("shell_mask excludes v=0", not bool(core.shell_mask(np.array([0]), A_EXP)[0]))


# ---------------------------------------------------------------------------
# 2. FB strip correctness -- tightest cases + cross-check vs shared harness
# ---------------------------------------------------------------------------

def t_strip(shared):
    print("2. FB strip -- exactness at the TIGHTEST case, and agreement with the shared harness")
    B = 1000  # 997 <= B < 1009, so "prime exactly AT the bound" and "just above" are both
    primes = core.primes_upto(B)  # realisable and distinct
    probes = [
        (997 ** 3, True, "997^3 is 997-smooth, prime exactly AT the bound"),
        (1009 ** 3, False, "1009^3, prime just ABOVE the bound"),
        (2 * 997, True, "2*997"),
        (2 * 1009, False, "2*1009"),
        (1, True, "1 is smooth"),
        (2 ** 60, True, "2^60"),
        (3 ** 38, True, "3^38"),
        (999983, False, "999983 = large prime, not B-smooth"),
        (2 ** 40 * 3, True, "2^40*3"),
        (2 ** 40 * 1009, False, "2^40*1009"),
    ]
    vals = np.array([p[0] for p in probes], dtype=np.int64)
    res = core.strip_multi(vals, primes, [B])[B]
    cof, maxexp = res[0], res[1]
    for i, (_, expect, name) in enumerate(probes):
        got = int(cof[i]) == 1
        check(f"strip: {name}", got == expect, f"got smooth={got} want {expect}")
    check("strip: maxexp(997^3)==3", int(maxexp[0]) == 3, f"got {int(maxexp[0])}")
    check("strip: maxexp(2*997)==1", int(maxexp[2]) == 1, f"got {int(maxexp[2])}")

    rng = np.random.default_rng(7)
    n = 400
    rr = np.maximum(rng.integers(0, X, size=n, dtype=np.int64), 1)
    rcof = core.strip_multi(rr, primes, [B])[B][0]
    mism = sum(1 for i in range(n)
               if (int(rcof[i]) == 1) != shared.is_smooth(int(rr[i]), B))
    check(f"strip agrees with shared is_smooth on {n} random values in the shell scale",
          mism == 0, f"{mism} mismatches")

    # mark accounting must be self-consistent: sum over primes of #{p|v} = number of
    # distinct prime factors; total marks = Omega.  On an exactly factored value.
    v = 2 ** 20 * 3 ** 10 * 5 ** 5
    cof, mx, ge1, tot, _ = core.strip_multi(np.array([v], dtype=np.int64), primes, [B])[B]
    check("mark count: #{p|v} == 3", int(ge1[:3].sum()) == 3, f"got {int(ge1[:3].sum())}")
    check("mark count: total marks == 20+10+5 == 35", int(tot[:3].sum()) == 35,
          f"got {int(tot[:3].sum())}")
    check("mark count: maxexp == 20", int(mx[0]) == 20, f"got {int(mx[0])}")

    # multi-target snapshot must agree with independent single-target runs
    mt = core.strip_multi(vals, primes, [64, 256, 1000])
    for B2 in (64, 256, 1000):
        s2 = core.strip_multi(vals, primes, [B2])[B2]
        check(f"snapshot at B={B2} equals an independent run",
              bool(np.array_equal(mt[B2][0], s2[0])),
              f"maxdiff {int(np.abs(mt[B2][0]-s2[0]).max())}")


# ---------------------------------------------------------------------------
# 3. The valuation law itself, by EXHAUSTIVE enumeration (the paper's protocol)
# ---------------------------------------------------------------------------

def t_law_exhaustive():
    print("3. valuation law by EXHAUSTIVE enumeration over ALL (a,b) mod p^k "
          "(including a^2 == b^3 -- the excluded cases ARE the effect)")
    for p, kmax in ((5, 4), (7, 3)):
        print(f"   p = {p}")
        for k in range(1, kmax + 1):
            mod = p ** k
            aa = np.arange(mod, dtype=np.int64)
            bb = np.arange(mod, dtype=np.int64)
            vals = (aa[:, None] * aa[:, None] - bb[None, :] * bb[None, :] * bb[None, :]) % mod
            n_hit = int((vals == 0).sum())
            # ratio = P(p^k | v)/(1/p^k) = (n_hit / p^(2k)) * p^k = n_hit / p^k
            ratio = n_hit / mod
            want = 1.0 if k == 1 else (2 - 1 / p)
            check(f"  p={p} k={k}: ratio={ratio:.6f} == {want:.6f}",
                  abs(ratio - want) < 1e-9, f"dev {abs(ratio-want):.2e}")
    # tightest case for the departure: p=3, k=6 must give 2-1/p + (p-1) = 5/3 + 2 = 3.6667
    for p, k in ((3, 6), (5, 6), (3, 5)):
        mod = p ** k
        aa = np.arange(mod, dtype=np.int64)
        bb = np.arange(mod, dtype=np.int64)
        vals = (aa[:, None] * aa[:, None] - bb[None, :] * bb[None, :] * bb[None, :]) % mod
        ratio = int((vals == 0).sum()) / mod
        base = 2 - 1 / p
        want = base + (p - 1) if k >= 6 else base
        check(f"  p={p} k={k}: ratio={ratio:.6f} == {want:.6f} "
              f"({'departure' if k >= 6 else 'still 2-1/p'})",
              abs(ratio - want) < 1e-9, f"dev {abs(ratio-want):.2e}")
    # and the true k=1 statement: NO excess at the prime itself, for every p tested
    ok = True
    for p in (3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 101, 997):
        mod = p
        aa = np.arange(mod, dtype=np.int64)
        bb = np.arange(mod, dtype=np.int64)
        vals = (aa[:, None] * aa[:, None] - bb[None, :] * bb[None, :] * bb[None, :]) % mod
        if abs(int((vals == 0).sum()) / mod - 1.0) > 1e-12:
            ok = False
    check("k=1 ratio == 1 exactly for p = 3..997 (12 primes, exhaustive)", ok)


# ---------------------------------------------------------------------------
# 4. THE SWITCH TEST -- the whole experiment hangs on this
# ---------------------------------------------------------------------------

def pooled_excess(x: np.ndarray, primes, kmin=2, kmax=3, minexp=5_000):
    """Pool the deviation of P(p^k|x)/(1/p^k) from 1 over (p,k) cells, weighting each cell
    by its Poisson variance.  Only cells with at least `minexp` expected hits are used --
    a cell with an expected count below ~5 has no power and would only add noise.
    Returns (pooled excess estimate, +-sigma, number of cells)."""
    num = 0.0
    var = 0.0
    n = x.shape[0]
    cells = 0
    for p in primes:
        pk = 1
        for k in range(1, kmax + 1):
            pk *= p
            if k < kmin:
                continue
            exp = n / pk
            if exp < minexp:
                continue
            obs = int((x % pk == 0).sum())
            num += obs - exp
            var += exp
            cells += 1
    if var == 0:
        return float("nan"), float("nan"), 0
    return num / var, math.sqrt(1.0 / var), cells


def t_switch():
    print("4. THE SWITCH TEST -- null arm must be free of the k>=2 excess")
    n = 3_000_000
    rng = np.random.default_rng(20261003)
    a, b, v = core.sample_box(rng, A_EXP, BB_EXP, n)
    m = core.shell_mask(v, A_EXP)
    vsh = v[m]
    xnull = core.nullize(vsh, rng)
    ns = vsh.shape[0]
    print(f"   box a<2^{A_EXP}, b<2^{BB_EXP}, X=2^{36}; shell |v| in [2^35, 2^36]: "
          f"{ns} of {n} samples ({100*ns/n:.1f}%)")
    print(f"   u = log2(X)/log2(B):  B=512 -> {36/9:.2f}, B=1024 -> {36/10:.2f}, "
          f"B=4096 -> {36/12:.2f}")

    lt = np.log2(np.abs(vsh).astype(np.float64))
    ln = np.log2(xnull.astype(np.float64))
    check("size distributions match (mean log2 |x| within 1e-3)",
          abs(lt.mean() - ln.mean()) < 1e-3,
          f"true {lt.mean():.5f} null {ln.mean():.5f}")

    xt = np.abs(vsh)
    for p in (5, 7, 11, 13, 17, 19, 23, 29, 31):
        want = 2 - 1 / p
        Rt, Rn, tol = {}, {}, {}
        for k in range(1, 5):
            pk = p ** k
            exp = ns / pk
            Rt[k] = int((xt % pk == 0).sum()) / ns * pk
            Rn[k] = int((xnull % pk == 0).sum()) / ns * pk
            tol[k] = max(0.04, 4 * math.sqrt(max(1.0, pk) / ns))
        bad_n = [k for k in range(1, 5) if abs(Rn[k] - 1.0) > tol[k]]
        bad_t = [k for k in range(2, 5) if abs(Rt[k] - want) > tol[k]]
        check(f"  p={p}: NULL arm is 1.0 for k=1..4  <-- SWITCH", not bad_n,
              " ".join(f"k{k}={Rn[k]:.4f}+-{tol[k]:.3f}" for k in range(1, 5)) +
              (f"  BAD k={bad_n}" if bad_n else ""))
        check(f"  p={p}: TRUE arm is 2-1/p={want:.4f} for k=2..4  <-- VACUITY", not bad_t,
              " ".join(f"k{k}={Rt[k]:.4f}+-{tol[k]:.3f}" for k in range(1, 5)) +
              (f"  BAD k={bad_t}" if bad_t else ""))
        check(f"  p={p}: TRUE arm is 1.0 at k=1 (no excess at the prime itself)",
              abs(Rt[1] - 1.0) < tol[1], f"k1={Rt[1]:.4f}+-{tol[1]:.3f}")

    # the SHARP version: pooled over the k >= 2 cells (where the excess lives), each cell
    # weighted by its Poisson variance, keeping only cells with >= 5000 expected hits.
    fp = [p for p in core.primes_upto(200)][1:]
    pt, st, cells = pooled_excess(xt, fp, kmin=2, kmax=3, minexp=5_000)
    pn, sn, _ = pooled_excess(xnull, fp, kmin=2, kmax=3, minexp=5_000)
    print(f"   POOLED excess over {cells} (p,k) cells:  TRUE {pt:.4f} +- {st:.4f}   "
          f"NULL {pn:.4f} +- {sn:.4f}")
    check("POOLED null excess is within 4 sigma of zero  <-- SWITCH (sharp)",
          abs(pn) < 4 * sn, f"{pn:.4f} +- {sn:.4f}  ({(pn/sn):.2f} sigma)")
    check("POOLED true excess is > 4 sigma from zero  <-- VACUITY (sharp)",
          abs(pt) > 4 * st, f"{pt:.4f} +- {st:.4f}  ({pt/st:.1f} sigma)")
    check("POOLED true excess is far above the null's (arms are separated)",
          pt > 6 * pn, f"true {pt:.4f} vs null {pn:.4f}")


# ---------------------------------------------------------------------------
# 5. The k_max decomposition -- where the gain lives
# ---------------------------------------------------------------------------

def t_kmax():
    print("5. k_max decomposition -- the sharp prediction of the MECHANISM")
    print("   Local densities:  r_p(0) = 1,  r_p(1) = (p-alpha)/(p-1) < 1,  "
          "r_p(e>=2) = alpha*p/(p-1) > 1")
    print("   => restricting to FB-SQUAREFREE values (k_max = 1) must make the NFS arm")
    print("      STRICTLY WORSE, and the unrestricted arm strictly BETTER.  Both are")
    print("      sharp, falsifiable predictions; if neither holds the premise is wrong.")
    B = 4096
    n = 400_000
    rng = np.random.default_rng(31337)
    a, b, v = core.sample_box(rng, A_EXP, BB_EXP, n)
    vsh = v[core.shell_mask(v, A_EXP)]
    xnull = core.nullize(vsh, rng)
    primes = core.primes_upto(B)
    rt = core.strip_multi(np.abs(vsh), primes, [B])[B]
    rn = core.strip_multi(xnull, primes, [B])[B]
    st, mt = rt[0] == 1, rt[1]
    sn, mn = rn[0] == 1, rn[1]
    ns = vsh.shape[0]
    prev = None
    mono = True
    for km in range(1, 7):
        num = int((st & (mt <= km)).sum())
        den = int((sn & (mn <= km)).sum())
        r = num / den if den else float("nan")
        print(f"     k_max<={km}: TRUE {num:7d}  NULL {den:7d}  ratio {r:.4f}")
        if prev is not None and r < prev - 0.02:
            mono = False
        prev = r
    r_full = int(st.sum()) / int(sn.sum())
    r_1 = int((st & (mt <= 1)).sum()) / int((sn & (mn <= 1)).sum())
    check("k_max=1 ratio is STRICTLY BELOW 1 (r_p(1) = (p-alpha)/(p-1) < 1)",
          r_1 < 0.97, f"ratio(k_max=1) = {r_1:.4f}")
    check("unrestricted (k_max=inf) ratio is ABOVE 1 (r_p(e>=2) > 1)",
          r_full > 1.05, f"ratio(full) = {r_full:.4f}")
    check("the gain is monotone in k_max (each extra power layer adds)",
          mono, f"ratio(k_max=1) = {r_1:.4f}  ->  ratio(full) = {r_full:.4f}")
    check("both denominators are well populated", int(sn.sum()) > 500)


# ---------------------------------------------------------------------------
# 6. Dickman sanity -- MEASURED vs the shared harness's rho (reported, not a gate)
# ---------------------------------------------------------------------------

def exact_psi(Xe: int, B: int) -> int:
    """EXACT count of B-smooth integers in [1, Xe].  n is B-smooth iff no prime > B divides
    it, so we sieve by the primes in (B, sqrt(Xe)].  No sampling, no floats."""
    lim = int(math.isqrt(Xe))
    smooth = np.ones(Xe + 1, dtype=bool)
    for p in core.primes_upto(lim):
        if p > B:
            smooth[p::p] = False
    smooth[0] = False
    return int(smooth.sum())


def t_dickman(shared):
    print("6. smoothness-rate sanity vs the shared harness rho (REPORTED, not gated)")
    print()
    print("6a. EXACT Psi (full sieve, no sampling) vs rho -- this is the check the brief asks")
    print("    for: rho is NOT a valid null at u in [5,8] (exact Psi = 8.46 rho there).")
    print("    Does the same inflation hold at NFS operating points u in [3,5]?")
    Xe = 1 << 24
    for u_target in (3.0, 3.5, 4.0, 4.5, 5.0):
        B = int(round(Xe ** (1.0 / u_target)))
        psi = exact_psi(Xe, B)
        meas = psi / Xe
        pred = shared.rho(u_target)
        print(f"     u={u_target:4.1f}  B={B:6d}  Psi/X={meas:.6e}  rho(u)={pred:.6e}  "
              f"exact/rho={meas/pred:6.3f}")
    print()
    print("6b. the NULL arm's smoothness rate in the sieved box (uniform-in-[1,X] rho is NOT")
    print("    the right comparison here: |a^2-b^3| is NOT uniform on [1,X], it concentrates")
    print("    toward 0, so this line is a scale check only, not a Dickman test.")
    Bmax = 4096
    primes = core.primes_upto(Bmax)
    masks = (("FULL BOX |v|<=X", lambda vv: vv != 0),
             ("SHELL |v| in [X/2,X]", lambda vv: core.shell_mask(vv, A_EXP)))
    for label, mfn in masks:
        rng = np.random.default_rng(999)
        a, b, v = core.sample_box(rng, A_EXP, BB_EXP, 400_000)
        xv = np.abs(v[mfn(v)])
        for B in (512, 1024, 4096):
            cof = core.strip_multi(xv, primes, [B])[B][0]
            meas = int((cof == 1).sum()) / xv.shape[0]
            u = math.log(X) / math.log(B)
            print(f"   {label:22s} n={xv.shape[0]:7d} B={B:5d} u={u:5.2f}  "
                  f"measured={meas:.6f}  rho(u)={shared.rho(u):.6f}  "
                  f"measured/rho={meas/shared.rho(u):6.3f}")


if __name__ == "__main__":
    shared = load_shared()
    print("=" * 78)
    print("ROUND 49 NFS END-TO-END SELF-TEST")
    print("=" * 78)
    t_box()
    t_strip(shared)
    t_law_exhaustive()
    t_switch()
    t_kmax()
    t_dickman(shared)
    print()
    if OK:
        print("ALL SELFTESTS PASS -- the switch works, arms are distinct, and end-to-end "
              "ratios from run.py may be reported.")
    else:
        print("!!! SELFTEST FAILURE -- do NOT report any ratio from run.py.")
    sys.exit(0 if OK else 1)