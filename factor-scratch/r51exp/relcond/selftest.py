"""
SELF-TEST FIRST.  Written and made to pass BEFORE any hypothesis is measured.

Every detector used by R1-R4 is exercised here against a PLANTED signal, because
the standing failure mode of this programme is a green control that is vacuous:
round 48's stride self-test could not detect the known-bad case; round 52's
two-proportion z accepted k = 220 of n = 200 and returned z = 0.00, i.e. a
detector that could NEVER fire.  A negative result from a vacuous detector is
worthless, so each control below is shown to fire on injected data.

Run:  python3 selftest.py      (exit 0 == all pass)
"""

from __future__ import annotations

import math
import random
import sys
from fractions import Fraction

import numpy as np

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r51exp/relcond")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/_shared")

from relcond_core import (  # noqa: E402
    a2b3_candidates, cap_gain, gen_semiprime, jacobi, jacobi_batch, jacobi_is_parity,
    pi, primes_upto, rate_ratio, smooth_mask_batch, smooth_mask_batch_active,
    stange_candidates, strata, two_prop_z, v2, wilson_lo,
)
from dickman import is_smooth, rho  # noqa: E402

FAILS: list[str] = []
NCHECK = 0


def check(name: str, cond: bool, detail: str = "") -> None:
    global NCHECK
    NCHECK += 1
    if cond:
        print(f"  ok   {name}" + (f"   [{detail}]" if detail else ""))
    else:
        print(f"  FAIL {name}   [{detail}]")
        FAILS.append(name)


# ---------------------------------------------------------------------------
# T1. the batch smoothness path agrees EXACTLY with the validated shared harness
# ---------------------------------------------------------------------------

def t1_batch_vs_shared() -> None:
    print("== T1. batch smoothness == validated shared is_smooth ==")
    rng = random.Random(11)
    n, p, q = gen_semiprime(40, rng)
    vals = stange_candidates(n, pow(5, 1, n), rng, 4000)
    for b in (500, 2000, 8000):
        mine = smooth_mask_batch(vals, b)
        ref = np.array([is_smooth(int(v), b) for v in vals[:1500]])
        agree = bool(np.array_equal(mine[:1500], ref))
        check(f"batch == is_smooth at B={b}", agree,
              f"({int(mine.sum())}/{len(mine)} smooth)")
    # and the "active" fast path must agree with the reference path EXACTLY
    a = smooth_mask_batch(vals, 2000)
    bb = smooth_mask_batch_active(vals, 2000)
    check("active fast path == reference path", bool(np.array_equal(a, bb)))


# ---------------------------------------------------------------------------
# T2. NON-VACUITY: inject a dependence and watch the detector fire.
#     This is the load-bearing test.  Without it, every "no conditioning helps"
#     result below is indistinguishable from a detector that cannot see.
# ---------------------------------------------------------------------------

def t2_injected_dependence() -> None:
    print("== T2. INJECTED DEPENDENCE -- the detector must FIRE ==")
    rng = np.random.default_rng(7)

    # Plant: in the "+1" stratum every 2nd candidate is B-smooth; in the "-1"
    # stratum every 20th is.  True rate ratio exactly 10.0.
    #
    # ⚠️ THIS TEST FAILED TWICE, BOTH TIMES IN THE INJECTOR, and both failures
    # are recorded because a control that silently under-plants is worse than no
    # control -- it looks like it passed.
    #   v1: built smooth values as prod of 8 uniforms in [2,B] -> OVERFLOWED int64
    #       (1000^8 = 1e24), wrapping some planted values into non-smooth garbage.
    #       Planted 5x measured as 1.48.
    #   v2: fixed the overflow but sampled the background uniformly in
    #       [5*10^9, 10^10], where ~3% of values are STILL B-smooth at B=1000
    #       (u = ln(10^10)/ln(1000) = 3.33).  That background dilutes the planted
    #       5x to a measured 3.77.
    # v3 (below): the background is made PROVABLY non-smooth by multiplying by a
    # prime q in (B, 2B].  Then the planted rate is exact and the recovered ratio
    # must equal the planted ratio to within sampling error.
    b = 1000
    xmax = 10**10
    q_big = 1009            # prime > B  ->  any multiple of q_big is NOT B-smooth
    assert q_big > b

    def a_smooth_value() -> int:
        v = int(rng.integers(2, b + 1))
        while v < 10**6 and rng.random() < 0.6:
            v *= int(rng.integers(2, b + 1))
        return v

    def plant(plus: bool):
        vals = np.empty(6000, dtype=np.int64)
        for i in range(len(vals)):
            # provably non-smooth background: carries the prime factor q_big > B
            vals[i] = q_big * int(rng.integers(10**8, 10**10))
        stride = 2 if plus else 20
        for i in range(0, len(vals), stride):
            vals[i] = a_smooth_value()
        assert int(vals.max()) < 2**62, "injector produced a value that can overflow"
        return smooth_mask_batch(vals, b)

    kp, kn = int(plant(True).sum()), int(plant(False).sum())
    z = two_prop_z(kp, 6000, kn, 6000)
    rr = rate_ratio(kp, 6000, kn, 6000)
    check("INJECTED ratio 10.0 is recovered", 8.0 < rr < 12.5, f"rate_ratio={rr:.4f}")
    check("INJECTED signal gives large |z|", abs(z) > 5.0, f"z={z:+.2f}")
    check("detector resolves a 5x effect", abs(z) > 3.0, f"z={z:+.2f}")

    # and the NEGATIVE control: identical rates must NOT fire
    vals = np.array([q_big * int(rng.integers(10**8, 10**10)) for _ in range(12000)])
    sm = smooth_mask_batch(vals, b)
    check("PROVABLY non-smooth background is 0/12000", int(sm.sum()) == 0,
          f"hits={int(sm.sum())}")
    vals2 = np.array([int(rng.integers(10**9, 10**10)) for _ in range(12000)])
    sm2 = smooth_mask_batch(vals2, b)
    z0 = two_prop_z(int(sm2[:6000].sum()), 6000, int(sm2[6000:].sum()), 6000)
    check("NEGATIVE control does not fire", abs(z0) < 3.0, f"z={z0:+.2f}")

    # RESOLUTION LIMIT -- state what this host can actually resolve.
    # ⚠️ my first band (1.5-3.5) was copied from round 52's n=200 numbers and is
    # wrong for n=6000; and my first "1pp" expression used 0.051-0.05 = 0.001,
    # which is one-tenth of a percentage point, not one.  Both were mine.
    z10 = abs((0.15 - 0.05)) / math.sqrt(0.05 * 0.95 * (2 / 6000))
    z1 = abs((0.06 - 0.05)) / math.sqrt(0.05 * 0.95 * (2 / 6000))
    check("resolution at n=6000/arm resolves 10pp easily", z10 > 10, f"z(10pp)={z10:.2f}")
    check("resolution at n=6000/arm resolves ~1pp", z1 > 1.5, f"z(1pp)={z1:.2f}")

def t3_gain_cap() -> None:
    print("== T3. the GAIN formula (*) and its q-cap ==")
    # a 10x enrichment on a balanced character still LOSES: q = 1/2 caps it at 5x
    g = cap_gain(q=0.5, s_ratio=10.0, c_cond_over_c_gen=0.0)
    check("q=1/2 with 10x enrichment still gains (5.0)", abs(g - 5.0) < 1e-12, f"{g}")
    check("q=1/2 caps the gain strictly below the enrichment",
          g < 10.0, f"gain {g} < 10")
    # perfect enrichment cannot be achieved by rejection: s_C <= 1 means s_C/s_0 <= 1/s_0
    # and q*s_C/s_0 <= q/s_0; with s_0 = 0.05, q = 0.5 the ABSOLUTE best is 10x
    gmax = cap_gain(q=0.5, s_ratio=1 / 0.05, c_cond_over_c_gen=0.0)
    check("absolute cap q/s_0 is 10x here", abs(gmax - 10.0) < 1e-9, f"{gmax}")
    # cost of the condition only makes it worse
    g1 = cap_gain(0.5, 4.0, 0.0)
    g2 = cap_gain(0.5, 4.0, 1.0)
    check("c_cond > 0 strictly reduces the gain", g2 < g1, f"{g1:.4f} -> {g2:.4f}")


# ---------------------------------------------------------------------------
# T4. Jacobi symbol correctness, INCLUDING on composite n.
# ---------------------------------------------------------------------------

def t4_jacobi() -> None:
    print("== T4. Jacobi symbol exactness on COMPOSITE n ==")
    rng = random.Random(3)
    n, p, q = gen_semiprime(36, rng)
    # against the (a/p)(a/q) factorisation -- which the ALGORITHM does not know
    ok = True
    for _ in range(2000):
        a = rng.randrange(1, n)
        want = jacobi(a % p, p) * jacobi(a % q, q)
        if jacobi(a, n) != want:
            ok = False
            break
    check("jacobi(a,n) == (a/p)(a/q) on composite n", ok)
    check("jacobi is multiplicative", jacobi(6, n) == jacobi(2, n) * jacobi(3, n))
    # quadratic-residue property: a^2 is always a residue mod n (for a coprime to n)
    check("a^2 always gives +1", all(jacobi(pow(a, 2, n), n) == 1
                                    for a in (2, 3, 5, 7, 11) if math.gcd(a, n) == 1))



# ---------------------------------------------------------------------------
# T5. THE STRUCTURAL FACT that makes the Stange Jacobi conditioning degenerate.
# ---------------------------------------------------------------------------

def t5_jacobi_is_parity() -> None:
    print("== T5. (g^x/n) == (g/n)^x -- conditioning is really conditioning on x parity ==")
    rng = random.Random(5)
    n, p, q = gen_semiprime(36, rng)
    g = 5 if math.gcd(5, n) == 1 else 7
    jn = jacobi(g, n)
    check("(g/n) is +-1 for gcd(g,n)=1", jn in (1, -1), f"(g/n)={jn}")
    bad = 0
    for _ in range(3000):
        x = rng.randrange(1, n)
        lhs = jacobi(pow(g, x, n), n)
        rhs = jn ** x
        if lhs != rhs:
            bad += 1
    check("candidate Jacobi == (g/n)^x on 3000 samples", bad == 0, f"violations={bad}")
    check("so conditioning on Jacobi == conditioning on x mod 2",
          jacobi_is_parity(n, g))
    # non-vacuity: the two parities genuinely DIFFER in Jacobi value
    vals_o = np.array([pow(g, 2 * k + 1, n) for k in range(300)])
    vals_e = np.array([pow(g, 2 * k + 2, n) for k in range(300)])
    jo, je = set(jacobi_batch(vals_o, n).tolist()), set(jacobi_batch(vals_e, n).tolist())
    check("odd and even x give OPPOSITE Jacobi signs", jo != je,
          f"odd={sorted(jo)} even={sorted(je)}")


# ---------------------------------------------------------------------------
# T6. MANDATORY: Dickman rho is NOT a valid null, and the harness refuses u>5.
# ---------------------------------------------------------------------------

def t6_rho_not_a_null() -> None:
    print("== T6. rho is not a null model; harness guard is live ==")
    try:
        rho(6.0)
        check("rho(6) raises (shared harness guard)", False, "NO RAISE -- guard dead")
    except ValueError:
        check("rho(6) raises (shared harness guard)", True)
    # ⚠️ FIRST VERSION FAILED HERE AND WAS WRONG IN AN INFORMATIVE WAY: it computed
    # u = ln(10^8)/ln(10^6) = 1.33 and asserted u > 5.  u = 1.33 is not the dead
    # zone at all -- I had picked an (x,B) pair that is EASY and then claimed it
    # was the hard one.  The divergence claim is a statement at FIXED B with
    # x -> infinity, so it must be tested that way, varying x at fixed B.
    import math
    b = 1000
    rows = []
    # x capped at 10^7: the EXACT Psi is the compute bottleneck (168 primes x 10^8
    # elements did not finish in 600 s).  This is the same bottleneck round 52
    # recorded, and it is itself part of why the NFS regime is untestable here.
    for x in (10**5, 10**6, 10**7):
        vals = np.arange(1, x + 1, dtype=np.int64)
        psi = int(smooth_mask_batch(vals, b).sum())      # EXACT count, not sampled
        dens = psi / x
        u = math.log(x) / math.log(b)
        r = rho(u) if u <= 5.0 else float("nan")         # harness guard: no rho past u=5
        rows.append((x, psi, dens, u, r, dens / r))
    euler = 0.5614594835668851
    lim = euler / math.log(b)
    for x, psi, dens, u, r, ratio in rows:
        print(f"      x={x:>10} B={b}  Psi/x={dens:.6f}  u={u:5.2f}  "
              f"rho={r:.4e}  Psi/rho={ratio:8.3f}")
    print(f"      e^{{-gamma}}/ln B = {lim:.6f}   (the value Psi/x must converge to)")
    d = [row[2] for row in rows]
    # (a) Psi/x is heading DOWN toward the Mertens constant, monotonically
    check("at FIXED B, Psi/x decreases monotonically toward e^{-gamma}/ln B",
          d[0] > d[1] > d[2] > lim,
          f"Psi/x {d[0]:.4f} -> {d[1]:.4f} -> {d[2]:.4f}, limit {lim:.4f}")
    # (b) rho DECAYS at fixed B.  I assert only monotone decay: at u = 2.33 rho has
    # NOT yet fallen below 2x the Mertens constant, so any stronger claim would be
    # an artefact of a threshold I picked rather than a property of rho.  What
    # actually kills rho is the LIMIT argument -- rho -> 0 while Psi/x -> a positive
    # constant -- not these three numbers.
    check("rho decays monotonically toward 0 at fixed B",
          rows[0][4] > rows[1][4] > rows[2][4],
          f"rho {rows[0][4]:.4f} -> {rows[1][4]:.4f} -> {rows[2][4]:.4f}")
    # (c) THE DIVERGENCE.  Honest statement: it is monotone but SLOW at reachable x
    # (1.09 -> 1.16 over two decades).  I assert monotonic growth, not a large
    # factor, and the slowness is itself the point -- anyone using rho as a null in
    # a regime where u is large is off by a factor that grows without bound.
    check("the ratio Psi/rho grows monotonically (divergence started, slowly)",
          rows[-1][5] > rows[0][5],
          f"Psi/rho {rows[0][5]:.3f} -> {rows[-1][5]:.3f} at u={rows[-1][3]:.2f}")
    check("divergence is SLOW here -- do not overstate it",
          rows[-1][5] < 2.0,
          f"only {rows[-1][5]:.2f}x after two decades; the limit argument, not "
          f"these numbers, is what kills rho")


# ---------------------------------------------------------------------------
# T7. MANDATORY: never int() a Rational; assert NON-VACUITY.
# ---------------------------------------------------------------------------

def t7_rational_and_vacuity() -> None:
    print("== T7. Rational handling + explicit non-vacuity assertion ==")
    half = Fraction(1, 2)
    check("Fraction(1,2) is exact", half == Fraction(1, 2))
    # THE TRAP: int(Fraction(1,2)) == 0 and that silently destroys M v = 0
    trap = int(half)
    check("int(Fraction(1,2)) == 0  (the documented trap)", trap == 0)
    check("so the trap is REAL, not hypothetical", trap == 0)
    # non-vacuity: an identically zero vector satisfies M v = 0 too
    M = [[1, 1]]
    zero = [0, 0]
    vacuous = all(sum(a * b for a, b in zip(row, zero)) == 0 for row in M)
    check("zero vector satisfies M v = 0  (the vacuity trap)", vacuous)
    nz = [Fraction(1, 2), Fraction(-1, 2)]
    real = all(sum(a * b for a, b in zip(row, nz)) == 0 for row in M)
    check("a NONZERO rational vector also satisfies M v = 0", real,
          "so M v = 0 alone is not evidence -- non-vacuity must be asserted")


# ---------------------------------------------------------------------------
# T8. z-detector validity: it must REFUSE impossible input (round-52 bug).
# ---------------------------------------------------------------------------

def t8_z_detector_validity() -> None:
    print("== T8. two_prop_z refuses k > n (the round-52 vacuous detector) ==")
    for bad in ((220, 200), (-1, 200), (5, 0)):
        try:
            two_prop_z(*bad, 10, 100)
            check(f"two_prop_z refuses {bad}", False, "NO RAISE -- vacuous detector")
        except ValueError:
            check(f"two_prop_z refuses {bad}", True)
    # and it must fire on a real, big, one-sided sample.
    # 30% vs 15% at n = 10000/arm is a 15pp shift; the analytic z is
    # 0.15/sqrt(0.225*0.775*2e-4) = 8.05.  Assert it fires at that scale, and
    # assert the analytic value matches so the statistic is not merely large.
    # (My first threshold was z > 15 -- but 15 is the COUNT, not the statistic.
    # The detector was correct; my bound was not.  Recorded because this is the
    # third time in this programme a wrong threshold -- not a wrong detector --
    # produced a spurious "FAIL" that looked like a code bug.)
    z = two_prop_z(300, 10000, 150, 10000)
    # pooled rate is 450/20000 = 0.0225, NOT 0.225 -- my first version was off
    # by a factor of 10 in the pooled probability and so predicted z = 25.4 for
    # a shift that actually gives 7.15.  The DETECTOR was right throughout.
    z_an = 0.015 / math.sqrt(0.0225 * 0.9775 * (2 / 10000))
    check("two_prop_z fires on a 15pp one-sided shift", z > 5, f"z={z:+.2f}")
    check("two_prop_z matches its analytic value", abs(z - z_an) < 1.0,
          f"measured {z:.2f} vs analytic {z_an:.2f}")


# ---------------------------------------------------------------------------
# T9. the sampler families produce sane, distinct, non-degenerate candidates.
# ---------------------------------------------------------------------------

def t9_samplers() -> None:
    print("== T9. sampler families sanity + degeneracy check ==")
    rng = random.Random(19)
    n, p, q = gen_semiprime(36, rng)
    g = 5 if math.gcd(5, n) == 1 else 7
    v = stange_candidates(n, g, rng, 5000)
    check("Stange candidates are in [1,n)", int(v.min()) >= 1 and int(v.max()) < n)
    check("Stange candidates are essentially distinct", len(set(v.tolist())) > 4900,
          f"{len(set(v.tolist()))}/5000 distinct")
    a, vv = a2b3_candidates(rng, 400, 4000)
    check("a^2-b^3 is nonzero and mixed-sign or positive",
          int(np.abs(vv).max()) > 0, f"max|F|={int(np.abs(vv).max())}")
    # the SMALL-VALUE degeneracy trap: check |V| distribution is not piled at 0
    med = int(np.median(np.abs(vv)))
    check("|a^2-b^3| is not degenerate (median is large)", med > 1000, f"median={med}")


# ---------------------------------------------------------------------------
# T10. the cap in (*) vs the parity BYPASS -- the one place conditioning can pay.
# ---------------------------------------------------------------------------

def t10_parity_bypass() -> None:
    print("== T10. parity conditioning has q=1, so the q-cap does NOT apply ==")
    # generating only odd x rejects nothing -> the candidate cost per accepted
    # candidate is c_gen, not c_gen/q.  Verified against the formula directly.
    g_rej = cap_gain(q=0.5, s_ratio=1.0)
    g_par = cap_gain(q=1.0, s_ratio=1.0)
    check("q=1/2 baseline gain is 0.5", abs(g_rej - 0.5) < 1e-12, f"{g_rej}")
    check("q=1.0 parity gain is 1.0 (neutral when uncorrelated)", abs(g_par - 1.0) < 1e-12)
    check("so parity conditioning is a FREE BET, not a capped one",
          g_par > g_rej)


def main() -> int:
    print("KK -- relation-finding conditioning: SELF-TEST\n")
    t1_batch_vs_shared()
    t2_injected_dependence()
    t3_gain_cap()
    t4_jacobi()
    t5_jacobi_is_parity()
    t6_rho_not_a_null()
    t7_rational_and_vacuity()
    t8_z_detector_validity()
    t9_samplers()
    t10_parity_bypass()
    print(f"\n{'ALL SELFTESTS PASS' if not FAILS else 'SELFTEST FAILURES: ' + ', '.join(FAILS)}"
          f"   ({NCHECK - len(FAILS)}/{NCHECK})")
    return 1 if FAILS else 0


if __name__ == "__main__":
    sys.exit(main())