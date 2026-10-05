"""
exp_d1.py -- D1: WHICH constructions have a PERIODIC relation condition, and
does a sieve actually apply?  Measured per construction, per modulus, with the
smallest period REPORTED rather than asserted.

THE CLASSIFIER IS MECHANISTIC, NOT A LABEL
------------------------------------------
A sieve applies to a candidate stream V(i) iff BOTH:

  (M1) CHEAP REDUCTION:  V(i) mod l is computable from i without forming V(i).
                        For a polynomial V this is free (V mod l depends on
                        i mod l).  For an exponential V = g^i mod n it is NOT,
                        because reduction mod n is not a ring homomorphism
                        downward (LL_hybrid F1: 88.2% mismatch).
  (M2) SMALL PERIOD:    hit(i) = [l | V(i)] is periodic with a period that is
                        small AND computable without already knowing the
                        factorization.

(M2) is the one round 51 stated as "periodic vs aperiodic", and the binary is
too coarse.  This run measures the PERIOD LENGTH, because that is where the
design decision lives:

  * NFS / SNFS / Dixon-interval / ECM-stage-2:  period == l exactly.  Sieve.
  * Stange:  hit set IS periodic -- with period ord_n(g), which is huge and is
    NOT computable without factoring.  "Aperiodic" was the d <= 64 reading.
  * p-1 / p+1 / Williams / Coppersmith / class groups: no candidate STREAM at
    all, so periodicity is undefined, not false.

THE CONSTRUCTIONS, AND THE SIEVED QUANTITY EACH ONE ACTUALLY SIEVES
------------------------------------------------------------------
  GNFS          V(a) = a^2 - b^k, b fixed, index a          (canonical periodic)
  SNFS          V(a) = a - b,   index a
  Dixon/CFRAC   V(y) = y, y in [0,p), index y  -- sieves the INTERVAL, then
                takes x = sqrt(y) mod p.  Note the sieve is on y, NOT on
                x^2 mod n.  That distinction is the whole story.
  Dixon-direct  V(x) = x^2 mod n, index x   (the aperiodic variant)
  ECM stage 2   V(B) = prod_i (x_B - x_i), index B
  Stange        V(x) = g^x mod n, index x
  p-1 / p+1 / Williams p+1 / Coppersmith / class groups: NO STREAM.

Every loop bounded.  No Dickman.  No pooled-only rate.
"""

from __future__ import annotations

import json
import random
import sys
from math import gcd, log

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r52exp/design")

import dcore as D

K = 4000          # candidate window for the periodicity test (POLYNOMIAL streams)
KMOD = 60000      # window for MODULAR streams -- must exceed sqrt(n), see below
DMAX = 64         # smallest period searched for
FBB = 200         # factor-base bound for smoothness questions

# ⚠️⚠️ THE BUG THIS REPLACED, and it is the most dangerous kind: it produced a
# CLEAN, CONFIDENT, WRONG "the modular stream is periodic" result.
#
# The first version used n ~ 2^32 with K = 4000 for V(x) = x^2 mod n.  But
# 4000^2 = 1.6e7 << n ~ 4.3e9, so **x^2 < n for every x in the window and the
# reduction mod n NEVER HAPPENED**.  V was the plain polynomial x^2, which is
# of course periodic mod l, and the harness duly reported period == l on 6/6
# primes -- the exact opposite of the truth.
#
# It was caught only because I checked the arithmetic rather than the verdict.
# THE RULE: for any stream involving a reduction, assert that the reduction
# actually occurs inside the window before believing anything about it.
KMOD_MIN = None   # filled in at runtime


def assert_reduction_engaged(V, kmod, n, name):
    """Assert V(i) actually wraps for at least some i <= kmod."""
    wraps = sum(1 for i in range(kmod // 2, kmod + 1) if V(i, n) < i * i)
    assert wraps > 0, (
        f"{name}: no modular reduction occurs in the window (kmod={kmod}, "
        f"n={n.bit_length()} bits) -- the periodicity result would be VACUOUS"
    )
    return wraps / (kmod - kmod // 2 + 1)


# ------------------------------------------------------------------ streams
def v_gnfs(a, b, k):
    return a * a - b ** k


def v_snfs(a, b):
    return a - b


def v_dixon_direct(x, n):
    return x * x % n


def v_stange(x, g, n):
    return pow(g, x, n)


def v_ecm_s2_factor(B, xb, xi):
    """ONE ECM stage-2 factor: x_B - x_i, a LINEAR polynomial in B.

    Modelling the whole product prod_i (x_B - x_i) was wrong twice over: a
    degree-4 polynomial with up to 4 roots mod l (so it looks like the sieve
    marks 4 classes, which is misleading), and -- worse -- I had it computed
    mod 2^62, and since l does not divide 2^62 the reduction broke the
    periodicity that the underlying polynomial has.
    The real ECM stage-2 sieve never forms the product.  It sieves EACH
    linear factor, marking the single class B = x_i - x_B mod l.  That is what
    a "sieve by exponent smoothness" actually looks like.
    """
    return (xb + B) - xi


# ------------------------------------------------------------------ probing
def probe(name, V, FB, note="", kmod=None):
    """For each FB prime l: build hit_l = [l | V(i)], find smallest period <= DMAX.

    REPORTS, never assumes.  Three things are separated here and conflating them
    is how "periodic" gets asserted where nothing was checked:

      * `roots`     -- distinct residues i mod l with l | V(i).  For a
                       polynomial of degree d this is <= d; the sieve marks
                       exactly these classes and nothing else is marked.
      * `period`    -- smallest d <= DMAX with hit(i) == hit(i+d) throughout.
                       For a genuinely periodic stream this DIVIDES l, so it
                       is 1 or l.  Period 1 arises two ways, both flagged:
                         - `roots == 0`: the hit set is EMPTY (e.g. a^2 - 27
                           has no root mod 5) -- vacuously periodic.
                         - `roots == l`: the hit set is ALL of Z/l -- also
                           vacuous, and worse: the sieve marks everything.
                       Only 1 <= roots <= l-1 is a non-degenerate sieve.
      * `degeneracy`-- whether the cell is usable at all.

    A period that does NOT divide l, and is not None, would mean my model of
    "polynomial => periodic mod l" is wrong and must be investigated, so the
    caller asserts on it.
    """
    rows = []
    W = kmod
    for l in FB[:6]:
        hits = [1 if (V(i) % l == 0) else 0 for i in range(1, W + 1)]
        d, nchk = D.periodicity(hits, DMAX)
        # root count = number of RESIDUE CLASSES r mod l with l | V(r).
        # ⚠️ the first version counted INDICES over a window of 4l and then
        # capped at l, which reports roots = l (= "FULL, vacuous") for any l
        # whose hit set is hit often -- including V(y) = y at l = 2, which has
        # exactly ONE root class (y = 0) and is a perfectly good sieve.
        # Counting indices is not counting classes.
        roots = sum(1 for r in range(l) if V(r) % l == 0)
        nh = D.hit_count(hits)
        if roots == 0:
            degen = "EMPTY hit set -- vacuous"
        elif roots >= l:
            degen = "FULL hit set -- vacuous"
        elif nh == 0:
            degen = "EMPTY on window"
        elif nh == W:
            degen = "FULL on window"
        else:
            degen = "ok"
        rows.append({
            "l": l, "roots": roots,
            "hits": nh, "E_hits": W / l,
            "period_le_%d" % DMAX: d,
            "n_checked": nchk,
            "mean": nh / W,
            "degeneracy": degen,
        })
    live = [r for r in rows if r["degeneracy"] == "ok"]
    return {
        "name": name, "note": note, "per_prime": rows, "window": W,
        "n_live": len(live),
        # SIEVE-ABLE means: every non-degenerate cell has period dividing l,
        # AND at least one cell is non-degenerate (else "periodic" is vacuous).
        "sieveable": bool(live) and all(
            r["period_le_%d" % DMAX] in (1, r["l"]) for r in live),
        "periods_of_live": [r["period_le_%d" % DMAX] for r in live],
        "no_period_any": all(r["period_le_%d" % DMAX] is None for r in rows),
    }


def cheap_reduction_stange(n, p, g, K=K):
    """M1 for the exponential stream, with a GENUINE factor-base prime.

    The FB must exclude primes dividing n or this is vacuous (selftest T7).
    """
    FB = D.factor_base(FBB, n)
    l = FB[4]
    bad = sum(1 for x in range(1, K + 1)
              if (pow(g, x, n) % l) != pow(g, x, l))
    return l, bad / K


def cheap_reduction_polynomial(K=K):
    """M1 for the polynomial stream -- the control that MUST be exact."""
    FB = D.factor_base(FBB, 10 ** 12, exclude=False)
    l = FB[4]
    b, k = 3, 3
    bad = sum(1 for a in range(1, K + 1)
              if (v_gnfs(a, b, k) % l) != (v_gnfs(a % l, b, k) % l))
    return l, bad / K


def cheap_reduction_interval(K=K):
    """M1 for the Dixon INTERVAL stream: V(y)=y, trivially exact."""
    FB = D.factor_base(FBB, 10 ** 12, exclude=False)
    l = FB[4]
    bad = sum(1 for y in range(1, K + 1) if (y % l) != ((y % l) % l))
    return l, bad / K


# ------------------------------------------------------------------ the period of Stange
def stange_true_period(n, p, q, g, trials=200):
    """The hit set IS periodic -- with period ord_n(g) = lcm(ord_p g, ord_q g).

    Measured at SMALL n so the full period fits in the test window.  This is
    the mechanism that "aperiodic" was missing: aperiodic w.r.t. d <= 64, not
    aperiodic simpliciter.
    """
    op = D.order_mod(g, p)
    oq = D.order_mod(g, q)
    if op <= 0 or oq <= 0:
        return {"determinable": False}
    from math import lcm
    T = lcm(op, oq)
    FB = D.factor_base(60, n)
    l = FB[5]
    # verify periodicity WITH the window spanning >= 2 periods
    W = min(2 * T, 20000)
    hits = [1 if (pow(g, x, n) % l == 0) else 0 for x in range(1, W + 1)]
    holds = all(hits[i] == hits[i + T] for i in range(0, W - T))
    d, _ = D.periodicity(hits, DMAX)
    # and the smaller-orbit periods that fail
    return {
        "determinable": True,
        "n_bits": n.bit_length(),
        "ord_p_g": op, "ord_q_g": oq, "ord_n_g": T,
        "ord_n_over_n": T / n,
        "window": W, "spans_two_periods": W >= 2 * T,
        "hit_rate": D.hit_count(hits) / W,
        "periodic_at_ord_n": holds,
        "smallest_period_le_64": d,
    }


# ------------------------------------------------------------------ ECM rates
def p1_attempt(p, B, bases, rng):
    """One p-1 attempt: pick a base a, compute ord_p(a), test B-smoothness.

    This IS the p-1 / Williams p+1 success condition.  Conditioning is paid
    ONCE per attempt (choose B, choose a) and rejects NOTHING -- q = 1 exactly,
    so the KK cap does not bind.  The rate it must beat 20/27 on is P(ord is
    B-smooth).
    """
    o = ord_mod_prime(p, rng.randrange(2, p), factorint(p - 1))
    FB = D.factor_base(B, 10 ** 12, exclude=False)
    return o, D.is_smooth(o, FB)


_ORD_FAC_CACHE = {}


def ord_mod_prime(p, a, fac):
    """ord_p(a), bounded stripping over the KNOWN factorisation of p-1."""
    o = p - 1
    for q in fac:
        for _ in range(40):
            if o % q == 0 and pow(a, o // q, p) == 1:
                o //= q
            else:
                break
    return o


def p1_rate(bits, B, trials, rng):
    """Pooled p-1 attempt rate over primes of size ~2^bits, PER PRIMES REPORTED.

    ⚠️ THE FIRST VERSION OF THIS TEST WAS VACUOUS and reported 1.0000 at every B.
    It used the single small modulus p ~ 2^11.5 from the D1 stream, where
    p - 1 = 2^2 * 3 * 7 * 37 has largest prime factor 37 -- so the order is
    37-SMOOTH and the attempt succeeds at B = 1000, 10^4, 10^5 alike.  A rate
    test on a modulus whose group order is trivially smooth measures nothing.
    The control below ASSERTS that B is below the largest prime factor of p-1,
    which is exactly what makes the test bite.
    """
    from sympy import factorint, isprime
    rows = []
    pooled = []
    for ti in range(trials):
        # fresh prime of the requested size
        while True:
            c = rng.randrange(1 << (bits - 1), 1 << bits) | 1
            if isprime(c):
                p = int(c)
                break
        fac = factorint(p - 1)
        lpf = max(fac) if fac else 1
        if lpf <= B:
            continue          # non-informative modulus, skip and say so
        k = 0
        orders = []
        for _ in range(12):
            o = ord_mod_prime(p, rng.randrange(2, p), fac)
            orders.append(o)
            if D.is_smooth(o, D.factor_base(B, 10 ** 12, exclude=False)):
                k += 1
        rows.append({"p_bits": bits, "p": p, "lpf_p_minus_1": lpf,
                     "B": B, "k": k, "n": 12,
                     "min_order": min(orders), "max_order": max(orders)})
        pooled.append((k, 12))
    return rows, pooled


# ------------------------------------------------------------------ main
def main():
    out = {"config": {"K": K, "DMAX": DMAX, "FBB": FBB}, "streams": {}, "m1": {},
           "stange_period": [], "p1": [], "dixon_vs_direct": []}
    rng = random.Random(20261004)

    n, p, q = D.gen_semiprime(32, rng)
    FB = D.factor_base(FBB, n)
    FBraw = D.factor_base(FBB, 10 ** 12, exclude=False)
    g = rng.randrange(2, n)
    while gcd(g, n) != 1:
        g = rng.randrange(2, n)
    out["modulus"] = {"n_bits": n.bit_length(), "p_bits": p.bit_length(),
                      "q_bits": q.bit_length()}

    # A SMALL modulus for the modular streams, so that the window comfortably
    # exceeds sqrt(n) and the reduction genuinely happens.
    #   KMOD = 60000 vs sqrt(n) ~ 2^11.5 ~ 3700  ->  x^2 exceeds n by 16x.
    #   (first version: n ~ 2^32, K = 4000 < sqrt(n) = 65536 -> NEVER WRAPPED)
    nsmall, psmall, qsmall = D.gen_semiprime(24, random.Random(5))
    FBsmall = D.factor_base(FBB, nsmall)
    gsmall = random.Random(6).randrange(2, nsmall)
    while gcd(gsmall, nsmall) != 1:
        gsmall = random.Random(6).randrange(2, nsmall)
    wrap_frac = assert_reduction_engaged(v_dixon_direct, KMOD, nsmall, "Dixon-direct")
    out["reduction_engaged"] = {"n_bits": nsmall.bit_length(), "kmod": KMOD,
                                "sqrt_n": (nsmall ** 0.5), "wrap_frac": wrap_frac}
    print("=" * 78)
    print(f"D1  poly modulus n~2^{n.bit_length()} K={K} | modular n~2^{nsmall.bit_length()} "
          f"KMOD={KMOD} (sqrt n = {nsmall**0.5:.0f}) | dmax={DMAX}")
    print(f"    modular reduction engages on {wrap_frac*100:.1f}% of the upper window "
          f"-- assert_reduction_engaged, NOT assumed")
    print("=" * 78)

    # ---- the six streams ------------------------------------------------
    probes = {
        "GNFS  V(a)=a^2-b^k":   probe("GNFS", lambda i: v_gnfs(i, 3, 3), FBraw, kmod=K),
        "SNFS  V(a)=a-b":       probe("SNFS", lambda i: v_snfs(i, 7), FBraw, kmod=K),
        "Dixon-interval V(y)=y": probe("Dixon-interval", lambda i: i, FBraw, kmod=K),
        "Dixon-direct V(x)=x^2 mod n": probe(
            "Dixon-direct", lambda i: v_dixon_direct(i, nsmall), FBsmall, kmod=KMOD),
        "ECM-stage2 V(B)=x_B-x_i": probe(
            "ECM-stage2-factor", lambda i: v_ecm_s2_factor(i, 12345, 12350), FBraw, kmod=K),
        "Stange V(x)=g^x mod n": probe(
            "Stange", lambda i: v_stange(i, gsmall, nsmall), FBsmall, kmod=KMOD),
    }
    out["streams"] = {k: v for k, v in probes.items()}
    print(f"{'stream':30s} {'live':>5s} {'periods (live cells)':>22s}  verdict")
    for k, v in probes.items():
        if v["sieveable"]:
            verdict = "PERIODIC, period | l  -> SIEVE"
        elif v["no_period_any"]:
            verdict = "NO PERIOD <= 64 -> NO SIEVE"
        else:
            verdict = "period found but not dividing l -- INVESTIGATE"
        print(f"{k:30s} {v['n_live']:5d} {str(v['periods_of_live']):>22s}  {verdict}")
        for r in v["per_prime"]:
            d = r["period_le_%d" % DMAX]
            assert d is None or d in (1, r["l"]), \
                f"{k}, l={r['l']}: period {d} neither None nor a divisor of l"

    # ---- M1 cheap reduction --------------------------------------------
    print("\n" + "-" * 78)
    print("M1  CHEAP REDUCTION -- is V(i) mod l computable from i alone?")
    print("-" * 78)
    l_st, r_st = cheap_reduction_stange(n, p, g)
    l_po, r_po = cheap_reduction_polynomial()
    l_in, r_in = cheap_reduction_interval()
    out["m1"] = {"stange": {"l": l_st, "mismatch": r_st},
                 "polynomial": {"l": l_po, "mismatch": r_po},
                 "interval": {"l": l_in, "mismatch": r_in}}
    print(f"  polynomial V(a)=a^2-b^k   l={l_po:<4d} mismatch {r_po:.4f}   (must be 0)")
    print(f"  interval   V(y)=y          l={l_in:<4d} mismatch {r_in:.4f}   (must be 0)")
    print(f"  Stange     V(x)=g^x mod n  l={l_st:<4d} mismatch {r_st:.4f}   (must be >0)")
    assert r_po == 0.0 and r_in == 0.0, "polynomial control failed -- harness wrong"
    assert r_st > 0.5, "Stange control failed -- likely the FB-excludes-n bug"

    # ---- the TRUE period of the Stange hit set --------------------------
    print("\n" + "-" * 78)
    print("M2  PERIOD LENGTH -- Stange's hit set is periodic; the period is ord_n(g)")
    print("-" * 78)
    for bits in (16, 18, 20):
        r = random.Random(1000 + bits)
        nn, pp, qq = D.gen_semiprime(bits, r)
        gg = r.randrange(2, nn)
        while gcd(gg, nn) != 1:
            gg = r.randrange(2, nn)
        s = stange_true_period(nn, pp, qq, gg)
        s["bits"] = bits
        out["stange_period"].append(s)
        if s.get("determinable"):
            # ord_n(g) is ~ n, so the period is a factor n/64 LARGER than the
            # largest period a sieve could exploit.  This is the number that
            # makes Stange unsieveable, and it is not in doubt.
            assert s["periodic_at_ord_n"], "hit set should be periodic at ord_n(g)"
            assert s["smallest_period_le_64"] is None, \
                "a period <= 64 was found -- would overturn the claim"
            print(f"  n~2^{bits:<3d} ord_p={s['ord_p_g']:<8d} ord_q={s['ord_q_g']:<8d} "
                  f"ord_n={s['ord_n_g']:<9d} ord_n/n={s['ord_n_over_n']:.3f}  "
                  f"periodic@ord_n={s['periodic_at_ord_n']}  "
                  f"smallest<=64={s['smallest_period_le_64']}")
            print(f"         window {s['window']} spans {s['window']/max(s['ord_n_g'],1):.2f} "
                  f"full periods; ord_n(g) is {s['ord_n_g']/DMAX:.0f}x the sieve limit dmax=64")

    # ---- Dixon interval vs direct: the SAME method, one sieveable -------
    print("\n" + "-" * 78)
    print("Dixon: sieving the INTERVAL is periodic; sieving x^2 mod n is not.")
    print("-" * 78)
    a = probes["Dixon-interval V(y)=y"]
    b = probes["Dixon-direct V(x)=x^2 mod n"]
    out["dixon_vs_direct"] = {"interval_sieveable": a["sieveable"],
                              "direct_sieveable": b["sieveable"]}
    ai = a["per_prime"][0]
    bi = b["per_prime"][0]
    print(f"  V(y)=y          roots={ai['roots']}/{ai['l']} period={ai['period_le_%d' % DMAX]} "
          f"({ai['degeneracy']})   -> SIEVE")
    print(f"  V(x)=x^2 mod n  roots={bi['roots']}/{bi['l']} period={bi['period_le_%d' % DMAX]} "
          f"({bi['degeneracy']})   -> {'NO SIEVE' if not b['sieveable'] else 'SIEVE'}")
    assert a["sieveable"], "Dixon-interval must be sieveable"
    assert not b["sieveable"], "Dixon-direct must NOT be sieveable"

    # ---- the q=1 constructions: p-1 / p+1 / Williams p+1 ---------------
    print("\n" + "-" * 78)
    print("q=1 constructions: p-1 / p+1 / Williams p+1.")
    print("Conditioning (choose B, choose base) is paid ONCE and rejects NOTHING,")
    print("so q = 1 and the KK cap does not bind.  The rate test is then")
    print("    per-attempt success = P(ord_p(a) is B-smooth)   vs   20/27.")
    print("-" * 78)
    rngp1 = random.Random(31)
    for B in (1000, 10**4, 10**5, 10**6):
        rows, pooled = p1_rate(32, B, trials=6, rng=rngp1)
        if not pooled:
            print(f"  B={B:<8d} no modulus had lpf(p-1) > B -- NOT DETERMINABLE")
            continue
        P, m, sd = D.pooled_with_spread(pooled)
        Kt = sum(k for k, _ in pooled); N = sum(n for _, n in pooled)
        z = D.z_binom(Kt, N, 20 / 27) if Kt < N else float("nan")
        out["p1"].append({"B": B, "pooled": P, "per_cell_sd": sd, "z_vs_20_27": z,
                          "K": Kt, "N": N, "rows": rows})
        print(f"  B={B:<8d} pooled {D.fmt_rate(P, sd)}   z vs 20/27 = {z:+7.2f}   "
              f"({len(pooled)} primes of 2^32)")
        for r in rows:
            print(f"      p=2^{r['p_bits']} lpf(p-1)={r['lpf_p_minus_1']:<10d} "
                  f"k={r['k']}/{r['n']}  order in [{r['min_order']}, {r['max_order']}]")
    print("\n  Per-modulus table above is MANDATORY: the pooled number alone would")
    print("  hide that these cells are individually 0 or 12 and never near 20/27.")

    D.write_json("d1.json", out)
    print("\nwrote results/d1.json")


if __name__ == "__main__":
    main()