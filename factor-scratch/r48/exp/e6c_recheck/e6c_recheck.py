#!/usr/bin/env python3
"""
E-6c RECHECK -- does the "~1.6x smoothness advantage of class numbers over
elliptic curves" claim survive a proper measurement?

    python3 selftest.py          # MUST pass first (all four T-blocks)
    python3 e6c_recheck.py       # this file; writes e6c_recheck_results.json

HYPOTHESES ARE PREREGISTERED in PREREG.md, whose sha256 is baked into
_PREREG_SHA256 below.  The run aborts if the file has been edited, so the
hypotheses cannot be tuned after seeing results.

WHAT THIS FIXES
---------------
`Experiments/e6c_results.json` is `{"n": 25, "class_smooth": 0.72,
"ec_smooth": 0.44}` -- three keys, no B, no bit-lengths, no seed, and no
`.py` anywhere in git history.  It claims 0.720 against a Dickman
prediction of 0.0587 at its own stated scale, i.e. 12.3x above uniform.

This file measures all three arms with the SHARED harness:

  arm A  class numbers  h(-q),  q prime = 3 mod 4          [no p]
  arm B  EC group orders #E(F_p) over a KNOWN prime p       [uses p]
  arm C  uniform random integers at matched bit-length      [null]
  arm D  ODD random integers at matched bit-length          [null, genus theory]

Arms C and D are matched by BINNING ON MEASURED BIT-LENGTH, so no
comparison anywhere in this file assumes the arms share a nominal scale.

Everything that could make a downstream number meaningless is recorded in
the output JSON: B, the bit-length distribution of every arm, sample sizes,
seeds, and the q / p values actually used.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
import platform
import random
import statistics
import sys
import time
from collections import Counter

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/_shared")

import cypari2  # noqa: E402
import numpy as np  # noqa: E402
import scipy  # noqa: E402
import sympy  # noqa: E402
from scipy import stats  # noqa: E402
from sympy import isprime, nextprime  # noqa: E402

import dickman  # noqa: E402  -- THE SHARED HARNESS. Never reimplemented here.

_HERE = os.path.dirname(os.path.abspath(__file__))
_PREREG_PATH = os.path.join(_HERE, "PREREG.md")

# Baked in when PREREG.md was finalised, BEFORE the measurement code ran.
# Recompute with: python3 -c "import hashlib,sys;print(hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest())" PREREG.md
_PREREG_SHA256 = "52b2c262f0a22933da5ea81ff9afb89d746b9b8f8a91cbb9c4f8cc942d8a02a4"


# ---------------------------------------------------------------------------
# Preregistration gate
# ---------------------------------------------------------------------------


def check_prereg() -> str:
    with open(_PREREG_PATH, "rb") as fh:
        digest = hashlib.sha256(fh.read()).hexdigest()
    if digest != _PREREG_SHA256:
        print("PREREGISTRATION MISMATCH.")
        print(f"  on disk: {digest}")
        print(f"  baked in: {_PREREG_SHA256}")
        print("The hypotheses were edited after the run was preregistered.")
        print("Restore PREREG.md, or --if you are deliberately re-preregistering,")
        print("re-run with --update-prereg to record the new hash deliberately.")
        sys.exit(2)
    return digest


# ---------------------------------------------------------------------------
# Statistics -- fixed in PREREG.md before the run
# ---------------------------------------------------------------------------


def wilson(k: int, n: int, conf: float = 0.95) -> tuple[float, float, float]:
    """Wilson score interval.  Returns (point, lo, hi).  n == 0 -> (nan,nan,nan)."""
    if n == 0:
        return (float("nan"),) * 3
    z = stats.norm.ppf(0.5 + conf / 2)
    p = k / n
    d = 1 + z * z / n
    centre = (p + z * z / (2 * n)) / d
    half = z * math.sqrt(p * (1 - p) / n + z * z / (4 * n * n)) / d
    return (p, max(0.0, centre - half), min(1.0, centre + half))


def bootstrap_ratio_ci(k1: int, n1: int, k2: int, n2: int,
                       reps: int = 10000, seed: int = 20261003,
                       conf: float = 0.95):
    """Percentile bootstrap CI for p1/p2 with p1 = k1/n1, p2 = k2/n2.

    Nonparametric, two independent binomials.  Returns (ratio, lo, hi, p_two_sided)
    where p_two_sided is the fraction of bootstrap ratios at least as extreme
    as the observed one in the direction away from 1.
    """
    if n1 == 0 or n2 == 0:
        return (float("nan"),) * 3 + (float("nan"),)
    obs = (k1 / n1) / (k2 / n2) if k2 else float("inf")
    rng = np.random.default_rng(seed)
    a = rng.binomial(n1, k1 / n1, size=reps).astype(np.float64)
    b = rng.binomial(n2, k2 / n2, size=reps).astype(np.float64)
    # add-1/2 keeps a zero-count cell from producing an infinite ratio
    denom = (b + 0.5) / (n2 + 1.0)
    ratios = ((a + 0.5) / (n1 + 1.0)) / denom
    ratios = ratios[np.isfinite(ratios)]
    lo, hi = np.quantile(ratios, [(1 - conf) / 2, 1 - (1 - conf) / 2])
    if k2 == 0:
        return (float("inf"), float(lo), float(hi), 0.0)
    # two-sided p: bootstrap mass at least as far from 1 as the observation
    dist = np.abs(np.log(ratios))
    p = float((np.abs(np.log(obs)) <= dist).mean())
    return (obs, float(lo), float(hi), min(1.0, 2 * min(p, 1.0)))


def dickman_mean(values: list[int], B: int) -> float:
    """Mean of rho(log2 n / log2 B) over the ACTUAL measured objects.

    NOT rho at a bin centre: the arms have spread in bit-length and the
    prediction must be integrated over that spread to be a fair null.
    """
    if not values:
        return float("nan")
    lb = math.log2(B)
    return float(np.mean([dickman.rho(math.log2(max(v, 2)) / lb) for v in values]))


# ---------------------------------------------------------------------------
# Arms
# ---------------------------------------------------------------------------


def prime_3mod4(bits: int, rng: random.Random) -> int:
    """A prime q = 3 mod 4 with exactly `bits` bits."""
    lo, hi = 2 ** (bits - 1), 2 ** bits
    while True:
        q = int(nextprime(rng.randrange(lo, hi)))
        while q % 4 != 3:
            q = int(nextprime(q + 1))
        if q.bit_length() == bits:
            return q


def arm_class_numbers(q_bits: int, n: int, seed: int, pari) -> list[dict]:
    """ARM A: h(-q) for q prime = 3 mod 4.  [does not use p]"""
    rng = random.Random(seed)
    out = []
    for _ in range(n):
        q = prime_3mod4(q_bits, rng)
        h = int(pari.qfbclassno(-q))
        out.append({"q": q, "h": h, "h_bits": h.bit_length(),
                    "h_is_odd": h % 2 == 1})
    return out


def prime_of_bits(bits: int, seed: int) -> int:
    """A prime with exactly `bits` bits."""
    rng = random.Random(seed)
    return int(nextprime(rng.randrange(2 ** (bits - 1), 2 ** bits)))


def arm_ec_orders_at_bits(target_bits: int, n: int, seed: int, pari
                          ) -> tuple[list[dict], int]:
    """ARM B: EC group orders matched to a TARGET BIT-LENGTH by construction.

    Every quantity here is [uses p].  We take the GROUP ORDER #E(F_p), which
    is the quantity ECM actually exploits and the one Hasse bounds to
    +-2*sqrt(p) around p+1.

    Matching is by construction, not by hope: pick p with `target_bits` bits,
    sample curves, and KEEP ONLY those whose order has exactly `target_bits`
    bits.  (The first version of this file sampled a handful of p and then
    intersected bit-length histograms; with Hasse-concentrated orders and a
    narrow class-number spread that left only 3 shared bins out of 5 scales,
    i.e. the "matched" comparison was matched at 3 points by luck.)
    """
    rng = random.Random(seed)
    p = prime_of_bits(target_bits, seed)
    while not isprime(p):
        p = int(nextprime(p + 1))
    # PARI `ellcard` on a COMPOSITE modulus silently returns N+1 and raises no
    # error (notes/T_pari_ellcard_hazard.md, verified 0/6 against CRT truth).
    # Every p here is prime and this asserts it at runtime, because "validated
    # on primes, then used on composites" is exactly how that hazard bites.
    assert isprime(p), f"EC baseline modulus {p} is not prime -- ellcard is unsafe"
    out = []
    guard = 0
    max_guard = 400 * n + 5000
    while len(out) < n and guard < max_guard:
        guard += 1
        a4 = rng.randrange(1, p)
        a6 = rng.randrange(1, p)
        if (4 * a4 ** 3 + 27 * a6 ** 2) % p == 0:
            continue          # singular curve: not an elliptic curve at all
        ell = pari.ellinit([a4, a6], p)
        card = int(pari.ellcard(ell))
        if card.bit_length() != target_bits:
            continue          # not at the matched scale: discard, do not keep
        out.append({"p": p, "a4": a4, "a6": a6, "order": card,
                    "order_bits": card.bit_length()})
    return out, p, guard


def arm_random(values_bits: list[int], seed: int, odd: bool) -> list[int]:
    """ARM C / D: uniform (or uniform ODD) integers at the given bit-lengths."""
    rng = random.Random(seed)
    out = []
    for b in values_bits:
        v = rng.randrange(2 ** (b - 1), 2 ** b)
        if odd:
            v |= 1
        out.append(v)
    return out


# ---------------------------------------------------------------------------
# Analysis
# ---------------------------------------------------------------------------


def analyse_cell(label: str, arm_vals: dict[str, list[int]], B: int) -> dict:
    """One (arm-set, B) cell.  arm_vals maps arm name -> list of integers."""
    cell = {"label": label, "B": B, "arms": {}}
    for name, vals in arm_vals.items():
        bits = [v.bit_length() for v in vals]
        hits = sum(1 for v in vals if dickman.is_smooth(v, B))
        n = len(vals)
        dm = dickman_mean(vals, B)
        p, lo, hi = wilson(hits, n)
        cell["arms"][name] = {
            "n": n,
            "hits": hits,
            "rate": p,
            "wilson95": [lo, hi],
            "bitlen_min": min(bits) if bits else None,
            "bitlen_max": max(bits) if bits else None,
            "bitlen_mean": float(np.mean(bits)) if bits else None,
            "bitlen_hist": dict(sorted(Counter(bits).items())),
            "dickman_mean_over_sample": dm,
            "rate_over_dickman": (p / dm) if dm and dm > 0 else float("nan"),
        }
    # ratios of interest
    ratios = {}
    base = "class"
    if base in arm_vals:
        for other in arm_vals:
            if other == base:
                continue
            k1 = cell["arms"][base]["hits"]
            n1 = cell["arms"][base]["n"]
            k2 = cell["arms"][other]["hits"]
            n2 = cell["arms"][other]["n"]
            ratios[f"{base}_over_{other}"] = {
                "bootstrap_ratio_ci": bootstrap_ratio_ci(k1, n1, k2, n2),
            }
        # THE CORRECT NULL for class numbers is random_odd, not random:
        # genus theory forces h(-q) odd (2-rank of Cl(-q) = t-1 = 0), and an
        # odd n-bit integer is measurably LESS likely to be B-smooth than an
        # unrestricted one (0.75x at 29 bits / B=1000, measured).  Comparing
        # class numbers to an unrestricted uniform null understates them.
        # The class_over_dickman entry below uses UNIFORM rho, i.e. the
        # original's own null; class_over_random_odd is the sharp one.
        dm = cell["arms"][base]["dickman_mean_over_sample"]
        p, lo, hi = wilson(cell["arms"][base]["hits"], cell["arms"][base]["n"])
        ratios["class_over_dickman"] = {
            "ratio": (p / dm) if dm > 0 else float("nan"),
            "ci_from_wilson": [lo / dm, hi / dm] if dm > 0 else None,
            "contains_1": bool(dm > 0 and lo / dm <= 1 <= hi / dm),
            "all_above_1": bool(dm > 0 and lo / dm > 1),
            "all_below_1": bool(dm > 0 and hi / dm < 1),
        }
        # Fisher exact class vs ec, on the matched bins only
        if "ec" in cell["arms"]:
            tbl = [[cell["arms"]["class"]["hits"],
                    cell["arms"]["class"]["n"] - cell["arms"]["class"]["hits"]],
                   [cell["arms"]["ec"]["hits"],
                    cell["arms"]["ec"]["n"] - cell["arms"]["ec"]["hits"]]]
            odds, pv = stats.fisher_exact(tbl, alternative="two-sided")
            ratios["fisher_class_vs_ec"] = {"odds_ratio": float(odds),
                                            "p_two_sided": float(pv)}
    cell["ratios"] = ratios
    return cell


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--n-class", type=int, default=1500,
                    help="class numbers per scale")
    ap.add_argument("--n-ec", type=int, default=1500,
                    help="EC group orders per p")
    ap.add_argument("--q-scales", type=int, nargs="+",
                    default=[21, 31, 41, 51, 61])
    ap.add_argument("--p-scales", type=int, nargs="*", default=[],
                    help="unused: arm B is matched to arm A's bins by "
                         "construction, not by a fixed p-scale list")
    ap.add_argument("--B", type=int, nargs="+",
                    default=[1000, 10**4, 10**5, 10**6])
    ap.add_argument("--seed", type=int, default=20261003)
    ap.add_argument("--update-prereg", action="store_true")
    args = ap.parse_args()

    if args.update_prereg:
        with open(_PREREG_PATH, "rb") as fh:
            print(hashlib.sha256(fh.read()).hexdigest())
        return 0

    prereg_sha = check_prereg()
    print(f"prereg sha256 verified: {prereg_sha[:16]}...")

    # The harness's own self-test must pass, or nothing below means anything.
    if not dickman._selftest():
        print("SHARED HARNESS SELFTEST FAILED -- aborting.")
        return 1

    pari = cypari2.Pari()
    t0 = time.time()
    out = {
        "meta": {
            "prereg_sha256": prereg_sha,
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S"),
            "python": platform.python_version(),
            "sympy": sympy.__version__,
            "scipy": scipy.__version__,
            "numpy": np.__version__,
            "pari": cypari2.__version__ if hasattr(cypari2, "__version__") else "cypari2",
            "platform": platform.platform(),
            "seed": args.seed,
            "B_grid": args.B,
            "q_scales": args.q_scales,
            "p_scales": args.p_scales,
            "n_class_per_scale": args.n_class,
            "n_ec_per_scale": args.n_ec,
            "harness": "/home/raver1975/lean/factor-scratch/r48/_shared/dickman.py",
            "harness_sha256": hashlib.sha256(
                open("/home/raver1975/lean/factor-scratch/r48/_shared/dickman.py",
                     "rb").read()).hexdigest(),
            "note": "arms labelled 'ec' and 'ec_card' are [uses p]",
        },
        "arms": {},
        "cells": [],
    }

    # ---------------- ARM A: class numbers [no p] ----------------
    print("\n[arm A] class numbers h(-q), q prime = 3 mod 4", flush=True)
    class_all = []
    for qb in args.q_scales:
        recs = arm_class_numbers(qb, args.n_class, args.seed + qb, pari)
        class_all += recs
        hb = [r["h_bits"] for r in recs]
        print(f"  q~2^{qb}: n={len(recs)} h_bits mean={statistics.mean(hb):.1f} "
              f"min={min(hb)} max={max(hb)} "
              f"all_odd={all(r['h_is_odd'] for r in recs)} "
              f"t={time.time()-t0:.0f}s", flush=True)
    out["arms"]["class"] = {
        "description": "h(-q) for random primes q = 3 mod 4; PARI qfbclassno",
        "uses_p": False,
        "n_total": len(class_all),
        "values": [r["h"] for r in class_all],
        "bitlen_hist": dict(sorted(Counter(r["h_bits"] for r in class_all).items())),
        "all_odd": all(r["h_is_odd"] for r in class_all),
        "q_values_head": [r["q"] for r in class_all[:20]],
    }

    # ---------------- ARM B: EC group orders [uses p] ----------------
    # Matched BY CONSTRUCTION to each class-number bit-length bin: for every
    # bit-length b that arm A actually produced, sample curves over a b-bit
    # prime p and keep only orders of exactly b bits.
    print("\n[arm B] EC group orders #E(F_p), matched bin-by-bin  [uses p]",
          flush=True)
    class_by_bits = {}
    for r in class_all:
        class_by_bits.setdefault(r["h_bits"], []).append(r["h"])

    ec_by_bits = {}
    ec_meta = []
    for b in sorted(class_by_bits):
        # ask for as many EC orders as we have class numbers in the bin
        want = max(args.n_ec, len(class_by_bits[b]))
        recs, p, guard = arm_ec_orders_at_bits(b, want, args.seed + 3 * b, pari)
        ec_by_bits[b] = [r["order"] for r in recs]
        ec_meta.append({"bits": b, "p": p, "p_bits": p.bit_length(),
                        "n_orders": len(recs), "curves_tried": guard,
                        "is_prime_p": bool(isprime(p))})
        print(f"  bin {b:>3}b: p={p} ({p.bit_length()}b) "
              f"n_ec={len(recs)} (tried {guard} curves) "
              f"t={time.time()-t0:.0f}s", flush=True)

    ec_all = [{"p": m["p"], "order_bits": m["bits"]}
              for m in ec_meta for _ in range(m["n_orders"])]
    out["arms"]["ec"] = {
        "description": ("#E(F_p) for random curves over a known prime p, "
                        "PARI ellcard; sampled per bit-length bin and filtered "
                        "to orders of exactly that bit-length"),
        "uses_p": True,
        "per_bin": ec_meta,
        "primes_p_used": sorted({m["p"] for m in ec_meta}),
        "n_total": sum(m["n_orders"] for m in ec_meta),
        "values": [v for b in sorted(ec_by_bits) for v in ec_by_bits[b]],
        "bitlen_hist": {str(b): len(ec_by_bits[b]) for b in sorted(ec_by_bits)},
    }

    # ---------------- bin everything on MEASURED bit-length ----------------
    # This is what makes the comparison matched: no cell relies on the arms
    # having the same nominal scale, only on the objects having the same
    # measured bit-length.
    shared_bits = [b for b in sorted(class_by_bits) if len(ec_by_bits.get(b, [])) >= 20]
    print(f"\nbit-length bins with >=20 samples in BOTH arms: {shared_bits}",
          flush=True)
    out["matched_bins"] = shared_bits

    for b in shared_bits:
        cvals = class_by_bits[b]
        evals = ec_by_bits[b]
        # arms C and D sampled to MATCH the bit-length multiset of arm A
        dvals = arm_random([b] * len(cvals), args.seed + 7 * b, odd=True)
        rvals = arm_random([b] * len(cvals), args.seed + 11 * b, odd=False)
        for B in args.B:
            cell = analyse_cell(f"bits={b}", {"class": cvals, "ec": evals,
                                             "random_odd": dvals,
                                             "random": rvals}, B)
            out["cells"].append(cell)

    # per-scale un-binned cells (the ORIGINAL's design: one arm per scale)
    for qb in args.q_scales:
        vals = [r["h"] for r in class_all if r["q"].bit_length() == qb]
        if not vals:
            continue
        for B in args.B:
            out["cells"].append(analyse_cell(
                f"class_only q~2^{qb}", {"class": vals}, B))

    # ---------------- the specific cell the original claimed ----------------
    # "at ~29-bit class numbers, 0.720 vs 0.440", B = 1000.  Select the bin
    # NEAREST 29 bits (first version kept only the LAST bin in the loop, so
    # the reported "claim cell" was bin 34, not the claimed 29).
    target_bits = 29
    best = min(shared_bits, key=lambda b: abs(b - target_bits))
    claim = {"claimed": {"n": 25, "class_smooth": 0.72, "ec_smooth": 0.44,
                         "B": 1000, "bits": target_bits},
             "matched_bin_used": best}
    for cell in out["cells"]:
        if cell["label"] == f"bits={best}" and cell["B"] == 1000:
            ca, ec = cell["arms"]["class"], cell["arms"]["ec"]
            claim.update({
                "measured_class_rate": ca["rate"],
                "measured_class_wilson95": ca["wilson95"],
                "measured_class_n": ca["n"], "measured_class_hits": ca["hits"],
                "measured_ec_rate": ec["rate"],
                "measured_ec_wilson95": ec["wilson95"],
                "measured_ec_n": ec["n"], "measured_ec_hits": ec["hits"],
                "measured_random_rate": cell["arms"]["random"]["rate"],
                "measured_random_odd_rate": cell["arms"]["random_odd"]["rate"],
                "dickman_mean": ca["dickman_mean_over_sample"],
                "class_over_dickman": cell["ratios"]["class_over_dickman"],
                "class_over_ec": cell["ratios"]["class_over_ec"],
                "class_over_random_odd": cell["ratios"].get("class_over_random_odd"),
                "fisher": cell["ratios"].get("fisher_class_vs_ec"),
                "claimed_ratio_vs_measured_ratio":
                    (0.720 / 0.440) / cell["ratios"]["class_over_ec"]
                    ["bootstrap_ratio_ci"][0],
            })
    out["e6c_claim_cell"] = claim

    # ---------------- verdicts, exactly as preregistered ----------------
    verdict = {"H1_cells": [], "H2_cells": [], "H3": {}}
    for cell in out["cells"]:
        if "class" not in cell["arms"] or "ec" not in cell["arms"]:
            continue
        cd = cell["ratios"]["class_over_dickman"]
        ce = cell["ratios"]["class_over_ec"]["bootstrap_ratio_ci"]
        verdict["H1_cells"].append({
            "cell": cell["label"], "B": cell["B"],
            "ratio_over_dickman": cd["ratio"], "ci": cd["ci_from_wilson"],
            "contains_1": cd["contains_1"], "all_above_1": cd["all_above_1"],
            "all_below_1": cd["all_below_1"],
            # the SHARP null, given that h(-q) is always odd
            "class_over_random_odd":
                cell["ratios"].get("class_over_random_odd", {})
                .get("bootstrap_ratio_ci"),
        })
        verdict["H2_cells"].append({
            "cell": cell["label"], "B": cell["B"],
            "class_over_ec": ce[0], "ci": [ce[1], ce[2]], "p": ce[3],
            "contains_1": bool(ce[1] <= 1 <= ce[2]),
        })

    # H3: the 1.6x claim, evaluated at every matched cell at B = 1000
    h3_cells = [v for v in verdict["H2_cells"] if v["B"] == 1000]
    surv = [v for v in h3_cells
            if v["ci"][0] <= 1.6 <= v["ci"][1] and not v["contains_1"]]
    verdict["H3"] = {
        "claim": 1.6,
        "cells_at_B1000": h3_cells,
        "survives_at_any_cell": bool(surv),
        "surviving_cells": surv,
    }
    verdict["H1_summary"] = {
        "any_cell_above_1": any(v["all_above_1"] for v in verdict["H1_cells"]),
        "all_cells_contain_1": all(v["contains_1"] for v in verdict["H1_cells"]),
        "any_cell_below_1": any(v["all_below_1"] for v in verdict["H1_cells"]),
    }
    verdict["H2_summary"] = {
        "any_cell_above_1": any(not v["contains_1"] and v["class_over_ec"] > 1
                               for v in verdict["H2_cells"]),
        "all_cells_contain_1": all(v["contains_1"] for v in verdict["H2_cells"]),
    }
    verdict["H2_summary"]["H2_holds"] = verdict["H2_summary"]["any_cell_above_1"]
    verdict["H1_summary"]["H1_holds"] = verdict["H1_summary"]["any_cell_above_1"]
    verdict["survives_claim"] = bool(
        verdict["H2_summary"]["H2_holds"] and verdict["H3"]["survives_at_any_cell"])
    out["verdict"] = verdict

    out["runtime_seconds"] = round(time.time() - t0, 1)
    path = os.path.join(_HERE, "e6c_recheck_results.json")
    with open(path, "w") as fh:
        json.dump(out, fh, indent=1, default=str)

    # ---------------- console summary ----------------
    print("\n" + "=" * 78)
    print("VERDICT (rules fixed in PREREG.md before this run)")
    print("=" * 78)
    print(f"H1 class numbers smoother than uniform: "
          f"{verdict['H1_summary']['H1_holds']}")
    print(f"   any cell above 1 : {verdict['H1_summary']['any_cell_above_1']}")
    print(f"   all cells contain 1: {verdict['H1_summary']['all_cells_contain_1']}")
    print(f"   any cell below 1 : {verdict['H1_summary']['any_cell_below_1']}")
    print(f"H2 advantage over a CORRECT matched EC baseline: "
          f"{verdict['H2_summary']['H2_holds']}")
    print(f"   all cells contain 1: {verdict['H2_summary']['all_cells_contain_1']}")
    print(f"H3 the 1.6x claim survives: "
          f"{verdict['H3']['survives_at_any_cell']}")
    print(f"'FIRST POSITIVE AT-SCALE SIGNAL' SURVIVES: "
          f"{verdict['survives_claim']}")
    print("\nB=1000 matched cells (class rate [CI], ec rate [CI], "
          "odd-null rate, ratio [CI]):")
    for v in h3_cells:
        cell = next(c for c in out["cells"]
                    if c["label"] == v["cell"] and c["B"] == 1000)
        ca, ec = cell["arms"]["class"], cell["arms"]["ec"]
        ro = cell["arms"].get("random_odd", {}).get("rate", float("nan"))
        print(f"  {v['cell']:>12}  "
              f"{ca['rate']:.4f} [{ca['wilson95'][0]:.4f},{ca['wilson95'][1]:.4f}]"
              f"  {ec['rate']:.4f} [{ec['wilson95'][0]:.4f},{ec['wilson95'][1]:.4f}]"
              f"  {ro:.4f}  "
              f"{v['class_over_ec']:.3f} [{v['ci'][0]:.3f},{v['ci'][1]:.3f}]"
              f"  p={v['p']:.3g}")

    print(f"\nTHE CLAIMED CELL (bin {claim['matched_bin_used']} bits, B=1000):")
    print(f"  class  measured {claim['measured_class_rate']:.4f} "
          f"[{claim['measured_class_wilson95'][0]:.4f},"
          f"{claim['measured_class_wilson95'][1]:.4f}]  "
          f"(n={claim['measured_class_n']}, claimed 0.720)")
    print(f"  EC     measured {claim['measured_ec_rate']:.4f} "
          f"[{claim['measured_ec_wilson95'][0]:.4f},"
          f"{claim['measured_ec_wilson95'][1]:.4f}]  "
          f"(n={claim['measured_ec_n']}, claimed 0.440)")
    print(f"  odd-null random {claim['measured_random_odd_rate']:.4f}, "
          f"uniform {claim['measured_random_rate']:.4f}, "
          f"Dickman {claim['dickman_mean']:.4f}")
    print(f"  class/Dickman = {claim['class_over_dickman']['ratio']:.3f} "
          f"[{claim['class_over_dickman']['ci_from_wilson'][0]:.3f},"
          f"{claim['class_over_dickman']['ci_from_wilson'][1]:.3f}]  "
          f"(claimed 12.3x)")
    print(f"  class/EC      = {claim['class_over_ec']['bootstrap_ratio_ci'][0]:.3f} "
          f"[{claim['class_over_ec']['bootstrap_ratio_ci'][1]:.3f},"
          f"{claim['class_over_ec']['bootstrap_ratio_ci'][2]:.3f}]  "
          f"(claimed 1.636x)")
    print(f"  Fisher class vs EC: p = "
          f"{claim['fisher']['p_two_sided']:.4g}, odds = "
          f"{claim['fisher']['odds_ratio']:.3f}")
    print(f"\nwrote {path}  ({out['runtime_seconds']}s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
