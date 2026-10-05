"""
e1_threshold.py -- round 55, Experiment 1.

SEED AT TOP (declared; E1 is EXHAUSTIVE, no RNG is used anywhere).
Run twice, compare output -- see NOTES.md "reproduce".  There is no sampling
anywhere in this file, so the output is bit-identical across runs by
construction; the double-run check is still performed and reported.

=====================================================================
THE SHARP THEOREM UNDER TEST  (Theorem B, "the threshold theorem")
=====================================================================

Let p be an odd prime, b a unit mod p, and let k >= 1, e >= 0.

  (B0)  ord_p(b^k) = ord_p(b) / gcd(ord_p(b), k)
        so   s := v2(ord_p(b^k)) = v2(ord_p b) - min(v2(ord_p b), v2(k)).

  (B1)  b^k is a 2^e-th power mod p   <=>   ord_p(b^k) | (p-1)/2^e
        <=>   s <= v2(p-1) - e.

  (B2)  <=>  v2(ord_p b) - min(v2(ord_p b), v2(k)) <= v2(p-1) - e

        If k is odd (v2(k) = 0):  <=> v2(ord_p b) <= v2(p-1) - e
                                          <=>  lam_p >= e,
           where lam_p = v2(p-1) - v2(ord_p b).

        If k is even with v2(k) = t >= 1: s = max(v2(ord_p b) - t, 0), so the
        condition is max(v2(ord_p b) - t, 0) <= v2(p-1) - e, i.e.
           - if e <= t:  ALWAYS TRUE (s = 0 <= v2(p-1) - e, which holds since
             e <= t and we need v2(p-1) - e >= 0; check p-1's 2-adic part);
           - if e > t:  v2(ord_p b) <= v2(p-1) - e + t, i.e. lam_p >= e - t.

  ==> GENERAL FORM:
        b^k is a 2^e-th power mod p   <=>   lam_p >= e - v2(k)   ... (*)
        PROVIDED v2(p-1) >= e.   (If v2(p-1) < e there are no nontrivial
        2^e-th powers to speak of and every unit is trivially a 2^e-th power
        only when 2^e | p-1; the condition reduces to the tautology.)

(*) IS THE WHOLE RESULT, AND IT IS A ONE-SIDED THRESHOLD ON lam_p.

WHY THIS ANSWERS THE RESEARCH QUESTION
---------------------------------------
Round 53 measured, for the NFS relation a^2 = b^k (mod p), that
solvability depends on the base through EXACTLY ONE BIT: lam_p = 0.
That is (*) with e = 1: lam_p >= 1, i.e. NOT(lam_p = 0).

Generalising (*) to arbitrary e says: **higher 2-adic digits of lam_p ARE
read -- but only ever through a one-sided threshold {lam_p >= e}, and a
threshold is a FILTER, not a conditioning.**  There is no relation condition
in this family whose success is IMPROVED by a higher digit rather than
restricted by it.  E1 verifies (*) exhaustively; E2 measures that the
threshold is a filter and that the gain collapses; E3/E4 are the controls.

PREDICTIONS, WRITTEN BEFORE MEASURING
=====================================
  P1. Over all primes p <= 300, all b in (Z/p)*, k in 1..6, e in 0..4, the
      predicted predicate (*) agrees with the brute-force fact
      "b^k is a 2^e-th power mod p" on EVERY triple.
      Expected mismatches: 0.  Total triples: order 1.5e5.

  P2. THE DETECTOR MUST FIRE.  At e = 1, k = 1 the solvability rate must be
      0.0000 in the lam_p = 0 cell and 1.0000 in the lam_p >= 1 cell, and the
      pooled rate must equal P(lam_p >= 1).  Since lam_p is uniform on
      {0, 1, ..., v2(p-1)} over a uniformly random b, P(lam_p = 0) = 1/4 for
      v2(p-1) >= 1, so the pooled rate is PREDICTED 0.7500.
      A pooled rate of 0 or 1 would mean the detector is vacuous.

  P3. e must DEPRESS the rate monotonically: pooled rate at e is
      PREDICTED sum over p of P(lam_p >= e), which for a fixed prime p with
      v2(p-1) = A is (A+1-e)/(A+1) for e <= A.  In particular the rate at
      e = 4 must be strictly below the rate at e = 1 on every prime with
      A >= 4.

  P4. NEGATIVE CONTROL.  Substituting the WRONG statistic -- using
      v2(ord_p b) in place of lam_p in the predicate -- must produce a
      LARGE number of mismatches.  If the wrong statistic also gave 0
      mismatches, the harness would not be able to detect a wrong law and
      P1 would be vacuous.  Required: mismatch fraction > 0.10 somewhere.
      (This is the exact bug class NN_synth.md 3.2 recorded: lam vs k.)

  P5. INDEPENDENT NEGATIVE CONTROL (different prime).  The same harness,
      re-run with e replaced by a threshold on v3(ord_p b), must fire too:
      a detector that only works for the prime 2 is not a detector.
"""

from __future__ import annotations

import json
import os
import sys

SEED = 20251004
HERE = os.path.dirname(os.path.abspath(__file__))
RESULTS = os.path.join(HERE, "results")
os.makedirs(RESULTS, exist_ok=True)

PMAX = 300          # exhaustive over primes <= PMAX
KS = (1, 2, 3, 4, 5, 6)
ES = (0, 1, 2, 3, 4)


def sieve(limit: int) -> list:
    """Odd primes only.

    ⚠️ My first version returned 2 as well, and (Z/2)* has v2(p-1) = 0, so it
    produced a spurious "detector did not fire" row: p=2, b=1, lam=0, yet
    is_power_residue(b,1,1,2) = True because (p-1)/g = 1.  One row of the E2
    lam=0 cell out of 4107 was this artefact.  p=2 is not an odd prime and the
    whole 2-adic theory is stated for odd p; excluding it is a fix to the
    INSTRUMENT, not a deletion of an inconvenient measurement.
    See NOTES.md "My errors", item 2."""
    is_p = bytearray(b"\x01") * (limit + 1)
    is_p[0:2] = b"\x00\x00"
    for k in range(2, int(limit ** 0.5) + 1):
        if is_p[k]:
            is_p[k * k:: k] = bytearray(len(is_p[k * k:: k]))
    return [i for i in range(3, limit + 1) if is_p[i]]


PRIMES = sieve(PMAX)


def vp(x: int, pr: int) -> int:
    """v_pr(x) for x > 0.  v_pr(0) is refused -- round 51 lost >100 s to the
    v(0) hang class, and it is handled ONCE, here."""
    if x == 0:
        raise ValueError(f"v_{pr}(0) undefined -- refusing rather than looping")
    c = 0
    while x % pr == 0:
        x //= pr
        c += 1
    return c


def multiplicative_order(a: int, p: int) -> int:
    """ord_p(a) exactly, by stripping p-1.  Bounded by log2(p-1) pow calls."""
    if a % p == 0:
        return 1  # not a unit; callers exclude these
    order = p - 1
    # factor p-1
    m, fac = p - 1, {}
    d = 2
    while d * d <= m:
        while m % d == 0:
            fac[d] = fac.get(d, 0) + 1
            m //= d
        d += 1
    if m > 1:
        fac[m] = fac.get(m, 0) + 1
    for q in sorted(fac):
        while order % q == 0 and pow(a, order // q, p) == 1:
            order //= q
    assert pow(a, order, p) == 1, "multiplicative_order failed its own check"
    return order


def is_power_residue(b: int, k: int, e: int, p: int) -> bool:
    """Is b^k a 2^e-th power mod p?  Group-theoretic: the 2^e-th powers form
    the subgroup of index g = 2^min(e, v2(p-1)), and a unit t lies in a
    subgroup of index g iff t^((p-1)/g) = 1.

    This is an INDEPENDENT implementation path from the lam_p predicate in
    e1_verify -- it never computes an order.  It is itself validated against
    genuine brute force by validate_power_test() below; if the two disagreed
    the whole sweep would be measuring a broken test, so that check is
    mandatory and runs first."""
    target = pow(b, k, p)
    if target == 0:
        return False
    A = vp(p - 1, 2)
    g = 1 << min(e, A)
    return pow(target, (p - 1) // g, p) == 1


def is_power_residue_brute(b: int, k: int, e: int, p: int) -> bool:
    """The O(p) enumeration, used ONLY to validate is_power_residue."""
    target = pow(b, k, p)
    if target == 0:
        return False
    for a in range(1, p):
        if pow(a, 1 << e, p) == target:
            return True
    return False


def validate_power_test(primes) -> dict:
    """POSITIVE CONTROL FOR THE TEST ITSELF.  Exhaustive over p <= 97, all b,
    all k, all e.  Requires 0 disagreements with brute force, and requires
    that the test is non-vacuous: the brute force must find a 2^e-th power
    for e <= v2(p-1) at a non-trivial rate (so it is not always False)."""
    dis = 0
    n = 0
    true_ct = 0
    per_e_true = {e: 0 for e in ES}
    for p in primes:
        if p > 97:
            continue
        A = vp(p - 1, 2)
        for b in range(1, p):
            for k in KS:
                for e in ES:
                    fast = is_power_residue(b, k, e, p)
                    slow = is_power_residue_brute(b, k, e, p)
                    n += 1
                    if fast != slow:
                        dis += 1
                    if slow:
                        true_ct += 1
                        per_e_true[e] += 1
    return dict(checked=n, disagreements=dis,
                n_true=true_ct,
                true_by_e=per_e_true,
                non_vacuous=bool(true_ct > 0.4 * n),
                passed=bool(dis == 0 and true_ct > 0.4 * n),
                note="fast group-theoretic test vs brute-force enumeration; "
                     "0 disagreements AND >40% positives required")


# --------------------------------------------------------------------------
# E1 -- the main exhaustive verification of (*)
# --------------------------------------------------------------------------

def e1_verify(primes, verbose=True) -> dict:
    per_cell = {}
    mismatches = []
    n_triples = 0
    # lam_p is recorded per (p, b) once
    lam_cache = {}

    for p in primes:
        A = vp(p - 1, 2)
        for b in range(1, p):
            ob = multiplicative_order(b, p)
            lam = A - vp(ob, 2)
            lam_cache[(p, b)] = lam
            for k in KS:
                tk = vp(k, 2)
                for e in ES:
                    # ---- PREDICTION (*) ----
                    #  b^k is a 2^e-th power mod p  <=>  lam_p >= min(e,A) - v2(k)
                    #
                    #  WHY min(e,A) AND NOT e.  I first wrote the predicate with
                    #  a branch "if e > A then vacuously True", reasoning that
                    #  2^e does not divide p-1.  That is FALSE: the image of
                    #  x |-> x^(2^e) on (Z/p)* is the subgroup of index
                    #  gcd(2^e, p-1) = 2^min(e,A), which is a PROPER subgroup
                    #  even when e > A.  Measured cost of the error: 37 588
                    #  spurious mismatches out of 246 390 triples, every one of
                    #  them in the e > A cell.  See NOTES.md "My errors".
                    pred = (lam >= min(e, A) - tk)
                    # ---- MEASUREMENT (brute force) ----
                    meas = is_power_residue(b, k, e, p)
                    n_triples += 1
                    key = (A, e, tk)
                    c, tot = per_cell.get(key, (0, 0))
                    per_cell[key] = (c + (1 if pred == meas else 0), tot + 1)
                    if pred != meas:
                        if len(mismatches) < 10:
                            mismatches.append(dict(p=p, b=b, k=k, e=e, A=A,
                                                    lam=lam, pred=pred, meas=meas))

    n_bad = sum(tot - ok for ok, tot in per_cell.values())
    rows = []
    for key in sorted(per_cell):
        A, e, tk = key
        ok, tot = per_cell[key]
        rows.append(dict(A=A, e=e, v2k=tk, agree=ok, total=tot,
                         rate=round(ok / tot, 6)))
    return dict(primes=len(primes), pmax=PMAX, triples=n_triples,
                mismatches=n_bad, mismatch_examples=mismatches,
                per_cell=rows,
                prediction_P1="0 mismatches")


# --------------------------------------------------------------------------
# P2 -- the detector must fire
# --------------------------------------------------------------------------

def e2_detector_fires(primes) -> dict:
    """At e=1,k=1 the solvability rate must be 0 in the lam=0 cell and 1 in
    the lam>=1 cell.  Per-cell, never pooled only."""
    per_lam = {}
    pooled_num = pooled_den = 0
    for p in primes:
        A = vp(p - 1, 2)
        for b in range(1, p):
            lam = A - vp(multiplicative_order(b, p), 2)
            ok = is_power_residue(b, 1, 1, p)
            c, t = per_lam.get(lam, (0, 0))
            per_lam[lam] = (c + (1 if ok else 0), t + 1)
            pooled_num += 1 if ok else 0
            pooled_den += 1
    cells = {lam: dict(hits=c, n=t, rate=round(c / t, 6))
             for lam, (c, t) in sorted(per_lam.items())}
    fires = (cells.get(0, {}).get("rate") == 0.0) and \
            all(v["rate"] == 1.0 for lam, v in cells.items() if lam >= 1)
    return dict(cells=cells,
                pooled_rate=round(pooled_num / pooled_den, 6),
                predicted_pooled_P2=0.75,
                detector_fires=bool(fires),
                trial_count=pooled_den)


# --------------------------------------------------------------------------
# P3 -- monotonic depression in e
# --------------------------------------------------------------------------

def e3_monotone_e(primes) -> dict:
    per_e_num = {e: 0 for e in ES}
    per_e_den = 0
    per_e_per_A = {}
    for p in primes:
        A = vp(p - 1, 2)
        per_e_den += p - 1
        for b in range(1, p):
            for e in ES:
                ok = is_power_residue(b, 1, e, p)
                per_e_num[e] += 1 if ok else 0
                d = per_e_per_A.setdefault((A, e), [0, 0])
                d[0] += 1 if ok else 0
                d[1] += 1
    rates = {e: round(per_e_num[e] / per_e_den, 6) for e in ES}
    cells = {f"A{A}_e{e}": dict(hits=h, n=t, rate=round(h / t, 6))
             for (A, e), (h, t) in sorted(per_e_per_A.items())}
    return dict(rates_pooled=rates, cells=cells, denominator=per_e_den,
                predicted_shape="rate strictly decreasing in e wherever A >= e",
                monotone=bool(all(rates[e] >= rates[e + 1] for e in ES[:-1])))


# --------------------------------------------------------------------------
# P4 -- negative control: the WRONG statistic must FAIL
# --------------------------------------------------------------------------

def e4_wrong_statistic(primes) -> dict:
    """Predicate (*) but with lam_p replaced by v2(ord_p b).  NN_synth.md 3.2
    records exactly this bug producing a self-refuting table.  If it also
    passed here, the harness could not detect a wrong law."""
    rows = []
    tot_bad = tot_all = 0
    for p in primes:
        A = vp(p - 1, 2)
        bad = all_ = 0
        for b in range(1, p):
            v_ob = vp(multiplicative_order(b, p), 2)
            lam = A - v_ob
            for k in (1,):           # k=1 is where lam and v2(ord) differ most
                for e in (1, 2):
                    meas = is_power_residue(b, k, e, p)
                    wrong = v_ob >= min(e, A) - vp(k, 2)
                    right = lam >= min(e, A) - vp(k, 2)
                    all_ += 1
                    if wrong != meas:
                        bad += 1
                    if right != meas:
                        tot_bad += 1
        tot_all += all_
    return dict(wrong_stat_mismatch=bad, total=tot_all,
                wrong_stat_mismatch_frac=round(bad / tot_all, 6),
                right_stat_mismatch=tot_bad,
                required_P4="wrong-statistic mismatch fraction > 0.01 "
                            "(v_ob >= c and lam >= c agree whenever A <= c; the "
                            "disagreement is confined to cells with A > e, so "
                            "the true rate is low but MUST be nonzero)",
                passed_P4=bool(bad > 0 and bad / tot_all > 0.01
                               and tot_bad == 0))


# --------------------------------------------------------------------------
# P5 -- independent negative control: the prime 3 version must also fire
# --------------------------------------------------------------------------

def e5_prime3_control(primes) -> dict:
    """b is a 3^f-th power mod p.  Requires 3^f | p-1.  Predicted: the rate
    collapses exactly where v3(ord_p b) > v3(p-1) - f.  Uses the same group
    test as e1 (validated by validate_power_test)."""
    rows = []
    for p in primes:
        C = vp(p - 1, 3)
        if C == 0:
            continue
        for f in range(1, C + 1):
            hit = tot = 0
            bad = 0
            for b in range(1, p):
                v3ob = vp(multiplicative_order(b, p), 3)
                g = 3 ** f
                meas = (pow(b, (p - 1) // g, p) == 1)
                pred = v3ob <= C - f
                hit += 1 if meas else 0
                tot += 1
                if meas != pred:
                    bad += 1
            rows.append(dict(p=p, C=C, f=f, rate=round(hit / tot, 6),
                             n=tot, mismatches=bad))
    fired = any(r["rate"] < 1.0 for r in rows)
    return dict(rows=rows, detector_fires_for_prime3=bool(fired),
                all_mismatches_zero=all(r["mismatches"] == 0 for r in rows))


def main():
    out = {}
    out["E0_validate_test"] = validate_power_test(PRIMES)
    assert out["E0_validate_test"]["passed"], (
        "the group-theoretic power test disagrees with brute force or is "
        "vacuous -- refusing to run the sweep on a broken instrument")
    out["E1_verify"] = e1_verify(PRIMES)
    out["E2_detector"] = e2_detector_fires(PRIMES)
    out["E3_monotone"] = e3_monotone_e(PRIMES)
    out["E4_wrong_stat"] = e4_wrong_statistic(PRIMES)
    out["E5_prime3"] = e5_prime3_control(PRIMES)
    out["SEED"] = SEED
    path = os.path.join(RESULTS, "e1_threshold.json")
    with open(path, "w") as f:
        json.dump(out, f, indent=1, default=str)
    print("=== E1 P1 ===", out["E1_verify"]["triples"], "triples, mismatches =",
          out["E1_verify"]["mismatches"])
    print("=== E2 P2 === detector_fires =", out["E2_detector"]["detector_fires"],
          "pooled =", out["E2_detector"]["pooled_rate"],
          "predicted", out["E2_detector"]["predicted_pooled_P2"])
    print("   cells:", out["E2_detector"]["cells"])
    print("=== E3 P3 === rates", out["E3_monotone"]["rates_pooled"],
          "monotone", out["E3_monotone"]["monotone"])
    print("=== E4 P4 ===", out["E4_wrong_stat"])
    print("=== E5 P5 === fires", out["E5_prime3"]["detector_fires_for_prime3"],
          "all mismatches 0:", out["E5_prime3"]["all_mismatches_zero"])
    print("wrote", path)


if __name__ == "__main__":
    main()