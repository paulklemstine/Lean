"""
Numerical demonstrations for:

    The Enumerative Layer of the m-Tamari / (m+1)-Constellation Correspondence:
    Fuss-Catalan Element Counts and Bousquet-Melou-Chapoton Interval Numbers

This self-contained script demonstrates, with exact integer / rational arithmetic:

  1. Fuss-Catalan numbers   Cat_m(n) = C((m+1)n, n) - m*C((m+1)n, n-1)
     as a manifest non-negative integer, and the closed form
         (m*n + 1) * Cat_m(n) = C((m+1)n, n),
     hence the divisibility  (m*n + 1) | C((m+1)n, n).

  2. Recovery of the ordinary Catalan numbers at m = 1, small values,
     and non-triviality (Cat_m(2) = m + 1).

  3. Bousquet-Melou-Chapoton interval numbers
         Int_m(n) = (m+1) / (n*(m*n+1)) * C((m+1)^2 * n + m, n-1),
     their classical values (1,3,13,68 for m=1; 1,6,58 for m=2),
     the fact that intervals strictly outnumber elements, the n-factor
     divisibility, and the reduced (m*n+1) divisibility.

  4. Two disproved conjectures: (m,n)-symmetry and the m-free two-term formula.

Everything uses Python's arbitrary-precision integers and the Fraction type;
no third-party libraries are required.
"""

from __future__ import annotations

from fractions import Fraction
from math import comb, gcd
from typing import List


# ---------------------------------------------------------------------------
# 1. Fuss-Catalan numbers
# ---------------------------------------------------------------------------

def fuss_catalan(m: int, n: int) -> int:
    """Fuss-Catalan number Cat_m(n) via the two-term binomial difference.

    Cat_m(0) = 1, and for n >= 1,
        Cat_m(n) = C((m+1)n, n) - m * C((m+1)n, n-1).
    This is a manifest non-negative integer (no division).
    """
    if n == 0:
        return 1
    return comb((m + 1) * n, n) - m * comb((m + 1) * n, n - 1)


def fuss_catalan_closed_form_lhs(m: int, n: int) -> int:
    """Left-hand side of the closed form: (m*n + 1) * Cat_m(n)."""
    return (m * n + 1) * fuss_catalan(m, n)


def fuss_catalan_closed_form_rhs(m: int, n: int) -> int:
    """Right-hand side of the closed form: C((m+1)n, n)."""
    return comb((m + 1) * n, n)


def catalan(n: int) -> int:
    """Ordinary Catalan number C_n = C(2n, n) / (n+1)."""
    return comb(2 * n, n) // (n + 1)


# ---------------------------------------------------------------------------
# 2. Interval numbers (Bousquet-Melou-Chapoton)
# ---------------------------------------------------------------------------

def interval_number(m: int, n: int) -> Fraction:
    """Int_m(n) = (m+1) / (n*(m*n+1)) * C((m+1)^2 * n + m, n-1), exactly."""
    numerator_binom = comb((m + 1) ** 2 * n + m, n - 1)
    return Fraction(m + 1) * Fraction(numerator_binom, n * (m * n + 1))


def interval_numerator(m: int, n: int) -> int:
    """The integer numerator (m+1) * C((m+1)^2 * n + m, n-1)."""
    return (m + 1) * comb((m + 1) ** 2 * n + m, n - 1)


# ---------------------------------------------------------------------------
# Demonstration routines
# ---------------------------------------------------------------------------

def demo_closed_form_and_divisibility(max_m: int = 4, max_n: int = 8) -> None:
    print("=" * 70)
    print("1. Fuss-Catalan closed form and divisibility")
    print("=" * 70)
    print("Checking  (m*n + 1) * Cat_m(n) == C((m+1)n, n)  and  (m*n+1) | C((m+1)n, n)")
    all_ok = True
    for m in range(1, max_m + 1):
        for n in range(0, max_n + 1):
            lhs = fuss_catalan_closed_form_lhs(m, n)
            rhs = fuss_catalan_closed_form_rhs(m, n)
            ok = (lhs == rhs) and (rhs % (m * n + 1) == 0)
            all_ok = all_ok and ok
    print(f"  All identities hold for 1<=m<={max_m}, 0<=n<={max_n}: {all_ok}")
    print("\n  Fuss-Catalan triangle Cat_m(n):")
    header = "   m\\n |" + "".join(f"{n:>8}" for n in range(0, 7))
    print(header)
    print("  " + "-" * (len(header) - 2))
    for m in range(1, max_m + 1):
        row = "".join(f"{fuss_catalan(m, n):>8}" for n in range(0, 7))
        print(f"   {m:>3} |{row}")


def demo_catalan_recovery(max_n: int = 10) -> None:
    print("\n" + "=" * 70)
    print("2. Recovery of Catalan numbers at m = 1, small values")
    print("=" * 70)
    row_fc = [fuss_catalan(1, n) for n in range(max_n + 1)]
    row_cat = [catalan(n) for n in range(max_n + 1)]
    print(f"  Cat_1(n) : {row_fc}")
    print(f"  catalan  : {row_cat}")
    print(f"  Equal    : {row_fc == row_cat}")
    print("\n  Small-value laws:")
    print(f"  Cat_m(0) = 1 for all m: {all(fuss_catalan(m, 0) == 1 for m in range(6))}")
    print(f"  Cat_m(1) = 1 for all m: {all(fuss_catalan(m, 1) == 1 for m in range(6))}")
    print(f"  Cat_m(2) = m+1        : "
          f"{all(fuss_catalan(m, 2) == m + 1 for m in range(6))}")


def demo_interval_numbers() -> None:
    print("\n" + "=" * 70)
    print("3. Interval numbers, excess over elements, and integrality")
    print("=" * 70)
    print("  m = 1 sequence (expect 1, 3, 13, 68, 399):")
    seq1 = [interval_number(1, n) for n in range(1, 6)]
    print(f"    {[int(x) for x in seq1]}")
    print("  m = 2 sequence (expect 1, 6, 58):")
    seq2 = [interval_number(2, n) for n in range(1, 4)]
    print(f"    {[int(x) for x in seq2]}")

    print("\n  Intervals vs. elements (Int_m(n) > Cat_m(n)):")
    for m in range(1, 4):
        for n in range(1, 5):
            el = fuss_catalan(m, n)
            iv = interval_number(m, n)
            flag = "  <-- strictly more" if iv > el else ""
            print(f"    m={m}, n={n}:  elements={el:>6}   intervals={int(iv):>8}{flag}")

    print("\n  Integrality diagnostics of Int_m(n):")
    print("    n | mn+1 coprime | n | numerator | (mn+1) | numerator | Int integer")
    for m in range(1, 4):
        for n in range(1, 6):
            num = interval_numerator(m, n)
            coprime = gcd(n, m * n + 1) == 1
            n_div = num % n == 0
            mn_div = num % (m * n + 1) == 0
            is_int = interval_number(m, n).denominator == 1
            print(f"    m={m} n={n} | coprime={coprime} | "
                  f"n|num={n_div} | (mn+1)|num={mn_div} | integer={is_int}")


def demo_disproofs() -> None:
    print("\n" + "=" * 70)
    print("4. Disproved conjectures")
    print("=" * 70)
    # Symmetry fails.
    a, b = fuss_catalan(1, 2), fuss_catalan(2, 1)
    print(f"  Symmetry Cat_1(2) == Cat_2(1)?  {a} == {b} -> {a == b}  (FALSE, as claimed)")

    # m-free two-term formula fails.
    def m_free(m: int, n: int) -> int:
        return comb((m + 1) * n, n) - comb((m + 1) * n, n - 1)

    true_val = fuss_catalan(2, 2)
    wrong_val = m_free(2, 2)
    print(f"  m-free formula at m=2,n=2:  {wrong_val}  vs true Cat_2(2) = {true_val}"
          f"  -> equal? {wrong_val == true_val}  (FALSE, as claimed)")
    print("  The multiplier m on the second binomial is essential.")


def main() -> None:
    demo_closed_form_and_divisibility()
    demo_catalan_recovery()
    demo_interval_numbers()
    demo_disproofs()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
