"""
The ONE cell the other two runs could not finish: n ~ 2^30, b = 52.

Isolated so it gets its own budget. Relation finding at b=52 with the faithful
'random' sampler needs ~1e4 trials per relation and there are 53 relations, so
~5e5 modular exponentiations per modulus -- tens of seconds each. That is why
exp_2adic.py and exp_D3.py both timed out here: they ran this cell after
another, not instead of it.

Per-modulus p_split throughout. Never the 20/27 average.
"""
from __future__ import annotations

import json
import math
import random
import sys
import time

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r51/exp/droptest")
import dtcore as D  # noqa: E402

OUT = "/home/raver1975/lean/factor-scratch/r51/exp/droptest/D3_2adic_b52.json"


def wilson(k, n):
    if n == 0:
        return (float("nan"), float("nan"))
    z = 1.959963984540054
    ph = k / n
    d = 1 + z * z / n
    c = (ph + z * z / (2 * n)) / d
    h = z * math.sqrt(ph * (1 - ph) / n + z * z / (4 * n * n)) / d
    return (max(0.0, c - h), min(1.0, c + h))


def main():
    b = 52
    bits = 30
    N = 12
    print(f"THE MISSING CELL: n ~ 2^{bits}, b = {b}, N = {N} moduli")
    print(f"per-modulus p_split; never vs 20/27 = {20/27:.4f}")
    print()
    nz = 0
    ps_sum = 0.0
    psl = []
    per = []
    for s in range(N):
        t0 = time.perf_counter()
        rng = random.Random(99000 + s)
        n, p, q = D.stange.gen_semiprime(bits, rng)
        ps, mp_, mq_ = D.p_split(p, q)
        ps_sum += ps
        psl.append(ps)
        g = D.rand_g(n, rng)
        FB = D.stange.factor_base(D.stange.bbound_for_b(b), n)
        ok = False
        try:
            rels, _ = D.stange.find_relations(n, g, FB, b + 1, rng, "random")
            M = D.build_M(rels, b)
            # ⚠️ Backend choice is what made this cell runnable at all.
            # stange.kernel_basis calls sympy Matrix.nullspace(), which takes
            # >200 s at b=52 on this host -- that single call is why BOTH
            # exp_2adic.py and exp_D3.py timed out on this cell (relation
            # finding is only ~3000 trials, i.e. under a second).
            # kernel_dense_DM is the same exact QQ computation via sympy's
            # DomainMatrix.rref and takes ~10 ms -- a >10^4 x difference.
            # It is 4-15x faster than every hand-written route I wrote (§2.1),
            # which is itself the note's main actionable finding.
            K = D.kernel_dense_DM(M, "b52")["basis"]
            xs = [rels[j][1] for j in range(len(rels))]
            G = 0
            for v in K:
                pv = D.stange.primitive([D.to_frac(z) for z in v])
                G = math.gcd(G, abs(sum(pv[j] * xs[j] for j in range(len(rels)))))
            ok = (G != 0)
        except Exception:
            ok = False
        nz += ok
        per.append({"p": p, "q": q, "p_split": ps, "nonzero_G": ok,
                    "v2_p_1": mp_, "v2_q_1": mq_})
        print(f"  mod {s:>2}: p={p} q={q}  p_split={ps:.4f}  "
              f"nonzero G={ok}  ({time.perf_counter()-t0:.1f}s)")
    rate = nz / N
    mps = ps_sum / N
    lo, hi = wilson(nz, N)
    print()
    print(f"  nonzero G: {nz}/{N} = {rate:.4f}   95% CI [{lo:.4f}, {hi:.4f}]")
    print(f"  mean p_split over these moduli: {mps:.4f}")
    print(f"  EXCESS vs mean p_split: {rate - mps:+.4f}")
    print(f"  p_split range: [{min(psl):.4f}, {max(psl):.4f}]  "
          f"(spread {max(psl)-min(psl):.4f})")
    print(f"  a raw rate vs 20/27 = {20/27:.4f} would read "
          f"{rate - 20/27:+.4f} instead")
    with open(OUT, "w") as f:
        json.dump({"bits": bits, "b": b, "N": N, "nonzero_G": nz,
                   "rate": rate, "mean_p_split": mps,
                   "excess_vs_mean": rate - mps,
                   "excess_vs_20_27": rate - 20 / 27,
                   "p_split_min": min(psl), "p_split_max": max(psl),
                   "per_modulus": per}, f, indent=1)
    print(f"\nwrote {OUT}")


if __name__ == "__main__":
    main()
