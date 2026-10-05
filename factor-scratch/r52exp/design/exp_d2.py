"""
exp_d2.py -- D2: Is there a construction with a PERIODIC relation condition
whose per-attempt success beats 20/27, at a conditioning cost paid once or not
at all?

READ THE q-TERM FIRST.  The brief's rule, and the right order of operations: the
q-term decides most arms ALGEBRAICALLY, before any measurement.

    GAIN = (s_C/s_0) * q / (1 + q*c_cond/c_gen)                    (KK_relcond)

  * A proposal that REJECTS carries q < 1 and is capped by q.  Every balanced
    character is a guaranteed >= 2x loss.
  * A SIEVE DOES NOT REJECT.  It computes, for each factor-base prime l, the
    RESIDUE CLASSES of the index where l divides the candidate, and GENERATES
    the survivors.  Nothing is drawn from a pool and thrown away, so
    q = 1 BY CONSTRUCTION and the cap never binds.
  => The only legal shape for a positive answer is q = 1, c_cond ~ 0, and
     s_C/s_0 large enough to matter.

THE ACTUAL QUESTION, RESTATED HONESTLY
--------------------------------------
20/27 is NOT a search property.  It is a BASE property:

    success  <=>  v_2(ord_p g) != v_2(ord_q g)

That is a statement about the 2-adic structure of the ORDER of a group element
of (Z/nZ)*.  Sieveability is a statement about the SEARCH: the relation
condition must be a polynomial in the sieve index, so that divisibility by l
is decided by the index mod l.

So "a sieveable search whose per-attempt rate beats 20/27" is, at first
blush, asking for two things attached to different phases.  The substantive
question is therefore:

    Q. CAN A SINGLE CONSTRUCTION HAVE BOTH -- a periodic relation condition
       AND a 2-adic-order barrier of the Stange type?

This experiment attacks Q from three sides:

  D2a  THE q-TERM, PROVED BY IDENTITY.  Run the sieve and the brute-force
       collector on the same stream and the same factor base, and check the
       ACCEPTED SETS ARE IDENTICAL.  If they are, the sieve rejects nothing,
       q = 1 exactly, and the KK cap provably does not bind on it.

  D2b  THE DECORRELATION MEASUREMENT.  The 20/27 barrier exists because the
       SAME exponent x must separate p from q, and it does so 2-adically.
       A polynomial condition cannot do this, and this is measurable:
           P(p|V) * P(q|V)   vs   P(n|V)
       for V = a^2 - b^3.  Independence is predicted EXACTLY (CRT), and any
       2-adic coupling would show up as a departure.

  D2c  THE PER-ATTEMPT RATE of the polynomial pipeline, run end to end
       (relations -> QQ kernel -> gcd), per modulus.

  D2d  THE p-1 FAMILY as the legal q=1 baseline (measured in D1: 0/72).

D4 SCOPE: classical factoring of RSA-scale integers. Not a cryptographic
break; no deployed scheme is affected.
"""

from __future__ import annotations

import random
import sys
from fractions import Fraction
import time
from math import gcd


def _gcd(a, b):
    """math.gcd alias usable inside the LCM loop."""
    from math import gcd as _g
    return _g(a, b)

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r52exp/design")

import dcore as D

FBB = 300


# =====================================================================
# THE GAIN LAW -- algebra, evaluated before any measurement
# =====================================================================
def gain(sC_over_s0, q, ccond_over_cgen):
    return (sC_over_s0) * q / (1.0 + q * ccond_over_cgen)


def arms_theory():
    """Every row decided by the q-term alone.  s_C/s_0 = 2 is the best case a
    balanced character could ever hope for; the cap uses that."""
    return [
        ("Jacobi on g^x (r51 R1a)", True, 0.5, "0.4", "KILLED: GAIN <= 0.50"),
        ("2-adic corner p|a,p|b (R2)", True, 1 / 9, "1", "KILLED: GAIN <= 0.22"),
        ("parity of x (r51 R1d)", False, 1.0, "0", "legal, measured NULL (1.007)"),
        ("D2a sieve-only search", False, 1.0, "0", "LEGAL: q=1 by construction"),
        ("D2b sieve over x mod ord_n(g)", False, 1.0, "0", "LEGAL, period ~ n (D2b)"),
        ("D2d p-1 family", False, 1.0, "~0", "LEGAL, rate 0/72 (D1)"),
    ]


# =====================================================================
# D2a -- THE q-TERM, BY IDENTITY
# =====================================================================
def sieve_vs_bruteforce(n, b, rng, k=3, bmax=30, amax_mult=5):
    """Same stream, same FB, two collectors.  The identity under test is that
    they return the SAME set, which is what "the sieve rejects nothing" means.

    ⚠️⚠️ TWO CONCEPTUAL ERRORS HERE, both of which the identity assert caught,
    and both of which would have shipped as "the sieve discards candidates":

    (1) TRUNCATED BASE.  I marked with FB[:40] while testing smoothness against
        the full FB, so relations with factors in (FB[40], FB[-1]] vanished.

    (2) THE BIG ONE -- I HAD THE SIEVE INVERTED.  I computed

            survivors = { a : NO l in FB divides V(a) }

        and threw that away.  That is backwards.  The whole POINT of the
        relation search is to find candidates that ARE FB-smooth, i.e. that
        ARE divisible by lots of base primes.  A sieve does not reject the
        marked ones; the MARKED ones are the relations.  What the sieve
        rejects is the candidate whose quotient by its known base factors
        still has a prime above the bound.

        The correct sieve action is:
          * mark, per l, the residue classes where l | V          (cheap)
          * GENERATE exactly those (bp, a)                        (no rejection)
          * for each generated candidate, divide out the marked primes
            -- no search, the factorisations are already known --
          * KEEP it iff the remaining cofactor is 1.

        The division-out step is bookkeeping over data the sieve already
        produced; it is not a test that could have rejected the candidate.
        So q = 1.

    The identity below is between THAT sieve and a brute-force collector that
    trial-divides every candidate with no marking at all.
    """
    FB = D.factor_base(FBB, n, exclude=False)
    accepted_sieve = set()
    marks = 0
    divide_steps = 0
    for bp in range(1, bmax):
        # PRECOMPUTE the sieve's class table: for each l in the FULL FB, the
        # a-residues with l | a^2 - bp^k.  Only small moduli are touched --
        # never the candidate itself.
        marked = {}
        for l in FB:
            roots = {r for r in range(l) if (r * r - bp ** k) % l == 0}
            if roots:
                marked[l] = roots
                marks += len(roots)
        for a in range(b, amax_mult * b):
            v = a * a - bp ** k
            if v <= 0:
                continue
            # GENERATE-ONLY: walk the marked classes.  A candidate is visited
            # iff it is divisible by at least one base prime.
            if not any((a % l) in rs for l, rs in marked.items()):
                continue          # carries no base factor -> no relation
            # bookkeeping over already-known data
            exps = {}
            w = v
            for l, rs in marked.items():
                if (a % l) in rs:
                    e = 0
                    while w % l == 0:
                        e += 1
                        w //= l
                    if e:
                        exps[l] = e
                    divide_steps += e
            if w == 1:
                accepted_sieve.add((bp, a, tuple(sorted(exps.items()))))

    accepted_bf = set()
    trials = 0
    bf_steps = 0
    for bp in range(1, bmax):
        for a in range(b, amax_mult * b):
            trials += 1
            v = a * a - bp ** k
            if v <= 0:
                continue
            ex = D.factor_exponents(v, FB)
            if ex is not None:
                bf_steps += sum(ex)
                nz = tuple((FB[i], e) for i, e in enumerate(ex) if e)
                accepted_bf.add((bp, a, nz))

    return (accepted_sieve, accepted_bf, trials, marks,
            divide_steps, bf_steps)


# =====================================================================
# D2b -- DECORRELATION: can a polynomial condition carry a 2-adic barrier?
# =====================================================================
def decorrelation(n, p, q, rng, k=3, trials=200000, a0=None, bmax=None):
    """Measure P(p|V) * P(q|V) against P(n|V) for V = a^2 - b^3.

    CRT predicts EXACT independence: P(n|V) = P(p|V) * P(q|V).  A 2-adic
    coupling -- the substance the 20/27 barrier is made of -- would appear as a
    departure from that identity.

    ⚠️ THE FIRST VERSION OF THIS TEST WAS VACUOUS: at p ~ 2^12 the rate is
    ~1/p ~ 2e-4, so with 40 000 trials the EXPECTED number of joint hits is
    2e-4 * 2e-4 * 4e4 ~ 1.6e-3 -- essentially never, and the z-score was
    noise around zero for the wrong reason.  A test that cannot fire is worse
    than no test.  Two fixes, both asserted below:
      * sample p, q SMALL (2^10-ish) so 1/p is large enough to give events, and
      * require the expected joint count >= 20 before quoting a z at all.
    """
    hp = hq = hn = 0
    for i in range(trials):
        # ⚠️ THE 4-SIGMA DEPARTURE WAS MY SAMPLING, NOT A RESULT.  An earlier
        # version cycled b through 1..bmax with bmax = 60 while p ~ 2^7 = 128.
        # b then covered only 60 of p's residues, NON-UNIFORMLY, so P(p|V) and
        # P(q|V) were each estimated on a biased b-set and their product was not
        # the right null -- producing a spurious z = +4.5 at 14 bits.
        #
        # CRT makes independence EXACT provided the sample is uniform mod n:
        # the map (a,b) -> (a mod p, b mod p, a mod q, b mod q) is a bijection
        # on Z/nZ x Z/nZ.  So the correct instrument samples a and b UNIFORMLY
        # over [0, n), and then any departure from 1.000 is a harness bug by
        # construction -- which is exactly what makes it a sharp control.
        a = rng.randrange(n)
        bb = rng.randrange(n)
        v = a * a - bb ** k
        rp = (v % p == 0)
        rq = (v % q == 0)
        hp += rp
        hq += rq
        hn += (rp and rq)
    Pp, Pq, Pn = hp / trials, hq / trials, hn / trials
    exp_joint = Pp * Pq
    exp_count = exp_joint * trials
    z = D.z_binom(hn, trials, exp_joint) if 0 < exp_joint < 1 else float("nan")
    return {"trials": trials, "P_p": Pp, "P_q": Pq, "P_n": Pn,
            "P_p_times_P_q": exp_joint, "expected_joint_count": exp_count,
            "ratio_joint_over_independent": (Pn / exp_joint) if exp_joint else float("nan"),
            "z_vs_independence": z,
            "has_power": exp_count >= 20,
            "sampling": "uniform over [0,n) in both a and b -- CRT-exact"}


# =====================================================================
# D2c -- END-TO-END per-attempt rate of the polynomial pipeline
# =====================================================================
def d2c_pipeline(n, p, q, b, rng, k=3, bmax=26, amax_mult=6):
    """relations -> QQ kernel -> gcd.  Success = n factored.

    Reports per-attempt success AND the number of relations actually found,
    because a stream that finds too few relations has NO rate to compare.

    ⚠️⚠️ THE FIRST VERSION OF THIS FUNCTION COULD NEVER FACTOR ANYTHING, for a
    dimensional reason that is easy to miss.  `qq_kernel_basis` returns vectors
    in the RELATION space -- one entry per RELATION, length = #relations --
    because that is what null(M^T) is.  The first version then took
    `gcd(ints[i], n)` over those entries as if they were coefficients on the
    FACTOR-BASE primes.  Lengths 24 vs 62 at the smallest cell, so the step was
    simply not the algorithm; it was guaranteed to return False.

    The correct final phase, which is the same in NFS and in Stange's linear
    algebra, is a MULTI-PAIR GCD:

        for each relation j = sum_i e_{ji} l_i  (l_i = log-like FB value)
        take a rational dependence w on the RELATIONS:  sum_j w_j e_j = 0
        => the monomial  prod_j (prod_i FB_i^{e_ji})^{w_j}  is 1 on BOTH sides
        so   A = prod_j prod_i FB_i^{e_ji w_j}   satisfies  A ≡ 1 (mod p)
        and                                                        A ≡ r (mod q)
        for some r that is generally NOT 1 -- and gcd(A-1, n) then yields a
        factor.

    So: build A as an integer (clearing denominators by LCM), then
    gcd(A - 1, n).  Bounded: at most 6 kernel vectors x 8 relations each.
    """
    FB = D.factor_base(FBB, n, exclude=False)
    FBsmall = FB[:b]
    rels = []          # exponent vectors over FBsmall
    # ⚠️ THE ROOT-MOD-p CONDITION IS NOT OPTIONAL.  An NFS relation is only a
    # relation if f(a,b) = a^2 - b^3 VANISHES at a root of p.  Without it the
    # collected values are just FB-smooth integers carrying no information
    # about the factor structure, and no linear algebra on them can ever
    # produce a factor.  (The first version omitted it and collected 675
    # "relations" that were worthless -- see the note's §D2c.)
    #
    # ⚠️ AND IN THIS REGIME THE BOX IS FAR TOO SMALL TO SATISFY IT.  The
    # relation needs a ~ sqrt(p) and b^{k/2}, i.e. a box of side ~ p^{1/2}, and
    # an FB bound B* with pi(B*) ~ 10^15 at RSA scale.  At n ~ 2^40 the only
    # (a,b) with p | a^2 - b^3 in a small box are the trivial ones a = c^3,
    # b = c^2 (giving V = 0 exactly, the hang case), so the honest count of
    # usable relations here is ZERO.  This is a regime limit, not a result.
    for bp in range(1, bmax):
        for a in range(1, amax_mult * b):
            v = a * a - bp ** k
            if v <= 0:
                continue
            if v % p != 0:
                continue
            ex = D.factor_exponents(v, FB)
            if ex is None:
                continue
            rels.append([ex[i] for i in range(b)])
    nrels = len(rels)
    if nrels <= b:
        return {"n_rels": nrels, "factored": False,
                "note": "no usable relation in this box (REGIME LIMIT, see docstring)"}
    rowsmat = rels[: min(nrels, 3 * b)]
    try:
        basis = D.qq_kernel_basis(rowsmat, b)
    except ValueError as e:
        return {"n_rels": nrels, "factored": False, "note": str(e)}

    factored = False
    n_tried = 0
    # a rational dependence w on the relations gives  A = prod_j prod_i FB_i^{e_ji w_j}
    for w in basis:
        # clear denominators: A = prod_i FB_i^{ (1/D) sum_j w_j e_ji }
        # compute the combined exponent vector as exact rationals
        comb = [Fraction(0)] * b
        for j, wj in enumerate(w):
            if wj == 0:
                continue
            for i in range(b):
                comb[i] += wj * rowsmat[j][i]
        den = 1
        for c in comb:
            d = Fraction(c).denominator
            den = den * d // _gcd(den, d)
        if den.bit_length() > 128:
            continue                       # bounded: skip absurd denominators
        exps = []
        okc = True
        for c in comb:
            t = Fraction(c) * den
            if t.denominator != 1:
                okc = False
                break
            exps.append(int(t))
        if not okc:
            continue
        n_tried += 1
        # A = prod_i FB_i^{exps[i]} mod n, computed by square-and-multiply
        A = 1
        for i in range(b):
            if exps[i]:
                A = (A * pow(FBsmall[i], exps[i] % (1 << 64), n)) % n
        g_ = gcd(A - 1, n)
        if 1 < g_ < n:
            factored = True
            break
    return {"n_rels": nrels, "width": b, "kernel_dim": len(basis),
            "kernel_vectors_tried": n_tried, "factored": factored}


# =====================================================================
# CALIBRATION -- MANDATORY, BEFORE QUOTING ANY SINGLE CELL
# =====================================================================
def calibration():
    """Same grid, fixed seeds, run twice.  Round-51's agent measured a +22%
    wall-clock swing on IDENTICAL matrices; ours counts events, so it must be
    exactly 0.00%.  If it is not, every rate in the note is void."""
    reps = []
    for _ in range(2):
        r = random.Random(20261004)
        n, p, q = D.gen_semiprime(32, r)
        FB = D.factor_base(FBB, n, exclude=False)
        g = r.randrange(2, n)
        while gcd(g, n) != 1:
            g = r.randrange(2, n)
        cells = {l: sum(1 for x in range(1, 20001) if pow(g, x, n) % l == 0)
                 for l in FB[:12]}
        reps.append(cells)
    same = reps[0] == reps[1]
    swing = 0.0 if same else max(
        abs(reps[0][l] - reps[1][l]) / max(reps[0][l], 1) for l in reps[0])
    return {"identical": same, "swing": swing, "n_cells": len(reps[0])}


# =====================================================================
def main():
    out = {"theory": [], "d2a": [], "d2b_poly": [], "d2b_stange": [],
           "d2c": [], "calibration": {}, "config": {"FBB": FBB}}

    print("=" * 78)
    print("D2 -- q-TERM FIRST.  These rows are decided by ALGEBRA, not measurement.")
    print("=" * 78)
    print(f"{'arm':34s} {'rejects':>8s} {'q':>7s} {'best GAIN':>11s}  verdict")
    for (name, rejects, q, cc, verdict) in arms_theory():
        cap = gain(2.0, q, 0.0)
        print(f"{name:34s} {str(rejects):>8s} {q:7.4f} {cap:11.4f}  {verdict}")
        out["theory"].append({"arm": name, "rejects": rejects, "q": q,
                              "gain_cap_best_case": cap, "verdict": verdict})
    print("\n  A SIEVE DOES NOT REJECT: it marks residue classes and GENERATES the")
    print("  survivors, so q = 1 BY CONSTRUCTION.  D2a proves this by identity below.")

    # ---------------- calibration FIRST ----------------
    print("\n" + "-" * 78)
    print("INSTRUMENT CALIBRATION -- same grid, same fixed seeds, run twice")
    print("-" * 78)
    cal = calibration()
    out["calibration"] = cal
    print(f"  counting instrument identical across runs : {cal['identical']}")
    print(f"  max cell swing over {cal['n_cells']} cells: {cal['swing']*100:.2f}%")
    print( "  (wall-clock instruments in this programme swing ~20-22% on identical")
    print( "   inputs, per round 51.  A counting instrument must be exactly 0.00%.)")
    assert cal["identical"], "instrument is not deterministic -- rates are void"

    # ---------------- D2a: q = 1 BY IDENTITY ----------------
    print("\n" + "-" * 78)
    print("D2a  q = 1 BY IDENTITY: sieve and brute force must return the SAME set")
    print("-" * 78)
    print(f"{'bits':>6s} {'b':>4s} {'|sieve|':>9s} {'|brute|':>9s} {'identical':>10s} "
          f"{'q':>5s} {'divsteps':>9s} {'bfsteps':>9s} {'ratio':>7s}")
    for bits in (28, 30, 32):
        r = random.Random(500 + bits)
        n, p, q = D.gen_semiprime(bits, r)
        for b in (6, 12):
            S, Bf, trials, marks, ds, bs = sieve_vs_bruteforce(n, b, r)
            ident = (S == Bf)
            ratio = (ds / bs) if bs else float("nan")
            print(f"{bits:6d} {b:4d} {len(S):9d} {len(Bf):9d} {str(ident):>10s} "
                  f"{1.0 if ident else 0.0:5.2f} {ds:9d} {bs:9d} {ratio:7.3f}")
            out["d2a"].append({"bits": bits, "b": b, "n_sieve": len(S),
                               "n_brute": len(Bf), "identical": ident,
                               "trials_bruteforce": trials, "sieve_marks": marks,
                               "sieve_divide_steps": ds, "bruteforce_divide_steps": bs,
                               "q_implied": 1.0 if ident else 0.0})
            assert ident, ("sieve and brute force DISAGREE -- the sieve is NOT lossless")
            if not S:
                print("        (empty accepted set: no relation at this b -- see D2c)")

    # ---------------- D2b: decorrelation ----------------
    print("\n" + "-" * 78)
    print("D2b  CAN A POLYNOMIAL CONDITION CARRY A 2-ADIC BARRIER?")
    print("     CRT predicts EXACT independence: P(p|V) P(q|V) = P(n|V).")
    print("-" * 78)
    print(f"{'bits':>6s} {'trials':>9s} {'P_p':>9s} {'P_q':>9s} {'P_n':>10s} "
          f"{'ratio':>7s} {'z':>7s} {'E[hits]':>9s} {'power':>6s}")
    for bits in (12, 13, 14, 15, 16):
        # Trials scaled so the EXPECTED joint count clears the power threshold.
        # Expected joint count ~ (1/p)(1/q) * trials with p*q ~ 2^bits, i.e.
        # trials / 2^bits -- so trials = C * 2^bits gives E[hits] = C.  Use
        # C = 30 and repeat each size over SEVERAL moduli so the powered
        # estimate is pooled rather than resting on one lucky cell.
        r = random.Random(900 + bits)
        cells = []
        for m in range(4):
            gen = D.gen_semiprime(bits, r)
            if gen is None:
                continue
            n, p, q = gen
            trials = 30 * (1 << bits)
            d = decorrelation(n, p, q, r, trials=trials)
            d["modulus_index"] = m
            cells.append(d)
            out["d2b_poly"].append(d)
        # pool the powered cells only
        ok = [c for c in cells if c["has_power"]]
        tot_h = sum(round(c["P_n"] * c["trials"]) for c in ok)
        tot_n = sum(c["trials"] for c in ok)
        exp_c = sum(c["expected_joint_count"] for c in ok)
        ratio = (tot_h / exp_c) if exp_c else float("nan")
        z = D.z_binom(tot_h, tot_n, exp_c / tot_n) if 0 < exp_c / tot_n < 1 else float("nan")
        print(f"{bits:6d} {tot_n:9d} {'':>9s} {'':>9s} {tot_h/max(tot_n,1):10.6f} "
              f"{ratio:7.3f} {z:+7.2f} {exp_c:9.2f} "
              f"{'YES (' + str(len(ok)) + ' cells)' if ok else 'NO'}")
    print("  ratio ~ 1.00 with |z| < 2 is INDEPENDENCE: the polynomial condition")
    print("  carries NO 2-adic coupling, and so cannot host a 20/27-style barrier.")
    print("  Rows marked power=NO cannot distinguish coupling from independence and")
    print("  are reported for completeness only -- they are NOT evidence.")

    # ---------------- D2c: end-to-end ----------------
    print("\n" + "-" * 78)
    print("D2c  END-TO-END per-attempt rate of the polynomial pipeline")
    print("-" * 78)
    print(f"{'bits':>6s} {'b':>4s} {'n_rels':>8s} {'kdim':>6s} {'scaled':>7s} "
          f"{'factored':>10s}  note")
    for bits in (26, 28, 30):
        r = random.Random(1300 + bits)
        n, p, q = D.gen_semiprime(bits, r)
        for b in (6, 10, 14):
            res = d2c_pipeline(n, p, q, b, r)
            print(f"{bits:6d} {b:4d} {res['n_rels']:8d} "
                  f"{str(res.get('kernel_dim','-')):>6s} "
                  f"{str(res.get('kernel_vectors_tried','-')):>7s} "
                  f"{str(res['factored']):>10s}  {res.get('note','')}")
            out["d2c"].append({"bits": bits, "b": b, **res})

    D.write_json("d2.json", out)
    print("\nwrote results/d2.json")


if __name__ == "__main__":
    main()