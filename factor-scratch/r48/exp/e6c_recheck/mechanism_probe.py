#!/usr/bin/env python3
"""
MECHANISM PROBE -- why would class numbers be smoother, or rougher, than uniform?

    python3 mechanism_probe.py     # writes mechanism_probe.json

This is a SUPPLEMENT to H1/H2/H3, run AFTER the preregistered experiment and
clearly labelled as such.  It is not part of the preregistered test and does
not change any verdict in e6c_recheck.py.

The question: the preregistered H1 predicts class numbers sit ABOVE the
Dickman rate.  There is a sharp theoretical prediction for the SIGN of the
deviation, from Cohen-Lenstra, and it says ABOVE is not the expected
direction.

Cohen-Lenstra (for odd l, on the class group away from 2) gives

    P( the l-part of Cl is trivial ) -> 1 - 1/(l+1) ... summed properly:
    P( l | h ) = sum over non-trivial l-parts of the CL weight.

The dominant non-trivial l-part is C_l = Z/l, whose CL weight is
1/(|Aut(C_l)| * l) = 1/((l-1)*l).  Summing the geometric series in the
exponent gives

    P(l | h)  ~  1/( (l-1) * l )  /  Z(l),   Z(l) = 1 + sum_{k>=1} 1/((l-1) l^{2k-1})

For l=3 this is about 0.1667/1.2 = 0.139, versus 1/3 = 0.333 for a uniform
integer.  So Cohen-Lenstra predicts class numbers are divisible by SMALL
ODD PRIMES **LESS** often than uniform integers, i.e. their odd parts are
shifted AWAY from small primes and toward large ones -- the exact opposite of
"more smooth".

Combined with genus theory (h(-q) is ODD for q = 3 mod 4 prime, so it never
carries a factor 2 either), the theoretical expectation is that class numbers
are ROUGHER than uniform, not smoother.

This script measures P(l | h) directly for small l, against
  (a) the uniform prediction 1/l,
  (b) the Cohen-Lenstra prediction,
so the direction of the deviation is established from data rather than
assumed.
"""

from __future__ import annotations

import json
import math
import os
import random
import sys

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/_shared")

import cypari2  # noqa: E402
from sympy import factorint, isprime, nextprime  # noqa: E402

_HERE = os.path.dirname(os.path.abspath(__file__))


def cl_prob(l: int) -> float:
    """Cohen-Lenstra prediction for P(l | h) for ODD l.

    Weight of an l-part G is 1/(|Aut G| * l^{v_l(|G|)}).  The l-parts in
    question are products of C_{l^k}.  We sum over
      k = 1..K (one factor of order l^k) and over rank-2 groups, which enter
    at order l^{2k} with weight 1/(|GL_2(F_l)| * l^{2k}).
    For the sizes that matter (l^{2k} << h) the rank-1 terms dominate and the
    tail is negligible, but both are included so the number is not an
    approximation dressed up as a formula.
    """
    if l == 2:
        return float("nan")   # the 2-part here is trivial by genus theory
    K = 6
    z = 1.0
    for k in range(1, K + 1):
        z += 1.0 / ((l - 1) * l ** (2 * k - 1))
    gl2 = (l ** 2 - 1) * (l ** 2 - l)
    for k in range(1, K):
        z += 1.0 / (gl2 * l ** (2 * k))
    num = sum(1.0 / ((l - 1) * l ** (2 * k - 1)) for k in range(1, K + 1))
    num += sum(1.0 / (gl2 * l ** (2 * k)) for k in range(1, K))
    return num / z


def main() -> int:
    import scipy.stats as st

    pari = cypari2.Pari()
    pari("default(parisize, 256*1024*1024)")

    rng = random.Random(20261003)
    Q_BITS = [41, 51, 61, 66]
    N_PER = 1200

    # Also generate matched uniform controls at the same h bit-lengths, so the
    # comparison is against the SAME sizes, not an average over them.
    hs, hb = [], []
    for qb in Q_BITS:
        for _ in range(N_PER):
            lo, hi = 2 ** (qb - 1), 2 ** qb
            q = int(nextprime(rng.randrange(lo, hi)))
            while q % 4 != 3:
                q = int(nextprime(q + 1))
            if q.bit_length() != qb:
                continue
            h = int(pari.qfbclassno(-q))
            hs.append(h)
            hb.append(h.bit_length())
    print(f"n = {len(hs)} class numbers, h_bits "
          f"{min(hb)}..{max(hb)}, mean {sum(hb)/len(hb):.1f}", flush=True)

    rnd = random.Random(777)
    ctrl = [rnd.randrange(2 ** (b - 1), 2 ** b) for b in hb]
    ctrl_odd = [v | 1 for v in ctrl]

    PRIMES = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]

    out = {"description": ("direct measurement of P(l | h) for small odd l, "
                           "vs uniform 1/l and vs the Cohen-Lenstra "
                           "prediction; supplementary to the preregistered "
                           "H1/H2/H3, run after them"),
           "n_class": len(hs), "q_bits": Q_BITS, "seed": 20261003,
           "h_bits_mean": sum(hb) / len(hb),
           "all_odd": all(h % 2 == 1 for h in hs),
           "p_divisibility": {}}

    print(f"\n{'l':>4} {'P(l|h)':>9} {'1/l':>8} {'CL pred':>9} "
          f"{'ratio/unif':>12} {'z vs unif':>10} {'vs CL':>8}")
    for l in PRIMES:
        kh = sum(1 for h in hs if h % l == 0)
        ph = kh / len(hs)
        unif = 1.0 / l
        clp = cl_prob(l)
        # binomial z against the uniform 1/l
        se = math.sqrt(unif * (1 - unif) / len(hs))
        z = (ph - unif) / se if se > 0 else float("nan")
        # binomial test of the CL prediction
        pv_cl = st.binomtest(kh, len(hs), clp).pvalue
        out["p_divisibility"][str(l)] = {
            "n": len(hs), "hits": kh, "P_measured": ph,
            "uniform_1_over_l": unif, "cohen_lenstra": clp,
            "cl_alt_normalisation_1_over_l_plus_1": 1.0 / (l + 1),
            "ratio_measured_over_uniform": ph / unif if unif else None,
            "z_vs_uniform": z,
            "binom_p_value_vs_cl": float(pv_cl),
            "matches_cl": bool(pv_cl > 0.01),
            "matches_uniform": bool(abs(z) < 3),
        }
        print(f"{l:>4} {ph:>9.4f} {unif:>8.4f} {clp:>9.4f} "
              f"{ph/unif:>12.3f} {z:>10.2f} "
              f"{'MATCH' if pv_cl > 0.01 else 'reject':>8}")

    # ---- the aggregate that actually drives smoothness: largest prime factor
    out["lpf"] = {}
    for name, vals in (("class", hs), ("uniform", ctrl), ("uniform_odd", ctrl_odd)):
        lpfs = []
        for v in vals:
            lpfs.append(max(factorint(v)))
        lpfs.sort()
        n = len(lpfs)
        out["lpf"][name] = {
            "n": n,
            "lpf_max": lpfs[-1],
            "lpf_p50": lpfs[n // 2],
            "lpf_p90": lpfs[int(0.90 * n)],
            "lpf_p99": lpfs[int(0.99 * n)],
            "lpf_geomean": math.exp(sum(math.log(x) for x in lpfs) / n),
            "lpf_hist_decades": {
                str(10 ** d): sum(1 for x in lpfs if 10 ** d <= x < 10 ** (d + 1))
                for d in range(1, 25)},
        }
        print(f"\n{name:>13}: lpf geomean {out['lpf'][name]['lpf_geomean']:.1f}"
              f"  p50 {out['lpf'][name]['lpf_p50']}"
              f"  p90 {out['lpf'][name]['lpf_p90']}"
              f"  max {out['lpf'][name]['lpf_max']}")

    # ---- distribution of the NUMBER of distinct prime factors
    out["omega"] = {}
    for name, vals in (("class", hs), ("uniform", ctrl), ("uniform_odd", ctrl_odd)):
        ws = [len(factorint(v)) for v in vals]
        out["omega"][name] = {"mean": sum(ws) / len(ws),
                              "hist": {str(k): ws.count(k)
                                       for k in range(1, 12)}}
        print(f"{name:>13}: omega (distinct primes) mean "
              f"{out['omega'][name]['mean']:.3f}")

    path = os.path.join(_HERE, "mechanism_probe.json")
    with open(path, "w") as fh:
        json.dump(out, fh, indent=1)
    print(f"\nwrote {path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
