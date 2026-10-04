"""
D2 -- THE DROP-IN TEST, CONCRETELY.

"At matched b and matched relation sets, which is faster -- Stange's dense
kernel, a sparse dictionary route, or NFS-style sparse reduction?"

Five routes, all on the SAME relation set, all exact where they claim to be:

  DM    sympy DomainMatrix.rref over QQ        (strongest dense backend)
  F     exact Fraction Gauss-Jordan, dense     (r50 fastnull's route)
  SQ    exact Fraction Gauss-Jordan, dicts     (sparse dictionary, over Q)
  Smod2 sparse Gauss-Jordan over F_2           (the NFS sign reduction)
  SmodP sparse Gauss-Jordan over a large F_p   (how fast could sparse be?)
  BB    Krylov/Wiedemann family, sparse matvec

⚠️ THE CENTRAL CAVEAT, and it is the honest answer to "is it a drop-in":
FQ and BB produce a kernel over Q / over F_p and can be fed to Algorithm 2.2
step 12.  Smod2/SmodP produce a kernel over a FINITE FIELD, which is NOT the
object Algorithm 2.2 asks for -- Stange needs a RATIONAL kernel vector,
because step 12 scales a basis element to integers.  A mod-p kernel is a
different computation (it is what NFS uses for its own purposes).  So a
mod-p route being faster is not evidence that the phase is cheaper; it is
evidence that a DIFFERENT, easier question was answered.  Both are timed and
both are reported, and the verdict distinguishes them.

Writes D2_routes.json.
"""
from __future__ import annotations

import json
import math
import random
import statistics
import sys
import time

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r51/exp/droptest")
import dtcore as D  # noqa: E402

OUT = "/home/raver1975/lean/factor-scratch/r51/exp/droptest/D2_routes.json"


def one_matrix(bits, b, seed):
    rng = random.Random(seed)
    n, p, q = D.stange.gen_semiprime(bits, rng)
    g = D.rand_g(n, rng)
    rels, trials = D.make_relations(n, g, b, 1, rng, "seq")
    return {"n": n, "b": b, "bits": n.bit_length(), "M": D.build_M(rels, b),
            "trials": trials, "B": D.stange.bbound_for_b(b)}


def bench(fn, M, reps, **kw):
    """Run a route `reps` times; return min time and the last result.

    min is the right statistic for a wall-clock comparison under noise: it is
    the least-contaminated estimate of the route's own cost.
    """
    best = None
    last = None
    for _ in range(reps):
        r = fn(M, **kw)
        last = r
        if best is None or r["time"] < best["time"]:
            best = r
    return best, last


def main():
    print("=" * 104)
    print("D2.  MATCHED b, MATCHED RELATION SETS: FIVE ROUTES, WALL CLOCK")
    print("=" * 104)
    print("Every route runs on the SAME matrix and is EXACTLY verified before its")
    print("time is recorded.  Q-routes return a rational kernel (usable by Alg 2.2")
    print("step 12); F_p-routes return a finite-field kernel (NOT the same object).")
    print()
    rows = []
    for bits in (30, 40):
        for b in (16, 26, 32, 40, 52, 64, 100, 128):
            reps = 3
            acc = {}
            dims = {}
            got = 0
            for s in range(reps):
                try:
                    inst = one_matrix(bits, b, 31000 + 977 * s + b)
                except Exception as e:
                    continue
                M = inst["M"]
                got += 1
                trials = []
                try:
                    r = D.kernel_dense_DM(M)
                    trials.append(("DM", r["time"], r["dim"], None))
                except TypeError:
                    trials.append(("DM", None, None, "float-leak"))
                r = D.kernel_dense_F(M)
                trials.append(("F", r["time"], r["dim"], r["ops"]))
                r = D.kernel_sparse_Q(M)
                trials.append(("SQ", r["time"], r["dim"], r["ops"]))
                for nm, pp in (("Smod2", 2), ("SmodP", 1000003)):
                    r = D.kernel_sparse_modp(M, pp)
                    trials.append((nm, r["time"], r["dim"], r["ops"]))
                bb = D.blackbox_kernel(M)
                trials.append(("BB", bb["time"] if bb else None, 1 if bb else 0,
                               bb["ops"] if bb else None))
                for nm, t, dim, extra in trials:
                    if t is None:
                        continue
                    acc.setdefault(nm, []).append(t)
                    dims.setdefault(nm, []).append(dim)
            if not got:
                continue
            st = D.incidence(inst["M"])
            med = {k: statistics.median(v) for k, v in acc.items()}
            row = {"bits": bits, "b": b, "ncols": st["ncols"], "nnz": st["nnz"],
                   "defect": st["defect"], "instances": got,
                   "times": med, "dims": {k: sorted(set(v)) for k, v in dims.items()}}
            # ratios against the incumbent (F, what r50 actually used)
            base = med.get("F")
            for k in med:
                row.setdefault("ratio_vs_F", {})[k] = med[k] / base if base else None
            rows.append(row)
            cells = "  ".join(
                f"{k}={med[k]*1e3:.3f}" for k in
                ("F", "SQ", "DM", "Smod2", "SmodP", "BB") if k in med)
            print(f"  n~2^{bits}  b={b:>4}  nnz={st['nnz']:>4}  defect={st['defect']:>4}"
                  f"   {cells}   (ms, median of {got})")
    with open(OUT, "w") as f:
        json.dump({"rows": rows}, f, indent=1, default=str)

    # ---- summary: crossovers and the factor-vs-b question ----
    print()
    print("=" * 104)
    print("D2 SUMMARY -- who beats whom, and where")
    print("=" * 104)
    hdr = (f"{'bits':>4} {'b':>5} {'F/SQ':>7} {'F/DM':>7} {'F/BB':>7} "
           f"{'F/Smod2':>9} {'F/SmodP':>9}")
    print(hdr)
    print("-" * len(hdr))
    for r in rows:
        t = r["times"]
        f = lambda a, c: (t[a] / t[c]) if (a in t and c in t) else float("nan")
        print(f"{r['bits']:>4} {r['b']:>5} {f('F','SQ'):>7.2f} {f('F','DM'):>7.2f} "
              f"{f('F','BB'):>7.2f} {f('F','Smod2'):>9.2f} {f('F','SmodP'):>9.2f}")
    print()
    print("ratio > 1 means the FIRST is SLOWER (dense/rational route loses).")
    print("SQ = sparse dictionary over Q; DM = sympy dense over QQ; BB = Krylov;")
    print("Smod2/SmodP = sparse over a finite field (a DIFFERENT computation).")
    print(f"\nwrote {OUT}")


if __name__ == "__main__":
    main()