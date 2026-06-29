"""
Numerical demonstrations for:

    "A Number-Theory x Holonomy Bridge: The Non-Existence of a Linear
     Recurrence for the Coefficients of Ramanujan's Third Order Mock
     Theta Function f(q)"

We numerically reproduce, with exact rational arithmetic (no floating point),
the four facts established formally:

  1. The genuine coefficients of
         f(q) = sum_{n>=0} q^{n^2} / prod_{k=1}^n (1+q^k)^2
     are integers, beginning 1, 1, -2, 3, -3, 3, ...  (OEIS A000025).
     In particular (a0, a1, a2) = (1, 1, -2), NOT the claimed (1, 0, 1).

  2. The claimed recurrence
         (n+3) a_{n+3} = (3n+4) a_{n+2} - (3n+1) a_{n+1} + n a_n
     run forward from the claimed initials (1, 0, 1) produces
         a3 = 4/3, a4 = 4/3, a5 = 6/5, ...  (non-integers).

  3. Hence NO integer sequence satisfies the claim: the n=0 instance
     forces 3 a3 = 4, which has no integer solution.

  4. An exact linear-algebra search finds NO nonzero polynomial recurrence
     of order <= 5 and degree <= 5 fitting the true coefficients,
     consistent with the non-holonomy of mock theta functions.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from typing import List


# ---------------------------------------------------------------------------
# 1. Genuine coefficients of f(q) by formal power-series division.
# ---------------------------------------------------------------------------
def _poly_mul(a: List[Fraction], b: List[Fraction], N: int) -> List[Fraction]:
    """Multiply two truncated power series mod q^N."""
    r: List[Fraction] = [Fraction(0)] * N
    for i, ai in enumerate(a):
        if ai == 0:
            continue
        for j, bj in enumerate(b):
            if i + j < N and bj != 0:
                r[i + j] += ai * bj
    return r


def _poly_inv(a: List[Fraction], N: int) -> List[Fraction]:
    """Reciprocal of a power series with nonzero constant term, mod q^N."""
    assert a[0] != 0, "series must have invertible constant term"
    r: List[Fraction] = [Fraction(0)] * N
    r[0] = 1 / a[0]
    for n in range(1, N):
        s = Fraction(0)
        for k in range(1, n + 1):
            ak = a[k] if k < len(a) else Fraction(0)
            s += ak * r[n - k]
        r[n] = -s / a[0]
    return r


def f_coefficients(N: int) -> List[int]:
    """Return [a_0, ..., a_{N-1}] for f(q) = sum_n q^{n^2}/prod(1+q^k)^2."""
    f: List[Fraction] = [Fraction(0)] * N
    n = 0
    while n * n < N:
        term: List[Fraction] = [Fraction(0)] * N
        term[n * n] = Fraction(1)
        # denominator = prod_{k=1}^n (1+q^k)^2
        denom: List[Fraction] = [Fraction(0)] * N
        denom[0] = Fraction(1)
        for k in range(1, n + 1):
            factor: List[Fraction] = [Fraction(0)] * N
            factor[0] = Fraction(1)
            if k < N:
                factor[k] = Fraction(1)
            denom = _poly_mul(denom, factor, N)
            denom = _poly_mul(denom, factor, N)
        term = _poly_mul(term, _poly_inv(denom, N), N)
        f = [f[i] + term[i] for i in range(N)]
        n += 1
    # All coefficients are integers; verify and return as ints.
    out: List[int] = []
    for c in f:
        assert c.denominator == 1, f"non-integer coefficient {c}!"
        out.append(int(c))
    return out


# ---------------------------------------------------------------------------
# 2. The claimed recurrence forward from the claimed initials (1, 0, 1).
# ---------------------------------------------------------------------------
def claim_seq(N: int) -> List[Fraction]:
    """Forward iteration of the claimed recurrence over the rationals."""
    a: List[Fraction] = [Fraction(0)] * max(N, 3)
    a[0], a[1], a[2] = Fraction(1), Fraction(0), Fraction(1)
    for n in range(0, N - 3):
        a[n + 3] = (
            (3 * n + 4) * a[n + 2]
            - (3 * n + 1) * a[n + 1]
            + n * a[n]
        ) / (n + 3)
    return a[:N]


# ---------------------------------------------------------------------------
# 4. Exact search for a polynomial-coefficient recurrence.
# ---------------------------------------------------------------------------
def _rank_exact(rows: List[List[Fraction]]) -> int:
    """Rank of a rational matrix via fraction-free Gaussian elimination."""
    mat = [row[:] for row in rows]
    if not mat:
        return 0
    ncols = len(mat[0])
    rank = 0
    pivot_row = 0
    for col in range(ncols):
        piv = None
        for r in range(pivot_row, len(mat)):
            if mat[r][col] != 0:
                piv = r
                break
        if piv is None:
            continue
        mat[pivot_row], mat[piv] = mat[piv], mat[pivot_row]
        pv = mat[pivot_row][col]
        for r in range(len(mat)):
            if r != pivot_row and mat[r][col] != 0:
                f = mat[r][col] / pv
                mat[r] = [mat[r][c] - f * mat[pivot_row][c] for c in range(ncols)]
        rank += 1
        pivot_row += 1
        if pivot_row == len(mat):
            break
    return rank


def recurrence_exists(a: List[int], order: int, degree: int) -> bool:
    """
    Decide whether a nonzero recurrence  sum_i p_i(n) a_{n+i} = 0
    with deg p_i <= degree exists, using the available terms of `a`.
    Returns True iff a nontrivial solution exists (kernel nonempty).
    """
    nunknown = (order + 1) * (degree + 1)
    # Need more equations than unknowns to certify triviality.
    max_n = len(a) - order
    if max_n <= nunknown:
        raise ValueError("not enough terms to certify; supply more coefficients")
    rows: List[List[Fraction]] = []
    for n in range(max_n):
        row: List[Fraction] = []
        for i in range(order + 1):
            for j in range(degree + 1):
                row.append(Fraction(a[n + i]) * Fraction(n) ** j)
        rows.append(row)
    rank = _rank_exact(rows)
    return rank < nunknown


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------
def main() -> None:
    print("=" * 68)
    print("Ramanujan's third order mock theta f(q): a disproof, numerically")
    print("=" * 68)

    N = 20
    coeffs = f_coefficients(N)
    print("\n[1] Genuine coefficients a_0..a_19 of f(q) (OEIS A000025):")
    print("   ", coeffs)
    print(f"    (a0, a1, a2) = ({coeffs[0]}, {coeffs[1]}, {coeffs[2]})"
          "  -- claimed (1, 0, 1) is WRONG")
    assert (coeffs[0], coeffs[1], coeffs[2]) == (1, 1, -2)

    cs = claim_seq(9)
    print("\n[2] Claimed recurrence forward from claimed initials (1, 0, 1):")
    print("   ", [str(x) for x in cs])
    print(f"    a3 = {cs[3]}  (= 4/3, NOT an integer)")
    print(f"    a4 = {cs[4]}  (= 4/3)")
    print(f"    a5 = {cs[5]}  (= 6/5)")
    assert cs[3] == Fraction(4, 3) and cs[4] == Fraction(4, 3)

    print("\n[3] No integer sequence can satisfy the claim:")
    print("    n=0 instance:  3*a3 = 4*a2 - a1 = 4*1 - 0 = 4")
    print("    => a3 = 4/3, impossible for a3 in Z  (3 does not divide 4)")

    print("\n[4] Exact recurrence search on the true coefficients:")
    big = f_coefficients(80)
    any_found = False
    for r in range(1, 6):
        for d in range(0, 6):
            try:
                found = recurrence_exists(big, r, d)
            except ValueError:
                continue
            if found:
                any_found = True
                print(f"    order={r}, degree={d}: RECURRENCE FOUND (!)")
    if not any_found:
        print("    No nonzero polynomial recurrence of order<=5, degree<=5 exists.")
        print("    (Consistent with non-holonomy of mock theta functions.)")

    print("\nAll assertions passed.")


if __name__ == "__main__":
    main()
