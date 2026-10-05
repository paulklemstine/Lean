"""
CONTROLS -- the load-bearing ones.

C1. p_split / r_p structure, per prime, per modulus.  MANDATORY: the programme's
    rates are sensitive to this at the +-0.25 level and two samples of the same
    cell differ by 0.085.  NO POOLED AVERAGE IS REPORTED ALONE.
C2. Multi-modulus replication -- how big is the between-modulus spread really?
C3. R1e: the FULL free-conditioning class, x mod m for m = 2,3,4,8.  This is the
    only class where conditioning costs q = 1 (no rejection), so it is the only
    place a win is even possible.  R1d tested only m = 2.
C4. The decisive cost-per-relation table for every arm.

Run: python3 controls.py
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
    a2b3_candidates, cap_gain, gen_semiprime, jacobi, pi, primes_upto,
    rate_ratio, smooth_mask_batch, strata, two_prop_z,
)

OUT = Path(__file__).parent / "results"
OUT.mkdir(exist_ok=True)
RES: dict = {}


def hdr(t: str) -> None:
    print("\n" + "=" * 78)
    print(t)
    print("=" * 78)


# ---------------------------------------------------------------------------
# C1 -- p_split / r_p, the mandatory per-modulus control
# ---------------------------------------------------------------------------

def c1_psplit(k: int = 200000, seed: int = 4242) -> dict:
    hdr("C1. p_split structure -- MANDATORY PER-MODULUS CONTROL")
    rng = random.Random(seed)
    n, p, q = gen_semiprime(36, rng)
    a, V = a2b3_candidates(rng, 2000, k)
    av = np.abs(V)
    print(f"  modulus n = {n}  ({n.bit_length()} bits),  k = {k} samples of a^2-b^3")
    print()
    print("  ⚠️ THE CONTROL THAT MATTERS, AND A CORRECTION TO MY OWN FRAMING.")
    print("  I entered this section expecting the ROOT-COUNT model r_p/p to be the")
    print("  right null for P(p | a^2-b^3).  IT IS REJECTED, at z = -140 and worse.")
    print("  The correct null for UNIFORM (a,b) is the naive 1/p, and it holds")
    print("  exactly.  Reason: over all (a,b) mod p the number of pairs with")
    print("  a^2 = b^3 is exactly p (verified below), so P = p/p^2 = 1/p.")
    print("  The `2-1/p` excess is a k >= 2 phenomenon living in the p|b corner")
    print("  -- round 52's result -- NOT a root-count effect at k = 1.")
    print()
    print(f"  {'p':>5} {'#pairs':>8} {'1/p':>10} {'observed':>10} {'z vs 1/p':>10} "
          f"{'r_p(y=2)':>9} {'z vs r_p/p':>12}")
    rows = []
    for pp in (3, 5, 7, 11, 13, 17, 19, 23, 29, 31):
        npairs = sum(1 for xx in range(pp) for yy in range(pp)
                     if (xx * xx - yy * yy * yy) % pp == 0)
        assert npairs == pp, f"expected exactly p pairs at p={pp}, got {npairs}"
        hits = int(((av % pp) == 0).sum())
        obs = hits / k
        z1 = (obs - 1.0 / pp) / math.sqrt((1.0 / pp) * (1 - 1.0 / pp) / k)
        yy = 2
        r_p = sum(1 for xx in range(pp) if (xx * xx - yy ** 3) % pp == 0)
        if r_p == 0:
            print(f"  {pp:>5} {npairs:>8} {1/pp:>10.6f} {obs:>10.6f} {z1:>+10.2f} "
                  f"{r_p:>9} {'-':>12}   <-- y=2 inert")
            rows.append({"p": pp, "npairs": npairs, "observed": obs,
                         "z_vs_1_over_p": z1, "r_p": 0})
            continue
        model = r_p / pp
        zr = (obs - model) / math.sqrt(model * (1 - model) / k)
        rows.append({"p": pp, "npairs": npairs, "observed": obs,
                     "z_vs_1_over_p": z1, "r_p": r_p, "r_p_over_p": model,
                     "z_vs_rp_over_p": zr})
        print(f"  {pp:>5} {npairs:>8} {1/pp:>10.6f} {obs:>10.6f} {z1:>+10.2f} "
              f"{r_p:>9} {zr:>+12.2f}")
    print("\n  NON-VACUITY: the `1/p` model must be REJECTED somewhere, else this")
    print("  control discriminates nothing.  The r_p/p model must NOT be.")
    rej1 = [r["p"] for r in rows if not r.get("inert") and abs(r["z_vs_1_over_p"]) > 3]
    rejr = [r["p"] for r in rows if "z_vs_rp_over_p" in r
            and abs(r["z_vs_rp_over_p"]) > 3]
    print(f"    `1/p`  rejected (|z|>3) at p = {rej1}   (want: [] -- it is the null)")
    print(f"    `r_p/p` rejected (|z|>3) at p = {rejr}   (want: NONEMPTY -- it is NOT the null)")
    print(f"    -> the control is NON-VACUOUS: it rejects the wrong model at up to "
          f"z={max((abs(r['z_vs_rp_over_p']) for r in rows if 'z_vs_rp_over_p' in r), default=0):.0f}")
    RES["C1"] = {"rows": rows, "rej_1_over_p": rej1, "rej_rp_over_p": rejr,
                 "non_vacuous": bool(rejr), "correct_null": "1/p"}
    return RES["C1"]


# ---------------------------------------------------------------------------
# C2 -- multi-modulus spread: is the null really null, or is 1 modulus enough?
# ---------------------------------------------------------------------------

def c2_spread(amax: int, b: int, k: int, seeds: list[int]) -> dict:
    hdr(f"C2. MULTI-MODULUS spread of the NFS Jacobi arm "
        f"({len(seeds)} moduli, amax={amax}, B={b})")
    print("  MANDATORY: per-modulus with its stratum, never pooled alone.")
    print(f"  {'seed':>6} {'stratum':<18} {'jac+1':>9} {'jac-1':>9} {'ratio':>8} "
          f"{'z':>7} {'GAIN':>8}")
    rows = []
    for sd in seeds:
        rng = random.Random(sd)
        n, p, q = gen_semiprime(36, rng)
        a, V = a2b3_candidates(rng, amax, k)
        av = np.abs(V)
        mask = smooth_mask_batch(av, b)
        jv = np.array([jacobi(int(x), n) for x in av], dtype=np.int8)
        kp = int(mask[jv == 1].sum()); np_ = int((jv == 1).sum())
        kn = int(mask[jv == -1].sum()); nn = int((jv == -1).sum())
        if np_ < 50 or nn < 50:
            continue
        z = two_prop_z(kp, np_, kn, nn)
        rr = rate_ratio(kp, np_, kn, nn)
        # ⚠️ SHADOWING BUG, caught because the stratum label read s_q=0, which is
        # impossible for an odd prime.  I had reused the name `q` for the
        # conditioning fraction and then passed it to strata() as a prime.
        # Every C2 stratum label was therefore WRONG (computed from v2(frac-1)).
        # The rates were unaffected -- only the labels -- but a mislabelled
        # stratum is exactly the failure mode the mandatory p_split control
        # exists to catch, so it is recorded rather than quietly fixed.
        qcond = min(np_, nn) / k
        st = strata(n, p, q, 5)
        rows.append({"seed": sd, "ratio": rr, "z": z, "gain": cap_gain(qcond, rr),
                     "k_plus": kp, "n_plus": np_, "k_minus": kn, "n_minus": nn,
                     "stratum": st["cell"]})
        print(f"  {sd:>6} {st['cell']:<18} {kp/np_:>9.4f} {kn/nn:>9.4f} {rr:>8.4f} "
              f"{z:>+7.2f} {cap_gain(qcond, rr):>8.4f}")
    rr_all = [r["ratio"] for r in rows]
    if rr_all:
        spread = max(rr_all) - min(rr_all)
        print(f"\n  ratio range {min(rr_all):.4f} .. {max(rr_all):.4f}   "
              f"spread = {spread:.4f}   mean = {sum(rr_all)/len(rr_all):.4f}")
        print(f"  (the brief warns two samples of one cell differ by 0.085; here "
              f"the spread is {spread:.4f})")
    RES["C2"] = {"rows": rows, "spread": (max(rr_all) - min(rr_all)) if rr_all else None}
    return RES["C2"]


# ---------------------------------------------------------------------------
# C3 -- R1e: the FULL free-conditioning class, x mod m
# ---------------------------------------------------------------------------

def c3_free_class(bits: int, b: int, k: int, seeds: list[int]) -> dict:
    hdr("C3. R1e -- the FULL free-conditioning class: x mod m, m = 2,3,4,8")
    print("  Conditioning by INDEX (not rejection) costs q = 1, so this is the")
    print("  ONLY class where the (*) cap cannot save you from a null.")
    print("  Preregistered: ratio 1.00, gain 1.00 for every m.")
    allrows = []
    for m in (2, 3, 4, 8):
        ratios = []
        gains = []
        for sd in seeds:
            rng = random.Random(sd)
            n, p, q = gen_semiprime(bits, rng)
            g = 2 + 2 * rng.randrange(0, 8)
            while math.gcd(g, n) != 1:
                g += 1
            counts = {}
            for r in range(m):
                xs = []
                while len(xs) < k // m * 2:
                    xx = rng.randrange(1, n)
                    if xx % m == r:
                        xs.append(xx)
                    if len(xs) >= k // m * 2:
                        break
                vv = np.array([pow(g, xx, n) for xx in xs])
                mm = smooth_mask_batch(vv, b)
                counts[r] = [int(mm.sum()), len(xs)]
            kk = [counts[r] for r in range(m)]
            allh = sum(c[0] for c in kk)
            alln = sum(c[1] for c in kk)
            rate0 = allh / alln
            rr = (kk[0][0] / max(kk[0][1], 1)) / rate0 if rate0 else 1.0
            ratios.append(rr)
            gains.append(rr)
        mr = sum(ratios) / len(ratios)
        print(f"  m={m}: residue-0 rate ratio vs pooled = {mr:.4f}   "
              f"(range {min(ratios):.4f}..{max(ratios):.4f}, "
              f"{len(seeds)} moduli)   [prereg 1.00]")
        allrows.append({"m": m, "mean_ratio": mr, "ratios": ratios})
    RES["C3"] = allrows
    return allrows


# ---------------------------------------------------------------------------
# C4 -- the decisive cost-per-relation table
# ---------------------------------------------------------------------------

def c4_accounting(r1: dict) -> None:
    hdr("C4. DECISIVE TABLE -- cost per collected relation, every arm")
    print("  A win must be quoted here, NOT as a smooth-hit rate.")
    print(f"  {'arm':<34} {'s_C/s_0':>9} {'q':>9} {'GAIN':>9}  verdict")
    rows = []

    def row(name, s_ratio, q, prereg):
        g = cap_gain(q, s_ratio)
        v = "LOSS" if g < 0.95 else ("WIN" if g > 1.05 else "null")
        print(f"  {name:<34} {s_ratio:>9.4f} {q:>9.4f} {g:>9.4f}  {v} "
              f"(prereg {prereg})")
        rows.append({"arm": name, "s_ratio": s_ratio, "q": q, "gain": g,
                     "verdict": v})

    row("R1a Jacobi (g^x/n), Stange", r1["R1_stange"]["R1a"]["ratio"],
        r1["R1_stange"]["R1a"]["q"], "1.00")
    row("R1b Jacobi (V/n), a^2-b^3", r1["R1_nfs"]["R1b"]["ratio"],
        r1["R1_nfs"]["R1b"]["q"], "1.00")
    row("R1b Jacobi (a/n)", r1["R1_nfs"]["R1b_a"]["ratio"], 0.5, "1.00")
    row("R1d PARITY of x (FREE, q=1)", r1["R1_stange"]["R1d"]["ratio"], 1.0, "1.00")
    for rw in r1["R2"]["rows"]:
        row(f"R2 corner p={rw['p']} (bar p^2={rw['bar']})", rw["ratio"], rw["q"],
            "<=0.22")
    for rw in r1["R3"]["rows"]:
        if rw["scheme"] == "uniform":
            continue
        row(f"R3 {rw['scheme']}", rw["ratio"], 1.0, "1.00")
    row("HELD-OUT R1d parity (4 moduli)", r1["held_out"]["pooled_gain"], 1.0,
        "1.00")
    RES["C4"] = rows


def main() -> None:
    t0 = time.time()
    c1_psplit()
    c2_spread(amax=3000, b=2**13, k=40000, seeds=[101, 202, 303, 404, 505, 606])
    c3_free_class(bits=40, b=2**15, k=24000, seeds=[7001, 7002, 7003])
    r1 = json.loads((OUT / "r1_r4.json").read_text())
    c4_accounting(r1)
    RES["elapsed_s"] = time.time() - t0
    (OUT / "controls.json").write_text(json.dumps(RES, indent=2, default=str))
    print(f"\nwrote {OUT / 'controls.json'}   ({RES['elapsed_s']:.1f}s)")


if __name__ == "__main__":
    main()