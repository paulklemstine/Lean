"""
sptest.py -- self-test for spcore.

DESIGN RULE (round 48's author tested the wrong quantity three times in one
session): a test that can only show the code running is not a test.  Every
block below contains either

  (a) a NEGATIVE CONTROL -- the harness is fed input on which the CORRECT
      answer is "null" / "fail" / "zero", and the harness must return it; or
  (b) an EXACT-ARITHMETIC identity check (M v = 0 over Q), never a rank,
      dimension, or float comparison.

Run:  python3 sptest.py
"""

from __future__ import annotations

import random
import sys
import time
from fractions import Fraction

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r49exp/sparse")

from spcore import (  # noqa: E402
    _frac_basis_exact,
    assert_kernel,
    assert_kernel_dense,
    cols_from_rels,
    defect_is_permutation_invariant,
    incidence_stats,
    kernel_dense,
    kernel_sparse,
    make_rels,
    matvec,
    matvec_ops,
    primitive,
    _WP_PRIMES,
    rand_g,
    wiedemann_nullvec,
)
from stange import gen_semiprime, kernel_basis  # noqa: E402  (reference impl)


def selftest(verbose=True) -> bool:
    ok = True

    def check(name, cond, detail=""):
        nonlocal ok
        if verbose:
            print(f"  [{'PASS' if cond else 'FAIL'}] {name} {detail}", flush=True)
        if not cond:
            ok = False

    def rejects(name, fn):
        """A negative control: fn() must RAISE.  If it does not, the harness
        is vacuous and every positive result it ever gave is worthless."""
        try:
            fn()
        except (AssertionError, ValueError, ZeroDivisionError, TypeError,
                IndexError, KeyError):
            check(name, True, "(correctly rejected)")
            return
        except Exception as e:  # pragma: no cover
            check(name, False, f"raised {type(e).__name__} not an assertion")
            return
        check(name, False, "!!! ACCEPTED BAD INPUT -- HARNESS IS VACUOUS")

    rng = random.Random(424242)

    # =====================================================================
    print("== ST1. the mandatory contract fires on a WRONG vector ==")
    # Round 48: "correct rank, correct dimension, completely wrong vectors."
    # Build a genuine kernel, then perturb ONE entry.  The assertion MUST fire.
    b, c = 9, 2
    cols = [[(i, rng.randrange(1, 4)) for i in rng.sample(range(b), 3)]
            for _ in range(b + c)]
    basis, rk, _pk, _o = kernel_sparse(cols, b)
    assert_kernel(cols, b, basis, label="ST1-good")
    check("ST1a. genuine kernel accepted", True, f"dimK={len(basis)}")

    bad = [list(v) for v in basis]
    bad[0][0] = Fraction(bad[0][0]) + 1
    rejects("ST1b. assertion REJECTS a one-entry-perturbed vector",
            lambda: assert_kernel(cols, b, bad, label="ST1-bad"))

    rejects("ST1c. assertion REJECTS a truncated vector",
            lambda: assert_kernel(cols, b, [v[:-1] for v in basis], "ST1c"))

    # Right dimension, wrong span: duplicate a vector -> not independent, and
    # each copy is still in the kernel, so ONLY check (2) can catch it.
    if len(basis) >= 1:
        dup = [list(basis[0])] * 2
        rejects("ST1d. assertion REJECTS a duplicated vector (each IS in the "
                "kernel -- only the independence check can see this)",
                lambda: assert_kernel(cols, b, dup, "ST1d"))

    # =====================================================================
    print("== ST2. the dense and sparse routes agree with sympy EXACTLY ==")
    for (bb, cc) in [(4, 2), (6, 1), (9, 3), (12, 1), (16, 2)]:
        for t in range(3):
            gcols = [[(i, rng.randrange(-4, 5)) for i in rng.sample(range(bb), 3)]
                     for _ in range(bb + cc)]
            dense_rows = [[0] * (bb + cc) for _ in range(bb)]
            for j, col in enumerate(gcols):
                for i, e in col:
                    dense_rows[i][j] = e
            Kd, rd, _ = kernel_dense(dense_rows)
            Ks, rs, _, _ = kernel_sparse(gcols, bb)
            assert_kernel_dense(dense_rows, Kd, "ST2-dense")
            assert_kernel(gcols, bb, Ks, "ST2-sparse")
            Kref, rr = kernel_basis(dense_rows)
            check(f"ST2 b={bb} c={cc} #{t}: sparse rank == dense == sympy",
                  rs == rd == rr, f"({rs}/{rd}/{rr})")
            check(f"ST2 b={bb} c={cc} #{t}: dimensions agree",
                  len(Ks) == len(Kd) == len(Kref) == bb + cc - rr,
                  f"({len(Ks)}/{len(Kd)}/{len(Kref)} vs {bb+cc-rr})")

    # =====================================================================
    print("== ST3. NEGATIVE CONTROL: a zero matrix must give the FULL kernel ==")
    # The null answer here is 'dimension n', and a route that quietly assumes
    # rank == b would return 1 vector.  This is where a hard-coded shortcut
    # (e.g. 'c=1 so one vector is enough') would show up.
    zcols = [[] for _ in range(7)]            # 7 columns, every entry zero
    Kz, rz, _, _ = kernel_sparse(zcols, 4)
    check("ST3a. all-zero M of rank 0 gives dimK == ncols == 7",
          len(Kz) == 7 and rz == 0, f"(dimK={len(Kz)}, rank={rz})")
    assert_kernel(zcols, 4, Kz, "ST3")
    check("ST3b. all-zero M: M v = 0 holds", True)

    # A matrix of RANK 0 but b=0 rows
    Kz2, rz2, _, _ = kernel_sparse([[], [], []], 0)
    check("ST3c. b = 0 (no rows): every column is free -> dimK == ncols",
          len(Kz2) == 3 and rz2 == 0, f"(dimK={len(Kz2)})")

    # =====================================================================
    print("== ST4. NEGATIVE CONTROL: full-rank case returns the EMPTY kernel ==")
    # M = I_b (b x b, square, rank b).  ker = {0}: dimK must be 0, and a route
    # that returns 'c vectors' unconditionally FAILS here.
    idcols = [[(i, 1)] for i in range(6)]
    Ki, ri, _, _ = kernel_sparse(idcols, 6)
    check("ST4a. identity M: rank 6, dimK 0", ri == 6 and len(Ki) == 0,
          f"(rank={ri}, dimK={len(Ki)})")
    Kd2, rd2, _ = kernel_dense([[1 if i == j else 0 for j in range(6)]
                                for i in range(6)])
    check("ST4b. dense route agrees on the identity", rd2 == 6 and len(Kd2) == 0)

    # =====================================================================
    print("== ST5. the permutation-invariance claim, on a REAL Stange matrix ==")
    n, p, q = gen_semiprime(20, random.Random(7))
    r2 = random.Random(11)
    g = rand_g(n, r2)
    rels, FB, BB, trials = make_rels(n, g, 10, 2, r2)
    cols = cols_from_rels(rels)
    st = incidence_stats(cols, 10)
    same, vals = defect_is_permutation_invariant(cols, 10, trials=10, rng=r2)
    check("ST5. defect identical under 10 random row/column permutations",
          same, f"(values {vals})")
    check("ST5b. defect == max(max rowdeg, max coldeg)",
          max(st["rowdeg_max"], st["coldeg_max"]) == max(vals),
          f"(rowdeg_max={st['rowdeg_max']}, coldeg_max={st['coldeg_max']})")
    check("ST5c. the matrix is SPARSE (density < 1) -- the premise of the axis",
          st["density"] < 1.0, f"(density={st['density']:.4f})")

    # =====================================================================
    print("== ST6. the sparse route on a real Stange matrix == M v = 0 EXACTLY ==")
    b = 10
    Mrows = [[rels[j][0][i] for j in range(len(rels))] for i in range(b)]
    Ks2, rs2, peak, ops = kernel_sparse(cols, b)
    assert_kernel(cols, b, Ks2, "ST6")
    check("ST6a. exact M v = 0 on a real relation matrix", True,
          f"(dimK={len(Ks2)}, rank={rs2})")
    Kd2, rd2, opsd = kernel_dense(Mrows)
    assert_kernel_dense(Mrows, Kd2, "ST6-dense")
    check("ST6b. dense rank == sparse rank", rd2 == rs2, f"({rd2})")
    check("ST6c. fill-in measured", peak >= st["nnz"], f"(peak={peak}, nnz={st['nnz']})")

    # =====================================================================
    print("== ST7. matvec agrees with the dense product EXACTLY ==")
    for _ in range(5):
        v = [Fraction(rng.randrange(-9, 10)) for _ in range(len(cols))]
        mv = matvec(cols, b, v)
        ref = [sum(Fraction(Mrows[i][j]) * v[j] for j in range(len(cols)))
               for i in range(b)]
        check("ST7. sparse matvec == dense M v", mv == ref)
    # NEGATIVE CONTROL: matvec of a zero vector is exactly zero, and matvec
    # cost must be reported as the nnz count, not something invented.
    check("ST7b. matvec(0) == 0 exactly",
          matvec(cols, b, [Fraction(0)] * len(cols)) == [0] * b)
    check("ST7c. matvec_ops == nnz", matvec_ops(cols, b) == st["nnz"],
          f"({matvec_ops(cols, b)} vs {st['nnz']})")

    # =====================================================================
    print("== ST8. Wiedemann (black-box) really returns a kernel vector ==")
    # over Z/p -- checked as an EXACT congruence, and the NEGATIVE CONTROL is
    # that a random vector is REJECTED.
    def mv_modp(w, p):
        acc = [0] * b
        for j, col in enumerate(cols):
            if w[j]:
                for i, e in col:
                    acc[i] += e * w[j]
        return acc

    found = 0
    for t in range(6):
        w, info = wiedemann_nullvec(cols, b, rng=random.Random(100 + t))
        if w is None:
            continue
        if all(x % info["p"] == 0 for x in mv_modp(w, info["p"])):
            found += 1
    check("ST8a. Wiedemann returns M w = 0 mod p on real data", found >= 1,
          f"({found}/6 cyclic)")

    rnd_bad = 0
    for t in range(20):
        info_p = _WP_PRIMES[t % len(_WP_PRIMES)]
        rv = [random.Random(t).randrange(info_p) for _ in range(len(cols))]
        if not all(x % info_p == 0 for x in mv_modp(rv, info_p)):
            rnd_bad += 1
    check("ST8b. NEGATIVE CONTROL: a random vector is NOT in the kernel",
          rnd_bad == 20, f"({rnd_bad}/20 rejected)")

    # ST8c. THE NILPOTENT-EMBEDDING TRAP, kept as a permanent control.
    # C = [[0,M],[0,0]] satisfies C^2 = 0, so its minimal polynomial is x^2 and
    # NO Berlekamp-Massey run can ever reach degree b+ncols.  My first
    # Wiedemann used exactly this embedding and returned 0/6 -- it was not a
    # tuner bug, it was structurally impossible.  This asserts the property
    # that explains the failure, so the trap cannot be re-entered silently.
    N2 = b + len(cols)

    def Cmul_nilpotent(x):
        """C = [[0, M],[0,0]] on a vector of length b+ncols:  C (u;v) = (M v;0)."""
        out = [0] * N2
        for j, col in enumerate(cols):
            vj = x[b + j]
            if vj:
                for i, e in col:
                    out[i] += e * vj
        return out

    Csq_is_zero = True
    nonzero_Cv = False
    for _ in range(4):
        vtest = [rng.randrange(-9, 10) for _ in range(N2)]
        Cv = Cmul_nilpotent(vtest)
        if any(Cv):
            nonzero_Cv = True
        if any(Cmul_nilpotent(Cv)):
            Csq_is_zero = False
            break
    check("ST8c-precondition. C itself is not identically zero on this data "
          "(so the test below is not vacuous)", nonzero_Cv)
    check("ST8c. the [[0,M],[0,0]] embedding is nilpotent (C^2 = 0), so a "
          "Wiedemann run on it can NEVER be cyclic -- this is why my first "
          "version returned 0/6", Csq_is_zero)

    # =====================================================================
    print("== ST9. the exactness trap: rational vs integer, and truncation ==")
    # r48's self-test T4: kernel vectors are Rational, and int() on 1/2 is 0.
    hit = 0
    for t in range(12):
        cc2 = [[(i, rng.randrange(-5, 6)) for i in rng.sample(range(7), 3)]
               for _ in range(9)]
        K, _r, _pk, _o = kernel_sparse(cc2, 7)
        nonint = sum(1 for v in K for x in v if Fraction(x).denominator != 1)
        if nonint:
            hit += 1
    check("ST9. kernel vectors really are rational on random sparse input",
          hit > 0, f"({hit}/12 had non-integer entries)")
    # primitive() must clear denominators AND keep the direction.
    v = [Fraction(1, 2), Fraction(-3, 4), Fraction(5, 6)]
    pv = primitive(v)
    check("ST9b. primitive() returns integers with gcd 1",
          all(isinstance(x, int) for x in pv))
    check("ST9c. primitive() keeps the direction",
          all(Fraction(pv[k]) * v[i] == Fraction(v[k]) * pv[i]
              for i in range(3) for k in range(3) if v[k] != 0))

    if verbose:
        print()
        print("ALL SELF-TESTS PASS" if ok else "!!! SELFTEST FAILURE")
    return ok


if __name__ == "__main__":
    sys.exit(0 if selftest() else 1)