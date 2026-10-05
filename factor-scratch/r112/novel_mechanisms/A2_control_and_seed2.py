#!/usr/bin/env python3
"""
A2 -- the MANDATORY control for candidate A, plus the decisive cells at a
second seed, plus the cells that came back indeterminate.

CONTROL (brief sec 1.2).  The closed axis measured, at N=2^128 balanced:
31 unknown bits WORKS, 32 FAILS.  If this harness does not reproduce THAT,
it is not measuring what the closed axis measured and candidate A is void.

DECISIVE CELL.  At pb=42 (beta ~ 0.328) the two predictions differ by 7 bits:
  PRED-A  X < N^(beta^2)  -> 2^13
  PRED-B  X < p^(1/2)      -> 2^21
The first run found 13 WORKS and 21 FAILS.  That kills PRED-B.  This run
repeats it at a SECOND, INDEPENDENT seed, because an uncited single-seed
boundary is exactly the unseeded-count trap.
"""
import sys, json, time, math, argparse
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r112/novel_mechanisms")
import A_unbalanced_threshold as A
from common112 import gen_semiprime


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--seed", type=int, default=7)
    a = ap.parse_args()
    # (pb, [unks to test])
    plan = [
        (64, [29, 30, 31, 32]),      # CONTROL: must show 31 works, 32 fails
        (42, [13, 14, 20, 21]),      # DECISIVE: PRED-A vs PRED-B, seed 2
        (51, [18, 19, 20, 25]),      # boundary was between 16 and 20
        (32, [6, 7, 8]),             # boundary was between 6 and 8
    ]
    out = dict(seed=a.seed, cells=[])
    for pb, unks in plan:
        p, q, N = gen_semiprime(128, a.seed * 1000 + pb, beta=pb / 128.0)
        assert p.bit_length() == pb, (p.bit_length(), pb)
        assert p * q == N and N.bit_length() == 128
        for unk in unks:
            r = A.cell(N, p, unk, budget_s=240)
            beta = pb / 128.0
            r.update(pb=pb, predA=round(beta ** 2 * 128, 2),
                     predB=round(beta / 2 * 128, 2), seed=a.seed)
            out["cells"].append(r)
            print("seed=%d pb=%d unk=%d found=%s dim=%s %.0fs "
                  "(predA=%.2f predB=%.2f)" %
                  (a.seed, pb, unk, r.get("found"), r.get("dim"),
                   r.get("seconds", 0), r["predA"], r["predB"]), flush=True)
    fn = ("/home/raver1975/lean/factor-scratch/r112/novel_mechanisms/"
          "out_A2_seed%d.json" % a.seed)
    json.dump(out, open(fn, "w"), indent=1)
    print("wrote", fn)


if __name__ == "__main__":
    main()
