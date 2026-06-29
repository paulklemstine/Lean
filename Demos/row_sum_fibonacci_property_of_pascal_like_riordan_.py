"""Numerical demonstration of the Riordan row-sum Fibonacci identities.

This script exercises the *main theorems* proved in
``Catalog/Novelty/RiordanRowSumFibonacci.lean``:

  * pascalRiordanA_eq_fib :  sum_{k=0}^{n} C(n+k, 2k)   = fib(2n+1)
  * pascalRiordanB_eq_fib :  sum_{k=0}^{n} C(n+k, 2k+1) = fib(2n)
  * pascalRiordan_three_term :  A(n+2) + A(n) = 3 * A(n+1)
  * pascalRiordanB_succ / pascalRiordanA_succ :
        B(n+1) = A(n) + B(n) ,  A(n+1) = A(n) + B(n+1)

Every demonstration uses exact Python integers, so the equalities below are
verified, not approximated.  Fibonacci indexing matches Mathlib's ``Nat.fib``:
fib(0) = 0, fib(1) = 1, fib(2) = 1, fib(3) = 2, ...
"""

from __future__ import annotations

from math import comb
from typing import List, Tuple


# --------------------------------------------------------------------------
# Reference sequences
# --------------------------------------------------------------------------
def fib(m: int) -> int:
    """The m-th Fibonacci number with fib(0) = 0, fib(1) = 1."""
    a, b = 0, 1
    for _ in range(m):
        a, b = b, a + b
    return a


def row_sum_A(n: int) -> int:
    """A(n) = sum_{k=0}^{n} C(n+k, 2k)  (Definition 2.1; pascalRiordanA)."""
    return sum(comb(n + k, 2 * k) for k in range(n + 1))


def row_sum_B(n: int) -> int:
    """B(n) = sum_{k=0}^{n} C(n+k, 2k+1)  (Definition 2.2; pascalRiordanB)."""
    return sum(comb(n + k, 2 * k + 1) for k in range(n + 1))


# --------------------------------------------------------------------------
# Demo 1: the two headline closed-form identities
# --------------------------------------------------------------------------
def demo_closed_forms(n_max: int = 15) -> None:
    """Verify A(n) = fib(2n+1) and B(n) = fib(2n) for n = 0..n_max."""
    print("=" * 72)
    print("Demo 1: A(n) = fib(2n+1)  and  B(n) = fib(2n)")
    print("=" * 72)
    print(f"{'n':>3} | {'A(n)':>12} {'fib(2n+1)':>12} | "
          f"{'B(n)':>12} {'fib(2n)':>12}")
    print("-" * 72)
    for n in range(n_max + 1):
        a, fa = row_sum_A(n), fib(2 * n + 1)
        b, fb = row_sum_B(n), fib(2 * n)
        assert a == fa, f"A({n}) mismatch: {a} != {fa}"
        assert b == fb, f"B({n}) mismatch: {b} != {fb}"
        print(f"{n:>3} | {a:>12} {fa:>12} | {b:>12} {fb:>12}")
    print(f"\nAll closed-form identities verified for n = 0..{n_max}.\n")


# --------------------------------------------------------------------------
# Demo 2: the order-two recurrence A(n+2) = 3 A(n+1) - A(n)
# --------------------------------------------------------------------------
def demo_three_term(n_max: int = 14) -> None:
    """Verify the row sums obey A(n+2) + A(n) = 3 A(n+1)."""
    print("=" * 72)
    print("Demo 2: three-term recurrence  A(n+2) = 3 A(n+1) - A(n)")
    print("=" * 72)
    print(f"{'n':>3} | {'A(n)':>10} {'A(n+1)':>10} {'A(n+2)':>10} | "
          f"{'3A(n+1)-A(n)':>14}")
    print("-" * 72)
    for n in range(n_max + 1):
        a0, a1, a2 = row_sum_A(n), row_sum_A(n + 1), row_sum_A(n + 2)
        pred = 3 * a1 - a0
        assert a2 == pred and a2 + a0 == 3 * a1, f"recurrence fails at n={n}"
        print(f"{n:>3} | {a0:>10} {a1:>10} {a2:>10} | {pred:>14}")
    print(f"\nThree-term recurrence verified for n = 0..{n_max}.\n")


# --------------------------------------------------------------------------
# Demo 3: the coupled Pascal recurrences (engine of the proof)
# --------------------------------------------------------------------------
def coupled_sequences(n_max: int) -> List[Tuple[int, int, int]]:
    """Generate (n, A(n), B(n)) via B(n+1)=A(n)+B(n), A(n+1)=A(n)+B(n+1)."""
    out: List[Tuple[int, int, int]] = []
    a, b = 1, 0  # A(0), B(0)
    out.append((0, a, b))
    for n in range(n_max):
        b = a + b      # pascalRiordanB_succ:  B(n+1) = A(n) + B(n)
        a = a + b      # pascalRiordanA_succ:  A(n+1) = A(n) + B(n+1)
        out.append((n + 1, a, b))
    return out


def demo_coupled(n_max: int = 15) -> None:
    """Verify the coupled recurrence reproduces the direct binomial sums."""
    print("=" * 72)
    print("Demo 3: coupled Pascal recurrence reproduces the binomial sums")
    print("=" * 72)
    print(f"{'n':>3} | {'A(coupled)':>12} {'A(direct)':>12} | "
          f"{'B(coupled)':>12} {'B(direct)':>12}")
    print("-" * 72)
    for n, a, b in coupled_sequences(n_max):
        ad, bd = row_sum_A(n), row_sum_B(n)
        assert a == ad and b == bd, f"coupled mismatch at n={n}"
        print(f"{n:>3} | {a:>12} {ad:>12} | {b:>12} {bd:>12}")
    print(f"\nCoupled recurrence matches direct sums for n = 0..{n_max}.\n")


# --------------------------------------------------------------------------
# Demo 4: the Riordan array itself  t[n][k] = C(n+k, 2k)
# --------------------------------------------------------------------------
def demo_array(n_max: int = 8) -> None:
    """Print the Pascal-like Riordan array and confirm its row sums are A(n)."""
    print("=" * 72)
    print("Demo 4: the Riordan array  t[n,k] = C(n+k, 2k)  and its row sums")
    print("=" * 72)
    for n in range(n_max + 1):
        row = [comb(n + k, 2 * k) for k in range(n + 1)]
        rsum = sum(row)
        assert rsum == fib(2 * n + 1)
        entries = " ".join(f"{x:>5}" for x in row)
        print(f"row {n:>2}: {entries:<48} -> sum {rsum:>5} = fib({2*n+1})")
    print(f"\nEvery row sum equals an odd-indexed Fibonacci number.\n")


# --------------------------------------------------------------------------
# Demo 5: golden-ratio growth rate of the row sums
# --------------------------------------------------------------------------
def demo_growth_rate(n_max: int = 20) -> None:
    """Show A(n+1)/A(n) approaches phi^2, the dominant root of 1-3x+x^2."""
    print("=" * 72)
    print("Demo 5: growth ratio A(n+1)/A(n) -> phi^2 = (3 + sqrt5)/2")
    print("=" * 72)
    phi_sq = (3 + 5 ** 0.5) / 2
    print(f"target phi^2 = {phi_sq:.10f}\n")
    print(f"{'n':>3} | {'A(n+1)/A(n)':>16} {'|error|':>14}")
    print("-" * 40)
    for n in range(1, n_max + 1):
        ratio = row_sum_A(n + 1) / row_sum_A(n)
        print(f"{n:>3} | {ratio:>16.10f} {abs(ratio - phi_sq):>14.2e}")
    print()


def main() -> None:
    demo_closed_forms()
    demo_three_term()
    demo_coupled()
    demo_array()
    demo_growth_rate()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
