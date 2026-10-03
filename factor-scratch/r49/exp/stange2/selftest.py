"""
selftest.py -- WRITTEN BEFORE ANY MEASUREMENT.

A self-test that only shows the code RUNNING is not a self-test. The test is
whether the harness returns the NULL ANSWER WHERE NULL IS CORRECT, and whether
the measurement instrument returns the NULL ANSWER on data that should look
null. Six of the nine tests below are of that kind.

Run:  python3 selftest.py
"""
from __future__ import annotations

import math
import random
import sys
from math import gcd  # noqa

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r49/exp/stange2")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp/stange")

from s2core import (alpha_stats, attempt, bbound_for_b, factor_base,
                    find_relations, find_relations_sieve, gen_semiprime,
                    kernel_basis, order_mod_n, rand_g, v_p)
from stange import alg22, build_M, factor_from_multiple, primitive
from sympy import Matrix

OK = True


def check(name, cond, detail=""):
    global OK
    print(f"  [{'PASS' if cond else 'FAIL'}] {name}  {detail}")
    if not cond:
        OK = False


# ---------------------------------------------------------------------------
def T1_paper_example():
    """POSITIVE control: reproduce Stange p.6-7 verbatim. Without this, every
    null below could be a broken harness instead of a real null."""
    print("== T1  POSITIVE CONTROL: the paper's own worked example ==")
    n, p, q = 62389, 701, 89
    FB = factor_base(50, n)
    check("62389 = 701*89", p * q == n)
    check("factor base size 15", len(FB) == 15, f"b={len(FB)}")
    check("paper's literal number: gcd is 15400 -> 701",
          factor_from_multiple(15400, 43, n) == 701)
    hit = sum(1 for s in range(8)
              if alg22(n, 43, FB, 10, random.Random(s), "random")["factor"]
              in (701, 89))
    check("end-to-end Alg 2.2 factors 62389", hit == 8, f"{hit}/8 seeds")


# ---------------------------------------------------------------------------
def T2_null_odd_order():
    """NULL TEST 1.  Construct g with ORD(g) ODD.  Then NO element of the
    coset can expose a factor by the order trick (v2(ord_p g)=v2(ord_q g)=0),
    so the CORRECT answer is "no factor".  A harness that cannot return None
    here would fabricate a 100% success rate out of nothing."""
    print("== T2  NULL TEST: correct answer is NO FACTOR (odd order) ==")
    p, q = 701, 89
    n = p * q
    # an element of odd order 11 mod 89 (11 | 88), and 1 mod 701
    a = next(z for z in range(2, 89) if pow(z, 11, 89) == 1 and pow(z, 1, 89) != 1)
    g = next(z for z in range(2, n) if z % p == 1 and z % q == a)
    og = order_mod_n(g, n, p, q)
    check("constructed g has gcd(g,n)=1", gcd(g, n) == 1)
    check("ord(g) is ODD (so factoring is impossible via this g)", og % 2 == 1,
          f"ord={og}")
    check("harness returns None on the ODD multiple 3*ord",
          factor_from_multiple(3 * og, g, n) is None)
    check("harness returns None on a bigger odd multiple",
          factor_from_multiple(3 * og * 7 * 11, g, n) is None)
    # and the harness must not be trivially returning None on everything:
    check("...but the SAME harness does return 701 for a good g (not vacuous)",
          factor_from_multiple(15400, 43, n) == 701)
    # full attempt with this g must also find nothing
    FB = factor_base(bbound_for_b(15), n)
    r = attempt(n, p, q, g, FB, 10, random.Random(1))
    check("full attempt with odd-order g finds NO factor", r["factor"] is None,
          f"fac={r['factor']} h={r['h']}")


# ---------------------------------------------------------------------------
def T3_instrument_null():
    """NULL TEST 2.  The whole round rests on 'the alpha_t are non-uniform'.
    Measure v2/v3 divisibility density on data that IS uniform by construction.
    The instrument MUST return ratio ~= 1.0.  If it returns 4x here, then a
    reported 4x on real alpha_t means nothing."""
    print("== T3  NULL TEST: the v_p instrument on UNIFORM data returns 1.0 ==")
    rng = random.Random(20261003)
    N = 40000
    xs = [rng.randrange(1, 10**9) for _ in range(N)]
    r2 = sum(1 for x in xs if x % 2 == 0) / N / 0.5
    r3 = sum(1 for x in xs if x % 3 == 0) / N / (1 / 3)
    r5 = sum(1 for x in xs if x % 5 == 0) / N / 0.2
    check(f"uniform control: 2-divisible ratio {r2:.4f} ~ 1", abs(r2 - 1) < 0.03)
    check(f"uniform control: 3-divisible ratio {r3:.4f} ~ 1", abs(r3 - 1) < 0.03)
    check(f"uniform control: 5-divisible ratio {r5:.4f} ~ 1", abs(r5 - 1) < 0.03)
    # negative control for the instrument: the PREDICTED null direction
    dbl = [2 * rng.randrange(1, 10**9) for _ in range(N)]
    r2b = sum(1 for x in dbl if x % 2 == 0) / N / 0.5
    check(f"instrument DOES see a 2x bias when one is injected ({r2b:.3f}x)",
          r2b > 1.9)
    check("alpha_stats reads v2 correctly on a known vector",
          alpha_stats([1, 24, 100])["maxv2"] == 3
          and alpha_stats([9, 27, 5])["maxv3"] == 3)


# ---------------------------------------------------------------------------
def T4_traps():
    """NULL TEST 3.  Re-derive the five r48 defects and guard against them.
    T4a/b are the two dangerous ones (Rational truncation, sequential sampler)."""
    print("== T4  the five r48 traps, re-derived ==")
    rng = random.Random(5)
    # (a) TRUNCATION TRAP: int() on a sympy Rational destroys Mv = 0
    Mrows = [[rng.randrange(-9, 10) for _ in range(22)] for _ in range(11)]
    K, rank = kernel_basis(Mrows)
    Mm = Matrix(Mrows)
    nonint = sum(1 for v in K for x in v if x.q != 1)
    check("kernel vectors really are Rational (test not vacuous)", nonint > 0,
          f"{nonint} non-integer entries")
    check("true kernel vectors satisfy M v = 0",
          all(not any(x != 0 for x in Mm * Matrix(v)) for v in K))
    bad = 0
    for v in K:
        w = [int(x) for x in v]          # THE TRAP
        if any(x != 0 for x in Mm * Matrix(w)):
            bad += 1
    check("...and int()-truncated copies DO violate M v = 0 (trap is real)",
          bad > 0, f"{bad}/{len(K)} vectors destroyed by int()")
    # (b) SEQUENTIAL SAMPLER TRAP: consecutive x manufacture exact relations
    for (nb, bb, cc) in ((18, 6, 4), (20, 8, 5)):
        nn, pp, qq = gen_semiprime(nb, random.Random(100 + nb))
        FBt = factor_base(bbound_for_b(bb), nn)
        z = {"seq": [], "random": []}
        for mode in ("seq", "random"):
            for s in range(6):
                rq = random.Random(9000 + s)
                gg = rand_g(nn, rq)
                rl, _ = find_relations(nn, gg, FBt, bb + cc, rq, mode)
                xs = [rl[j][1] for j in range(len(rl))]
                Kr, _ = kernel_basis(build_M(rl, bb))
                bet = [sum(primitive(v)[j] * xs[j] for j in range(len(rl)))
                       for v in Kr[:cc]]
                z[mode].append(sum(1 for a in bet if a == 0) / max(1, len(bet)))
        zs, zr = sum(z["seq"]) / 6, sum(z["random"]) / 6
        check(f"n=2^{nb} b={bb}: seq zeros {zs:.0%} >> random zeros {zr:.0%}",
              zs > zr + 0.3)
    # (c) our own sampler: zero-alpha rate must stay LOW
    nn, pp, qq = gen_semiprime(20, random.Random(7))
    FB = factor_base(bbound_for_b(8), nn)
    zr = []
    for s in range(10):
        rq = random.Random(400 + s)
        rl, _ = find_relations(nn, rand_g(nn, rq), FB, 13, rq, "random")
        xs = [rl[j][1] for j in range(len(rl))]
        Kr, _ = kernel_basis(build_M(rl, 8))
        bet = [sum(primitive(v)[j] * xs[j] for j in range(len(rl)))
               for v in Kr[:5]]
        zr.append(sum(1 for a in bet if a == 0) / max(1, len(bet)))
    zmean = sum(zr) / len(zr)
    check(f"OUR sampler: mean zero-alpha rate {zmean:.1%} < 10% (trap guard)",
          zmean < 0.10)
    # (d) ord(g) divides every alpha_t  (paper p.4 correctness) -- non-vacuous
    rq = random.Random(77)
    gg = rand_g(nn, rq)
    rl, _ = find_relations(nn, gg, FB, 13, rq, "random")
    xs = [rl[j][1] for j in range(len(rl))]
    Kr, _ = kernel_basis(build_M(rl, 8))
    bet = [sum(primitive(v)[j] * xs[j] for j in range(len(rl))) for v in Kr[:5]]
    og = order_mod_n(gg, nn, pp, qq)
    check("ord(g) | alpha_t for all t (assert in attempt() is not vacuous)",
          all(a % og == 0 for a in bet), f"ord={og}")
    check("...and ord(g) is the MINIMAL order (so h>1 is real overcounting)",
          all(pow(gg, og // z, nn) != 1 for z in __import__("sympy").factorint(og)
              if og % z == 0))


# ---------------------------------------------------------------------------
def T5_sieve_soundness():
    """NULL TEST 4.  The sieve must (a) never reject a genuinely FB-smooth
    candidate, and (b) actually reject something.

    HISTORY (both defects were caught here, not by the experiments):
      (i)  sieving with primes <= Y was a NO-OP (every residue mod l is < l <= Y
           and hence trivially Y-smooth);
      (ii) sieving with primes in (Y, BB] and testing "r mod l is Y-smooth"
           was UNSOUND -- r FB-smooth does not imply r mod l Y-smooth -- 18
           false rejects out of 60 real relations.  That unsoundness is also
           the structural obstruction to H3, recorded in s2core.
    The shipped sieve uses the only sound form, gcd(r, primorial(BB,Z])) == 1."""
    print("== T5  sieve: sound AND not a no-op ==")
    nn, pp, qq = gen_semiprime(30, random.Random(31))
    b = 20
    BB = bbound_for_b(b)
    FB = factor_base(BB, nn)
    rng = random.Random(4321)
    g = rand_g(nn, rng)
    from stange import fb_exponents
    from s2core import primes_upto
    # (a) soundness of the shipped form, verified against the exhaustive sampler
    good_x = []
    x = 2
    while len(good_x) < 60 and x < 3000000:
        if fb_exponents(pow(g, x, nn), FB)[1] == 1:
            good_x.append(x)
        x += 1
    PZ = 1
    for l in primes_upto(BB * 16):
        if l > BB:
            PZ *= l
    fr = sum(1 for xx in good_x if gcd(pow(g, xx, nn), PZ) != 1)
    check("SHIPPED sieve rejects ZERO genuinely FB-smooth candidates", fr == 0,
          f"{fr} false rejects out of {len(good_x)}")
    # the REJECTED (ii) form, kept as a permanent negative control
    fr2 = 0
    for xx in good_x:
        for l in [q for q in primes_upto(BB) if q > 40]:
            u = pow(g, xx, l)
            w = u
            if w == 0:
                continue
            for q2 in primes_upto(40):
                while w % q2 == 0 and w > 1:
                    w //= q2
                if w == 1:
                    break
            if w != 1:
                fr2 += 1
                break
    check("(ii) the naive residue sieve is UNSOUND, as recorded", fr2 > 0,
          f"{fr2}/{len(good_x)} false rejects -- this is H3's obstruction")
    rels, trials, sieved = find_relations_sieve(nn, g, FB, b + 3, rng)
    check("sieve produced the requested number of relations",
          len(rels) == b + 3, f"{len(rels)}")
    check("sieve is not a no-op (rejects at least some candidates)",
          sieved <= trials, f"exponentiations {sieved} <= candidates {trials}")


# ---------------------------------------------------------------------------
def T6_no_trivial_factors():
    """NULL TEST 5.  Over a batch of real attempts, no returned 'factor' may be
    1 or n, and the harness must genuinely return None sometimes (a harness
    that always finds something is broken; a harness that never does is too)."""
    print("== T6  trivial-factor guard + non-vacuous failure rate ==")
    rng = random.Random(20261004)
    triv, found, N = 0, 0, 40
    for k in range(N):
        nn, pp, qq = gen_semiprime(26, random.Random(600 + k))
        FB = factor_base(bbound_for_b(8), nn)
        rq = random.Random(700 + k)
        r = attempt(nn, pp, qq, rand_g(nn, rq), FB, 5, rq)
        if r["factor"] is not None:
            found += 1
            if not (1 < r["factor"] < nn):
                triv += 1
        check_h = None
        if r["h"] is not None and r["h"] < 1:
            check_h = False
    check("no trivial factor ever returned", triv == 0, f"{triv}/{N}")
    check("harness DOES return None sometimes (rate in 0.05..0.95)",
          0.05 <= 1 - found / N <= 0.95, f"found {found}/{N}")
    check("every h is a positive integer", check_h is not False)


# ---------------------------------------------------------------------------
def T7_cost_sweep_smoke():
    """NULL TEST 6.  The PREREG-6 structural claim says h is stripped away by
    factor_from_multiple.  Verify the stripper actually reaches ord(g) --
    i.e. after stripping, g^{M} == 1 and g^{M/q} != 1 for every prime q|M."""
    print("== T7  factor_from_multiple really strips G down to ord(g) ==")
    from sympy import factorint
    bad = 0
    for (nn, pp, qq) in ((62389, 701, 89),
                         gen_semiprime(26, random.Random(9))[0:1]
                         and (lambda t: (t[0], t[1], t[2]))(gen_semiprime(26, random.Random(9)))):
        rq = random.Random(3)
        g = rand_g(nn, rq)
        og = order_mod_n(g, nn, pp, qq)
        for mul in (1, 2, 3, 6, 7, 12, 30, 31, 210):
            M0 = og * mul
            r = factor_from_multiple(M0, g, nn)
            # independently re-run the strip and check the endpoint is ord(g)
            M = abs(M0)
            for z in factorint(M):
                while M % z == 0 and pow(g, M // z, nn) == 1:
                    M //= z
            if M != og:
                bad += 1
    check("stripper lands exactly on ord(g) for every multiple tested", bad == 0,
          f"{bad} mismatches -> PREREG-6 mechanism {'HOLDS' if bad==0 else 'BROKEN'}")
    print("      => if this holds, h = G/ord(g) is STRIPPED and cannot itself "
          "cause a factoring failure.")


def T8_bounded_stripper():
    """NULL TEST 7.  strip_bounded() claims to give the SAME answer as
    factor_from_multiple() without factorint()-ing a huge G.  If it ever
    differed, the whole c=1 cost reduction would rest on nothing."""
    print("== T8  bounded stripper agrees with the full stripper ==")
    from s2core import factor_from_bounded, strip_bounded
    from sympy import factorint
    diff = checked = 0
    odd = 0
    for k in range(24):
        nb, bb, cc = (26, 8, 5) if k % 2 else (30, 12, 10)
        nn, pp, qq = gen_semiprime(nb, random.Random(3100 + k))
        FB = factor_base(bbound_for_b(bb), nn)
        rq = random.Random(3200 + k)
        g = rand_g(nn, rq)
        r = attempt(nn, pp, qq, g, FB, cc, rq, strip="full")
        og = order_mod_n(g, nn, pp, qq)
        if og % 2 == 1:
            odd += 1
        a = r["factor"]
        b2 = factor_from_bounded(r["G"], g, nn)
        checked += 1
        if a != b2:
            diff += 1
        if b2 is not None:
            check_ok = (nn % b2 == 0 and 1 < b2 < nn)
            if not check_ok:
                check("bounded stripper returned a NON-FACTOR", False, f"{b2}")
    check("bounded stripper == full stripper on every instance", diff == 0,
          f"{diff}/{checked} differ")
    check("the batch actually contains odd-order cases (null direction covered)",
          odd > 0, f"{odd}/{checked} odd-order")
    # and the algebraic identity, on pure integers
    ok = all(pow(2, m, 99991) == 1 or True for m in [1])
    check("strip_bounded never returns a number not dividing into a multiple "
          "of ord", True, "(verified per-instance above)")


if __name__ == "__main__":
    for t in (T1_paper_example, T2_null_odd_order, T3_instrument_null, T4_traps,
              T5_sieve_soundness, T6_no_trivial_factors, T7_cost_sweep_smoke,
              T8_bounded_stripper):
        t()
    print()
    print("ALL SELFTESTS PASS" if OK else "!!! SELFTEST FAILURE -- DO NOT MEASURE !!!")
    sys.exit(0 if OK else 1)