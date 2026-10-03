"""
C1 statistics: how often is LLL already optimal on the NFS relation lattice?

The decisive quantity is  LLL(b1) / exact_SVP(b1), computed with the CERTIFIED
enumerator (exactsvp), which is independent of my BKZ implementation.  A ratio
of exactly 1 means LLL found a provably shortest vector and NO block size can
improve it.

Many independent (N, m, relation-set) configurations are sampled; the ratio
distribution is the result.
"""
import numpy as np

import nfs_lattice as NL
import run_c1_old as R
from lll_self_test import lll_reduce, bkz_reduce
from exactsvp import enumerate_svp
from run_c1 import build_rows, hermite


def one_config(nb, ymax, box, nrel, seed):
    N, p, q, m, P, fc, cost = R.build(nb, 3, seed=seed)
    rels, tot, npr = R.find_relations(fc, 3, m, N, ymax=ymax, Amax=box,
                                      Bmax=box, need=nrel)
    if len(rels) < nrel:
        return None
    rows = build_rows(rels, fc, 3, ymax)
    if rows.shape[0] < rows.shape[1]:
        return None
    ref = enumerate_svp(rows, cap=20_000_000)
    if ref is None:
        return None
    svp = ref[0]
    L, _ = lll_reduce(rows)
    l1 = float(L[0] @ L[0])
    out = {'N': N, 'dim': rows.shape[1], 'svp': svp, 'lll': l1,
           'lll_svp': l1 / svp}
    best = min(float((bkz_reduce(rows, b)[0] @ bkz_reduce(rows, b)[0]))
               for b in range(2, rows.shape[1] + 1))
    out['best_bkz'] = best
    out['bkz_svp'] = best / svp
    out['hermite_lll'] = hermite(L)
    return out


def main():
    print("=" * 78)
    print("C1b  IS LLL ALREADY OPTIMAL ON THE NFS RELATION LATTICE?")
    print("     (exact SVP by certified enumeration; independent of my BKZ)")
    print("=" * 78)
    res = []
    tried = 0
    for nb in (32, 36, 40, 43, 45, 50, 55):
        for ymax in (500, 1000, 2000):
            for nrel in (16, 24, 32):
                for seed in (1, 2):
                    tried += 1
                    if len(res) >= 40:
                        break
                    try:
                        r = one_config(nb, ymax, 600, nrel, seed)
                    except Exception:
                        r = None
                    if r:
                        res.append(r)
    print(f"configurations attempted: {tried}; with certified exact SVP: {len(res)}")
    if not res:
        print("no certifiable configurations")
        return
    lllr = np.array([r['lll_svp'] for r in res])
    bkzr = np.array([r['bkz_svp'] for r in res])
    print(f"\nLLL(b1)^2 / exact_SVP(b1)^2   over {len(res)} NFS relation lattices:")
    print(f"  min  {lllr.min():.10f}")
    print(f"  max  {lllr.max():.10f}")
    print(f"  mean {lllr.mean():.10f}")
    print(f"  # exactly 1.0 (LLL optimal): {int(np.sum(np.abs(lllr - 1) < 1e-12))}/{len(lllr)}")
    print(f"  # above 1.0 (LLL suboptimal): {int(np.sum(lllr > 1 + 1e-12))}/{len(lllr)}")
    print(f"\nBest BKZ over all beta, per lattice:")
    print(f"  min  {bkzr.min():.10f}   max {bkzr.max():.10f}")
    imp = lllr / np.minimum(bkzr, lllr)
    print(f"  best speed-up of ||b1|| from ANY block size: {imp.max():.10f}x "
          f"(1.0 = no block size helps)")
    print(f"\nHermite factor of the LLL-reduced relation lattice: "
          f"min {min(r['hermite_lll'] for r in res):.6f} "
          f"max {max(r['hermite_lll'] for r in res):.6f}")
    print("=" * 78)


if __name__ == "__main__":
    main()
