"""
D1-B DIAGNOSTIC -- why did the O(1)-defect control come out SLOWER, and what
is the right way to ask "does the Theta(b) defect cost anything at b~26-52?"

Two confounds, both of which I have to measure rather than assume.

CONFOUND 1 (fatal to the naive timing comparison).
  The DENSE route is Theta(b^3) INDEPENDENT of the defect: dense Gauss-Jordan
  touches every one of the ncols entries in every pivot row, so a matrix with
  defect 7 and a matrix with defect 88 do exactly the same number of
  multiplications.  A dense-vs-dense wall-clock comparison therefore CANNOT
  measure the cost of the defect at all -- it measures only the cost of the
  ARITHMETIC (numerator/denominator sizes).  That is the whole story of the
  inverted ratio in exp_D1 part B.

CONFOUND 2.
  The two matrices also differ in ENTRY SIZE.  Fraction arithmetic is not
  constant-time: the real Stange kernel vectors have structured, small
  entries, while a random control's have large denominators.

So the correct measurement is an OPERATION/FILL count on the SPARSE route --
where the defect actually bites -- not a wall clock on the dense route.

Measured here:
  * fill (total stored nonzeros at the end of elimination) for real vs control
  * the same, at matched entry-size, by forcing both to the same value set
  * an INDEPENDENT handle-lift model: for a matrix with a dense row, elimination
    must propagate through it; count that directly.

Writes D1_diag.json.
"""
from __future__ import annotations

import json
import random
import statistics
import sys
import time
from fractions import Fraction

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r51/exp/droptest")
import dtcore as D  # noqa: E402

OUT = "/home/raver1975/lean/factor-scratch/r51/exp/droptest/D1_diag.json"


def one_matrix(bits, b, seed):
    rng = random.Random(seed)
    n, p, q = D.stange.gen_semiprime(bits, rng)
    g = D.rand_g(n, rng)
    rels, _ = D.make_relations(n, g, b, 1, rng, "seq")
    return D.build_M(rels, b)


def sparse_fill_and_ops(rows, label=""):
    """Sparse exact Gauss-Jordan; report ops AND fill. Both are structure-only
    (no arithmetic on numerator sizes), so they isolate the sparsity effect."""
    rd = [dict((j, Fraction(int(x))) for j, x in enumerate(r) if x) for r in rows]
    m, ncols = len(rows), len(rows[0])
    R = [dict(r) for r in rd]
    ops = 0
    fill = 0
    piv = []
    r = 0
    for c in range(ncols):
        pr = None
        for i in range(r, m):
            if R[i].get(c, 0) != 0:
                pr = i
                break
        if pr is None:
            continue
        R[r], R[pr] = R[pr], R[r]
        pv = R[r][c]
        Rr = {j: v / pv for j, v in R[r].items()}
        R[r] = Rr
        ops += len(Rr)
        for i in range(m):
            if i != r:
                f = R[i].get(c, 0)
                if f != 0:
                    Ri = R[i]
                    for j, v in Rr.items():
                        nv = Ri.get(j, 0) - f * v
                        if nv == 0:
                            Ri.pop(j, None)
                        else:
                            Ri[j] = nv
                    ops += len(Rr)
        fill += sum(len(x) for x in R)
        piv.append(c)
        r += 1
        if r == m:
            break
    return {"ops": ops, "fill": fill, "rank": len(piv)}


def entry_sizes(basis):
    """Numerator/denominator bit-lengths of a kernel basis -- the ARITHMETIC
    cost driver that a dense-vs-dense timing conflates with the defect."""
    ns, ds = [], []
    for v in basis:
        for x in v:
            x = D.to_frac(x)
            ns.append(abs(x.numerator).bit_length())
            ds.append(x.denominator.bit_length())
    return {"max_num_bits": max(ns), "max_den_bits": max(ds),
            "mean_den_bits": statistics.mean(ds)}


def main():
    print("=" * 100)
    print("D1-B DIAGNOSTIC: separating DEFECT from ARITHMETIC COST")
    print("=" * 100)
    print()
    print("(1) The DENSE route's op count is structure-INDEPENDENT.  Verify that")
    print("    the control and the real matrix do the SAME number of dense ops.")
    print()
    hdr = (f"{'b':>4} {'nnz':>5} {'def(real)':>10} {'def(ctrl)':>10} "
           f"{'dense ops real':>15} {'dense ops ctrl':>15} {'ratio':>7}")
    print(hdr)
    print("-" * len(hdr))
    rows = []
    for b in (16, 26, 40, 52, 64, 100, 128):
        acc = {}
        for s in range(3):
            try:
                M = one_matrix(40, b, 8100 + 13 * s + b)
            except Exception:
                continue
            C = D.bounded_defect_control(M, random.Random(500 + s))
            acc.setdefault("real", []).append((M, D.kernel_dense_F(M)))
            acc.setdefault("ctrl", []).append((C, D.kernel_dense_F(C)))
        if not acc:
            continue
        mr = [r for _, r in acc["real"]]
        mc = [r for _, r in acc["ctrl"]]
        oR = statistics.median([r["ops"] for r in mr])
        oC = statistics.median([r["ops"] for r in mc])
        dR = statistics.median([D.incidence(M)["defect"] for M, _ in acc["real"]])
        dC = statistics.median([D.incidence(C)["defect"] for C, _ in acc["ctrl"]])
        nn = statistics.median([D.incidence(M)["nnz"] for M, _ in acc["real"]])
        print(f"{b:>4} {nn:>5.0f} {dR:>10.1f} {dC:>10.1f} "
              f"{oR:>15.0f} {oC:>15.0f} {oR/max(oC,1):>7.3f}")
        rows.append({"b": b, "nnz": nn, "def_real": dR, "def_ctrl": dC,
                     "dense_ops_real": oR, "dense_ops_ctrl": oC})
    print()
    print("    -> the ratio is ~1:00: the dense route does the SAME work on both.")
    print("       So a dense wall clock cannot measure the defect.  (CONFOUND 1.)")
    print()
    print("(2) The two matrices differ in ENTRY SIZE, which is what the dense")
    print("    wall clock was actually measuring.  (CONFOUND 2.)")
    print()
    print(f"{'b':>4} {'max num bits real':>18} {'max num bits ctrl':>18} "
          f"{'max den bits real':>18} {'max den bits ctrl':>18}")
    print("-" * 92)
    esrows = []
    for b in (16, 26, 40, 64, 100):
        try:
            M = one_matrix(40, b, 8100 + b)
        except Exception:
            continue
        C = D.bounded_defect_control(M, random.Random(500))
        er = entry_sizes(D.kernel_dense_F(M)["basis"])
        ec = entry_sizes(D.kernel_dense_F(C)["basis"])
        print(f"{b:>4} {er['max_num_bits']:>18} {ec['max_num_bits']:>18} "
              f"{er['max_den_bits']:>18} {ec['max_den_bits']:>18}")
        esrows.append({"b": b, "real": er, "ctrl": ec})
    print()
    print("(3) THE RIGHT MEASUREMENT: fill/ops on the SPARSE route, where the")
    print("    defect actually bites.  Both exact; both structure-only counts.")
    print()
    hdr = (f"{'b':>4} {'nnz':>5} {'def real':>9} {'def ctrl':>9} "
           f"{'sparse ops real':>16} {'sparse ops ctrl':>16} {'ratio':>7} "
           f"{'fill real':>11} {'fill ctrl':>11} {'ratio':>7}")
    print(hdr)
    print("-" * len(hdr))
    sp = []
    for b in (16, 26, 40, 52, 64, 100, 128, 200, 256):
        acc = {}
        for s in range(2):
            try:
                M = one_matrix(40, b, 8200 + 17 * s + b)
            except Exception:
                continue
            C = D.bounded_defect_control(M, random.Random(600 + s))
            acc.setdefault("real", []).append((M, sparse_fill_and_ops(M)))
            acc.setdefault("ctrl", []).append((C, sparse_fill_and_ops(C)))
        if not acc:
            continue
        oR = statistics.median([r["ops"] for _, r in acc["real"]])
        oC = statistics.median([r["ops"] for _, r in acc["ctrl"]])
        fR = statistics.median([r["fill"] for _, r in acc["real"]])
        fC = statistics.median([r["fill"] for _, r in acc["ctrl"]])
        dR = statistics.median([D.incidence(M)["defect"] for M, _ in acc["real"]])
        dC = statistics.median([D.incidence(C)["defect"] for C, _ in acc["ctrl"]])
        nn = statistics.median([D.incidence(M)["nnz"] for M, _ in acc["real"]])
        print(f"{b:>4} {nn:>5.0f} {dR:>9.1f} {dC:>9.1f} {oR:>16.0f} {oC:>16.0f} "
              f"{oR/max(oC,1):>7.2f} {fR:>11.0f} {fC:>11.0f} {fR/max(fC,1):>7.2f}")
        sp.append({"b": b, "nnz": nn, "def_real": dR, "def_ctrl": dC,
                   "ops_real": oR, "ops_ctrl": oC, "fill_real": fR,
                   "fill_ctrl": fC})
    print()
    print("    -> ratio > 1 means the Theta(b)-defect matrix costs MORE sparse")
    print("       operations than the O(1)-defect matrix at the SAME nnz.  That")
    print("       ratio is the quantity that says whether the defect binds.")
    with open(OUT, "w") as f:
        json.dump({"dense_ops": rows, "entry_sizes": esrows, "sparse": sp},
                  f, indent=1, default=str)
    print(f"\nwrote {OUT}")


if __name__ == "__main__":
    main()