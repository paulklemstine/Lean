"""
The 2-adic control, at the PHASE level, reported per modulus.

Separate from exp_D3 because the faithful 'random' sampler makes relation
finding expensive and the full Q1 sweep plus Q2 in one process is slow.

The cell under test: does the linear-algebra/gcd phase produce a NONZERO
multiple G of ord(g)?  That is the step the phase is responsible for, and it
is the step whose 2-adic rate the NFS comparison would depend on.

Every rate is reported against its OWN modulus's exact p_split(p,q).
"""
from __future__ import annotations

import json
import math
import random
import statistics
import sys

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r51/exp/droptest")
import dtcore as D  # noqa: E402

OUT = "/home/raver1975/lean/factor-scratch/r51/exp/droptest/D3_2adic.json"


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
    print("=" * 104)
    print("THE 2-ADIC CONTROL, PER MODULUS -- never against the 20/27 average")
    print("=" * 104)
    print()
    hdr = (f"{'bits':>4} {'b':>4} {'N':>4} {'nonzero G':>10} {'rate':>7} "
           f"{'95% CI':>16} {'mean p_split':>13} {'EXCESS':>8} "
           f"{'p_split min':>12} {'p_split max':>12}")
    print(hdr)
    print("-" * 104)
    rows = []
    N = 20
    for bits, b in ((30, 32), (30, 52)):
        nz = 0
        trials = 0
        ps_sum = 0.0
        psl = []
        for s in range(N):
            rng = random.Random(88000 + s)
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
                K, _r = D.stange.kernel_basis(M)
                xs = [rels[j][1] for j in range(len(rels))]
                G = 0
                for v in K:
                    pv = D.stange.primitive([D.to_frac(z) for z in v])
                    G = math.gcd(G, abs(sum(pv[j] * xs[j] for j in range(len(rels)))))
                ok = (G != 0)
            except Exception:
                ok = False
            nz += ok
            trials += 1
        if not trials:
            continue
        rate = nz / trials
        mps = ps_sum / trials
        lo, hi = wilson(nz, trials)
        print(f"{bits:>4} {b:>4} {trials:>4} {nz:>10} {rate:>7.4f} "
              f"[{lo:.3f},{hi:.3f}] {mps:>13.4f} {rate-mps:>+8.4f} "
              f"{min(psl):>12.3f} {max(psl):>12.3f}")
        rows.append({"bits": bits, "b": b, "N": trials, "nonzero_G": nz,
                     "rate": rate, "mean_p_split": mps,
                     "excess": rate - mps, "ci": [lo, hi],
                     "p_split_min": min(psl), "p_split_max": max(psl)})
        print(f"     p_split spread [{min(psl):.3f}, {max(psl):.3f}] -- a raw rate")
        print(f"     compared to 20/27 = 0.7407 would inherit this spread as a")
        print(f"     spurious 'effect' of up to {max(psl)-20/27:+.3f}.")
    with open(OUT, "w") as f:
        json.dump(rows, f, indent=1)
    print(f"\nwrote {OUT}")


if __name__ == "__main__":
    main()