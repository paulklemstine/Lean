"""
Exact bond dimension of periodic combs — numerical demonstrations.
==================================================================

This self-contained script (standard library only) demonstrates every
quantitative claim of the accompanying paper:

  1.  Exact rank law:      rank(comb matrix) = min(P, r / gcd(r, Q))   for 0 < r <= Q.
  2.  Odd-part law:        on a binary cut the rank is min(2^a, odd part of r).
  3.  Product dichotomy:   the comb is a product state iff its period is a power of two.
  4.  Exponential barrier: period 2^a - 1 on 2a qubits forces bond dimension 2^a - 1.
  5.  Transform law:       for an exact comb (r | n) the transformed state has
                           rank min(P, m / gcd(m, Q)) with m = n / r.
  6.  Complementarity:     rank(in) * rank(out) <= P = n / Q in the exact case.
  7.  Explicit SVD:        the singular values of the comb matrix are sqrt(mu_c * nu_c),
                           giving Eckart-Young truncation errors in closed form.
  8.  Zero-count law:      for a *truncated* comb (r does not divide n, n = 2^L) the
                           transform vanishes at exactly gcd(n, J) - 1 frequencies,
                           where J is the number of teeth; full support holds iff J
                           is odd.  This corrects the naive "never vanishes" guess.
  9.  Exact transform rank: computed over a finite field carrying a genuine n-th root
                           of unity (no floating point), the transformed truncated
                           comb has rank min(P, J) — maximal for the balanced cut in
                           the regime relevant to order finding.

Run:  python3 demo.py
"""

from __future__ import annotations

import cmath
import math
from fractions import Fraction
from typing import Dict, List, Tuple

# ----------------------------------------------------------------------------
# Matrix construction
# ----------------------------------------------------------------------------


def comb_matrix(P: int, Q: int, r: int, x0: int) -> List[List[Fraction]]:
    """Reshape of the periodic comb sum_{x < P*Q, x = x0 (mod r)} |x> across the
    cut x = p*Q + q.  Entry is 1 on the comb's support, 0 elsewhere."""
    target = x0 % r
    return [
        [Fraction(1) if (p * Q + q) % r == target else Fraction(0) for q in range(Q)]
        for p in range(P)
    ]


def exact_rank(matrix: List[List[Fraction]]) -> int:
    """Rank over the rationals by exact Gaussian elimination (no floating point)."""
    rows = [row[:] for row in matrix]
    n_rows = len(rows)
    n_cols = len(rows[0]) if n_rows else 0
    rank = 0
    for col in range(n_cols):
        pivot = next((r_ for r_ in range(rank, n_rows) if rows[r_][col] != 0), None)
        if pivot is None:
            continue
        rows[rank], rows[pivot] = rows[pivot], rows[rank]
        inv = rows[rank][col]
        rows[rank] = [v / inv for v in rows[rank]]
        for r_ in range(n_rows):
            if r_ != rank and rows[r_][col] != 0:
                factor = rows[r_][col]
                rows[r_] = [a - factor * b for a, b in zip(rows[r_], rows[rank])]
        rank += 1
        if rank == n_rows:
            break
    return rank


def numeric_rank(matrix: List[List[complex]], tol: float = 1e-9) -> int:
    """Rank of a complex matrix by Gaussian elimination with partial pivoting."""
    rows = [row[:] for row in matrix]
    n_rows = len(rows)
    n_cols = len(rows[0]) if n_rows else 0
    scale = max((abs(v) for row in rows for v in row), default=0.0)
    if scale == 0.0:
        return 0
    threshold = tol * scale
    rank = 0
    for col in range(n_cols):
        pivot, best = -1, threshold
        for r_ in range(rank, n_rows):
            if abs(rows[r_][col]) > best:
                pivot, best = r_, abs(rows[r_][col])
        if pivot < 0:
            continue
        rows[rank], rows[pivot] = rows[pivot], rows[rank]
        piv = rows[rank][col]
        rows[rank] = [v / piv for v in rows[rank]]
        for r_ in range(n_rows):
            if r_ != rank:
                factor = rows[r_][col]
                if abs(factor) > 0.0:
                    rows[r_] = [a - factor * b for a, b in zip(rows[r_], rows[rank])]
        rank += 1
        if rank == n_rows:
            break
    return rank


# ----------------------------------------------------------------------------
# The closed-form predictions
# ----------------------------------------------------------------------------


def reduced_period(r: int, Q: int) -> int:
    """s(r, Q) = r / gcd(r, Q): the order of Q in the cyclic group Z/rZ."""
    return r // math.gcd(r, Q)


def predicted_rank(P: int, Q: int, r: int) -> int:
    """min(P, r / gcd(r, Q)) — the exact Schmidt rank when 0 < r <= Q."""
    return min(P, reduced_period(r, Q))


def odd_part(r: int) -> int:
    """The largest odd divisor of r."""
    while r % 2 == 0:
        r //= 2
    return r


# ----------------------------------------------------------------------------
# Demonstration 1: exhaustive verification of the exact rank law
# ----------------------------------------------------------------------------


def demo_exact_rank_law(limit: int = 12, offsets: int = 4) -> None:
    print("=" * 74)
    print("1.  Exact rank law:  rank = min(P, r/gcd(r,Q))   for 0 < r <= Q")
    print("=" * 74)
    tested = mismatches = 0
    for P in range(1, limit + 1):
        for Q in range(1, limit + 1):
            for r in range(1, Q + 1):
                for x0 in range(offsets):
                    got = exact_rank(comb_matrix(P, Q, r, x0))
                    want = predicted_rank(P, Q, r)
                    tested += 1
                    if got != want:
                        mismatches += 1
                        print(f"   MISMATCH P={P} Q={Q} r={r} x0={x0}: {got} != {want}")
    print(f"   matrices tested : {tested}")
    print(f"   mismatches      : {mismatches}")
    print("   the offset x0 never affects the rank.\n")


# ----------------------------------------------------------------------------
# Demonstration 2: the odd-part law and the product-state dichotomy
# ----------------------------------------------------------------------------


def demo_odd_part_law(a: int = 3, b: int = 3) -> None:
    P, Q = 2 ** a, 2 ** b
    print("=" * 74)
    print(f"2.  Odd-part law on the binary cut 2^{a} (x) 2^{b}")
    print("=" * 74)
    print("     r   2-part   odd part m   rank   min(2^a, m)   product state?")
    for r in range(1, Q + 1):
        m = odd_part(r)
        two_part = r // m
        rank = exact_rank(comb_matrix(P, Q, r, 0))
        print(
            f"   {r:3d}   {two_part:6d}   {m:10d}   {rank:4d}   {min(P, m):11d}"
            f"   {'yes' if rank == 1 else 'no':>14}"
        )
    print("   a comb is a product state exactly when its period is a power of two.\n")


# ----------------------------------------------------------------------------
# Demonstration 3: the exponential barrier at the balanced cut
# ----------------------------------------------------------------------------


def demo_exponential_barrier(max_a: int = 7) -> None:
    print("=" * 74)
    print("3.  Exponential barrier: period 2^a - 1 on L = 2a qubits, balanced cut")
    print("=" * 74)
    print("     a    L=2a    period r=2^a-1    minimal bond D    tensor-train memory ~ D^2")
    for a in range(1, max_a + 1):
        P = Q = 2 ** a
        r = P - 1
        D = predicted_rank(P, Q, r)
        if a <= 5:  # verify the closed form directly for the small cases
            assert D == exact_rank(comb_matrix(P, Q, r, 0)), "closed form failed"
        print(f"   {a:3d}   {2*a:5d}   {r:14d}   {D:14d}   {D*D:22d}")
    print("   D = 2^(L/2) - 1 : the 'compressed' form is as large as the state.\n")


# ----------------------------------------------------------------------------
# Demonstration 4: the exact comb, its Fourier transform, complementarity
# ----------------------------------------------------------------------------


def comb_dft(m: int, r: int, x0: int, k: int) -> complex:
    """Unnormalised DFT at frequency k of the exact comb sum_{j<m} |x0 + j r>
    inside a register of dimension n = m*r.  Computed as a literal sum."""
    n = m * r
    return sum(cmath.exp(2j * cmath.pi * ((x0 + j * r) * k % n) / n) for j in range(m))


def demo_transform_and_complementarity() -> None:
    print("=" * 74)
    print("4.  Transform law and complementarity (exact combs, r | n)")
    print("=" * 74)
    print("      n     r     m    P    Q   rank_in  rank_out  product   bound P")
    cases: List[Tuple[int, int, int, int]] = [
        (3, 4, 3, 4),      # n = 12, r = 3, m = 4, P = 3, Q = 4
        (4, 3, 4, 3),      # n = 12, r = 4, m = 3
        (3, 8, 4, 6),      # n = 24
        (5, 4, 4, 5),      # n = 20
        (6, 6, 6, 6),      # n = 36, balanced cut
        (7, 4, 4, 7),      # n = 28
    ]
    for r, m, P, Q in cases:
        n = r * m
        assert n == P * Q, "cut must factor the register"
        if r > Q or m > Q:
            continue
        rank_in = exact_rank(comb_matrix(P, Q, r, 0))
        x0 = 1
        out = [[comb_dft(m, r, x0, p * Q + q) for q in range(Q)] for p in range(P)]
        rank_out = numeric_rank(out)
        assert rank_in == predicted_rank(P, Q, r)
        assert rank_out == predicted_rank(P, Q, m)
        flag = "OK" if rank_in * rank_out <= P else "VIOLATED"
        print(
            f"   {n:4d}  {r:4d}  {m:4d}  {P:3d}  {Q:3d}  {rank_in:7d}  {rank_out:8d}"
            f"  {rank_in*rank_out:7d}  {P:7d}  {flag}"
        )
    print("   the transform inverts the period r -> m = n/r; the product never")
    print("   exceeds P = n/Q, so one side of the transform is always cheap.\n")


def demo_sharp_peak(m: int = 4, r: int = 3, x0: int = 1) -> None:
    n = m * r
    print("=" * 74)
    print(f"4b. Sharp-peak theorem, n = {n} = {m}*{r}, offset x0 = {x0}")
    print("=" * 74)
    print("      k    |Psi(k)|      m | k ?")
    for k in range(n):
        val = comb_dft(m, r, x0, k)
        print(f"   {k:4d}   {abs(val):9.6f}      {'yes' if k % m == 0 else 'no'}")
        assert (abs(val) > 1e-9) == (k % m == 0)
    print(f"   nonzero exactly on the multiples of m = {m}, with modulus m.\n")


# ----------------------------------------------------------------------------
# Demonstration 5: explicit singular values, and Eckart-Young errors
# ----------------------------------------------------------------------------


def comb_singular_values(P: int, Q: int, r: int, x0: int) -> List[float]:
    """The comb matrix is a sum of rank-one terms indexed by the reachable
    residues c = p*Q mod r; the left factors are indicators of disjoint row sets
    (size mu_c) and the right factors indicators of disjoint column sets (size
    nu_c).  Hence the singular values are exactly sqrt(mu_c * nu_c)."""
    mu: Dict[int, int] = {}
    for p in range(P):
        c = (p * Q) % r
        mu[c] = mu.get(c, 0) + 1
    sigmas: List[float] = []
    for c, mu_c in mu.items():
        nu_c = sum(1 for q in range(Q) if (c + q) % r == x0 % r)
        if nu_c:
            sigmas.append(math.sqrt(mu_c * nu_c))
    return sorted(sigmas, reverse=True)


def demo_singular_values(P: int = 8, Q: int = 8, r: int = 5, x0: int = 0) -> None:
    print("=" * 74)
    print(f"5.  Closed-form singular values and truncation error (P={P}, Q={Q}, r={r})")
    print("=" * 74)
    sigmas = comb_singular_values(P, Q, r, x0)
    frob_sq = sum(s * s for s in sigmas)
    entries = sum(1 for p in range(P) for q in range(Q) if (p * Q + q) % r == x0 % r)
    print(f"   singular values          : {[round(s, 4) for s in sigmas]}")
    print(f"   sum of squares           : {frob_sq:.4f}")
    print(f"   number of nonzero entries: {entries}   (must agree)")
    assert abs(frob_sq - entries) < 1e-9
    K = len(sigmas)
    print(f"   exact rank K             : {K}  (predicted {predicted_rank(P, Q, r)})")
    print("      D    best rank-D Frobenius error^2    relative error")
    for D in range(K + 1):
        err_sq = sum(s * s for s in sigmas[D:])
        print(f"   {D:4d}   {err_sq:29.4f}   {math.sqrt(err_sq/frob_sq):14.4f}")
    print("   no low-rank surrogate is close until D reaches the true rank.\n")


# ----------------------------------------------------------------------------
# Demonstration 6: Dirichlet smearing for the truncated comb (Conjecture 1)
# ----------------------------------------------------------------------------


def truncated_comb_dft(n: int, r: int, x0: int, k: int) -> complex:
    """DFT at frequency k of the *truncated* comb {x < n : x = x0 (mod r)}."""
    return sum(
        cmath.exp(2j * cmath.pi * (x * k % n) / n) for x in range(x0 % r, n, r)
    )


def tooth_count(n: int, r: int, x0: int) -> int:
    """Number of teeth J = #{x < n : x = x0 (mod r)} of the truncated comb."""
    return len(range(x0 % r, n, r))


def demo_zero_count_law(max_L: int = 9) -> None:
    print("=" * 74)
    print("8.  Zero-count law for the transformed *truncated* comb (n = 2^L, r odd)")
    print("=" * 74)
    print("      n     r    x0     J    zeros observed    gcd(n,J)-1    full support?")
    for L in range(2, max_L + 1):
        n = 2 ** L
        for r in [3, 5, 7, 9, 11]:
            if r >= n:
                continue
            for x0 in range(min(r, 2)):
                J = tooth_count(n, r, x0)
                zeros = sum(
                    1 for k in range(n) if abs(truncated_comb_dft(n, r, x0, k)) < 1e-8
                )
                pred = math.gcd(n, J) - 1
                assert zeros == pred, "zero-count law failed"
                print(
                    f"   {n:4d}  {r:4d}  {x0:4d}  {J:4d}   {zeros:15d}   {pred:11d}"
                    f"   {'yes' if zeros == 0 else 'no':>14}"
                )
    print("   the transform vanishes at exactly gcd(n, J) - 1 frequencies, i.e. it has")
    print("   full support precisely when the number of teeth J is odd.  The naive")
    print("   'never vanishes' guess is false: n = 16, r = 5, x0 = 0 has J = 4 teeth")
    print("   and the transform vanishes at k = 4, 8, 12.\n")


# ----------------------------------------------------------------------------
# Demonstration 7: exact rank of the transformed truncated comb, no floating point
# ----------------------------------------------------------------------------


def _find_root_of_unity(n: int) -> Tuple[int, int]:
    """Return a prime p = 1 (mod n) together with an element of exact order n in
    the field with p elements.  Arithmetic in that field is an exact stand-in for
    arithmetic with a complex n-th root of unity: the rank computed there is a
    lower bound for (and generically equal to) the rank over the complex numbers."""
    def is_prime(v: int) -> bool:
        if v < 2:
            return False
        for d in range(2, int(v ** 0.5) + 1):
            if v % d == 0:
                return False
        return True

    k = 1
    while True:
        p = k * n + 1
        if is_prime(p):
            for g in range(2, p):
                z = pow(g, (p - 1) // n, p)
                if all(pow(z, n // q, p) != 1 for q in _prime_factors(n)):
                    return p, z
        k += 1


def _prime_factors(v: int) -> List[int]:
    factors, d = [], 2
    while d * d <= v:
        if v % d == 0:
            factors.append(d)
            while v % d == 0:
                v //= d
        d += 1
    if v > 1:
        factors.append(v)
    return factors


def modular_rank(matrix: List[List[int]], p: int) -> int:
    """Exact rank over the field with p elements."""
    rows = [row[:] for row in matrix]
    n_rows, n_cols, rank = len(rows), len(rows[0]), 0
    for col in range(n_cols):
        pivot = next((i for i in range(rank, n_rows) if rows[i][col] % p), None)
        if pivot is None:
            continue
        rows[rank], rows[pivot] = rows[pivot], rows[rank]
        inv = pow(rows[rank][col], p - 2, p)
        rows[rank] = [v * inv % p for v in rows[rank]]
        for i in range(n_rows):
            if i != rank and rows[i][col] % p:
                f = rows[i][col]
                rows[i] = [(a - f * b) % p for a, b in zip(rows[i], rows[rank])]
        rank += 1
    return rank


def demo_exact_transform_rank(levels: List[int] = [4, 6, 8]) -> None:
    print("=" * 74)
    print("9.  Exact rank of the transformed truncated comb (finite-field arithmetic)")
    print("=" * 74)
    print("      n     r    x0     J     P     exact rank     min(P, J)")
    for L in levels:
        n = 2 ** L
        p, z = _find_root_of_unity(n)
        P = 2 ** (L // 2)
        Q = n // P
        for r in [3, 5, 7, 9, 11, 13]:
            if r >= n:
                continue
            for x0 in [0, 1]:
                J = tooth_count(n, r, x0)
                mat = [
                    [
                        sum(
                            pow(z, (x * (pp * Q + q)) % n, p)
                            for x in range(x0 % r, n, r)
                        )
                        % p
                        for q in range(Q)
                    ]
                    for pp in range(P)
                ]
                rk = modular_rank(mat, p)
                print(
                    f"   {n:4d}  {r:4d}  {x0:4d}  {J:4d}  {P:4d}   {rk:12d}   {min(P, J):11d}"
                )
                assert rk == min(P, J), "transform rank law failed"
    print("   the transformed truncated comb is a sum of J rank-one terms, so its rank")
    print("   is at most J; in every case tested it is exactly min(P, J) - maximal")
    print("   whenever the tooth count reaches the block size, which is the regime of")
    print("   order finding (register size n ~ N^2 makes both r and J about sqrt(n)).\n")


def demo_truncated_vs_exact(L: int = 6) -> None:
    n = 2 ** L
    a = L // 2
    P = Q = 2 ** a
    print("=" * 74)
    print(f"7b. Input bond dimension on a binary register, n = 2^{L} = {n}, cut {P}x{Q}")
    print("=" * 74)
    print("      r    odd part    exact rank    predicted min(2^a, m)")
    for r in range(1, Q + 1):
        m = odd_part(r)
        rank = exact_rank(comb_matrix(P, Q, r, 0))
        print(f"   {r:4d}   {m:9d}   {rank:11d}   {min(P, m):22d}")
        assert rank == min(P, m)
    print("   an odd order is never compressible; a power-of-two period is free.\n")


# ----------------------------------------------------------------------------


def main() -> None:
    demo_exact_rank_law()
    demo_odd_part_law()
    demo_exponential_barrier()
    demo_sharp_peak()
    demo_transform_and_complementarity()
    demo_singular_values()
    demo_truncated_vs_exact()
    demo_zero_count_law()
    demo_exact_transform_rank()
    print("All demonstrations completed; every assertion held.")


if __name__ == "__main__":
    main()
