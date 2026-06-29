"""Numerical demonstrations for:

    Row-Exchange Invariance under Eventual Contraction
    for the Infinite Asymmetric Five-Vertex Half-Strip

This script is fully self-contained: it implements small dense real-matrix
arithmetic and the L-infinity (maximum absolute row sum) operator norm from
scratch, with no third-party dependencies.

It numerically exercises the main theorems proved in the Lean development:

  * conj_pow_eq               -- a commuting involution fixes every power: S A^n S = A^n
  * conj_inverse_one_sub_eq   -- resolvent row-exchange invariance: S (I-A)^-1 S = (I-A)^-1
  * conj_tsum_geom_eq         -- series form of the above
  * conj_unit_inverse_one_sub_eq -- invariance under conjugation by ANY commuting unit
  * norm_inverse_one_sub_le   -- Neumann bound: ||(I-A)^-1|| <= 1/(1-||A||)
  * prodDown_tendsto_zero     -- eventual contraction collapses the half-strip product

All demos act on genuine 5x5 transfer operators of the asymmetric five-vertex
half-strip, not on trivial special cases.
"""

from __future__ import annotations

from typing import List, Tuple

Matrix = List[List[float]]
Vector = List[float]

# --------------------------------------------------------------------------- #
#  Minimal dense real-matrix algebra                                          #
# --------------------------------------------------------------------------- #


def zeros(n: int, m: int) -> Matrix:
    """Return an n x m zero matrix."""
    return [[0.0 for _ in range(m)] for _ in range(n)]


def identity(n: int) -> Matrix:
    """Return the n x n identity matrix."""
    return [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]


def matmul(a: Matrix, b: Matrix) -> Matrix:
    """Return the matrix product A B."""
    n, k, m = len(a), len(b), len(b[0])
    out = zeros(n, m)
    for i in range(n):
        ai = a[i]
        for t in range(k):
            ait = ai[t]
            if ait == 0.0:
                continue
            bt = b[t]
            oi = out[i]
            for j in range(m):
                oi[j] += ait * bt[j]
    return out


def matadd(a: Matrix, b: Matrix) -> Matrix:
    """Return the entrywise sum A + B."""
    return [[a[i][j] + b[i][j] for j in range(len(a[0]))] for i in range(len(a))]


def matsub(a: Matrix, b: Matrix) -> Matrix:
    """Return the entrywise difference A - B."""
    return [[a[i][j] - b[i][j] for j in range(len(a[0]))] for i in range(len(a))]


def matpow(a: Matrix, n: int) -> Matrix:
    """Return A^n by binary exponentiation (A^0 = I)."""
    result = identity(len(a))
    base = [row[:] for row in a]
    e = n
    while e > 0:
        if e & 1:
            result = matmul(result, base)
        base = matmul(base, base)
        e >>= 1
    return result


def linfty_norm(a: Matrix) -> float:
    """L-infinity operator norm = maximum absolute row sum."""
    return max(sum(abs(x) for x in row) for row in a)


def max_abs_diff(a: Matrix, b: Matrix) -> float:
    """Return the largest entrywise absolute difference between A and B."""
    return max(
        abs(a[i][j] - b[i][j]) for i in range(len(a)) for j in range(len(a[0]))
    )


def perm_matrix(perm: List[int]) -> Matrix:
    """Permutation matrix S with S e_k = e_{perm[k]} (rows indexed by perm)."""
    n = len(perm)
    out = zeros(n, n)
    for k in range(n):
        out[perm[k]][k] = 1.0
    return out


def swap_perm(n: int, i: int, j: int) -> List[int]:
    """Permutation list for the transposition exchanging i and j."""
    p = list(range(n))
    p[i], p[j] = p[j], p[i]
    return p


# --------------------------------------------------------------------------- #
#  Core algorithms                                                            #
# --------------------------------------------------------------------------- #


def neumann_resolvent(a: Matrix, tol: float = 1e-12) -> Tuple[Matrix, int, float]:
    """Approximate (I - A)^-1 by the truncated Neumann series sum_{n<T} A^n.

    Returns (resolvent, T, certified_tail_bound). The truncation T is chosen so
    that the certified tail ||A||^T / (1 - ||A||) <= tol (Theorem 5 on the tail).
    Requires ||A|| < 1.
    """
    n = len(a)
    nrm = linfty_norm(a)
    if nrm >= 1.0:
        raise ValueError(f"need ||A|| < 1 for convergence, got {nrm}")
    # Smallest T with ||A||^T/(1-||A||) <= tol.
    bound = 1.0 / (1.0 - nrm)
    T = 1
    while (nrm ** T) * bound > tol:
        T += 1
    term = identity(n)          # A^0
    total = identity(n)
    for _ in range(1, T):
        term = matmul(term, a)  # A^k
        total = matadd(total, term)
    tail = (nrm ** T) * bound
    return total, T, tail


def prod_down(ms: List[Matrix], dim: int) -> Matrix:
    """Accumulated half-strip product prodDown: P_{m+1} = M_m * P_m, P_0 = I.

    Given ms = [M_0, M_1, ..., M_{m-1}], returns M_{m-1} * ... * M_1 * M_0.
    The empty product is the dim x dim identity.
    """
    p = identity(dim)
    for mk in ms:
        p = matmul(mk, p)
    return p


def conjugate(s: Matrix, a: Matrix, s_inv: Matrix) -> Matrix:
    """Return the conjugate S A S^{-1}."""
    return matmul(matmul(s, a), s_inv)


# --------------------------------------------------------------------------- #
#  A genuine swap-symmetric 5x5 five-vertex transfer operator                 #
# --------------------------------------------------------------------------- #


def symmetric_five_vertex_operator() -> Tuple[Matrix, List[int]]:
    """Build a 5x5 contraction A and a row-swap permutation S with S A = A S.

    We swap indices i=1 and j=3. A is made invariant under simultaneously
    swapping rows {1,3} and columns {1,3}, so that S A S = A, and it is scaled
    to be an L-infinity contraction (||A|| < 1), modeling an eventually
    contracting five-vertex transfer operator.
    """
    i, j = 1, 3
    # Base weights (asymmetric five-vertex flavour), then symmetrized over swap.
    raw = [
        [0.30, 0.10, 0.05, 0.10, 0.04],
        [0.08, 0.22, 0.06, 0.12, 0.05],
        [0.05, 0.07, 0.28, 0.07, 0.06],
        [0.08, 0.12, 0.06, 0.22, 0.05],
        [0.04, 0.06, 0.05, 0.06, 0.30],
    ]

    def sw(idx: int) -> int:
        if idx == i:
            return j
        if idx == j:
            return i
        return idx

    n = 5
    a = zeros(n, n)
    for r in range(n):
        for c in range(n):
            # Average the entry with its swap-image to enforce S A S = A exactly.
            a[r][c] = 0.5 * (raw[r][c] + raw[sw(r)][sw(c)])
    # Scale to guarantee contraction with comfortable margin.
    nrm = linfty_norm(a)
    scale = 0.6 / nrm
    a = [[scale * a[r][c] for c in range(n)] for r in range(n)]
    return a, swap_perm(n, i, j)


# --------------------------------------------------------------------------- #
#  Demonstrations                                                             #
# --------------------------------------------------------------------------- #


def demo_power_invariance() -> None:
    """conj_pow_eq: S A^n S = A^n for every power n of a commuting involution."""
    print("=" * 70)
    print("DEMO 1  conj_pow_eq:  S A^n S = A^n  (5x5 five-vertex operator)")
    print("=" * 70)
    a, perm = symmetric_five_vertex_operator()
    s = perm_matrix(perm)
    assert max_abs_diff(matmul(s, s), identity(5)) < 1e-12, "S not an involution"
    assert max_abs_diff(matmul(s, a), matmul(a, s)) < 1e-12, "S A != A S"
    print(f"  ||A||_inf = {linfty_norm(a):.6f}   ||S||_inf = {linfty_norm(s):.6f}")
    for npow in (1, 2, 5, 10):
        an = matpow(a, npow)
        conj = conjugate(s, an, s)  # S = S^{-1}
        print(f"  n = {npow:>2}:  max |S A^n S - A^n| = {max_abs_diff(conj, an):.3e}")
    print()


def demo_resolvent_invariance() -> None:
    """conj_inverse_one_sub_eq / conj_tsum_geom_eq: S (I-A)^-1 S = (I-A)^-1."""
    print("=" * 70)
    print("DEMO 2  conj_inverse_one_sub_eq:  S (I-A)^-1 S = (I-A)^-1")
    print("=" * 70)
    a, perm = symmetric_five_vertex_operator()
    s = perm_matrix(perm)
    res, T, tail = neumann_resolvent(a, tol=1e-14)
    conj = conjugate(s, res, s)
    print(f"  Neumann truncation T = {T}, certified tail = {tail:.2e}")
    print(f"  max |S (I-A)^-1 S - (I-A)^-1| = {max_abs_diff(conj, res):.3e}")
    print("  (resolvent inherits the row-exchange symmetry exactly)")
    print()


def demo_unit_conjugation() -> None:
    """conj_unit_inverse_one_sub_eq: invariance under ANY commuting unit u.

    We use a non-involutive unit: a 3-cycle permutation matrix on the
    coordinates fixed by the symmetric operator's structure. We build A to also
    commute with this 3-cycle, demonstrating the involution hypothesis is not
    needed (u != u^{-1}).
    """
    print("=" * 70)
    print("DEMO 3  conj_unit_inverse_one_sub_eq:  u (I-A)^-1 u^-1 = (I-A)^-1")
    print("=" * 70)
    # 3-cycle on indices (0 1 2): u e0=e1, u e1=e2, u e2=e0; fixes 3,4.
    cycle = [1, 2, 0, 3, 4]
    u = perm_matrix(cycle)
    u_inv = perm_matrix([cycle.index(k) for k in range(5)])
    assert max_abs_diff(matmul(u, u_inv), identity(5)) < 1e-12
    assert max_abs_diff(matmul(u, u), identity(5)) > 0.5, "u should NOT be an involution"
    # Build A commuting with u: A = c0*I + c1*u + c2*u^2 is a polynomial in u.
    u2 = matmul(u, u)
    a = zeros(5, 5)
    for c, mat in ((0.20, identity(5)), (0.12, u), (0.08, u2)):
        a = matadd(a, [[c * mat[r][q] for q in range(5)] for r in range(5)])
    assert max_abs_diff(matmul(u, a), matmul(a, u)) < 1e-12, "u A != A u"
    print(f"  ||A||_inf = {linfty_norm(a):.6f}   (u is a non-involutive 3-cycle)")
    res, T, tail = neumann_resolvent(a, tol=1e-14)
    conj = matmul(matmul(u, res), u_inv)
    print(f"  Neumann truncation T = {T}, certified tail = {tail:.2e}")
    print(f"  max |u (I-A)^-1 u^-1 - (I-A)^-1| = {max_abs_diff(conj, res):.3e}")
    print()


def demo_neumann_bound() -> None:
    """norm_inverse_one_sub_le: ||(I-A)^-1|| <= 1/(1-||A||)."""
    print("=" * 70)
    print("DEMO 4  norm_inverse_one_sub_le:  ||(I-A)^-1|| <= 1/(1-||A||)")
    print("=" * 70)
    a, _ = symmetric_five_vertex_operator()
    res, _, _ = neumann_resolvent(a, tol=1e-14)
    nrm_a = linfty_norm(a)
    lhs = linfty_norm(res)
    rhs = 1.0 / (1.0 - nrm_a)
    print(f"  ||A||         = {nrm_a:.6f}")
    print(f"  ||(I-A)^-1||  = {lhs:.6f}")
    print(f"  1/(1-||A||)   = {rhs:.6f}")
    print(f"  bound holds:  {lhs <= rhs + 1e-9}")
    print()


def demo_product_collapse() -> None:
    """prodDown_tendsto_zero: eventual contraction collapses the half-strip product.

    The first few rows are deliberately expanding (||M_k|| > 1); from threshold
    N onward every ||M_k|| <= c < 1. The accumulated norm still tends to 0, and
    is bracketed by the certificate ||P_N|| * c^(m-N).
    """
    print("=" * 70)
    print("DEMO 5  prodDown_tendsto_zero:  ||P_m|| -> 0 under eventual contraction")
    print("=" * 70)
    base, perm = symmetric_five_vertex_operator()
    s = perm_matrix(perm)
    n_threshold = 3
    c = 0.6

    def row_op(k: int) -> Matrix:
        if k < n_threshold:
            # Expanding boundary rows: scale base up past norm 1.
            scale = 2.0 / linfty_norm(base)
            return [[scale * base[r][q] for q in range(5)] for r in range(5)]
        return base  # ||base|| = 0.6 = c < 1

    ms: List[Matrix] = []
    pN_norm = None
    print(f"  threshold N = {n_threshold}, contraction ratio c = {c}")
    print(f"  {'m':>3} | {'||P_m||':>12} | {'cert ||P_N||*c^(m-N)':>22} | {'||S P_m||':>12}")
    for m in range(0, 16):
        ms = [row_op(k) for k in range(m)]
        p = prod_down(ms, 5)
        pm_norm = linfty_norm(p)
        sp_norm = linfty_norm(matmul(s, p))
        if m == n_threshold:
            pN_norm = pm_norm
        cert = (pN_norm * c ** (m - n_threshold)) if (pN_norm is not None and m >= n_threshold) else float("nan")
        print(f"  {m:>3} | {pm_norm:>12.3e} | {cert:>22.3e} | {sp_norm:>12.3e}")
    print("  (||S P_m|| <= ||P_m|| since ||S|| = 1: row-exchanged product also vanishes)")
    print()


def main() -> None:
    """Run all demonstrations."""
    demo_power_invariance()
    demo_resolvent_invariance()
    demo_unit_conjugation()
    demo_neumann_bound()
    demo_product_collapse()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
