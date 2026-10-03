"""
r48 / AXIS-B : MAIN MEASUREMENT.

Runs every family, buckets the orders by bit-length, and at MATCHED bit-length
measures P(B-smooth) with the single shared predicate from smooth.py.

Usage:  python3.12 run_measure.py [n_per_family]
"""
from __future__ import annotations

import json
import math
import random
import sys
import time
from collections import Counter

import families as F
from harness import matched_bucket, order_stats, smoothness_curve, _wilson
from smooth import iroot, is_B_smooth, rho

N = int(sys.argv[1]) if len(sys.argv) > 1 else 3000
UGRID = (2.0, 2.5, 3.0, 3.5, 4.0)

RESULTS = {}


def log(*a):
    print(*a, flush=True)


def do_family(name, sampler, want_bits, n, note=""):
    t0 = time.time()
    pairs = sampler(n)
    dt = time.time() - t0
    orders_all = [m for _, m in pairs]
    bucket, slack = matched_bucket(pairs, want_bits, n)
    orders = [m for _, m in bucket]
    sc = smoothness_curve(orders, UGRID)
    RESULTS[name] = {
        "note": note,
        "want_bits": want_bits,
        "matched_slack_bits": slack,
        "n_drawn": len(pairs),
        "n_matched": len(orders),
        "draw_seconds": dt,
        "order_stats_drawn": order_stats(orders_all) if orders_all else {},
        "order_stats_matched": order_stats(orders),
        "smoothness": {str(u): sc[u] for u in sc},
    }
    log(f"  {name:28s} bits={want_bits} n={len(orders)} "
        f"(slack {slack}, drew {len(pairs)} in {dt:.1f}s)")
    for u in UGRID:
        r = sc[u]
        log(f"      u={u:<4} P(B-smooth) = {r['P_smooth']:.4f}  "
            f"CI95 {r['ci95'][0]:.4f}..{r['ci95'][1]:.4f}   "
            f"(rho(u)={rho(u):.4f})")
    return RESULTS[name]


def matched_rows(want_bits):
    """Assemble the comparison table at one scale."""
    ec = RESULTS["EC_baseline"]
    rows = []
    for name, r in RESULTS.items():
        if r["want_bits"] != want_bits:
            continue
        s2 = r["smoothness"]["2.0"]
        rows.append({
            "family": name,
            "bits": want_bits,
            "P_smooth_u2": s2["P_smooth"],
            "ci95": s2["ci95"],
            "n": s2["n"],
            "P_u25": r["smoothness"]["2.5"]["P_smooth"],
            "P_u3": r["smoothness"]["3.0"]["P_smooth"],
            "P_u4": r["smoothness"]["4.0"]["P_smooth"],
            "ratio_vs_EC": (s2["P_smooth"] / ec["smoothness"]["2.0"]["P_smooth"]
                            if ec["smoothness"]["2.0"]["P_smooth"] else None),
            "slack": r["matched_slack_bits"],
            "bits_median_matched": r["order_stats_matched"]["bits_median"],
        })
    return rows


def main():
    log(f"=== r48 AXIS-B measurement, N={N} per family ===")
    log(f"rho(2) = {rho(2.0):.6f}  (1-ln2 = {1 - math.log(2):.6f})")
    log("")

    # ---------- CONTROL 0: uniform random integers, the null ----------
    for bits in (64, 96):
        log(f"[{bits}-bit] uniform random integer (NULL control)")
        rng = random.Random(1000 + bits)
        pairs = [("rand", rng.randrange(1 << (bits - 1), 1 << bits))
                 for _ in range(N)]
        orders = [m for _, m in pairs]
        sc = smoothness_curve(orders, UGRID)
        RESULTS[f"uniform_rand_{bits}"] = {
            "note": "NULL CONTROL: a uniform random integer of the same size",
            "want_bits": bits, "matched_slack_bits": 0,
            "n_drawn": len(orders), "n_matched": len(orders),
            "draw_seconds": 0.0,
            "order_stats_drawn": order_stats(orders),
            "order_stats_matched": order_stats(orders),
            "smoothness": {str(u): sc[u] for u in sc},
        }
        log(f"  {'uniform_rand':28s} bits={bits} n={len(orders)}")
        for u in UGRID:
            r = sc[u]
            log(f"      u={u:<4} P(B-smooth) = {r['P_smooth']:.4f}  "
                f"CI95 {r['ci95'][0]:.4f}..{r['ci95'][1]:.4f}  "
                f"(rho(u)={rho(u):.4f})")
    log("")

    for bits in (64, 96):
        log(f"===== SCALE: {bits}-bit GROUP ORDERS =====")
        log(f"[{bits}] EC baseline -- the control every family must beat")
        do_family("EC_baseline", lambda n, b=bits: F.ec_orders(n, b),
                  bits, N, "random curve over a random b-bit prime; m ~ p")

        log(f"[{bits}] imaginary quadratic class group, FREE D "
            f"(D ~ 2^{bits+1} so that h ~ 2^{bits})")
        do_family("imq_class_free_D",
                  lambda n, b=bits: F.class_numbers(n, 2 * b + 2), bits, N,
                  "h(Q(sqrt(-D))), D fundamental and FREE.  Best order "
                  "distribution any class group can offer -- but D is not a "
                  "function of N, so this family cannot factor anything.")

        log(f"[{bits}] imaginary quadratic class group, D = -N for a random "
            f"semiprime N (Schnorr-Lenstra slice -- REACHABLE)")
        do_family("imq_class_D_eq_N",
                  lambda n, b=bits: F.semiprime_class_numbers(n, 2 * b), bits, N,
                  "h(Q(sqrt(-N))) with N = pq.  The field IS a function of N, "
                  "so a rho walk here can factor N -- at the cost of having no "
                  "freedom to resample D.")

        log(f"[{bits}] PGL(2,p), order ~ p^3")
        do_family("PGL2_p", lambda n, b=bits: F.pgl2_orders(n, bits // 3 + 1),
                  bits, N, "|PGL(2,p)| = p(p^2-1)")

        log(f"[{bits}] GL(2,p), order ~ p^4")
        do_family("GL2_p", lambda n, b=bits: F.gl2_orders(n, bits // 4 + 1),
                  bits, N, "|GL(2,p)| = (p^2-1)(p^2-p)")

        log(f"[{bits}] 3-torsion of the imaginary quadratic class group")
        do_family("imq_3torsion", lambda n, b=bits: F.selmer3_orders(n, 2 * b + 2),
                  bits, N, "3-part of h(Q(sqrt(-D)))")

        log(f"[{bits}] pure cubic class group, x^3-m")
        do_family("cubic_class_group",
                  lambda n, b=bits: F.cubic_class_numbers(max(30, n // 20), 2 * b + 4),
                  bits, N, "h of Q(cuberoot(m))")

        log(f"[{bits}] pure quartic class group, x^4-m")
        do_family("quartic_class_group",
                  lambda n, b=bits: F.quartic_class_numbers(max(20, n // 40), 2 * b + 6),
                  bits, N, "h of Q(4throot(m))")
        log("")

    with open("results.json", "w") as fh:
        json.dump({"results": RESULTS,
                   "rows_64": matched_rows(64),
                   "rows_96": matched_rows(96),
                   "rho2": rho(2.0)}, fh, indent=1)
    log("wrote results.json")
    for bits in (64, 96):
        log(f"")
        log(f"### MATCHED TABLE, {bits}-bit orders (P(B-smooth) at u=2)")
        log(f"{'family':26s} {'P_u2':>8s} {'CI95':>18s} {'ratio/EC':>9s} "
            f"{'P_u3':>8s} {'P_u4':>8s} {'n':>6s}")
        for r in matched_rows(bits):
            log(f"{r['family']:26s} {r['P_smooth_u2']:8.4f} "
                f"[{r['ci95'][0]:.4f},{r['ci95'][1]:.4f}] "
                f"{r['ratio_vs_EC']:9.3f} {r['P_u3']:8.4f} {r['P_u4']:8.4f} "
                f"{r['n']:6d}")


if __name__ == "__main__":
    main()