"""
G3b -- END-TO-END: DOES THE JACOBI BASE ACTUALLY FACTOR MORE OFTEN?

The order-step rate going 20/27 -> 8/9 is necessary but not sufficient: Stange's success also
depends on the Q-kernel step (the h>1 tail documented in K_stange.md).  So the rate of the
ORDER step and the rate of the WHOLE algorithm are different numbers, and only the second one
is an improvement to a working factoring method.

This runs the real `stange.alg22` end-to-end (imported read-only from
factor-scratch/r48/exp/stange/stange.py) on fresh semiprimes, once with a uniform base and
once with a Jacobi(g/n) = -1 base, and counts GENUINE non-trivial factors.

Reported per modulus and pooled, with the per-modulus 2-adic cell shown for each.
"""

from __future__ import annotations

import json
import math
import random
import sys
from pathlib import Path

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp/stange")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r50exp/baseg")

import stange  # noqa: E402
from measure import jacobi, s_of  # noqa: E402


def pick_g(n: int, p: int, q: int, rng: random.Random, mode: str) -> int:
    """The base.  'uniform' is what the whole programme has always used."""
    for _ in range(500):
        g = rng.randrange(2, n)
        if math.gcd(g, n) != 1:
            continue
        if mode == "uniform":
            return g
        if mode == "jac_neg" and jacobi(g, n) == -1:
            return g
    raise RuntimeError("could not find a base")


def run(n_mod: int, bbound: int, c: int, bits: int, seed: int) -> dict:
    rng = random.Random(seed)
    out = []
    for i in range(n_mod):
        # stange.gen_semiprime returns (n, p, q) -- NOT (p, q, n).  Unpacking it the other
        # way round silently produced 13-bit moduli (p*q where p was really n) and made the
        # whole end-to-end run read 0/40.  Asserted below so it cannot recur.
        n, p, q = stange.gen_semiprime(bits, rng)
        assert p * q == n, (p, q, n)
        # nextprime() can carry across a power of two, so n may land one bit under.  Assert
        # the real invariant (p*q == n, both factors the right size) rather than an exact
        # bit-length that the generator legitimately fails.
        assert abs(n.bit_length() - bits) <= 1, (n.bit_length(), bits)
        # b is the FACTOR-BASE BOUND (a smoothness cutoff), not the number of FB elements;
        # stange.factor_base(bound, n) returns the primes <= bound.
        FB = stange.factor_base(bbound, n)
        rec = {"p": p, "q": q, "a": s_of(p), "b_": s_of(q)}
        for mode in ("uniform", "jac_neg"):
            g = pick_g(n, p, q, rng, mode)
            try:
                r = stange.alg22(n, g, FB, c, rng)
                fac = r["factor"]
            except Exception as e:  # a crash is a FAILURE, not a dropped sample
                fac, r = None, {"G": 0, "note": repr(e)}
            rec[mode] = 1 if (fac and 1 < fac < n) else 0
            rec[mode + "_G"] = int(r.get("G", 0))
            rec[mode + "_g"] = g
            rec[mode + "_jac"] = jacobi(g, n)
        out.append(rec)
        if (i + 1) % 5 == 0:
            print(f"      ... {i+1}/{n_mod}", flush=True)
    return {"rows": out, "n_mod": n_mod, "bbound": bbound, "c": c, "bits": bits, "seed": seed}


def report(d: dict) -> None:
    rows = d["rows"]
    N = len(rows)
    print()
    print("=" * 78)
    print(f"END-TO-END Stange Algorithm 2.2 -- {N} fresh semiprimes of {d['bits']} bits, "
          f"BB={d['bbound']} c={d['c']}")
    print("=" * 78)
    hu = sum(r["uniform"] for r in rows)
    hj = sum(r["jac_neg"] for r in rows)
    for name, h in (("uniform base (baseline)", hu), ("Jacobi(g/n)=-1 base", hj)):
        lo = h / N
        se = math.sqrt(lo * (1 - lo) / N)
        print(f"  {name:>24}: {h}/{N} = {lo:.4f}  (+/- {1.96*se:.4f})")
    # paired test: same modulus, two different bases
    diff = [r["jac_neg"] - r["uniform"] for r in rows]
    md = sum(diff) / N
    sd = math.sqrt(sum((x - md) ** 2 for x in diff) / (N - 1))
    print()
    print(f"  PAIRED difference (same modulus, both bases): {md:+.4f}")
    print(f"    discordant pairs: jac-only {sum(1 for x in diff if x>0)}, "
          f"uniform-only {sum(1 for x in diff if x<0)}")
    if sd > 0:
        print(f"    paired t = {md/(sd/math.sqrt(N)):+.2f} on {N-1} df")
    print()
    print("  NOTE: this is the WHOLE algorithm, whose ceiling is bounded by BOTH the")
    print("  order step and the Q-kernel step.  The order step went 0.7407 -> 0.8889;")
    print("  the end-to-end gain is necessarily the SMALLER of the two.")
    print()

    print("  per-modulus 2-adic cell (the mandatory control):")
    print(f"    {'a,b':>7} {'N':>4} {'uniform rate':>14} {'jac rate':>10}")
    buck: dict = {}
    for r in rows:
        buck.setdefault((r["a"], r["b_"]), []).append(r)
    for k in sorted(buck):
        rs = buck[k]
        print(f"    {f'{k[0]},{k[1]}':>7} {len(rs):>4} "
              f"{sum(x['uniform'] for x in rs)/len(rs):>14.4f} "
              f"{sum(x['jac_neg'] for x in rs)/len(rs):>10.4f}")
    print()
    diag = [r for r in rows if r["a"] == r["b_"]]
    if diag:
        print(f"  on the {len(diag)} DIAGONAL moduli (a==b, where the lever is worth the most):")
        print(f"    uniform {sum(r['uniform'] for r in diag)}/{len(diag)}, "
              f"jac {sum(r['jac_neg'] for r in diag)}/{len(diag)}")
    print()
    print("  SANITY: the chosen bases really do carry Jacobi = -1")
    print(f"    jac_neg rows with Jacobi(g/n) == -1: "
          f"{sum(1 for r in rows if r['jac_neg_jac']==-1)}/{N}")


if __name__ == "__main__":
    nm = int(sys.argv[1]) if len(sys.argv) > 1 else 40
    bb = int(sys.argv[2]) if len(sys.argv) > 2 else 10
    cc = int(sys.argv[3]) if len(sys.argv) > 3 else 10
    bits = int(sys.argv[4]) if len(sys.argv) > 4 else 26
    seed = int(sys.argv[5]) if len(sys.argv) > 5 else 777
    data = run(nm, bb, cc, bits, seed)
    with open("e2e_out.json", "w") as f:
        json.dump(data, f)
    report(data)