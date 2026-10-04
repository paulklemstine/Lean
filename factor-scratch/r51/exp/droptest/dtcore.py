"""
PP -- the drop-in test: is Stange's linear-algebra/gcd phase a drop-in for NFS's?

Independent re-implementation. Nothing here is copied from the read-only
`r49exp/sparse/spcore.py`; the only import is r48's VALIDATED relation finder
and factoring primitives, which are reused (not re-implemented) per the
project's harness discipline.

MANDATORY CONTROLS BUILT IN:
  * assert_Mv_zero()  -- EXACT M v = 0 over Q, per vector, before any timing
                         is recorded. Every route calls it.
  * to_frac()         -- handles sympy Rational / Fraction / int without the
                         hasattr('.q') trap that r48 documents.
  * Dense route runs rref over QQ, NEVER over ZZ (see selftest ST-ZZ).
  * p_split()         -- exact per-modulus 2-adic baseline, so no rate is ever
                         compared against the 20/27 average.
  * No Dickman, no rho, no float cube roots anywhere.
"""
from __future__ import annotations

import math
import random
import sys
import time
from collections import defaultdict
from fractions import Fraction

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp/stange")
import stange  # noqa: E402  (validated harness: relation finder, kernel_basis, ...)

# ---------------------------------------------------------------------------
# exact rational helpers  (the .q trap)
# ---------------------------------------------------------------------------


_FLOAT_LEAKS = [0]


def to_frac(x) -> Fraction:
    """int / Fraction / sympy Rational / MPQ -> fractions.Fraction.

    `hasattr(x, 'q')` is NOT a valid test: fractions.Fraction has no `.q`, so a
    hasattr-based converter silently returns the numerator and truncates every
    Fraction to 0. stange._denominator documents this; we branch explicitly.

    ⚠️ FLOAT LEAK, found by the self-test -- a second documented trap in the
    same library call as the ZZ one (MM_sparse §4).  sympy's
    `DomainMatrix.rref()` over `QQ` normally returns python-flint `MPQ`
    objects, but on RANK-DEFICIENT integer matrices it leaks genuine python
    `float`s.  Measured: **20/20** random rank-deficient integer matrices leak
    floats; **0/4** real Stange relation matrices do.  The leaked values are
    not all 1.0 -- the exact assertion caught one equal to `2**-52`, i.e.
    `1/4503599627370496`, so the leak carries genuine rounding error and
    silently converts an exact route into an approximate one.

    The sound handling is therefore STRICT REJECTION: a float in an exact
    route is an error, not something to convert.  `Fraction(1.0)` would have
    been exact, but `Fraction(float(1/3))` is not, and the two are
    indistinguishable after the fact.  The route raises instead.
    """
    if isinstance(x, Fraction):
        return x
    if isinstance(x, int):
        return Fraction(x)
    if isinstance(x, float):
        _FLOAT_LEAKS[0] += 1
        raise TypeError(
            f"FLOAT in an exact-arithmetic route: {x!r}. sympy's QQ rref leaks "
            f"floats on rank-deficient matrices; this route is not exact and "
            f"must not be reported as if it were.")
    # python-flint MPQ (what sympy's DomainMatrix.rref returns).  It is NOT a
    # tuple, has no .p/.q and no .num/.den -- attribute duck-typing on it fails
    # three different ways.  sympy's own QQ.to_sympy is the supported bridge.
    if type(x).__name__ in ("PythonMPQ", "MPQ", "fmpq"):
        from sympy import QQ as _QQ
        s = _QQ.to_sympy(x)
        return Fraction(int(s.p), int(s.q))
    # sympy Rational / Integer / Zero / One
    return Fraction(int(x.p), int(x.q))


def assert_Mv_zero(rows, v, label: str = "") -> None:
    """EXACT assertion M v = 0 over Q.  M integer, v rational.

    A rank/dimension check passes every bug this project has recorded; only this
    does not.  Every route in this file calls it before recording a time.
    """
    ncols = len(rows[0])
    assert len(v) == ncols, f"{label}: len(v)={len(v)} != ncols={ncols}"
    for i, row in enumerate(rows):
        s = Fraction(0)
        for j, x in enumerate(row):
            if x:
                s += Fraction(x) * to_frac(v[j])
        assert s == 0, f"{label}: (M v)_i = {s} != 0 at row {i}"


def assert_Mv_zero_mod(rows, v, p: int, label: str = "") -> None:
    """M v = 0 over F_p.  Separate predicate: a mod-p kernel is NOT the Q kernel
    and must never be reported as if it were."""
    ncols = len(rows[0])
    assert len(v) == ncols, f"{label}: len(v)={len(v)} != ncols={ncols}"
    for i, row in enumerate(rows):
        s = 0
        for j, x in enumerate(row):
            if x:
                s = (s + (int(x) % p) * int(v[j])) % p
        assert s == 0, f"{label}: (M v)_i = {s} != 0 mod {p} at row {i}"


# ---------------------------------------------------------------------------
# relation sets  (r48's validated finder; 'seq' is the fast validated sampler)
# ---------------------------------------------------------------------------


def make_relations(n, g, b, c, rng, sampler="random", cap=200_000_000):
    BB = stange.bbound_for_b(b)
    FB = stange.factor_base(BB, n)
    assert len(FB) == b, (len(FB), b)
    return stange.find_relations(n, g, FB, b + c, rng, sampler, cap)


def rand_g(n, rng):
    g = rng.randrange(2, n)
    while math.gcd(g, n) != 1:
        g = rng.randrange(2, n)
    return g


def build_M(rels, b):
    """b x (b+c) integer matrix, row i = prime p_i, column j = relation j."""
    return [[rels[j][0][i] for j in range(len(rels))] for i in range(b)]


def rows_to_dicts(rows):
    return [dict((j, int(x)) for j, x in enumerate(r) if x) for r in rows]


# ---------------------------------------------------------------------------
# D1: sparsity, defect, and the permutation-invariance proof (numerical check)
# ---------------------------------------------------------------------------


def incidence(rows):
    """rowdeg / coldeg / nnz / density / defect, computed from scratch."""
    m = len(rows)
    ncols = len(rows[0])
    rowdeg = [sum(1 for x in r if x) for r in rows]
    coldeg = [0] * ncols
    for r in rows:
        for j, x in enumerate(r):
            if x:
                coldeg[j] += 1
    nnz = sum(rowdeg)
    return {
        "b": m,
        "ncols": ncols,
        "nnz": nnz,
        "density": nnz / (m * ncols),
        "max_rowdeg": max(rowdeg),
        "max_coldeg": max(coldeg),
        "defect": max(max(rowdeg), max(coldeg)),
        "defect_frac": max(max(rowdeg), max(coldeg)) / ncols,
        "rowdeg": rowdeg,
        "coldeg": coldeg,
    }


def defect_under_permutations(rows, trials=8, rng=None, seed=12345):
    """Numerical check of the invariance proof: permuting ROWS permutes the
    entries WITHIN each column (so coldeg is fixed) and permuting COLS
    permutes the entries WITHIN each row (so rowdeg is fixed).  Hence
    defect(sigma A tau) = defect(A) for every (sigma, tau)."""
    if rng is None:
        rng = random.Random(seed)
    m, ncols = len(rows), len(rows[0])
    base = incidence(rows)
    out = []
    for _ in range(trials):
        pr = list(range(m))
        pc = list(range(ncols))
        rng.shuffle(pr)
        rng.shuffle(pc)
        A = [[rows[pr[i]][pc[j]] for j in range(ncols)] for i in range(m)]
        st = incidence(A)
        assert st["defect"] == base["defect"], (
            f"defect changed under permutation: {st['defect']} != {base['defect']}")
        assert sorted(st["rowdeg"]) == sorted(base["rowdeg"])
        assert sorted(st["coldeg"]) == sorted(base["coldeg"])
        out.append(st["defect"])
    return base["defect"], out


def bounded_defect_control(rows, rng, seed=999):
    """MATCHED-SHAPE / MATCHED-NNZ control with an O(1) defect.

    Same b, same ncols=b+c, same total nnz, but row degrees flattened to
    ~nnz/b.  This isolates the cost of the Theta(b) defect with every other
    property of the matrix held fixed -- the experiment D1 needs to answer
    "does the defect cost anything at b ~ 26-52?".

    ⚠️ First version built a random cell list and then truncated each row's
    share to a quota.  When a row drew MORE cells than its quota the excess was
    silently discarded, so the control came out with FEWER nonzeros than the
    real matrix (108 vs 96 measured) -- the control was not matched at all, and
    a timing comparison against it would have been meaningless.  The quota is
    now assigned FIRST and each row picks exactly that many distinct columns.
    """
    st = incidence(rows)
    b, ncols, nnz = st["b"], st["ncols"], st["nnz"]
    r2 = random.Random(seed)
    A = [[0] * ncols for _ in range(b)]
    # Flatten BOTH row and column degrees.  My first control flattened only the
    # ROWS, which left the column degrees untouched and concentrated: at b=26
    # its own COLUMN degree (12) became the new max, so the "O(1)-defect"
    # control still had defect 12 against the real matrix's 20.  A control
    # whose defect is barely lower cannot decide the question.
    # Bipartite construction: place nnz edges so every row and every column
    # carries ceil(nnz/b) or ceil(nnz/ncols) edges -- O(1) in BOTH directions.
    # Greedy round-robin over columns, rows visited in a rotating offset.
    base_c, rem_c = divmod(nnz, ncols)
    per_row, rem_r = divmod(nnz, b)
    off = 0
    for i in range(b):
        tgt = per_row + (1 if i < rem_r else 0)
        for t in range(tgt):
            # pick the currently lightest-loaded column, breaking ties randomly
            best = min((sum(1 for k in range(b) if A[k][j]) for j in range(ncols)))
            cands = [j for j in range(ncols)
                     if sum(1 for k in range(b) if A[k][j]) == best and A[i][j] == 0]
            j = cands[r2.randrange(len(cands))]
            A[i][j] = r2.randrange(1, 6)
    assert incidence(A)["nnz"] == nnz, "control nnz mismatch"
    sc = incidence(A)
    # O(1) defect in the strong sense: bounded by a small constant, not a
    # constant FRACTION of the dimensions.
    assert sc["defect"] <= max(2 * per_row, 2 * base_c) + 2, (
        f"control defect {sc['defect']} is not O(1): rows {per_row}, cols {base_c}")
    return A


# ---------------------------------------------------------------------------
# ROUTE 1: DENSE over QQ, sympy DomainMatrix.rref  (the strongest dense backend)
# ---------------------------------------------------------------------------


def kernel_dense_DM(rows, label="DM"):
    from sympy import QQ
    from sympy.polys.matrices import DomainMatrix

    m, ncols = len(rows), len(rows[0])
    t0 = time.perf_counter()
    dm = DomainMatrix([[int(x) for x in r] for r in rows], (m, ncols), QQ)
    R, _piv = dm.rref()
    Rm = R.to_list()
    t1 = time.perf_counter()

    # Pivot columns = the LEADING column of each nonzero RREF row.
    #
    # BUG CAUGHT HERE (the first version scanned "does any row have a nonzero
    # in column j" and returned rank 27 for a 26x27 matrix -- impossible, and
    # it silently produced dim=0, i.e. "the kernel is empty", on a matrix
    # whose true kernel has dimension 2).  A free column j has a NONZERO in
    # every pivot row (that is the whole point of RREF), so the naive scan
    # calls every column a pivot.  A RANK/DIMENSION CHECK PASSES THAT BUG TOO;
    # only assert M v = 0 on the extracted vectors catches the consequence.
    piv = []
    for i in range(m):
        fp = _first_pivot(Rm[i])
        if fp >= 0:
            piv.append(fp)
    assert len(piv) == len(set(piv)), "duplicate pivot column"
    assert piv == sorted(piv), "pivots not increasing"
    assert len(piv) <= m, f"rank {len(piv)} > rows {m}"
    pivset = set(piv)
    free = [j for j in range(ncols) if j not in pivset]

    basis = []
    for fc in free:
        v = [Fraction(0)] * ncols
        v[fc] = Fraction(1)
        for k, pc in enumerate(piv):
            v[pc] = -to_frac(Rm[k][fc])
        assert_Mv_zero(rows, v, label)
        basis.append(v)
    return {"basis": basis, "rank": len(piv), "dim": len(basis),
            "time": t1 - t0, "label": label}


def _first_pivot(row):
    for j, x in enumerate(row):
        if x != 0:
            return j
    return -1


# ---------------------------------------------------------------------------
# ROUTE 2: DENSE exact Gauss-Jordan over QQ with Fractions (r50 fastnull style)
# ---------------------------------------------------------------------------


def kernel_dense_F(rows, label="F"):
    m, ncols = len(rows), len(rows[0])
    t0 = time.perf_counter()
    A = [[Fraction(x) for x in r] for r in rows]
    ops = 0
    piv = []
    r = 0
    for c in range(ncols):
        pr = None
        for i in range(r, m):
            if A[i][c] != 0:
                pr = i
                break
        if pr is None:
            continue
        A[r], A[pr] = A[pr], A[r]
        pv = A[r][c]
        A[r] = [x / pv for x in A[r]]
        ops += ncols
        for i in range(m):
            if i != r and A[i][c] != 0:
                f = A[i][c]
                Ai, Ar = A[i], A[r]
                A[i] = [a - f * bb for a, bb in zip(Ai, Ar)]
                ops += ncols
        piv.append(c)
        r += 1
        if r == m:
            break
    pivset = set(piv)
    free = [j for j in range(ncols) if j not in pivset]
    basis = []
    for fc in free:
        v = [Fraction(0)] * ncols
        v[fc] = Fraction(1)
        for k, pc in enumerate(piv):
            v[pc] = -A[k][fc]
        assert_Mv_zero(rows, v, label)
        basis.append(v)
    t1 = time.perf_counter()
    return {"basis": basis, "rank": len(piv), "dim": len(basis),
            "time": t1 - t0, "ops": ops, "label": label}


# ---------------------------------------------------------------------------
# ROUTE 3: SPARSE exact Gauss-Jordan over QQ on dictionaries
# ---------------------------------------------------------------------------


def kernel_sparse_Q(rows, label="SQ"):
    # BUG CAUGHT HERE: the first version seeded the dictionaries with python
    # `int`s, so the very first `v / pv` was int/int -> FLOAT, and every
    # subsequent elimination step ran in floating point.  It still "worked" in
    # the sense of returning a dimension, and it still produced vectors that
    # were correct only because M*v happened to round to 0 -- i.e. it was
    # silently inexact.  Seed with Fraction so the whole route is exact over Q.
    rd = [dict((j, Fraction(int(x))) for j, x in enumerate(r) if x) for r in rows]
    m, ncols = len(rows), len(rows[0])
    t0 = time.perf_counter()
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
    pivset = set(piv)
    free = [j for j in range(ncols) if j not in pivset]
    basis = []
    for fc in free:
        v = [Fraction(0)] * ncols
        v[fc] = Fraction(1)
        for k, pc in enumerate(piv):
            v[pc] = -R[k].get(fc, 0)
        assert_Mv_zero(rows, v, label)
        basis.append(v)
    t1 = time.perf_counter()
    return {"basis": basis, "rank": len(piv), "dim": len(basis),
            "time": t1 - t0, "ops": ops, "fill": fill, "label": label}


# ---------------------------------------------------------------------------
# ROUTE 4: NFS-STYLE SPARSE REDUCTION -- sparse elimination over F_p
# ---------------------------------------------------------------------------
# This is the analogue of what NFS actually does: a sparse system solved modulo
# a small prime (GF(2) for sign propagation, Z/2^k for the dual-number trick),
# never over Q.  It is the honest "what NFS's linear algebra costs" baseline.
# NOTE: its output is a kernel over F_p, NOT over Q, so it is not by itself a
# drop-in for Algorithm 2.2 step 12.  That caveat is part of the answer.


def _inv(a, p):
    return pow(int(a) % p, p - 2, p)


def kernel_sparse_modp(rows, p=2, label="Smod"):
    """Sparse Gauss-Jordan over F_p on dictionaries.

    p=2 reproduces the NFS sign/positivity reduction exactly (it is the mod-2
    case).  p large is a 'how fast could sparse possibly be' bound.
    """
    ncols = len(rows[0])
    t0 = time.perf_counter()
    R = [dict((j, int(x) % p) for j, x in enumerate(r) if x % p) for r in rows]
    m = len(R)
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
        if p == 2:
            Rr = dict(R[r])
        else:
            ipv = _inv(pv, p)
            Rr = {j: (v * ipv) % p for j, v in R[r].items()}
        R[r] = Rr
        ops += len(Rr)
        for i in range(m):
            if i != r:
                f = R[i].get(c, 0)
                if f != 0:
                    Ri = R[i]
                    for j, v in Rr.items():
                        nv = (Ri.get(j, 0) - f * v) % p
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
    pivset = set(piv)
    free = [j for j in range(ncols) if j not in pivset]
    basis = []
    for fc in free:
        v = [0] * ncols
        v[fc] = 1
        for k, pc in enumerate(piv):
            v[pc] = (-R[k].get(fc, 0)) % p
        assert_Mv_zero_mod(rows, v, p, label)
        basis.append(v)
    t1 = time.perf_counter()
    return {"basis": basis, "rank": len(piv), "dim": len(basis),
            "time": t1 - t0, "ops": ops, "fill": fill, "label": label,
            "field": f"F_{p}"}


# ---------------------------------------------------------------------------
# ROUTE 5: BLACK-BOX / Wiedemann-family sparse matvec route
# ---------------------------------------------------------------------------
# T = M^T M (ncols x ncols, symmetric PSD) has ker(T) = ker(M) over Q and,
# for p not dividing the relevant minors, the same relation mod p.  A Krylov
# dependence among T v, T^2 v, ... , T^{b+1} v yields a vector in ker(T):
#   sum_j lam_j T^j v = 0  =>  w = sum_j lam_j T^j v  and  M w = 0.
# Cost: (b+1) T-applies = 2(b+1) sparse matvecs = Theta(b * nnz) = Theta(b^2).

PRIMES = [1000003, 1000033, 1000037, 1000039, 1000081, 1000099]


def _spmv_rows(rows, v, p):
    """M v over F_p, sparse, counting touched nonzeros."""
    out = []
    ops = 0
    for r in rows:
        s = 0
        for j, x in enumerate(r):
            if x:
                s = (s + (int(x) % p) * v[j]) % p
                ops += 1
        out.append(s)
    return out, ops


def _spmv_rows_T(rows, v, p):
    """M^T v over F_p, sparse.  (M^T v)_j = sum_i M[i][j] v[i]."""
    ncols = len(rows[0])
    out = [0] * ncols
    ops = 0
    for i, r in enumerate(rows):
        vi = v[i] % p
        if vi == 0:
            continue
        for j, x in enumerate(r):
            if x:
                out[j] = (out[j] + (int(x) % p) * vi) % p
                ops += 1
    return out, ops


def blackbox_kernel(rows, p=None, tries=6, seed=4242, label="BB"):
    """Krylov / Wiedemann-family route.

    BUG CAUGHT HERE, and it is the exact trap r49exp/sparse records as its
    "attempt 2": my first version reconstructed w = sum_j lam_j T^j v from a
    dependence among T^1 v, ..., T^{m+1} v.  That is WRONG -- T^j v is not in
    ker(M), because M T = M M^T M != T M.  The dependence must be DIVIDED BY
    ONE POWER OF T: from sum_{j=1..L} lam_j T^j v = 0, set
        w = sum_{j=1..L} lam_j T^{j-1} v,
    which satisfies T w = 0, hence M w = 0.  The exact mod-p assertion caught
    it: every candidate was rejected and the route returned None.  A rank or
    dimension check would have reported success.
    """
    ncols = len(rows[0])
    m = len(rows)
    rd = [dict((j, int(x)) for j, x in enumerate(r) if x) for r in rows]
    t0 = time.perf_counter()
    tot_ops = 0
    for pr in (PRIMES if p is None else [p]):
        r = random.Random(seed)
        v = [r.randrange(1, pr) for _ in range(ncols)]
        # power[j] = T^j v for j = 0..L.  The DEPENDENCE uses power[1..L];
        # the RECONSTRUCTION uses power[0..L-1] (the divided-out power of T).
        power = [v]
        cur = v
        for _ in range(m + 1):
            t1, o1 = _spmv_dict(rd, cur, pr)       # M cur
            t2, o2 = _spmv_dict_T(rd, t1, pr, ncols)   # M^T (M cur) = T cur
            tot_ops += o1 + o2
            power.append(t2)
            cur = t2
            if all(x == 0 for x in cur):
                break
        L = len(power) - 1
        if L < 1:
            continue
        # dependence: sum_{j=1..L} lam_j T^j v = 0, i.e. A lambda = 0 with
        # A[i][j-1] = (T^j v)_i  (an ncols x L matrix)
        A = [[power[j][i] % pr for j in range(1, L + 1)] for i in range(ncols)]
        Lam = _dense_null_vec_modp(A, pr)
        if Lam is None:
            continue
        # divide out ONE power of T: w = sum_{j=1..L} lam_j T^{j-1} v, so T w = 0
        w = [0] * ncols
        for jj, lj in enumerate(Lam):
            if lj:
                pj = power[jj]
                for i in range(ncols):
                    w[i] = (w[i] + lj * pj[i]) % pr
        # ⚠️ The zero vector PASSES assert_Mv_zero_mod -- it is trivially in
        # every kernel.  An undivided reconstruction returns exactly the
        # dependence equation, i.e. identically zero, and would therefore sail
        # through a membership test.  The nonzero test is what makes this route
        # correct, so it is checked explicitly on every candidate.
        if all(x == 0 for x in w):
            continue
        assert_Mv_zero_mod(rows, w, pr, label)
        t1 = time.perf_counter()
        return {"basis": [w], "rank": None, "dim": 1, "time": t1 - t0,
                "ops": tot_ops, "label": label, "field": f"F_{pr}"}
    return None


def _spmv_dict(rd, v, p):
    """M v over F_p from dictionaries, counting touched nonzeros."""
    out = [0] * len(rd)
    ops = 0
    for i, r in enumerate(rd):
        s = 0
        for j, x in r.items():
            s = (s + (x % p) * v[j]) % p
            ops += 1
        out[i] = s
    return out, ops


def _spmv_dict_T(rd, v, p, ncols):
    """M^T v over F_p from dictionaries: (M^T v)_j = sum_i M[i][j] v[i].

    ncols is passed explicitly: it is NOT len(rd[0]), which is row 0's NONZERO
    count and is far smaller (that mistake raised IndexError immediately).
    """
    out = [0] * ncols
    ops = 0
    for i, r in enumerate(rd):
        vi = v[i] % p
        if vi == 0:
            continue
        for j, x in r.items():
            out[j] = (out[j] + (x % p) * vi) % p
            ops += 1
    return out, ops


def _dense_null_vec_modp(A, pr):
    """Return one nonzero vector in the right kernel of A over F_pr, or None."""
    m = len(A)
    n = len(A[0])
    M = [row[:] for row in A]
    piv = []
    r = 0
    for c in range(n):
        pr_ = None
        for i in range(r, m):
            if M[i][c] % pr:
                pr_ = i
                break
        if pr_ is None:
            continue
        M[r], M[pr_] = M[pr_], M[r]
        ipv = _inv(M[r][c], pr)
        M[r] = [(x * ipv) % pr for x in M[r]]
        for i in range(m):
            if i != r and M[i][c] % pr:
                f = M[i][c]
                M[i] = [(a - f * bb) % pr for a, bb in zip(M[i], M[r])]
        piv.append(c)
        r += 1
        if r == m:
            break
    pivset = set(piv)
    free = [j for j in range(n) if j not in pivset]
    if not free:
        return None
    fc = free[0]
    v = [0] * n
    v[fc] = 1
    for k, pc in enumerate(piv):
        v[pc] = (-M[k][fc]) % pr
    return v


# ---------------------------------------------------------------------------
# 2-ADIC CONTROL: exact per-modulus p_split (never the 20/27 average)
# ---------------------------------------------------------------------------


def v2(x):
    r = 0
    while x % 2 == 0:
        x //= 2
        r += 1
    return r


def p_split(p, q):
    """EXACT P_g[ v2(ord_p g) != v2(ord_q g) ] for this specific modulus (p,q)."""
    mp_, mq_ = v2(p - 1), v2(q - 1)

    def dist(m):
        d = {0: 2.0 ** -m}
        for k in range(1, m + 1):
            d[k] = 2.0 ** (k - 1 - m)
        return d

    a, b = dist(mp_), dist(mq_)
    same = sum(a[k] * b.get(k, 0.0) for k in a)
    return 1.0 - same, mp_, mq_


# ---------------------------------------------------------------------------
# exact Psi  (used for the Pr[2|r] mechanism check; NO Dickman, NO rho)
# ---------------------------------------------------------------------------


def psi_exact(x, B, primes=None):
    """Count B-smooth integers in [1, x] by exact enumeration.

    Enumerates over the FULL prime set <= B.  stange.factor_base() DROPS primes
    dividing n, which removes 2 for even n and returns Pr[2|r] = 0.0000 -- a
    clean, confident, completely wrong number that r49exp/sparse recorded.  We
    therefore never route this through factor_base.
    """
    if primes is None:
        primes = [q for q in stange.primerange(2, B + 1)]
    vals = [1]
    for q in primes:
        nv = []
        for v in vals:
            w = v
            while w <= x:
                nv.append(w)
                w *= q
        vals = nv
    return len(vals)


if __name__ == "__main__":
    rng = random.Random(7)
    n, p, q = stange.gen_semiprime(30, rng)
    g = rand_g(n, rng)
    rels, _ = make_relations(n, g, 26, 1, rng, "seq")
    M = build_M(rels, 26)
    st = incidence(M)
    print("n bits", n.bit_length(), "nnz", st["nnz"], "density %.4f" % st["density"],
          "maxrow", st["max_rowdeg"], "maxcol", st["max_coldeg"],
          "defect", st["defect"], "defect/ncols %.3f" % st["defect_frac"])
    d0, dl = defect_under_permutations(M, 5, rng)
    print("defect invariant under 5 row+col permutations:", dl)
    for name, fn in [("DM", kernel_dense_DM), ("F", kernel_dense_F),
                     ("SQ", kernel_sparse_Q)]:
        r = fn(M)
        print(f"  {name}: dim={r['dim']} rank={r['rank']} t={r['time']*1e3:.2f}ms")
    r = kernel_sparse_modp(M, 2)
    print(f"  Smod(F2): dim={r['dim']} t={r['time']*1e3:.2f}ms fill={r['fill']}")
    bb = blackbox_kernel(M)
    print("  BB:", None if bb is None else f"dim={bb['dim']} t={bb['time']*1e3:.2f}ms")
