"""
diag_Gzero.py -- WHY might a small b have a low rate?

Round 49 measured a b=6 rate of 0.6417 (z = -2.48) and never settled it.  The
obvious candidate mechanism is NOT the order step: if the kernel has dimension
> c (which happens at small b, where the exponent matrix is so sparse that rank
< b), then the FIRST c basis vectors are an arbitrary sub-family, and it is
possible for the corresponding beta_t to be 0 -- i.e. G = gcd(0,...,0) = 0,
which yields no factor at all.  That is a FAILURE MODE THAT IS NOT THE ORDER
STEP, so it WOULD depress the rate below 20/27 at small b specifically.

So a low b=6 rate would NOT contradict round 49's "P = 20/27 exactly, always" --
it would mean the relation search sometimes returns a useless multiple.  This
script separates the two failure modes so the two can be told apart:

    factor found            -- success
    G != 0, no factor       -- the order step failed (20/27 law applies)
    G == 0                  -- NO USABLE MULTIPLE; not an order-step failure

and reports the rate CONDITIONAL on G != 0, which is the quantity the 20/27 law
is about.
"""
from __future__ import annotations

import json
import os
import sys
import time
from multiprocessing import Pool

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from run_sweep import _work_full  # noqa: E402
from bsweep_core import P_TRUE  # noqa: E402
import math  # noqa: E402

NPROC = int(os.environ.get("NPROC", 12))


def main():
    nbits = int(os.environ.get("NBITS", 30))
    N = int(os.environ.get("NFULL", 400))
    bs = [int(x) for x in os.environ.get("BS", "6,8,12,20,40,64").split(",")]
    SEED0 = int(os.environ.get("SEED0", 1_950_000))
    jobs = [(nbits, b, 1, SEED0 + 13 * b + k, 0, 8_000_000)
            for b in bs for k in range(N)]
    print(f"G=0 DIAGNOSTIC  n ~ 2^{nbits}, c=1, N={N}/b, seeds {SEED0}+", flush=True)
    t0 = time.time()
    with Pool(NPROC) as pool:
        res = pool.map(_work_full, jobs, chunksize=1)
    print(f"wall {time.time()-t0:.1f}s\n", flush=True)
    print(f"{'b':>5}{'N':>6}{'factors':>9}{'G==0':>8}{'no-factor, G!=0':>16}"
          f"{'raw rate':>10}{'z vs 20/27':>12}{'rate | G!=0':>13}"
          f"{'z | G!=0':>11}{'mean dimK':>11}", flush=True)
    out = {}
    for b in bs:
        rs = [r for r in res if r["b"] == b and r["err"] is None
              and not r["cap_hit"]]
        Nn = len(rs)
        f = sum(1 for r in rs if r["ok"])
        g0 = sum(1 for r in rs if r["G"] == 0)
        nf = Nn - f - g0
        rate = f / max(Nn, 1)
        se = math.sqrt(P_TRUE * (1 - P_TRUE) / max(Nn, 1))
        m = Nn - g0
        rf = f / max(m, 1)
        sef = math.sqrt(P_TRUE * (1 - P_TRUE) / max(m, 1))
        print(f"{b:>5}{Nn:>6}{f:>9}{g0:>8}{nf:>16}{rate:>10.4f}"
              f"{(rate-P_TRUE)/se:>+12.2f}{rf:>13.4f}{(rf-P_TRUE)/sef:>+11.2f}"
              f"{'':>11}", flush=True)
        out[b] = {"N": Nn, "f": f, "G0": g0, "nofactor_Gneq0": nf, "rate": rate,
                  "rate_cond_Gneq0": rf, "z": (rate - P_TRUE) / se,
                  "z_cond": (rf - P_TRUE) / sef}
    json.dump(out, open(os.path.join(HERE, "gzero.json"), "w"), indent=1)
    print("\ndone -> gzero.json", flush=True)


if __name__ == "__main__":
    main()