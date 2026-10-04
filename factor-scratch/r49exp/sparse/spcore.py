"""
spcore -- SPARSITY / DEFECT analysis and sparse linear-algebra routes for
Stange's Q-kernel method (arXiv:2211.06821, Algorithm 2.2, step 11).

Round 49 agent MM.  Everything additive; the validated relation-finding and
factoring primitives are IMPORTED from the read-only r48 implementation, never
re-implemented, so the defects its self-test caught cannot come back:

    /home/raver1975/lean/factor-scratch/r48/exp/stange/stange.py
        factor_base, fb_exponents, find_relations, build_M, primitive,
        kernel_basis, factor_from_multiple, gen_semiprime, bbound_for_b

r48/_shared/dickman.py is NOT used (broken above u = 5; see
notes/LL_dickman_harness_broken.md).  Smoothness here is always EXACT trial
division by the factor base, which is the definition of FB-smoothness.

==============================================================================
THE MATRIX
==============================================================================
M is b x (b+c); COLUMN j is the exponent vector of relation j:

    M[i][j] = v_{p_i}( r_j ),   r_j = g^{x_j} mod n,  r_j = prod_i p_i^{M[i][j]}.

So the nonzeros of column j are exactly the DISTINCT primes dividing a
uniformly random B-smooth integer r <= n.  Write  omega = #{i : M[i][j] != 0}.

==============================================================================
THE STRUCTURAL FACT THAT DECIDES THE AXIS (exact, not an estimate)
==============================================================================
ROW i is nonzero in column j iff p_i | r_j.  Relations are drawn with x
uniform in [1,n), so r_j is uniform over the B-smooth integers in [1,n].
THEREFORE EXACTLY:

    Pr[ row i nonzero ]  =  # {B-smooth r <= n : p_i | r} / #{B-smooth r <= n}
                          =  Psi(n/p_i, B) / Psi(n, B)                    (*)

because r is B-smooth and p_i | r  <=>  r = p_i * s with s B-smooth, s <= n/p_i.

  (a) COLUMN nnz = E[omega] = Theta(1) (small-prime events are nearly
      independent for a random smooth number).  nnz(M) = Theta(b) in a b x b
      matrix: density Theta(1/b).
  (b) ROW nnz for p = 2 is Psi(n/2,B)/Psi(n,B) = Theta(1) (measured 0.40-0.55
      in the working regime; exactly 1/2 as B -> infinity at fixed n, because
      then Psi(n,B) = n).

  => max_i rowdeg_i = Theta(b).

  THE PERMUTATION-SIMILARITY DEFECT IS TRIVIALLY INVARIANT HERE.  Permuting
  COLUMNS permutes the entries inside each row, so each row's nnz count -- and
  the multiset of row degrees, and its maximum -- is unchanged.  Symmetrically
  for rows/columns.  Hence for EVERY sigma, tau:

        defect(sigma A tau) = defect(A) = max(max_i rowdeg_i, max_j coldeg_j)

  No permutation lowers it; the minimum over (sigma,tau) is attained at the
  identity.  `defect_is_permutation_invariant()` verifies this numerically on
  real Stange matrices anyway (an assertion nobody ran is not a result).

  THIS IS WHERE THE NFS ANALOGY DIES.  NFS's sparse O(n^2) linear algebra rests
  on the NFS relation matrix having, after Montgomery's "minimal candidate
  selection" reorder, O(log n / log B) nonzeros PER ROW -- a bounded defect.
  Stange's matrix has defect Theta(b) for a structural reason no reordering
  touches: the row for p = 2 is dense because a constant fraction of all
  B-smooth numbers are even.

==============================================================================
MANDATORY CORRECTNESS CONTRACT
==============================================================================
Round 48 wrote an exact null space twice and BOTH versions returned the right
rank and the WRONG vectors.  So `assert_kernel` checks, in EXACT rational
arithmetic:

  (1) M v = 0 elementwise, exactly, for every returned vector;
  (2) the returned vectors are linearly independent over Q (exact Fraction rref
      of the matrix whose ROWS are the vectors -- not a floating rank);
  (3) len(basis) == ncols - rank  (reported, but on its own NOT sufficient).

The self-test additionally hands `assert_kernel` a DELIBERATELY BROKEN basis
and requires it to FAIL: an assertion that cannot reject the broken case
certifies nothing about the good one.
"""

from __future__ import annotations

import math
import random
import time
from fractions import Fraction
from math import gcd

R48 = "/home/raver1975/lean/factor-scratch/r48/exp/stange"
import sys  # noqa: E402

if R48 not in sys.path:
    sys.path.insert(0, R48)

from stange import (  # noqa: E402  -- READ-ONLY, validated by r48's self-test
    bbound_for_b,
    build_M,
    factor_base,
    factor_from_multiple,
    fb_exponents,
    find_relations,
    gen_semiprime,
    kernel_basis,
    primitive,
)


# ---------------------------------------------------------------------------
# tiny helpers
# ---------------------------------------------------------------------------

def rand_g(n: int, rng) -> int:
    g = rng.randrange(2, n)
    while gcd(g, n) != 1:
        g = rng.randrange(2, n)
    return g


# ===========================================================================
# T1.  SPARSITY AND DEFECT
# ===========================================================================

def cols_from_rels(rels):
    """Sparse columns of M: [(i, e), ...] with e != 0, for each relation.

    O(nnz) to build -- never materialises the b x (b+c) dense list.
    """
    out = []
    for exps, _x in rels:
        col = [(i, e) for i, e in enumerate(exps) if e]
        out.append(col)
    return out


def incidence_stats(cols, b):
    """Everything T1 asks for, in one O(nnz) pass.

    density            = nnz / (b * ncols)
    maxrowdeg          = max over rows of nnz  <-- the permutation defect
    maxcoldeg          = max over cols of nnz  <-- the other half of the defect
    heavy_rows         = #{i : rowdeg_i >= 0.05 * ncols}   ("dense" rows)
    active_rows        = #{i : rowdeg_i >= 1}
    top_rows           = [(prime_index i, rowdeg_i)] for the 12 heaviest rows
    """
    ncols = len(cols)
    rowdeg = [0] * b
    coldeg = []
    for col in cols:
        coldeg.append(len(col))
        for i, _e in col:
            rowdeg[i] += 1
    nnz = sum(coldeg)
    order = sorted(range(b), key=lambda i: -rowdeg[i])
    heavy = sum(1 for d in rowdeg if d >= 0.05 * ncols)
    return {
        "b": b,
        "ncols": ncols,
        "nnz": nnz,
        "density": nnz / (b * ncols) if ncols else 0.0,
        "nnz_per_col_mean": nnz / ncols if ncols else 0.0,
        "coldeg_max": max(coldeg) if coldeg else 0,
        "coldeg_mean": nnz / ncols if ncols else 0.0,
        "rowdeg_max": max(rowdeg) if rowdeg else 0,
        "rowdeg_max_frac": (max(rowdeg) / ncols) if ncols and rowdeg else 0.0,
        "active_rows": sum(1 for d in rowdeg if d),
        "heavy_rows": heavy,
        "top_rows": [(i, rowdeg[i]) for i in order[:12]],
        "rowdeg": rowdeg,
        "coldeg": coldeg,
    }


def defect_of(rowdeg, coldeg):
    """Permutation-similarity defect.  See the module docstring: this is
    INVARIANT, so the min over (sigma, tau) equals the value at the identity."""
    return max(max(rowdeg) if rowdeg else 0, max(coldeg) if coldeg else 0)


def defect_is_permutation_invariant(cols, b, trials=6, rng=None):
    """Empirical check of the invariance claim on a REAL Stange matrix.

    Returns (all_equal, list_of_defect_values).  Feeds random row and column
    permutations; every value must be identical.
    """
    rng = rng or random.Random(0)
    st = incidence_stats(cols, b)
    base = defect_of(st["rowdeg"], st["coldeg"])
    vals = [base]
    for _ in range(trials):
        rp = list(range(b))
        cp = list(range(len(cols)))
        rng.shuffle(rp)
        rng.shuffle(cp)
        rowdeg = [0] * b
        coldeg = []
        for j, col in enumerate(cols):
            coldeg.append(len(col))
            for i, _e in col:
                rowdeg[rp[i]] += 1
        vals.append(defect_of(rowdeg, coldeg))
    return all(v == base for v in vals), vals


def psi_ratio_2(n, B, FB=None):
    """Pr[ a uniformly random B-smooth r <= n is EVEN ] = Psi(n/2,B)/Psi(n,B),
    EXACTLY, by brute-force enumeration over [1, n] when n is small enough.

    This is formula (*) instantiated at p = 2, i.e. the exact density of the
    heaviest row.  Only usable for small n; that is why it is a CONTROL on the
    measured row degrees, not the production estimator.
    """
    FB = FB or factor_base(B, n)
    tot = 0
    even = 0
    for r in range(1, n + 1):
        _e, rem = fb_exponents(r, FB)
        if rem == 1:
            tot += 1
            if r % 2 == 0:
                even += 1
    return (even / tot if tot else None), tot


# ===========================================================================
# EXACT NULL-SPACE ROUTES
# ===========================================================================

def _frac_basis_exact(rows):
    """Exact RREF + nullspace of a rational matrix given as rows of Fractions.

    Returns (basis, rank, ops).  `ops` counts Fraction multiply/add operations
    so that the routes can be compared on work, not just wall clock.
    """
    m = len(rows)
    n = len(rows[0]) if m else 0
    A = [[Fraction(x) for x in r] for r in rows]
    ops = 0
    piv = []
    r = 0
    for c in range(n):
        if r >= m:
            break
        p = None
        for i in range(r, m):
            if A[i][c] != 0:
                p = i
                break
        if p is None:
            continue
        A[r], A[p] = A[p], A[r]
        pv = A[r][c]
        A[r] = [x / pv for x in A[r]]
        ops += n
        Ar = A[r]
        for i in range(m):
            if i == r:
                continue
            f = A[i][c]
            if f == 0:
                continue
            Ai = A[i]
            for j in range(c, n):
                Ai[j] -= f * Ar[j]
                ops += 1
            Ai[c] = Fraction(0)
        piv.append(c)
        r += 1
    pivset = set(piv)
    free = [j for j in range(n) if j not in pivset]
    basis = []
    for fc in free:
        x = [Fraction(0)] * n
        x[fc] = Fraction(1)
        for i in range(len(piv) - 1, -1, -1):
            pc = piv[i]
            s = Fraction(0)
            Ai = A[i]
            for j in range(n):
                if j != pc and Ai[j] and x[j]:
                    s += Ai[j] * x[j]
                    ops += 1
            x[pc] = -s
        basis.append(x)
    return basis, r, ops


def kernel_dense(rows):
    """Route DENSE-F: exact Fraction Gauss-Jordan on the dense b x (b+c) list.

    (Same method as r50/exp/bsweep/fastnull.py; re-implemented here rather than
    imported, so that this round does not silently depend on another agent's
    mutable file.  Cross-checked against sympy's kernel_basis in the self-test.)
    """
    return _frac_basis_exact(rows)


def kernel_sparse(cols, b, ncols=None):
    """Route SPARSE: exact Gauss-Jordan on a DICTIONARY representation.

    Only stored nonzeros are ever touched.  Returns
        (basis, rank, nnz_peak, ops)
    where nnz_peak is the maximum total nonzeros ever held in the working
    matrix -- i.e. the FILL-IN, measured directly rather than estimated.

    Cost = O(fill) Fraction operations.  If fill is Theta(b^2) the sparse route
    is a constant-factor win over dense O(b^3) and nothing more; that is the
    number this function exists to produce.
    """
    ncols = ncols if ncols is not None else len(cols)
    A = [dict() for _ in range(b)]          # A[row][col] = Fraction, never 0
    for j, col in enumerate(cols):
        for i, e in col:
            if e:
                A[i][j] = Fraction(e)
    nnz_now = sum(len(r) for r in A)
    nnz_peak = nnz_now
    ops = 0
    piv = []
    r = 0
    for c in range(ncols):
        if r >= b:
            break
        p = None
        for i in range(r, b):
            # `.get(c)` not `c in A[i]`: a stored ZERO must not count as a
            # pivot.  (Found by self-test ST2, which feeds matrices whose
            # "sparse" columns contain explicit zeros.)
            if A[i].get(c):
                p = i
                break
        if p is None:
            continue
        A[r], A[p] = A[p], A[r]
        pv = A[r][c]
        Ar = A[r]
        for j in list(Ar):
            Ar[j] = Ar[j] / pv
            ops += 1
        for i in range(b):
            if i == r:
                continue
            Ai = A[i]
            f = Ai.get(c)
            if not f:
                Ai.pop(c, None)
                continue
            for j, v in list(Ar.items()):
                if j == c:
                    continue
                nv = Ai.get(j)
                if nv is None:
                    w = -f * v
                    if w:
                        Ai[j] = w
                        nnz_now += 1
                else:
                    nv -= f * v
                    if nv == 0:
                        del Ai[j]
                        nnz_now -= 1
                    else:
                        Ai[j] = nv
                ops += 1
            del Ai[c]
            nnz_now -= 1
        nnz_peak = max(nnz_peak, nnz_now)
        piv.append(c)
        r += 1
    pivset = set(piv)
    free = [j for j in range(ncols) if j not in pivset]
    basis = []
    for fc in free:
        x = [Fraction(0)] * ncols
        x[fc] = Fraction(1)
        for i in range(len(piv) - 1, -1, -1):
            pc = piv[i]
            s = Fraction(0)
            Ai = A[i]
            for j, v in Ai.items():
                if j != pc and x[j]:
                    s += v * x[j]
                    ops += 1
            x[pc] = -s
        basis.append(x)
    nnz_peak = max(nnz_peak, sum(len(r) for r in A))
    return basis, r, nnz_peak, ops


# --- Route BLACKBOX: matvec cost, the inner loop of Wiedemann / Lanczos ----

def matvec(cols, b, v):
    """M v, computed from the SPARSE COLUMN representation in O(nnz).

    This is the ONLY primitive a black-box (Wiedemann/Lanczos) method needs.
    Its cost, multiplied by the O(b) matvecs the method performs, is the
    rigorous lower bound on every matrix-product route.
    """
    out = [0] * b
    for j, col in enumerate(cols):
        vj = v[j]
        if vj:
            for i, e in col:
                out[i] += e * vj
    return out


def matvec_ops(cols, b):
    """Exact operation count of one sparse matvec on THIS matrix shape."""
    return sum(len(col) for col in cols)


# --- Route MODP-WIEDEMANN: a real black-box kernel vector over Z/p ---------

_WP_PRIMES = [
    1000000007, 1000000009, 998244353, 1004535809, 469762049,
    985661441, 943718401, 935329793, 918552577, 897581057,
]


def _berlekamp_massey(s, p):
    """Minimal polynomial of a sequence over Z/p, coefficients low->high."""
    C = [1]
    B = [1]
    L = 0
    m = 1
    b = 1
    for n in range(len(s)):
        d = s[n]
        for i in range(1, L + 1):
            d = (d + C[i] * s[n - i]) % p
        if d == 0:
            m += 1
            continue
        T = list(C)
        coef = d * pow(b, p - 2, p) % p
        if len(C) < len(B) + m:
            C = C + [0] * (len(B) + m - len(C))
        for i in range(len(B)):
            C[i + m] = (C[i + m] - coef * B[i]) % p
        if 2 * L <= n:
            L = n + 1 - L
            B = T
            b = d
            m = 1
        else:
            m += 1
    return C[: L + 1]


def wiedemann_nullvec(cols, b, p=None, rng=None, tries=4):
    """BLACK-BOX (matrix-product) nonzero kernel vector of M over Z/p.

    Four attempts, three structurally wrong.  Recorded because each failure
    mode is a standard trap and because the version that works is much simpler
    than the ones that failed.

      (1) C = [[0, M],[0,0]] of size 2b+c.  0/6.  C(u;v) = (M v; 0), so
          C^2 = 0: C is NILPOTENT OF INDEX 2, its minimal polynomial is x^2,
          and no Berlekamp-Massey run can ever reach degree 2b+c.  ST8c pins
          this property so the trap cannot be re-entered.

      (2) Berlekamp-Massey on s_k = u^T T^k v for T = S S^T.  BM itself is
          correct (unit-tested on Fibonacci and on 3^k, both exact), but the
          RECOVERED VECTOR was wrong: BM returns the minimal polynomial of the
          SEQUENCE, and the operator identity sum_i C[i] T^i = 0 that would
          license reading off a kernel vector does not hold for a
          non-cyclic matrix.  Measured at b=10: deg 12 against matrix size 21,
          and both candidate shifts gave T w != 0.

      (3) An incremental sparse elimination hunting the first Krylov
          dependence.  It reported "no dependence" among 13 Krylov vectors in
          an 11-dimensional space, where one must exist: a bug in MY
          elimination, not in the mathematics.

      (4) THIS VERSION.  Drop Berlekamp-Massey and the clever bookkeeping.
          Build the Krylov matrix explicitly and run ordinary Gaussian
          elimination mod p on it.  Same O(b^2) asymptotics, obviously correct.

    METHOD.  Take the first N = b+1 columns c_0..c_b of M.  They are b+1
    vectors in Q^b, so they are linearly dependent.  Let S be the N x b matrix
    whose ROWS are those columns and put T = S S^T, an N x N matrix.  Then

        ker T = ker S^T = { dependencies among the chosen columns }.

    T is never formed.  One application: u = sum_t x_t c_t (one sparse matvec,
    O(nnz)), then (T x)_t = <u, c_t>.  N applications cost O(b * nnz).

    With a random v, form the Krylov matrix

        K = [ T v , T^2 v , ... , T^{N} v ]        (N columns, each length N)

    and find cvec with K cvec = 0 by mod-p Gaussian elimination.  Because
    T^i v = T (T^{i-1} v), the relation reads

        sum_{i>=1} cvec_i T^i v  =  T ( sum_{i>=1} cvec_i T^{i-1} v ) = 0,

    so w := sum_{i>=1} cvec_i T^{i-1} v is a KERNEL vector of T.  This is why
    the Krylov vectors START AT T v: starting at v gives a relation with a
    free constant term, and dividing out that power of T is precisely the step
    attempt (2) got wrong.

    w is VERIFIED entry by entry as M w = 0 mod p before it is returned, so
    this function cannot return a wrong vector -- at worst it returns None.

    COST: N = b+1 sparse double-matvecs = Theta(b * nnz) = Theta(b^2)
    modular operations, plus one O(N^2) mod-p elimination.  Genuinely
    Theta(b^2), not Theta(b^3).
    """
    ncols = len(cols)
    rng = rng or random.Random(1)
    p = p or _WP_PRIMES[rng.randrange(len(_WP_PRIMES))]
    N = b + 1
    if ncols < N:
        return None, {"error": "need b+1 columns", "ncols": ncols, "b": b}
    sub = cols[:N]                   # the b+1 chosen columns, each length b

    def Tmul(x):
        u = [0] * b
        for t, col in enumerate(sub):
            xt = x[t]
            if xt:
                for i, e in col:
                    u[i] += e * xt
        return [sum(e * u[i] for i, e in col) % p for col in sub]

    def verify(full):
        acc = [0] * b
        for j, col in enumerate(cols):
            wj = full[j]
            if wj:
                for i, e in col:
                    acc[i] = (acc[i] + e * wj) % p
        return all(x == 0 for x in acc)

    last = {"p": p, "N": N, "matvec_nnz": matvec_ops(cols, b)}
    for attempt in range(tries):
        v = [rng.randrange(p) for _ in range(N)]
        K = []                        # Krylov columns, STARTING AT T v
        cur = v
        for _ in range(N):
            cur = Tmul(cur)
            K.append(list(cur))

        rows = [[K[j][i] % p for j in range(N)] for i in range(N)]
        piv = []
        r = 0
        for c in range(N):
            pr = next((i for i in range(r, N) if rows[i][c]), None)
            if pr is None:
                continue
            rows[r], rows[pr] = rows[pr], rows[r]
            inv = pow(rows[r][c], p - 2, p)
            rows[r] = [(x * inv) % p for x in rows[r]]
            for i in range(N):
                if i == r:
                    continue
                f = rows[i][c]
                if f:
                    rows[i] = [(x - f * y) % p for x, y in zip(rows[i], rows[r])]
            piv.append(c)
            r += 1
        free = [j for j in range(N) if j not in set(piv)]
        last.update({"attempt": attempt, "rank_K": r, "nfree": len(free)})
        if not free:
            continue                 # K invertible: retry with another v

        cvec = [0] * N
        cvec[free[0]] = 1
        for i in range(len(piv) - 1, -1, -1):
            pc = piv[i]
            s = 0
            for j in range(N):
                if j != pc and rows[i][j] and cvec[j]:
                    s += rows[i][j] * cvec[j]
            cvec[pc] = (-s) % p
        if not any(cvec):
            continue

        # w = sum_{i>=1} cvec_i T^{i-1} v
        prev = v                       # T^0 v
        w = [0] * N
        for i in range(N):
            if cvec[i]:
                for t in range(N):
                    w[t] = (w[t] + cvec[i] * prev[t]) % p
            prev = Tmul(prev)
        full = [0] * ncols
        for t in range(N):
            if w[t]:
                full[t] = w[t]
        if any(full) and verify(full):
            last.update({"matvecs": N,
                         "total_ops": N * matvec_ops(cols, b),
                         "verified": True})
            return full, last
    last["verified"] = False
    return None, last
# ===========================================================================
# EXACT VERIFICATION -- the mandatory contract
# ===========================================================================

def assert_kernel(cols, b, basis, label=""):
    """Assert M v = 0 EXACTLY for every v, plus exact independence.

    Returns True or raises AssertionError with a diagnostic.  Callers must not
    swallow the exception: the whole point is that a wrong vector is a
    catastrophe, not a rounding detail.
    """
    ncols = len(cols)
    # (1) M v = 0 exactly, evaluated with integer arithmetic (all entries and
    #     the vector are rationals; we use Fractions to be type-agnostic).
    for vi, v in enumerate(basis):
        if len(v) != ncols:
            raise AssertionError(
                f"{label}: kernel vector {vi} has length {len(v)}, expected {ncols}")
        acc = [Fraction(0)] * b
        for j, col in enumerate(cols):
            vj = Fraction(v[j])
            if vj == 0:
                continue
            for i, e in col:
                acc[i] += e * vj
        for i, a in enumerate(acc):
            if a != 0:
                raise AssertionError(
                    f"{label}: M v != 0 for vector {vi} at row {i}: {a}")
    # (2) exact linear independence (Fraction rref, no floats anywhere)
    if basis:
        rowsT = [[Fraction(v[j]) for v in basis] for j in range(ncols)]
        _b, r, _ops = _frac_basis_exact(rowsT)
        if r != len(basis):
            raise AssertionError(
                f"{label}: returned {len(basis)} vectors but they span only {r}")
    return True


def assert_kernel_dense(Mrows, basis, label=""):
    """Same contract, dense form, for the routes that take a dense matrix."""
    b = len(Mrows)
    ncols = len(Mrows[0]) if b else 0
    for vi, v in enumerate(basis):
        if len(v) != ncols:
            raise AssertionError(f"{label}: vector {vi} length {len(v)} != {ncols}")
        for i, row in enumerate(Mrows):
            s = sum(Fraction(int(row[j])) * Fraction(v[j]) for j in range(ncols))
            if s != 0:
                raise AssertionError(f"{label}: M v != 0 at ({i}, vec {vi}): {s}")
    if basis:
        rowsT = [[Fraction(v[j]) for v in basis] for j in range(ncols)]
        _b, r, _o = _frac_basis_exact(rowsT)
        if r != len(basis):
            raise AssertionError(f"{label}: span rank {r} != {len(basis)}")
    return True


# ===========================================================================
# relation-set generation (thin wrapper; the finder itself is r48's)
# ===========================================================================

def make_rels(n, g, b, c, rng, cap=8_000_000):
    BB = bbound_for_b(b)
    FB = factor_base(BB, n)
    if len(FB) != b:
        raise RuntimeError(f"factor base size {len(FB)} != b {b}")
    rels, trials = find_relations(n, g, FB, b + c, rng, "random", cap)
    return rels, FB, BB, trials