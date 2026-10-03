"""
r48 / AXIS-B : matched-scale smoothness for the families that are cheap to
sample, using the SINGLE shared smoothness predicate from smooth.py.

Scale choice: the class-group order distribution is only measurable at
h ~ 28 bits on this host (see cost_curve.py), so the PRIMARY matched-twin
comparison is run at 28-bit GROUP ORDERS, where every family can be sampled.
The 64- and 96-bit rows are reported for the families that reach them.
"""
from __future__ import annotations

import json
import math
import random
import sys
from collections import Counter

import families as F
from harness import _wilson, lpf_stats, matched_bucket, order_stats, smoothness_curve
from smooth import iroot, is_B_smooth, rho

UGRID = (2.0, 2.5, 3.0, 3.5, 4.0)
RESULTS = {}
N = int(sys.argv[1]) if len(sys.argv) > 1 else 3000


def log(*a):
    print(*a, flush=True)


def record(name, pairs, want_bits, note, took=None):
    orders_all = [m for _, m in pairs]
    bucket, slack = matched_bucket(pairs, want_bits, N)
    orders = [m for _, m in bucket]
    sc = smoothness_curve(orders, UGRID)
    lf = lpf_stats(orders)
    RESULTS.setdefault(name, {})[want_bits] = {
        "note": note, "slack": slack, "n_drawn": len(pairs), "n_matched": len(orders),
        "took": took, "stats_drawn": order_stats(orders_all),
        "stats_matched": order_stats(orders), "smoothness": {str(u): sc[u] for u in sc},
        "lpf": lf,
    }
    log(f"  {name:24s} @{want_bits}b  n_matched={len(orders)} (slack {slack}, "
        f"drawn {len(pairs)})")
    for u in UGRID:
        r = sc[u]
        log(f"       u={u:<4} P={r['P_smooth']:.4f}  CI95 "
            f"[{r['ci95'][0]:.4f},{r['ci95'][1]:.4f}]  rho(u)={rho(u):.4f}")
    if lf:
        log(f"       LARGEST PRIME POWER FACTOR: log2 median "
            f"{lf['log2_lpf_median']:.1f} (group order log2 ~{want_bits}) "
            f"-> walk cost ~ 2^{lf['log2_lpf_median']/2:.1f}")
    return RESULTS[name][want_bits]


def main():
    log(f"=== r48 AXIS-B matched-scale smoothness, N={N} ===")
    log(f"rho(2)=1-ln2={1-math.log(2):.6f}   (asymptotic; see selftest T3)\n")

    # ---------------- PRIMARY SCALE: 28-bit group orders ----------------
    B = 28
    log(f"########## PRIMARY MATCHED SCALE: {B}-bit GROUP ORDERS ##########")

    rng = random.Random(4242)
    log(f"[{B}] NULL CONTROL: uniform random integer")
    record(f"uniform_rand_{B}",
           [("r", rng.randrange(1 << (B - 1), 1 << B)) for _ in range(N)],
           B, "uniform random integer -- the null")

    log(f"[{B}] EC baseline")
    record("EC_baseline", F.ec_orders(N, B, seed=11), B,
           "random curve over a random b-bit prime; |E(F_p)| ~ p")

    log(f"[{B}] PGL(2,p), order p(p^2-1) ~ p^3")
    record("PGL2_p", F.pgl2_orders(N, B, seed=12), B,
           "|PGL(2,p)| = p(p^2-1)")

    log(f"[{B}] GL(2,p), order ~ p^4")
    record("GL2_p", F.gl2_orders(N, B, seed=13), B,
           "|GL(2,p)| = (p^2-1)(p^2-p)")

    log(f"[{B}] PSL(2,p) = |PGL(2,p)|/gcd(2,p-1)")
    record("PSL2_p", F.psl2_orders(N, B, seed=14), B, "|PSL(2,p)|")

    # NOTE: C(D)[3] is a POWER OF 3 by construction, so P(B-smooth) = 1 for
    # every B >= 3.  Sampling it would burn hours of PARI time to confirm a
    # tautology, so it is asserted in the notes rather than measured here.
    # The quantity that actually matters for it is how LARGE 3^rank gets.

    # ---------------- LARGER SCALES for the reachable families ----------
    for B2 in (64, 96):
        log(f"\n########## SECONDARY SCALE: {B2}-bit GROUP ORDERS ##########")
        rng = random.Random(4200 + B2)
        record(f"uniform_rand_{B2}",
               [("r", rng.randrange(1 << (B2 - 1), 1 << B2)) for _ in range(N)],
               B2, "uniform random integer -- the null")
        record("EC_baseline", F.ec_orders(N, B2, seed=20 + B2), B2,
               "random curve over a random b-bit prime; |E(F_p)| ~ p")
        record("PGL2_p", F.pgl2_orders(N, B2, seed=30 + B2), B2,
               "|PGL(2,p)|")
        record("GL2_p", F.gl2_orders(N, B2, seed=40 + B2), B2,
               "|GL(2,p)|")

    with open("matched_results.json", "w") as fh:
        json.dump(RESULTS, fh, indent=1)

    for B3 in sorted({k2 for v in RESULTS.values() for k2 in v}):
        rows = []
        for name, per_bits in RESULTS.items():
            if B3 in per_bits:
                r = per_bits[B3]
                s2 = r["smoothness"]["2.0"]
                rows.append((name, s2["P_smooth"], s2["ci95"],
                             r["smoothness"]["3.0"]["P_smooth"],
                             r["smoothness"]["4.0"]["P_smooth"], s2["n"]))
        ecp = dict((r[0], r[1]) for r in rows).get("EC_baseline")
        up = dict((r[0], r[1]) for r in rows).get(f"uniform_rand_{B3}")
        log("")
        log(f"### MATCHED TABLE, {B3}-bit group orders")
        log(f"{'family':22s} {'P(u=2)':>8s} {'CI95':>17s} {'/EC':>7s} "
            f"{'/rand':>7s} {'P(u=3)':>8s} {'P(u=4)':>8s} {'n':>6s}")
        for name, p2, ci, p3, p4, n in sorted(rows, key=lambda t: -t[1]):
            re_ = p2 / ecp if ecp else float('nan')
            ru = p2 / up if up else float('nan')
            log(f"{name:22s} {p2:8.4f} [{ci[0]:.4f},{ci[1]:.4f}] {re_:7.3f} "
                f"{ru:7.3f} {p3:8.4f} {p4:8.4f} {n:6d}")
    log("\nwrote matched_results.json")


if __name__ == "__main__":
    main()