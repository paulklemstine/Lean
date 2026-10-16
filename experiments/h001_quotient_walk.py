#!/usr/bin/env python3
"""
HYPOTHESIS #001 (Vector C: Endomorphism Rings & Equivalence Classes)
====================================================================

On j-invariant-0 curves E: y^2 = x^3 + b over F_p (p ≡ 1 mod 3) with GLV
automorphism phi(x,y) = (beta*x, y), beta^3 = 1, walking Pollard's rho on the
equivalence classes {±P, ±phi(P), ±phi^2(P)} (6 elements generically) reduces
the expected number of group operations by a factor of sqrt(6) ≈ 2.449 versus
vanilla Pollard's rho.  Intermediate: negation-only classes {±P} give sqrt(2).

FALSIFIABLE PREDICTIONS (per instance, n = |<G>|):
    E[ops(vanilla)] ≈ sqrt(pi*n/2)   ≈ 1.2533 * sqrt(n)
    E[ops(m=2)]     ≈ sqrt(pi*n/4)   ≈ 0.8862 * sqrt(n)   (ratio 1/sqrt(2))
    E[ops(m=6)]     ≈ sqrt(pi*n/12)  ≈ 0.5117 * sqrt(n)   (ratio 1/sqrt(6))

Design:
  * Paired comparison: identical instance (d, Q), identical step table,
    identical dp_bits/W for all three algorithms.
  * Metric: group operations (point additions).  Wall time reported secondarily.
  * Oracle-leak guard: solvers receive ONLY (curve, Q, n, steps, ...) — the
    secret d is generated and used solely for post-hoc verification.
  * Controls: popcount(d)-vs-ops correlation; per-instance paired ratios;
    log-log complexity fit (slope must be 0.5 for all variants).

Tiers:  k = 16, 20, 24, 28 (Tier 1) and 32, 36, 40 (Tier 2), 20 instances each.
"""
import json
import math
import os
import random
import sys
import time

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "benchmarks"))

from curve_ladder import get_curve, make_step_table  # noqa: E402

SEED = 20261015
TIERS = [16, 20, 24, 28, 32, 36, 40]
N_INST = 20
W = 256


def rho_quotient(curve, Q, m, steps, dp_bits, rng, max_ops):
    """
    Pollard rho walking on equivalence classes of size m in {1, 2, 6}.

    m=1: vanilla.  m=2: classes {±P}.  m=6: classes {±P, ±phi P, ±phi^2 P}.
    Walk state X = a*G + b*Q evolves by X <- X + R_{w(X)} where the partition
    index w depends only on the class (via canonical representative), making the
    projected walk on classes Markov.  DP collisions are detected on canonical
    representatives; X_i = eps*phi^j(X_j) is resolved by trying all (eps, j).

    Fruitless-cycle handling: if a walk exceeds restart_at steps without a
    collision (its cycle contains no distinguished point), restart from a fresh
    random step point.  The DP table persists across restarts (cross-restart
    collisions are still valid class collisions).  Reported group_ops is the
    TOTAL across restarts (honest accounting).

    Returns (d or None, total_group_ops, n_restarts).
    """
    n = curve.n
    p = curve.p
    G = curve.G
    beta = curve.beta
    lam = curve.lam
    Wloc = len(steps)
    mask = (1 << dp_bits) - 1

    def canon(X):
        if m == 1:
            return X
        x, y = X
        ys = y if y <= p - y else p - y          # min(y, p-y): negation-invariant
        if m == 2:
            return (x, ys)
        bx = beta * x % p
        b2x = beta * bx % p
        xs = x
        if bx < xs:
            xs = bx
        if b2x < xs:
            xs = b2x                              # min(x, bx, b2x): phi-invariant
        return (xs, ys)

    # collision candidates: X = eps * phi^j (X0), eps in {±1}, j in Z/3
    if m == 1:
        cands = ((1, 0),)
    elif m == 2:
        cands = ((1, 0), (-1, 0))
    else:
        cands = tuple((e, j) for e in (1, -1) for j in (0, 1, 2))

    table = {}
    total_ops = 0
    n_restarts = 0
    restart_at = max(1000, int(15.0 * math.sqrt(math.pi * n / (2.0 * m))))
    while total_ops < max_ops:
        w0 = rng.randrange(Wloc)
        (x, y), a, b = steps[w0]
        X = (x, y)
        cX = canon(X)
        while total_ops < max_ops:
            w = int(cX[0]) % Wloc
            (Rx, Ry), ca, cb = steps[w]
            X = curve.add(X, (Rx, Ry))
            a = (a + ca) % n
            b = (b + cb) % n
            total_ops += 1
            if X is None:
                # a*G + b*Q = O  =>  d = -a/b
                if b != 0:
                    dd = (-a) * pow(b, -1, n) % n
                    if curve.mul(dd, G) == Q:
                        return dd, total_ops, n_restarts
                w = rng.randrange(Wloc)
                X = steps[w][0]
                a, b = steps[w][1], steps[w][2]
                cX = canon(X)
                continue
            cX = canon(X)
            if (int(cX[0]) & mask) == 0:
                if cX in table:
                    a0, b0 = table[cX]
                    found = None
                    for e, j in cands:
                        ccoef = e * pow(lam, j, n) % n
                        num = (a - ccoef * a0) % n
                        den = (ccoef * b0 - b) % n
                        if den != 0:
                            dd = num * pow(den, -1, n) % n
                            if curve.mul(dd, G) == Q:
                                found = dd
                                break
                    if found is not None:
                        return found, total_ops, n_restarts
                    # degenerate collision (all den == 0): keep walking
                else:
                    table[cX] = (a, b)
            if total_ops >= restart_at * (n_restarts + 1):
                break  # fruitless cycle: restart with fresh start
        n_restarts += 1
    return None, total_ops, n_restarts


def run_tier(k, n_inst=N_INST):
    curve = get_curve(k)
    n = curve.n
    # DP density: window ~ sqrt(n)/32 keeps every walk-cycle well-populated with
    # distinguished points (fruitless-cycle probability ~e^{-32}), while the
    # detection delay 2^dp stays << expected ops.
    dp_bits = max(4, k // 2 - 5)
    max_ops = min(int(20 * math.sqrt(math.pi * n / 2)), 40_000_000)
    results = []
    for i in range(n_inst):
        rng_inst = random.Random(f"{SEED}-{k}-{i}")
        d = rng_inst.randrange(1, n)
        Q = curve.mul(d, curve.G)
        # shared step table (identical for all three algorithms)
        rng_tab = random.Random(f"{SEED}-{k}-{i}-tab")
        steps = make_step_table(curve, Q, W, rng_tab)
        rec = {"k": k, "i": i, "d": d, "n": n}
        for m in (1, 2, 6):
            rng_walk = random.Random(f"{SEED}-{k}-{i}-m{m}")
            t0 = time.time()
            dd, ops, resumes = rho_quotient(curve, Q, m, steps, dp_bits,
                                           rng_walk, max_ops)
            t1 = time.time()
            rec[f"ops{m}"] = ops
            rec[f"ok{m}"] = (dd == d)
            rec[f"time{m}"] = t1 - t0
            rec[f"resumes{m}"] = resumes
        results.append(rec)
        ok_all = rec["ok1"] and rec["ok2"] and rec["ok6"]
        print(f"  k={k} i={i:2d}: ops1={rec['ops1']:8d} ops2={rec['ops2']:8d} "
              f"ops6={rec['ops6']:8d} ok={ok_all}")
    return results


def summarize(all_results):
    print("\n================ AGGREGATE REPORT ================")
    hdr = f"{'k':>3} {'n_bits':>6} | {'vanilla':>9} {'m=2':>9} {'m=6':>9} | " \
          f"{'r2 med':>7} {'r6 med':>7} {'r6 mean':>8} | {'slope1':>6} {'slope6':>6}"
    print(hdr)
    summary = {}
    for k in TIERS:
        res = all_results[k]
        n = res[0]["n"]
        o1 = [r["ops1"] for r in res]
        o2 = [r["ops2"] for r in res]
        o6 = [r["ops6"] for r in res]
        r2 = sorted(a / b for a, b in zip(o1, o2))
        r6 = sorted(a / b for a, b in zip(o1, o6))
        med = lambda v: v[len(v) // 2]
        nbits = n.bit_length()
        # log-log slope of median ops vs n across tiers (filled later)
        summary[k] = dict(
            n_bits=nbits,
            vanilla_mean=sum(o1) / len(o1), m2_mean=sum(o2) / len(o2),
            m6_mean=sum(o6) / len(o6),
            vanilla_med=med(sorted(o1)), m2_med=med(sorted(o2)), m6_med=med(sorted(o6)),
            r2_med=med(r2), r6_med=med(r6),
            r6_mean=sum(a / b for a, b in zip(o1, o6)) / len(o1),
            fail=sum(1 for r in res if not (r["ok1"] and r["ok2"] and r["ok6"])),
            sqrt_n=math.sqrt(n),
        )
        print(f"{k:>3} {nbits:>6} | {summary[k]['vanilla_mean']:>9.0f} "
              f"{summary[k]['m2_mean']:>9.0f} {summary[k]['m6_mean']:>9.0f} | "
              f"{summary[k]['r2_med']:>7.3f} {summary[k]['r6_med']:>7.3f} "
              f"{summary[k]['r6_mean']:>8.3f}")
    # complexity fit: slope of log2(median ops) vs log2(n)
    xs = [summary[k]["n_bits"] for k in TIERS]
    for key, label in (("vanilla_med", "slope1"), ("m6_med", "slope6")):
        ys = [math.log2(summary[k][key]) for k in TIERS]
        xm = sum(xs) / len(xs)
        ym = sum(ys) / len(ys)
        slope = sum((x - xm) * (y - ym) for x, y in zip(xs, ys)) / \
            sum((x - xm) ** 2 for x in xs)
        for k in TIERS:
            summary[k][label] = slope
    # oracle-leak control: correlation of ops with popcount(d)
    print("\n--- oracle-leak control: corr(ops, popcount(d)) ---")
    for k in TIERS:
        res = all_results[k]
        pc = [bin(r["d"]).count("1") for r in res]
        for m in (1, 6):
            ops = [r[f"ops{m}"] for r in res]
            mp = sum(pc) / len(pc)
            mo = sum(ops) / len(ops)
            cov = sum((a - mp) * (b - mo) for a, b in zip(pc, ops)) / len(pc)
            sp = (sum((a - mp) ** 2 for a in pc) / len(pc)) ** 0.5
            so = (sum((b - mo) ** 2 for b in ops) / len(ops)) ** 0.5
            corr = cov / (sp * so) if sp * so else 0.0
            print(f"  k={k} m={m}: corr={corr:+.3f}")
    return summary


def main():
    all_results = {}
    for k in TIERS:
        print(f"--- tier k={k} ---")
        all_results[k] = run_tier(k)
    summary = summarize(all_results)
    out = {"seed": SEED, "n_inst": N_INST, "W": W, "summary": summary,
           "per_instance": {str(k): all_results[k] for k in TIERS}}
    path = os.path.join(os.path.dirname(__file__), "h001_results.json")
    with open(path, "w") as f:
        json.dump(out, f, indent=1)
    print(f"\nwrote {path}")


if __name__ == "__main__":
    main()
