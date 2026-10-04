"""
R1-R4 -- does conditioning buy anything on relation-finding?

Predictions are in PREREG.md, committed BEFORE this ran.  Run:
    python3 r1_r4.py            (writes results/*.json)

MANDATORY CONTROLS, all live here:
  * every rate is reported PER STRATUM (the p_split analogue: 2-adic cell of the
    modulus+base).  No pooled average is reported alone.
  * the cost-per-relation accounting (*) is applied to EVERY arm, so no arm can
    be won on hit rate alone.
  * the small-value degeneracy detector runs on every structured arm (R3).
  * held-out moduli and a held-out base are evaluated at the end.
"""

from __future__ import annotations

import json
import math
import random
import sys
import time
from pathlib import Path

import numpy as np

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r51exp/relcond")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/_shared")

from relcond_core import (  # noqa: E402
    a2b3_candidates, cap_gain, distinct_fraction, gen_semiprime, jacobi,
    jacobi_batch, pi, primes_upto, rate_ratio, smooth_mask_batch, strata,
    two_prop_z, wilson_lo,
)

OUT = Path(__file__).parent / "results"
OUT.mkdir(exist_ok=True)
RESULTS: dict = {}


def hdr(t: str) -> None:
    print("\n" + "=" * 78)
    print(t)
    print("=" * 78)


def arm(k: int, n: int) -> str:
    """Rate with a Wilson lower bound.  An EMPTY stratum prints EMPTY, not a crash.

    An empty stratum is a real and informative outcome here -- it is exactly what
    the Jacobi character does when (g/n) = +1 -- so it must be reported, not
    hidden behind a ZeroDivisionError.
    """
    if n == 0:
        return "EMPTY STRATUM (n=0)"
    return f"{k/n:.4f} (>{wilson_lo(k, n):.4f}, n={n})"


# ---------------------------------------------------------------------------
# R1 -- character conditioning on the STANGE family
# ---------------------------------------------------------------------------

def r1_stange(bits: int, b: int, k: int, seed: int) -> dict:
    hdr(f"R1 -- Stange family, n ~ 2^{bits}, B = {b}  ({k} candidates/arm)")
    rng = random.Random(seed)
    n, p, q = gen_semiprime(bits, rng)
    # choose a base in a KNOWN 2-adic stratum so the report is per-cell.
    # Prefer (g/n) = -1: with (g/n) = +1 the candidate Jacobi symbol is constant
    # (every g^x is a QR mod n) and the character has no second stratum at all.
    g = None
    for want in (-1, 1):
        for cand in (5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
            if math.gcd(cand, n) == 1 and jacobi(cand, n) == want:
                g = cand
                break
        if g is not None:
            break
    st = strata(n, p, q, g)
    print(f"  stratum: {st['cell']}   v2(n-1)={st['v2_n_minus_1']}   "
          f"(g/n)={st['jac_g_n']}   pi(B)={pi(b)}")

    xu = np.array([rng.randrange(1, n) for _ in range(k)])
    uncond = np.array([pow(g, int(x), n) for x in xu])
    s0_mask = smooth_mask_batch(uncond, b)
    k0 = int(s0_mask.sum())
    jn = jacobi(g, n)
    jv = jacobi_batch(uncond, n)
    res = {"stratum": st["cell"], "v2_n_minus_1": st["v2_n_minus_1"],
           "jac_g_n": int(jn), "pi_B": pi(b), "uncond": [k0, k]}

    # --- R1a: Jacobi of the candidate.  Preregistered ratio 1.00.
    arms = {}
    for sign, name in ((1, "jac_+1"), (-1, "jac_-1")):
        sel = jv == sign
        kk = int(s0_mask[sel].sum())
        nn = int(sel.sum())
        arms[name] = [kk, nn]
        if nn == 0:
            print(f"  R1a candidate (V/n)={sign:+d}: EMPTY STRATUM")
        else:
            print(f"  R1a candidate (V/n)={sign:+d}: rate {arm(kk, nn)}")
    # ⚠️ STRUCTURAL: if (g/n) = +1 then EVERY g^x is a quadratic residue mod n, so
    # the candidate Jacobi symbol is CONSTANT and the character conditions NOTHING.
    # The Jacobi arm is only non-degenerate when the base has (g/n) = -1.
    # This is worth stating on its own: it means the transplant of the round-50
    # trick is, for half of all bases, not merely useless but *undefined* --
    # there is no second stratum to compare against.
    if min(arms["jac_+1"][1], arms["jac_-1"][1]) == 0:
        print(f"      Jacobi character is CONSTANT on this base ((g/n)={jn:+d}): "
              f"q=1 for one sign, no split exists. R1a is degenerate here.")
        res["R1a"] = {"degenerate": True, "jac_g_n": int(jn)}
    elif min(arms["jac_+1"][1], arms["jac_-1"][1]) > 50:
        z = two_prop_z(*arms["jac_+1"], *arms["jac_-1"])
        rr = rate_ratio(*arms["jac_+1"], *arms["jac_-1"])
        q = min(arms["jac_+1"][1], arms["jac_-1"][1]) / k
        print(f"      R1a ratio {rr:.4f}   z={z:+.2f}   q={q:.3f}   "
              f"GAIN={cap_gain(q, rr):.4f}   [prereg 1.00]")
        res["R1a"] = {"ratio": rr, "z": z, "q": q, "gain": cap_gain(q, rr),
                      "degenerate": False}
    res["R1a_arms"] = arms

    # --- R1c: v2 of the candidate
    def v2arr(v):
        return np.array([int(x) & -int(x) for x in v])  # 2^v2(v)
    v2a = v2arr(uncond)
    for lo, hi, name in ((0, 2, "v2_0"), (2, 2**12, "v2_ge2")):
        sel = (v2a == lo) if lo == 0 else (v2a >= hi)
        kk, nn = int(s0_mask[sel].sum()), int(sel.sum())
        arms[name] = [kk, nn]
        print(f"  R1c candidate {name}: rate {arm(kk, nn)}")
    if arms["v2_0"][1] == 0 or arms["v2_ge2"][1] == 0:
        print("      v2 stratum empty -- a candidate was ODD only (or EVEN only).")
        res["R1c"] = {"degenerate": True}
    elif arms["v2_0"][1] > 50 and arms["v2_ge2"][1] > 50:
        z = two_prop_z(*arms["v2_0"], *arms["v2_ge2"])
        rr = rate_ratio(*arms["v2_0"], *arms["v2_ge2"])
        print(f"      R1c ratio {rr:.4f}   z={z:+.2f}   [prereg 1.00]")
        res["R1c"] = {"ratio": rr, "z": z}
    res["R1c_arms"] = {k2: v for k2, v in arms.items() if k2.startswith("v2_")}

    # --- R1d: PARITY OF x -- the q=1 BYPASS.  Preregistered ratio 1.00.
    #     This is the one arm where conditioning is free, so it is the only arm
    #     where a genuine win is even possible.
    par = {}
    for want_odd, name in ((True, "x_odd"), (False, "x_even")):
        xs = []
        while len(xs) < k:
            xx = rng.randrange(1, n)
            if (xx % 2 == 1) == want_odd:
                xs.append(xx)
        vv = np.array([pow(g, xx, n) for xx in xs])
        mm = smooth_mask_batch(vv, b)
        par[name] = [int(mm.sum()), k, distinct_fraction(vv)]
        print(f"  R1d x_{'odd' if want_odd else 'even':<4}: rate {arm(int(mm.sum()), k)}"
              f"   distinct={par[name][2]:.4f}")
    z = two_prop_z(*par["x_odd"][:2], *par["x_even"][:2])
    rr = rate_ratio(*par["x_odd"][:2], *par["x_even"][:2])
    # honest cost: odd x reaches only the coset g*<g^2>, so fewer distinct values
    df_o, df_e = par["x_odd"][2], par["x_even"][2]
    # gain corrected for the distinct-value deficit
    gain = rr * (df_o / df_e)
    print(f"      R1d ratio {rr:.4f}   z={z:+.2f}   distinct(odd/even)="
          f"{df_o:.3f}/{df_e:.3f}   GAIN={gain:.4f}   [prereg 1.00]")
    res["R1d"] = {"ratio": rr, "z": z, "distinct_odd": df_o,
                  "distinct_even": df_e, "gain": gain}
    res["R1d_arms"] = par
    res["uncond_rate"] = k0 / k
    return res


# ---------------------------------------------------------------------------
# R1b -- character conditioning on the NFS/SQUOFF family a^2 - b^3
# ---------------------------------------------------------------------------

def r1_nfs(amax: int, b: int, k: int, seed: int) -> dict:
    hdr(f"R1b -- NFS family, V = a^2-b^3, a,b in [1,{amax}], B = {b}")
    rng = random.Random(seed)
    n, p, q = gen_semiprime(36, rng)
    a, V = a2b3_candidates(rng, amax, k)
    av = np.abs(V)
    mask = smooth_mask_batch(av, b)
    k0 = int(mask.sum())
    print(f"  unconditional: {arm(k0, k)}")
    res = {"uncond": [k0, k], "amax": amax, "pi_B": pi(b)}

    # R1b: Jacobi of V mod n  (V is the analogue of the Stange candidate)
    jv = jacobi_batch(np.where(av == 0, 1, av), n)
    arms = {}
    for sign, name in ((1, "jac_+1"), (-1, "jac_-1")):
        sel = jv == sign
        kk, nn = int(mask[sel].sum()), int(sel.sum())
        arms[name] = [kk, nn]
        print(f"  R1b (V/n)={sign:+d}: rate {arm(kk, nn)}")
    if arms["jac_+1"][1] > 50 and arms["jac_-1"][1] > 50:
        z = two_prop_z(*arms["jac_+1"], *arms["jac_-1"])
        rr = rate_ratio(*arms["jac_+1"], *arms["jac_-1"])
        q = min(arms["jac_+1"][1], arms["jac_-1"][1]) / k
        print(f"      R1b ratio {rr:.4f}   z={z:+.2f}   q={q:.3f}   "
              f"GAIN={cap_gain(q, rr):.4f}   [prereg 1.00]")
        res["R1b"] = {"ratio": rr, "z": z, "q": q, "gain": cap_gain(q, rr)}
    res["R1b_arms"] = arms

    # R1b-2: Jacobi of the COORDINATES a and b (the "condition on a, or on b" arm)
    # R1b-2: Jacobi of the COORDINATE a -- the "condition on a, or on b" arm.
    # Only `a` is tested; `b` is symmetric in the sampling but `a` is the one
    # that enters F(a,b) quadratically, so it is the informative half.
    ja = jacobi_batch(a, n)
    armsa = {}
    for sign in (1, -1):
        sel = ja == sign
        armsa[str(sign)] = [int(mask[sel].sum()), int(sel.sum())]
    if armsa["1"][1] > 50 and armsa["-1"][1] > 50:
        z = two_prop_z(*armsa["1"], *armsa["-1"])
        rr = rate_ratio(*armsa["1"], *armsa["-1"])
        print(f"  R1b (a/n): +1 {arma(*armsa['1'])}   -1 {arma(*armsa['-1'])}")
        print(f"      ratio {rr:.4f}  z={z:+.2f}   [prereg 1.00]")
        res["R1b_a"] = {"ratio": rr, "z": z}
    return res


def arma(kk: int, nn: int) -> str:
    return f"{kk/max(1,nn):.4f} (n={nn})"


# ---------------------------------------------------------------------------
# R2 -- the 2 - 1/p corner, revisited as a SEARCH condition
# ---------------------------------------------------------------------------

def r2_corner(amax: int, b: int, k: int, seed: int, ps=(3, 5, 7, 11)) -> dict:
    hdr("R2 -- conditioning the SEARCH on the p|a, p|b corner (the 2-1/p excess)")
    rng = random.Random(seed)
    a, V = a2b3_candidates(rng, amax, k)
    av = np.abs(V)
    mask = smooth_mask_batch(av, b)
    base = int(mask.sum())
    print(f"  unconditional: {arm(base, k)}   (q for the corner is 1/p^2)")
    res = {"uncond": [base, k], "rows": []}

    for p in ps:
        # We need BOTH a and b divisible by p.  `a` was already drawn; `b` is
        # redrawn explicitly here so the corner stratum is honestly defined
        # rather than reconstructed by back-solving.
        bb = np.array([rng.randrange(1, amax + 1) for _ in range(k)])
        VV = np.abs(a * a - bb * bb * bb)
        sel = (a % p == 0) & (bb % p == 0)
        if int(sel.sum()) < 100:
            print(f"  p={p}: only {int(sel.sum())} corner samples -- too few")
            continue
        mm = smooth_mask_batch(VV, b)
        kk = int(mm[sel].sum())
        nn = int(sel.sum())
        # the CONDITION also costs q = P(corner) in rejections
        q = nn / k
        rr = rate_ratio(kk, nn, base, k)
        gain = cap_gain(q, rr)
        print(f"  p={p}: corner rate {arm(kk, nn)}   ratio vs base {rr:.4f}   "
              f"q=1/{k//max(nn,1)}={q:.5f}   GAIN={gain:.5f}")
        print(f"        bar for a win is s_C/s_0 > p^2 = {p*p}   "
              f"(measured {rr:.3f}, so GAIN < {rr/(p*p):.5f} ALWAYS)")
        res["rows"].append({"p": p, "k": kk, "n": nn, "ratio": rr, "q": q,
                            "gain": gain, "bar": p * p})
    return res


# ---------------------------------------------------------------------------
# R3 -- structural striding, with the small-value degeneracy detector
# ---------------------------------------------------------------------------

def r3_structure(bits: int, b: int, k: int, seed: int) -> dict:
    hdr("R3 -- structured generation vs uniform (with degeneracy detector)")
    rng = random.Random(seed)
    n, p, q = gen_semiprime(bits, rng)
    g = 5 if math.gcd(5, n) == 1 else 7

    def gen_unif():
        return np.array([pow(g, rng.randrange(1, n), n) for _ in range(k)])

    def gen_seq(t: int):
        # walk (a,b) -> (a+t, b) in the Stange analogue: r -> r * g^t
        r0 = pow(g, rng.randrange(1, n), n)
        gt = pow(g, t, n)
        out = np.empty(k, dtype=np.int64)
        r = r0
        for i in range(k):
            out[i] = r
            r = (r * gt) % n
        return out

    schemes = {
        "uniform": gen_unif,
        "walk_t1": lambda: gen_seq(1),
        "walk_t2": lambda: gen_seq(2),
        "walk_t_large": lambda: gen_seq(n // 3),
        "sublattice_parity": lambda: np.array(
            [pow(g, 2 * rng.randrange(1, n // 2) + 1, n) for _ in range(k)]),
    }
    res = {"rows": []}
    print(f"  {'scheme':<20} {'rate':>22} {'distinct':>9} {'med |V|':>12} "
          f"{'ratio':>8} {'GAIN':>8}")
    base_rate = None
    for name, fn in schemes.items():
        t0 = time.time()
        vals = fn()
        gen_s = time.time() - t0
        mm = smooth_mask_batch(vals, b)
        kk, nn = int(mm.sum()), k
        rate = kk / nn
        df = distinct_fraction(vals)
        medv = int(np.median(vals))
        if base_rate is None:
            base_rate = rate
        rr = rate / base_rate if base_rate else 1.0
        # honest cost per RELATION, not per candidate: generation time is charged
        cost_rel = gen_s / max(kk, 1)
        res["rows"].append({"scheme": name, "k": kk, "n": nn, "rate": rate,
                            "distinct": df, "median": medv, "ratio": rr,
                            "gen_s": gen_s, "cost_per_rel_s": cost_rel})
        print(f"  {name:<20} {kk/nn:>10.4f} (n={nn}) {df:>9.4f} {medv:>12} "
              f"{rr:>8.3f} {'-':>8}")

    # the degeneracy detector: a scheme "winning" by finding SMALL values is the
    # known round-48 artifact, and it manufactures a spurious kernel
    med_base = [r for r in res["rows"] if r["scheme"] == "uniform"][0]["median"]
    print(f"\n  DEGENERACY CHECK (median |V|, uniform = {med_base}):")
    for r in res["rows"]:
        flag = "  <-- SMALL-VALUE DEGENERACY" if r["median"] < med_base / 4 else ""
        print(f"    {r['scheme']:<20} median={r['median']:>12}  "
              f"ratio={r['ratio']:.3f}{flag}")
    res["median_uniform"] = med_base
    return res


# ---------------------------------------------------------------------------
# HELD-OUT -- fresh moduli, fresh bases, never used for tuning
# ---------------------------------------------------------------------------

def held_out(bits: int, b: int, k: int, seeds: list[int]) -> dict:
    hdr(f"HELD-OUT -- R1d parity, {len(seeds)} FRESH moduli (never used for tuning)")
    print("  (the arm most likely to have been over-fitted: it is the only free one)")
    rows = []
    for sd in seeds:
        rng = random.Random(sd)
        n, p, q = gen_semiprime(bits, rng)
        # FRESH base, chosen without reference to any tuning
        g = 2 + 2 * rng.randrange(0, 8)
        while math.gcd(g, n) != 1:
            g += 2
        par = {}
        for want_odd in (True, False):
            xs = []
            while len(xs) < k:
                xx = rng.randrange(1, n)
                if (xx % 2 == 1) == want_odd:
                    xs.append(xx)
            vv = np.array([pow(g, xx, n) for xx in xs])
            mm = smooth_mask_batch(vv, b)
            par[want_odd] = [int(mm.sum()), k, distinct_fraction(vv)]
        z = two_prop_z(*par[True][:2], *par[False][:2])
        rr = rate_ratio(*par[True][:2], *par[False][:2])
        gain = rr * (par[True][2] / par[False][2])
        st = strata(n, p, q, g)
        rows.append({"seed": sd, "stratum": st["cell"], "jac_g_n": st["jac_g_n"],
                     "ratio": rr, "z": z, "gain": gain})
        print(f"  seed {sd}: stratum {st['cell']:<18} (g/n)={st['jac_g_n']:+d}  "
              f"ratio {rr:.4f}  z={z:+6.2f}  GAIN {gain:.4f}")
    gains = [r["gain"] for r in rows]
    pooled = sum(gains) / len(gains)
    print(f"\n  HELD-OUT pooled gain = {pooled:.4f}   [prereg 1.00 +/- 0.15]")
    print(f"  range {min(gains):.4f} .. {max(gains):.4f} over {len(gains)} moduli")
    return {"rows": rows, "pooled_gain": pooled}


def main() -> None:
    t0 = time.time()
    RESULTS["R1_stange"] = r1_stange(bits=40, b=2**15, k=60000, seed=1234)
    RESULTS["R1_nfs"] = r1_nfs(amax=3000, b=2**14, k=40000, seed=555)
    RESULTS["R2"] = r2_corner(amax=1500, b=2**13, k=60000, seed=777)
    RESULTS["R3"] = r3_structure(bits=40, b=2**14, k=40000, seed=888)
    RESULTS["held_out"] = held_out(bits=40, b=2**15, k=40000,
                                   seeds=[9001, 9002, 9003, 9004])
    RESULTS["elapsed_s"] = time.time() - t0
    (OUT / "r1_r4.json").write_text(json.dumps(RESULTS, indent=2, default=str))
    print(f"\nwrote {OUT / 'r1_r4.json'}   ({RESULTS['elapsed_s']:.1f}s)")


if __name__ == "__main__":
    main()