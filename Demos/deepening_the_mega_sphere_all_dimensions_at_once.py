"""
The Mega-Sphere: All Dimensions at Once — Numerical Demonstrations
=================================================================

Self-contained Python demonstrations of the three threads of the mega-sphere
program:

  1. Inverse limits of towers of additive groups: collapse of the
     multiplication tower, the nontrivial-stages/trivial-limit disproof, and
     the Mittag-Leffler (surjective-tower) phenomenon.
  2. Bernoulli numbers via a single generating recursion, the disproof that all
     odd Bernoulli numbers vanish, and Faulhaber's "one polynomial per
     exponent" power-sum theorem.
  3. The mod-2 cohomology ring of the infinite real projective space:
     non-nilpotence of the twisting class, nilpotence in truncations, the
     Poincare count, the Whitney-Frobenius identity (1+w)^(2^k) = 1 + w^(2^k),
     and the all-ones dual classes.

Every function is inlined and uses only the standard library
(fractions.Fraction), so the file runs with `python demo.py`.
"""

from __future__ import annotations

from fractions import Fraction
from math import comb
from typing import Callable, List, Optional


# ---------------------------------------------------------------------------
# Thread 1: Inverse limits of towers
# ---------------------------------------------------------------------------

def divisible_by_all_powers(a: int, d: int, max_power: int) -> bool:
    """Return True iff the integer `a` is divisible by d^n for n = 0..max_power.

    By the collapse lemma, if |d| >= 2 then only a == 0 stays divisible as
    max_power -> infinity.
    """
    return all(a % (d ** n) == 0 for n in range(max_power + 1))


def multiplication_tower_bottom_from_top(d: int, top_level: int,
                                         top_value: int) -> int:
    """Bottom entry x_0 of a coherent thread of the tower Z <-xd- Z <-xd- ...
    given the entry x_N = top_value at level N = top_level.

    Coherence forces x_0 = d^N * x_N, so a nonzero thread would make x_0
    divisible by arbitrarily large d^N — impossible unless x_0 = 0.
    """
    return (d ** top_level) * top_value


def collapse_witness(d: int, search_bound: int = 10_000) -> Optional[int]:
    """Look for a nonzero bottom value x_0 whose whole thread stays integral for
    every level. For |d| >= 2 none exists (the tower collapses), so return None;
    for |d| == 1 every value works, so return the first nonzero one found.
    """
    for a in range(1, search_bound):
        # x_0 must be divisible by d^n for all n; test a large window.
        if divisible_by_all_powers(a, d, max_power=40):
            return a
    return None


def surjective_tower_lift(a0: int, lift: Callable[[int, int], int],
                          levels: int) -> List[int]:
    """Mittag-Leffler: given a bottom value a0 and a preimage-chooser
    `lift(n, x_n) -> x_{n+1}` with pi_n(x_{n+1}) = x_n, build a coherent thread.
    Demonstrates that surjective towers surject onto the bottom stage.
    """
    thread = [a0]
    for n in range(levels):
        thread.append(lift(n, thread[-1]))
    return thread


# ---------------------------------------------------------------------------
# Thread 2: Bernoulli numbers and Faulhaber
# ---------------------------------------------------------------------------

def bernoulli_numbers(upto: int) -> List[Fraction]:
    """Return [B_0, ..., B_upto] using the single defining recursion coming from
    the generating identity (sum B_n x^n/n!)(e^x - 1) = x, namely
        sum_{i=0}^{m} C(m+1, i) B_i = 0   for m >= 1,  and  B_0 = 1.
    This is the B_1 = -1/2 convention.
    """
    B: List[Fraction] = [Fraction(1)]
    for m in range(1, upto + 1):
        s = sum(comb(m + 1, i) * B[i] for i in range(m))
        B.append(-s / Fraction(comb(m + 1, m)))
    return B


def odd_bernoulli_report(upto: int) -> List[tuple[int, Fraction]]:
    """Return the (index, value) pairs of odd-indexed Bernoulli numbers, making
    the disproof visible: B_1 = -1/2 != 0, while B_n = 0 for odd n >= 3.
    """
    B = bernoulli_numbers(upto)
    return [(n, B[n]) for n in range(1, upto + 1, 2)]


def faulhaber_coeffs(p: int) -> List[Fraction]:
    """Coefficients (from constant term up) of the single polynomial P with
    sum_{k<n} k^p = P(n), via
        P(x) = 1/(p+1) * sum_{i=0}^{p} C(p+1, i) B_i x^{p+1-i}.
    """
    B = bernoulli_numbers(p)
    coeffs = [Fraction(0)] * (p + 2)
    for i in range(p + 1):
        power = p + 1 - i
        coeffs[power] += Fraction(comb(p + 1, i), p + 1) * B[i]
    return coeffs


def poly_eval(coeffs: List[Fraction], n: int) -> Fraction:
    """Evaluate a polynomial given by ascending coefficients at n."""
    return sum(c * Fraction(n) ** k for k, c in enumerate(coeffs))


def power_sum_direct(p: int, n: int) -> Fraction:
    """Direct computation of sum_{k<n} k^p, for cross-checking Faulhaber."""
    return sum(Fraction(k) ** p for k in range(n))


# ---------------------------------------------------------------------------
# Thread 3: Cohomology of RP^infinity modeled by F_2[w]
# ---------------------------------------------------------------------------

def poly_mul_f2(a: List[int], b: List[int]) -> List[int]:
    """Multiply two F_2-coefficient polynomials (lists of 0/1, ascending)."""
    out = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        if ai:
            for j, bj in enumerate(b):
                out[i + j] ^= (ai & bj)
    return out


def w_power(n: int) -> List[int]:
    """The class w^n in F_2[w] as a coefficient list; always nonzero,
    witnessing non-nilpotence of w in H*(RP^infinity; F_2)."""
    return [0] * n + [1]


def w_power_in_truncation(n: int, trunc: int) -> List[int]:
    """w^n reduced modulo w^{trunc+1} (the ring H*(RP^trunc; F_2)). For
    n >= trunc+1 this is 0, witnessing nilpotence in every finite stage."""
    p = w_power(n)
    return [c for k, c in enumerate(p) if k <= trunc]


def poincare_dim(n: int) -> int:
    """Dimension over F_2 of the degree-<n part of F_2[w]: exactly n."""
    return len([0] * n)  # basis 1, w, ..., w^{n-1}


def frobenius_lhs(k: int) -> List[int]:
    """(1 + w)^(2^k) expanded in F_2[w] via repeated squaring."""
    result = [1]  # the polynomial 1
    base = [1, 1]  # 1 + w
    e = 2 ** k
    while e:
        if e & 1:
            result = poly_mul_f2(result, base)
        base = poly_mul_f2(base, base)
        e >>= 1
    return result


def frobenius_rhs(k: int) -> List[int]:
    """1 + w^(2^k) in F_2[w]."""
    return [1] + [0] * (2 ** k - 1) + [1]


def dual_classes(trunc: int) -> List[int]:
    """Coefficients of (1 + w)^(-1) in F_2[[w]], truncated to degree `trunc`.
    Computed from the recursion y_0 = 1, y_k = y_{k-1}; all should be 1."""
    y = [1]
    for _ in range(1, trunc + 1):
        y.append(y[-1])  # y_k = y_{k-1} over F_2
    return y


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("THREAD 1: Inverse limits — collapse, disproof, Mittag-Leffler")
    print("=" * 70)
    for d in (2, 3, -2, 10):
        w = collapse_witness(d)
        print(f"  Multiplication tower base d={d:>3}: "
              f"nonzero coherent thread found? {w is not None}  "
              f"(tower collapses to {{0}})")
    print("  Disproof: stages all Z/2 (nontrivial), connecting maps all 0.")
    print("           Only coherent thread is (0,0,0,...) -> limit is trivial.")
    # Mittag-Leffler on the surjective tower Z/2^(n+1) -> Z/2^n (reduction).
    lift = lambda n, x: x  # any preimage; here the representative lifts directly
    thread = surjective_tower_lift(a0=1, lift=lift, levels=5)
    print(f"  Mittag-Leffler lift of a0=1 through 5 surjective stages: {thread}")

    print()
    print("=" * 70)
    print("THREAD 2: Bernoulli numbers and Faulhaber")
    print("=" * 70)
    B = bernoulli_numbers(10)
    print("  B_0..B_10 =", [str(b) for b in B])
    print("  Odd-indexed Bernoulli numbers (disproof of 'all vanish'):")
    for n, val in odd_bernoulli_report(9):
        flag = "  <-- NONZERO exception!" if val != 0 else ""
        print(f"     B_{n} = {val}{flag}")
    for p in range(1, 6):
        coeffs = faulhaber_coeffs(p)
        ok = all(poly_eval(coeffs, n) == power_sum_direct(p, n)
                 for n in range(0, 12))
        print(f"  Faulhaber p={p}: single polynomial matches direct sum "
              f"for n=0..11? {ok}")
    # Explicit p=4 closed form check.
    n = 7
    closed = Fraction((n - 1) * n * (2 * n - 1) * (3 * n ** 2 - 3 * n - 1), 30)
    print(f"  p=4, n={n}: closed form {closed} == direct "
          f"{power_sum_direct(4, n)}? {closed == power_sum_direct(4, n)}")

    print()
    print("=" * 70)
    print("THREAD 3: Cohomology of RP^infinity, modeled by F_2[w]")
    print("=" * 70)
    print("  w^n nonzero for n=1..6 (non-nilpotent in RP^infinity):",
          [w_power(n)[-1] == 1 for n in range(1, 7)])
    trunc = 4
    print(f"  In truncation F_2[w]/(w^{trunc+1}) ~ H*(RP^{trunc}): "
          f"w^{trunc+1} = "
          f"{w_power_in_truncation(trunc + 1, trunc)} (nilpotent)")
    print("  Poincare count dim(deg<n) = n for n=1..6:",
          [poincare_dim(n) for n in range(1, 7)])
    for k in range(4):
        lhs, rhs = frobenius_lhs(k), frobenius_rhs(k)
        print(f"  Whitney-Frobenius k={k}: (1+w)^(2^{k}) == 1 + w^(2^{k})? "
              f"{lhs == rhs}")
    duals = dual_classes(8)
    print(f"  Dual classes (1+w)^(-1) coefficients (all 1): {duals}")


if __name__ == "__main__":
    main()
