"""
Numerical demonstrations for the extended Eulerian numbers A(n, k, s).

Definition
----------
    A(n, k, s) = sum_{i=0}^{k} (-1)^i * C(n+1, i) * (k + 1 - i - s)^n

At s = 0 this reproduces the classical Eulerian numbers <n, k> (permutations of
{1,...,n} with exactly k descents).

Results demonstrated here
-------------------------
1. A(n, k, 0) equals the classical Eulerian numbers.
2. Boundary vanishing:            A(n, k, s) = 0 for all k >= n + 1, any s.
3. Shift-invariant row sum:       sum_{k=0}^{n} A(n, k, s) = n!, any s.
4. The proof mechanism:           row sum = (Delta^{n+1} Q)(0) = n!, where
                                  Q(t) = sum_{m<t} (m + 1 - s)^n.

Everything is inlined and depends only on the standard library, using exact
rational arithmetic (fractions.Fraction) so all identities hold on the nose for
rational shifts s.
"""

from __future__ import annotations

from fractions import Fraction
from math import comb, factorial
from typing import Callable, List, Sequence


# --------------------------------------------------------------------------- #
# Core definitions
# --------------------------------------------------------------------------- #
def extended_eulerian(n: int, k: int, s: Fraction) -> Fraction:
    """Return A(n, k, s) via the alternating binomial closed form (exact)."""
    total = Fraction(0)
    for i in range(k + 1):
        base = Fraction(k + 1 - i) - s          # (k + 1 - i - s)
        term = Fraction((-1) ** i) * comb(n + 1, i) * base ** n
        total += term
    return total


def extended_eulerian_row(n: int, s: Fraction) -> List[Fraction]:
    """Return the full supported row [A(n, 0, s), ..., A(n, n, s)]."""
    return [extended_eulerian(n, k, s) for k in range(n + 1)]


def classical_eulerian(n: int, k: int) -> int:
    """Classical Eulerian number <n, k> = A(n, k, 0), returned as an int."""
    return int(extended_eulerian(n, k, Fraction(0)))


# --------------------------------------------------------------------------- #
# Finite-difference machinery (the proof mechanism)
# --------------------------------------------------------------------------- #
def forward_difference(seq: Sequence[Fraction]) -> List[Fraction]:
    """One step of the forward difference: (Delta f)[j] = f[j+1] - f[j]."""
    return [seq[j + 1] - seq[j] for j in range(len(seq) - 1)]


def iterated_difference(seq: Sequence[Fraction], times: int) -> List[Fraction]:
    """Apply the forward difference `times` times."""
    out = list(seq)
    for _ in range(times):
        out = forward_difference(out)
    return out


def partial_power_sum(n: int, s: Fraction) -> Callable[[int], Fraction]:
    """Q(t) = sum_{m=0}^{t-1} (m + 1 - s)^n, the discrete antiderivative."""

    def Q(t: int) -> Fraction:
        return sum((Fraction(m + 1) - s) ** n for m in range(t))

    return Q


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_classical_match() -> None:
    print("=" * 68)
    print("1. A(n, k, 0) reproduces the classical Eulerian triangle")
    print("=" * 68)
    for n in range(6):
        row = [classical_eulerian(n, k) for k in range(n)]
        print(f"  n = {n}:  {row}   (row sum = {sum(row)} = {n}!)")
    print()


def demo_boundary_vanishing() -> None:
    print("=" * 68)
    print("2. Boundary vanishing: A(n, k, s) = 0 for k >= n + 1")
    print("=" * 68)
    shifts = [Fraction(-2), Fraction(1, 3), Fraction(0), Fraction(7, 5)]
    for n in [2, 3, 4]:
        for s in shifts:
            vals = [extended_eulerian(n, k, s) for k in range(n + 1, n + 5)]
            ok = all(v == 0 for v in vals)
            print(f"  n={n}, s={str(s):>5}:  A(n, k, s) for k in [n+1, n+4] = "
                  f"{[str(v) for v in vals]}   all zero? {ok}")
    print()


def demo_shift_invariant_rowsum() -> None:
    print("=" * 68)
    print("3. Shift-invariant row sum: sum_k A(n, k, s) = n!")
    print("=" * 68)
    shifts = [Fraction(-3), Fraction(-1, 2), Fraction(0),
              Fraction(1, 3), Fraction(1), Fraction(22, 7)]
    for n in [1, 2, 3, 4, 5]:
        target = factorial(n)
        print(f"  n = {n}  (target n! = {target})")
        for s in shifts:
            row = extended_eulerian_row(n, s)
            total = sum(row)
            print(f"     s = {str(s):>6}:  row sum = {str(total):>6}   "
                  f"match n!? {total == target}")
    print()


def demo_row_values_vary() -> None:
    print("=" * 68)
    print("4. The entries genuinely vary while the sum stays frozen (n = 3)")
    print("=" * 68)
    for s in [Fraction(0), Fraction(1, 2), Fraction(1), Fraction(-1)]:
        row = extended_eulerian_row(3, s)
        pretty = [str(v) for v in row]
        print(f"  s = {str(s):>4}:  row = {pretty}   sum = {sum(row)}")
    print()


def demo_proof_mechanism() -> None:
    print("=" * 68)
    print("5. The proof mechanism: row sum = (Delta^{n+1} Q)(0) = n!")
    print("=" * 68)
    for n in [2, 3, 4, 5]:
        for s in [Fraction(0), Fraction(3, 4), Fraction(-2)]:
            Q = partial_power_sum(n, s)
            table = [Q(t) for t in range(n + 2)]           # Q(0..n+1)
            top = iterated_difference(table, n + 1)[0]      # (Delta^{n+1} Q)(0)
            row_sum = sum(extended_eulerian_row(n, s))
            print(f"  n={n}, s={str(s):>5}:  (Delta^(n+1) Q)(0) = {str(top):>5}"
                  f"   row sum = {str(row_sum):>5}   n! = {factorial(n)}")
    print()


def main() -> None:
    demo_classical_match()
    demo_boundary_vanishing()
    demo_shift_invariant_rowsum()
    demo_row_values_vary()
    demo_proof_mechanism()
    print("All demonstrations complete: every row sums to n!, independent of s.")


if __name__ == "__main__":
    main()
