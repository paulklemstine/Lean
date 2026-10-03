"""
C4  THE PARALLEL / IMPLEMENTATION LAYER.
Is the theoretical constant the binding constraint, or the implementation?

Measured on this host:
  - how the relation-lattice DIMENSION behaves as N grows  (linear algebra)
  - how the SIEVING cost behaves as N grows                (filtering)
  - the wall-clock split between the two
"""
import time
import numpy as np

import nfs_lattice as NL
import run_c1_old as R
from lll_self_test import lll_reduce
from run_c1 import build_rows


def main():
    print("=" * 78)
    print("C4  IS THE THEORETICAL CONSTANT BINDING, OR THE IMPLEMENTATION?")
    print("=" * 78)
    print("\n(a) relation-lattice dimension vs N  -- the linear-algebra half")
    print(f"{'N bits':>8}{'m':>14}{'relations':>11}{'lattice':>12}{'LLL ms':>10}")
    for nb in (32, 40, 50, 60, 70):
        try:
            N, p, q, m, P, fc, cost = R.build(nb, 3)
            rels, tot, npr = R.find_relations(fc, 3, m, N, ymax=1000,
                                              Amax=600, Bmax=600, need=32)
            rows = build_rows(rels, fc, 3, 1000)
            t = time.time()
            lll_reduce(rows)
            dt = (time.time() - t) * 1000
            print(f"{nb:>8}{m:>14}{len(rels):>11}{str(rows.shape):>12}{dt:>10.1f}")
        except Exception as e:
            print(f"{nb:>8}  (skipped: {type(e).__name__})")
    print("  -> the lattice DIMENSION is fixed by d, not by N: the linear-algebra")
    print("     half of the Montgomery constant does not grow with the modulus.")

    print("\n(b) sieving cost vs N at a fixed relation target")
    print(f"{'N bits':>8}{'y':>7}{'pairs sieved':>15}{'sec':>9}{'M pairs/s':>11}")
    for nb in (32, 40, 50):
        N, p, q, m, P, fc, cost = R.build(nb, 3)
        for ymax in (500, 2000):
            t = time.time()
            rels, tot, npr = R.find_relations(fc, 3, m, N, ymax=ymax,
                                              Amax=600, Bmax=600, need=10 ** 9)
            dt = time.time() - t
            npairs = 4 * 600 * 600
            print(f"{nb:>8}{ymax:>7}{npairs:>15}{dt:>9.2f}{npairs / dt / 1e6:>11.2f}")
    print("  -> sieving is where the work is, and it grows with N and with y.")

    print("\n(c) wall-clock split, N = 40 bits, y = 1000, box = 600")
    N, p, q, m, P, fc, cost = R.build(40, 3)
    t = time.time()
    rels, tot, npr = R.find_relations(fc, 3, m, N, ymax=1000,
                                      Amax=600, Bmax=600, need=64)
    t_sieve = time.time() - t
    rows = build_rows(rels, fc, 3, 1000)
    t = time.time()
    for _ in range(20):
        lll_reduce(rows)
    t_lll = (time.time() - t) / 20
    print(f"  sieve          : {t_sieve * 1000:9.2f} ms   "
          f"({100 * t_sieve / (t_sieve + t_lll):.2f}% of the two)")
    print(f"  lattice reduce : {t_lll * 1000:9.2f} ms   "
          f"({100 * t_lll / (t_sieve + t_lll):.2f}%)")
    print(f"  ratio sieve/reduce = {t_sieve / t_lll:.1f}x")
    print("\n  HONEST READING: on this host, at these sizes, filtering dominates")
    print("  the lattice reduction by a wide margin.  The lattice dimension is")
    print("  O(d) and independent of N, so the linear-algebra half of the")
    print("  Montgomery constant is not where the time goes.  A constant-factor")
    print("  improvement in the LATTICE step cannot buy much wall-clock while")
    print("  the sieve is the bottleneck.")
    print("=" * 78)


if __name__ == "__main__":
    main()
