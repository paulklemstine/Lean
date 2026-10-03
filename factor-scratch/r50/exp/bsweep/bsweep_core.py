"""
bsweep_core -- round 50, agent W: the b-sweep of TOTAL COST.

REUSES, does not rewrite:
  /home/raver1975/lean/factor-scratch/r48/exp/stange/stange.py    (alg 2.2 core)
  /home/raver1975/lean/factor-scratch/r49/exp/stange2/s2core.py   (attempt, jacobi,
                                                                    bounded stripper)
  /home/raver1975/lean/factor-scratch/r48/_shared/dickman.py       (rho, is_smooth)

==============================================================================
PREREGISTRATION -- written 2026-10-03, BEFORE any measurement in this round.
==============================================================================

BACKGROUND (established by round 49, agent U, `notes/U_stange_improve.md`):
the per-attempt success rate is the order-finding constant P = 20/27 EXACTLY,
independent of b, c and n (the index h = G/ord(g) is algebraically erased by the
stripper before the gcd runs -- U's self-test T7).  Therefore the ONLY lever
that matters is COST, and the cost per SUCCESSFUL FACTOR is

      COST(b, c, n)  =  (b + c) * (exponentiations per relation) / rate

with rate = 20/27 (or 8/9 under the Jacobi filter).  NOTE THE ORDER OF
OPERATIONS: a lower exponentiations-per-relation that raises (b+c) is NOT an
improvement, and the (b+c) factor is inside the metric.

-------------------------------------------------------------------------------
PREREG-0 (BASELINE, MANDATORY GATE)
    Fresh seeds disjoint from r48 (7-11) and r49 (>=77000), using r48's own
    kill configurations, must reproduce a pooled rate of 0.70-0.85 against the
    closed form 20/27 (|z| < 3).  FAILURE => STOP, report, do not sweep.

-------------------------------------------------------------------------------
PREREG-1 (H1)  cost(b) HAS AN INTERIOR MINIMUM over b in [4, 64].
    Model: cost(b) = (b+1)/rho(u(b)), u(b) = log2(n)/log2(prime(b)).
    Computed from the SHARED rho, c = 1, BEFORE measurement:

      n ~ 2^30: argmin over b in [4,1000] is b* = 200, cost 3535 exp/attempt
                (= 4772 exponentiations per SUCCESSFUL factor).
                Over the REQUIRED grid [4..64] the model is still strictly
                FALLING at b=64 (5324 at b=64 vs 3535 at b=200).

      n ~ 2^40: argmin over b in [4,1000] is b* = 700, cost 23841
                (= 32186 per successful factor).

    So the model does NOT put the argmin inside [4,64] at either size.  This is
    the number to beat: the MEASUREMENT must be compared against the model
    curve at the same b, not against "cost went down".

    Preregistered expectation that measured and model DIFFER: round 49 measured
    smoothness running ~5-25x ABOVE the asymptotic rho at BB=13..71 (small
    BB), converging to rho at large BB.  A cost curve that is LOWER than the
    model on the left and EQUAL to it on the right has its argmin at SMALLER b
    than the model predicts.

    PREREG-1a (directional): measured argmin(b) at 2^30 is in [32, 120] --
    i.e. BELOW the model's b*=200, because of the above.
    PREREG-1b (mechanism): measured exp/rel at b=64 is BELOW the model 1/rho
    (measured smoothness > rho), and the ratio measured/model is monotone
    decreasing in b.

-------------------------------------------------------------------------------
PREREG-2 (H2)  THE ARGMIN MOVES WITH n, TO LARGER b.
    Model says b* = 200 at 2^30 and b* = 700 at 2^40.  Preregistered
    qualitative prediction: argmin(2^40) > argmin(2^30).  If both are pinned to
    the top of the measurable grid (the argmin runs off the end), that is
    REPORTED AS "no argmin found up to b_max", NOT as a number.

-------------------------------------------------------------------------------
PREREG-3 (H3)  COMBINED CONFIGURATION.
    With (a) c=1 instead of c=10, and (b) g drawn with Jacobi(g/n) = -1:
      * the RATE rises 20/27 -> 8/9 (round 49, held out), a factor 1.20x;
      * the COST FACTOR (b+c) falls from b+10 to b+1.
    PREREGISTERED: the optimal b is UNCHANGED by (a) and (b), because both act
    as a constant multiplier on the b-dependent curve -- (b) multiplies cost by
    27/20 and (a) is an additive -9 in (b+c), which at b >= 32 is a <=22%
    effect that falls as b grows.  FALSIFIED if the held-out combined sweep
    puts its argmin at a b different from the unfiltered sweep's argmin by more
    than the sampling noise on the cost curve.

-------------------------------------------------------------------------------
PREREG-4 (b = 6 ANOMALY)  Round 49 measured a b=6 rate of 0.6417 (z = -2.48)
    and never settled it.  PREREGISTERED: at N = 400 fresh instances the b=6
    rate is consistent with 20/27 (|z| < 3).  If it is NOT, the anomaly is real
    and b=6 is excluded from every recommendation.  The question is RATE ONLY,
    and is asked separately from COST -- a cheap b is worthless if it is also
    an unreliable one, and a b=6 cost number quoted without its rate is the
    specific error to avoid.

-------------------------------------------------------------------------------
PREREG-5 (INFEASIBILITY IS A RESULT, NOT A NUMBER)
    Any (n, b) whose per-instance exponentiation count exceeds CAP is reported
    as INFEASIBLE with the cost as a LOWER BOUND.  No point estimate is
    extrapolated from a capped run.

-------------------------------------------------------------------------------
PREREG-6 (COST METRIC, fixed before measuring)
    PRIMARY:   exp per successful factor = (b+c) * (exp/rel) / rate
    SECONDARY: exp/rel  (exponentiations per relation) -- reported, but a
               decrease in it is an improvement ONLY if the primary falls.
    WALL CLOCK is reported at the argmin and is a SEPARATE metric: it includes
    the linear algebra, which is NOT counted in exponentiations and grows with
    b.
-------------------------------------------------------------------------------
"""

from __future__ import annotations

import math
import random
import sys
import time
from math import gcd

R48 = "/home/raver1975/lean/factor-scratch/r48/exp/stange"
R48SH = "/home/raver1975/lean/factor-scratch/r48/_shared"
R49 = "/home/raver1975/lean/factor-scratch/r49/exp/stange2"
for _p in (R48, R48SH, R49):
    if _p not in sys.path:
        sys.path.insert(0, _p)

from stange import (  # noqa: E402
    alg22, bbound_for_b, build_M, factor_base, factor_from_multiple,
    fb_exponents, find_relations, gen_semiprime, index_S_full, kernel_basis,
    order_mod_n, primitive, zeta,
)
from s2core import (  # noqa: E402
    alpha_stats, factor_from_bounded, jacobi, primes_upto, rand_g, strip_bounded,
)
from dickman import is_smooth, rho  # noqa: E402  -- SHARED, do not re-implement
from sympy import primerange  # noqa: E402

P_TRUE = 20.0 / 27.0
P_JACOBI = 8.0 / 9.0


# ---------------------------------------------------------------------------
# cost model (the thing the measurement is compared against)
# ---------------------------------------------------------------------------

def bb_for_b(b: int) -> int:
    """Factor-base bound: the b-th prime. Same convention as stange.bbound_for_b."""
    return bbound_for_b(b)


def u_of(b: int, nbits: float) -> float:
    """Dickman parameter u = log(n)/log(BB), in log2 units."""
    return nbits / math.log2(bb_for_b(b))


def cost_model(b: int, c: int, nbits: float) -> float:
    """(b+c)/rho(u) -- exponentiations per ATTEMPT under the asymptotic model."""
    return (b + c) / rho(u_of(b, nbits))


def cost_model_per_success(b: int, c: int, nbits: float, rate: float = P_TRUE) -> float:
    return (b + c) / rho(u_of(b, nbits)) / rate


def model_argmin(nbits: float, c: int = 1, bmax: int = 1000) -> tuple:
    best, bb = None, None
    for b in range(4, bmax + 1):
        v = cost_model(b, c, nbits)
        if best is None or v < best:
            best, bb = v, b
    return bb, best


# ---------------------------------------------------------------------------
# relation search: counts EXPONENTIATIONS (pow calls), not loop iterations,
# and has a hard cap so that an infeasible configuration is reported as such.
# ---------------------------------------------------------------------------

def find_relations_counted(n, g, FB, need, rng, cap=2_000_000):
    """Exactly stange.find_relations(sampler='random') but:
      - returns the number of pow() calls, not loop iterations;
      - aborts at `cap` exponentiations and reports cap_hit.
    A duplicate x is skipped BEFORE the exponentiation, exactly as upstream, so
    the pow count is the true exponentiation count.
    """
    rels, seen = [], set()
    exps = 0
    while len(rels) < need:
        if exps >= cap:
            return rels, exps, True
        x = rng.randrange(1, n)
        if x in seen:
            continue
        r = pow(g, x, n)
        exps += 1
        exps_v, rem = fb_exponents(r, FB)
        if rem == 1:
            seen.add(x)
            rels.append((exps_v, x))
    return rels, exps, False


def jacobi_g(n, rng, want=-1, tries=200):
    """Draw a unit g mod n with Jacobi(g/n) == want.

    Uses the REAL Jacobi symbol.  NEVER pow(g,(n-1)//2,n)==n-1: that is Euler's
    criterion, valid only for PRIME n, and it never fires for n=pq -- unbounded
    it hangs, bounded it silently deletes the arm and reports 'no effect'.
    (Round 49 lost ~40 minutes to exactly this.)
    """
    for _ in range(tries):
        g = rand_g(n, rng)
        if jacobi(g, n) == want:
            return g
    raise RuntimeError("jacobi filter: no g found in %d tries" % tries)


# ---------------------------------------------------------------------------
# one attempt
# ---------------------------------------------------------------------------

def attempt_counted(n, p, q, g, FB, c, rng, strip="bounded", cap=2_000_000,
                    Y=200_000):
    """Instrumented Algorithm 2.2. Returns None-equivalent dict with cap_hit."""
    b = len(FB)
    t0 = time.perf_counter()
    rels, exps, cap_hit = find_relations_counted(n, g, FB, b + c, rng, cap)
    t_rels = time.perf_counter() - t0
    if cap_hit:
        return {"n": n, "b": b, "c": c, "g": g, "cap_hit": True,
                "exps": exps, "rels_found": len(rels), "factor": None,
                "secs": time.perf_counter() - t0, "secs_rels": t_rels,
                "ok": False, "G": 0, "rank": 0, "dimK": 0}
    t1 = time.perf_counter()
    Mrows = build_M(rels, b)
    K, rank = kernel_basis(Mrows)
    xs = [rels[j][1] for j in range(len(rels))]
    betas = [sum(primitive(v)[j] * xs[j] for j in range(len(rels)))
             for v in K[:c]]
    G = 0
    for a in betas:
        G = gcd(G, abs(a))
    og = order_mod_n(g, n, p, q)
    assert G == 0 or G % og == 0, "p.4 correctness: ord(g) divides every alpha_t"
    t_alg = time.perf_counter() - t1
    t2 = time.perf_counter()
    if G:
        fac = (factor_from_multiple(G, g, n) if strip == "full"
               else factor_from_bounded(G, g, n, Y))
    else:
        fac = None
    t_str = time.perf_counter() - t2
    return {"n": n, "b": b, "c": c, "g": g, "cap_hit": False, "exps": exps,
            "rels_found": len(rels), "factor": fac, "ok": fac in (p, q),
            "G": G, "ord_g": og, "rank": rank, "dimK": len(K),
            "secs": time.perf_counter() - t0, "secs_rels": t_rels,
            "secs_alg": t_alg, "secs_strip": t_str}


def one(nbits, b, c, seed, jac=0, strip="bounded", cap=2_000_000, Y=200_000):
    """A single trial: fresh n, fresh g, one full attempt."""
    rng = random.Random(seed)
    n, p, q = gen_semiprime(nbits, rng)
    FB = factor_base(bb_for_b(b), n)
    assert len(FB) == b, (len(FB), b, nbits)
    g = jacobi_g(n, rng, -1) if jac else rand_g(n, rng)
    r = attempt_counted(n, p, q, g, FB, c, rng, strip=strip, cap=cap, Y=Y)
    r["seed"] = seed
    r["nbits"] = nbits
    if r["factor"] is not None:
        assert n % r["factor"] == 0 and 1 < r["factor"] < n
    return r


# ---------------------------------------------------------------------------
# SELF-TESTS.  The standard here is the round-48 one: a self-test that only
# shows the code running is not a self-test.  Each returns the NULL / FAILURE
# where that is the correct answer.
# ---------------------------------------------------------------------------

def selftest(verbose=True) -> bool:
    ok = True

    def check(name, cond, detail=""):
        nonlocal ok
        print(f"  [{'PASS' if cond else 'FAIL'}] {name} {detail}", flush=True)
        if not cond:
            ok = False

    def say(*a):
        if verbose:
            print(*a, flush=True)

    say("== W1. the smoothness predicate CAN return False ==")
    # Two harnesses in this round called everything smooth.  If is_smooth and
    # the acceptance test in find_relations_counted cannot reject, nothing they
    # report about cost means anything.
    # NOTE the size.  The FIRST version of this test used b=8 at n~2^30, where
    # rho(u=7.06) = 2.8e-6, and demanded acc>0 -- it correctly returned 0/1200
    # accepted and the self-test FAILED.  The harness was right and the test was
    # wrong.  Two tests, both sides, at a size where both classes exist:
    rng = random.Random(4242)
    n30, _, _ = gen_semiprime(30, random.Random(1))
    FBbig = factor_base(bb_for_b(8), n30)
    g30 = rand_g(n30, rng)
    acc30 = sum(1 for e in range(600)
                if fb_exponents(pow(g30, e, n30), FBbig)[1] == 1)
    check("b=8 at n=2^30 accepts ~nothing (rho(u=7.06) ~ 3e-6)", acc30 <= 1,
          f"{acc30}/600 accepted")
    n20, _, _ = gen_semiprime(20, random.Random(2))
    FB = factor_base(bb_for_b(26), n20)
    BBl = FB[-1]
    g20 = rand_g(n20, rng)
    cands = [pow(g20, e, n20) for e in range(600)]
    acc, rej = 0, 0
    for r in cands:
        _, rem = fb_exponents(r, FB)
        if rem == 1:
            acc += 1
            assert is_smooth(r, BBl), "acceptance disagrees with is_smooth"
        else:
            rej += 1
            assert not is_smooth(r, BBl), "REJECTED but is_smooth says smooth"
    check(f"b=26 at n=2^20: rejects {rej}/600 AND accepts {acc}/600",
          rej > 400 and acc > 5)
    # and it must reject a KNOWN-rough number on the SAME base.  (The first
    # version of this line reused the b=26 base, where 3^11*101 IS smooth, and
    # the test failed for the right reason again.)
    FB8 = factor_base(bb_for_b(8), n20)
    rough = 3**11 * 101          # lpf = 101 > BB(8) = 19
    check("known-rough rejected (B=19, lpf=101)", not is_smooth(rough, 19))
    _, rem = fb_exponents(rough, FB8)
    check("known-rough rejected by acceptance path", rem != 1)
    smooth_known = 3**11         # lpf = 3 <= 19
    check("known-smooth ACCEPTED on the same base",
          is_smooth(smooth_known, 19) and fb_exponents(smooth_known, FB8)[1] == 1)

    say("== W2. the relation search returns EXACTLY relations, and they verify ==")
    # Not 'it ran'.  Every returned relation must satisfy
    # g^x == prod p_i^{e_i} (mod n), with a DISTINCT x, exactly b+c of them.
    for (nb, bb, cc) in ((20, 8, 2), (24, 10, 3)):
        n, p, q = gen_semiprime(nb, random.Random(900 + nb))
        FBt = factor_base(bb_for_b(bb), n)
        rq = random.Random(31 + nb)
        g = rand_g(n, rq)
        rels, exps, cap_hit = find_relations_counted(n, g, FBt, bb + cc, rq)
        check(f"n=2^{nb} b={bb} c={cc}: exactly {bb+cc} relations, no cap",
              len(rels) == bb + cc and not cap_hit, f"got {len(rels)}")
        okv = True
        for e, x in rels:
            prod = 1
            for i, pp in enumerate(FBt):
                prod = prod * pow(pp, e[i], n) % n
            if prod != pow(g, x, n) or not (1 <= x < n):
                okv = False
        check(f"  every relation verifies g^x == prod p^e (mod n)", okv)
        check(f"  x values distinct", len({x for _, x in rels}) == len(rels))
        check(f"  exps ({exps}) >= relations ({len(rels)})", exps >= len(rels))

    say("== W3. the CAP fires and reports a LOWER BOUND, not a number ==")
    # The null case.  b=4 at n=2^30 is ~10^6 exponentiations per relation; with
    # cap=5000 the harness MUST return cap_hit rather than an extrapolated cost.
    n, p, q = gen_semiprime(30, random.Random(5))
    FBt = factor_base(bb_for_b(4), n)
    rq = random.Random(6)
    g = rand_g(n, rq)
    rels, exps, cap_hit = find_relations_counted(n, g, FBt, 5, rq, cap=5000)
    check("b=4, n=2^30, cap=5000 -> cap_hit True", cap_hit)
    check("  and it did NOT fabricate the full relation set",
          len(rels) < 5, f"got {len(rels)}")
    check("  exps stopped at the cap", exps <= 5000, f"exps={exps}")
    r = one(30, 4, 1, 5, cap=5000)
    check("attempt_counted propagates cap_hit", r["cap_hit"] is True)

    say("== W4. the rate is a PROPERTY OF g, not of the relation set ==")
    # A direct check of the mechanism the whole round rests on: with the SAME
    # relations and the SAME g, changing nothing about the search cannot change
    # success.  Concretely: score the very same instances with the full and the
    # bounded stripper and require agreement (round 49's T8), and verify that
    # the stripper lands exactly on ord(g).
    n, p, q = gen_semiprime(20, random.Random(77))
    FBt = factor_base(bb_for_b(8), n)
    agree = 0
    for s in range(20):
        rq = random.Random(7000 + s)
        g = rand_g(n, rq)
        rels, exps, cap_hit = find_relations_counted(n, g, FBt, 8 + 1, rq)
        Mrows = build_M(rels, 8)
        K, _ = kernel_basis(Mrows)
        xs = [rels[j][1] for j in range(len(rels))]
        G = 0
        for v in K[:1]:
            G = gcd(G, abs(sum(primitive(v)[j] * xs[j] for j in range(len(rels)))))
        og = order_mod_n(g, n, p, q)
        if G:
            Mf = factor_from_multiple(G, g, n)
            Mb = factor_from_bounded(G, g, n)
            agree += (Mf == Mb)
            if Mb is not None:
                assert n % Mb == 0 and 1 < Mb < n
        # T7 model: stripper lands exactly on ord(g).
        Ms = strip_bounded(G, g, n)
        assert Ms % og == 0 and (Ms // og) % 2 == 1, "stripper left an even quotient"
    check("full stripper == bounded stripper on every non-null instance",
          agree >= 17, f"{agree}/20 agreed")

    say("== W5. Jacobi filter: finds g, and is NOT the Euler-criterion bug ==")
    # The failure mode that cost round 49 40 minutes.  Test is that it TERMINATES
    # and that its g really has Jacobi = -1, cross-checked against sympy.
    n, p, q = gen_semiprime(24, random.Random(555))
    rq = random.Random(556)
    t0 = time.perf_counter()
    gs = [jacobi_g(n, rq, -1) for _ in range(50)]
    dt = time.perf_counter() - t0
    check("50 Jacobi-conditioned draws terminate", dt < 20.0, f"{dt:.2f}s")
    from sympy.functions.combinatorial.numbers import jacobi_symbol
    agree = sum(1 for g in gs if int(jacobi_symbol(g, n)) == -1)
    check("all 50 satisfy (g/n) = -1 vs sympy", agree == 50, f"{agree}/50")
    check("all 50 are units mod n", all(gcd(g, n) == 1 for g in gs))
    # And the negative control: the Euler form never fires for n = pq.
    euler_hits = sum(1 for _ in range(2000)
                     if pow(rand_g(n, rq), (n - 1) // 2, n) == n - 1)
    check("NEGATIVE CONTROL: pow(g,(n-1)/2,n)==n-1 fires ~0 times for n=pq",
          euler_hits == 0, f"{euler_hits}/2000")

    say("== W6. the cost model is the shared rho, and rho is the null ==")
    check("cost_model(12,1,30) == 13/rho(30/log2(37))",
          abs(cost_model(12, 1, 30) - 13 / rho(30 / math.log2(37))) < 1e-9)
    check("rho(3) = 0.0486084 (Dickman table)", abs(rho(3.0) - 0.0486084) < 1e-5)
    check("rho(1)==1, rho(0)==1, rho(-1)==0",
          rho(1.0) == 1.0 and rho(0.0) == 1.0 and rho(-1.0) == 0.0)

    say("== W7. the PRIMARY metric is not the secondary metric ==")
    # A configuration with BETTER exp/rel but WORSE (b+c) must be scored WORSE
    # by the primary.  This is the specific confusion the round must avoid.
    def primary(b, c, expr, rate):
        return (b + c) * expr / rate
    check("worse exp/rel + smaller (b+c): primary prefers the cheap-per-candidate one",
          primary(20, 1, 400, P_TRUE) < primary(6, 1, 20000, P_TRUE))
    check("primary == (b+c)/rho/rate under the model",
          abs(primary_model(20, 1, 30, P_TRUE) - cost_model_per_success(20, 1, 30)) < 1e-9)

    say()
    if ok:
        print("ALL SELFTESTS PASS -- harness is usable.")
    else:
        print("!!! SELFTEST FAILURE -- do NOT report any measurement from this harness.")
    return ok


def primary_model(b, c, nbits, rate):
    return (b + c) / rho(u_of(b, nbits)) / rate


if __name__ == "__main__":
    sys.exit(0 if selftest() else 1)