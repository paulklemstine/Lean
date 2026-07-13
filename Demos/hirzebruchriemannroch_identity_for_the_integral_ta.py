"""
Numerical demonstrations for the Hirzebruch--Riemann--Roch (P^K = Hilb) identity
for the Boolean matroid B_n.

Everything below is self-contained (standard library only) and independently
computes and cross-checks the results:

  * the Eulerian numbers  <n,k>  via the triangle recurrence
    (graded Betti numbers / Hilbert function of the Chow ring A*(B_n));
  * palindromicity  <n,k> = <n,n-1-k>  (Poincare duality);
  * the row sum  sum_k <n,k> = n!  (total dimension = value of Hilbert series at 1);
  * Worpitzky's identity  m^n = sum_k <n,k> C(m+k, n)  (Riemann--Roch bridge);
  * the alternating Euler-characteristic formula
        tau(n,k) = sum_j (-1)^j C(n+1, j) (k+1-j)^n
    and its equality  tau(n,k) = <n,k>  (P^K = Hilb, coefficientwise).
"""

from __future__ import annotations

from math import comb, factorial
from typing import Dict, List, Tuple


def eulerian_table(n_max: int) -> List[List[int]]:
    """Return the table E[n][k] = <n,k> for 0 <= k <= n <= n_max.

    Uses the classical (unshifted) recurrence
        <n+1,k> = (k+1)<n,k> + (n+1-k)<n,k-1>,
    with <n,0> = 1 and <0,0> = 1.
    """
    table: List[List[int]] = [[1]]  # row n = 0
    for n in range(1, n_max + 1):
        prev = table[n - 1]
        row: List[int] = [0] * (n + 1)
        row[0] = 1
        for k in range(1, n + 1):
            left = prev[k] if k < len(prev) else 0
            right = prev[k - 1] if k - 1 < len(prev) else 0
            row[k] = (k + 1) * left + (n - k) * right
        table.append(row)
    return table


def eulerian(n: int, k: int) -> int:
    """The Eulerian number <n,k> (0 if k out of range 0..n)."""
    if k < 0 or k > n:
        return 0
    return eulerian_table(n)[n][k]


def tangent_k_coeff(n: int, k: int) -> int:
    """The alternating K-theoretic coefficient
        tau(n,k) = sum_{j=0}^{k} (-1)^j C(n+1, j) (k+1-j)^n.
    This is a genuine signed sum (an Euler characteristic).
    """
    total = 0
    for j in range(k + 1):
        total += (-1) ** j * comb(n + 1, j) * (k + 1 - j) ** n
    return total


def hilbert_series(n: int) -> List[int]:
    """Coefficients [<n,0>, <n,1>, ..., <n,n>] of the Hilbert series of A*(B_n)."""
    row = eulerian_table(n)[n]
    return row + [0] * ((n + 1) - len(row))


def k_polynomial(n: int) -> List[int]:
    """Coefficients [tau(n,0), ..., tau(n,n)] of the K-polynomial of T^Z_{B_n}."""
    return [tangent_k_coeff(n, k) for k in range(n + 1)]


def worpitzky_rhs(m: int, n: int, table: List[List[int]]) -> int:
    """Right-hand side of Worpitzky: sum_k <n,k> C(m+k, n)."""
    return sum(table[n][k] * comb(m + k, n) for k in range(n + 1))


def is_palindrome(seq: List[int]) -> bool:
    trimmed = seq[:]
    while trimmed and trimmed[-1] == 0:
        trimmed.pop()
    return trimmed == trimmed[::-1]


def demo_eulerian_triangle(n_max: int = 6) -> None:
    print("=" * 70)
    print("Eulerian triangle  <n,k>  (Hilbert function of A*(B_n))")
    print("=" * 70)
    table = eulerian_table(n_max)
    for n in range(n_max + 1):
        row = table[n][: n + 1]
        print(f"  n={n:<2}  {row}   (row sum = {sum(row)}, n! = {factorial(n)})")
    print()


def demo_poincare_duality(n_max: int = 7) -> None:
    print("=" * 70)
    print("Poincare duality:  <n,k> = <n, n-1-k>   (palindromic Hilbert series)")
    print("=" * 70)
    table = eulerian_table(n_max)
    for n in range(1, n_max + 1):
        row = table[n][:n]  # nonzero part sits in degrees 0..n-1
        ok = all(row[k] == row[n - 1 - k] for k in range(n))
        print(f"  n={n:<2}  {row}   palindrome? {ok}")
    print()


def demo_row_sum(n_max: int = 8) -> None:
    print("=" * 70)
    print("Total dimension:  sum_k <n,k> = n!   (Hilbert series at t = 1)")
    print("=" * 70)
    table = eulerian_table(n_max)
    for n in range(n_max + 1):
        s = sum(table[n])
        print(f"  n={n:<2}  sum = {s:<8}  n! = {factorial(n):<8}  match? {s == factorial(n)}")
    print()


def demo_worpitzky(n_max: int = 6, m_max: int = 6) -> None:
    print("=" * 70)
    print("Worpitzky:  m^n = sum_k <n,k> C(m+k, n)   (Riemann--Roch bridge)")
    print("=" * 70)
    table = eulerian_table(n_max)
    all_ok = True
    for n in range(n_max + 1):
        for m in range(m_max + 1):
            lhs = m ** n
            rhs = worpitzky_rhs(m, n, table)
            if lhs != rhs:
                all_ok = False
                print(f"  MISMATCH  n={n} m={m}: {lhs} != {rhs}")
    print(f"  All identities m^n = sum_k <n,k> C(m+k,n) verified: {all_ok}")
    print()


def demo_pk_equals_hilb(n_max: int = 7) -> None:
    print("=" * 70)
    print("P^K = Hilb:  tau(n,k) = <n,k>   (alternating sum == dimension count)")
    print("=" * 70)
    table = eulerian_table(n_max)
    for n in range(n_max + 1):
        hilb = hilbert_series(n)[: n + 1]
        kpol = k_polynomial(n)
        ok = hilb == kpol
        print(f"  n={n}")
        print(f"    Hilb coeffs (counts)      : {hilb}")
        print(f"    K-poly coeffs (alternating): {kpol}")
        print(f"    equal?  {ok}")
    print()


def demo_alternating_cancellation(n: int = 5, k: int = 2) -> None:
    print("=" * 70)
    print(f"Inside one alternating coefficient  tau({n},{k})")
    print("=" * 70)
    partials: List[Tuple[int, int]] = []
    running = 0
    for j in range(k + 1):
        term = (-1) ** j * comb(n + 1, j) * (k + 1 - j) ** n
        running += term
        partials.append((term, running))
    print("  j : term (signed)      running partial sum")
    for j, (term, run) in enumerate(partials):
        print(f"  {j} : {term:>12}      {run:>12}")
    print(f"  final tau({n},{k}) = {running}   =   <{n},{k}> = {eulerian(n, k)}")
    print()


def main() -> None:
    demo_eulerian_triangle()
    demo_poincare_duality()
    demo_row_sum()
    demo_worpitzky()
    demo_pk_equals_hilb()
    demo_alternating_cancellation()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
