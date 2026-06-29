"""
demo.py — Numerical demonstrations of the Combinatorial Species / EGF bridge.

This script illustrates, with exact rational arithmetic, the theorems formalized in
`Catalog/Applications/CombinatorialSpecies.lean`:

  * egf_add               — EGF of a sum of sequences is the sum of EGFs.
  * egf_mul               — EGF of the binomial convolution is the product of EGFs.
  * egf_const_one         — EGF of the constant-1 sequence (species of sets) is exp.
  * egf_linearOrderSpecies— EGF of the factorial sequence (linear orders) is 1/(1-X).
  * card_prodSpecies      — cardinality of the structural product = binomial convolution.
  * egf_card_prodSpecies  — the full bridge: EGF(product) = product of EGFs.

Everything is self-contained: power series are represented as truncated coefficient lists
of exact `fractions.Fraction`s, and all helper functions are inlined.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from math import comb, factorial
from typing import Callable, List, Sequence


# --------------------------------------------------------------------------------------
# Core definitions (mirroring the Lean file)
# --------------------------------------------------------------------------------------

def egf_coeffs(a: Sequence[Fraction], n_terms: int) -> List[Fraction]:
    """Coefficients [X^0..X^(n_terms-1)] of the EGF of sequence `a`: [X^n] = a_n / n!."""
    return [Fraction(a[n]) / factorial(n) for n in range(n_terms)]


def bin_conv(a: Sequence[Fraction], b: Sequence[Fraction], n_terms: int) -> List[Fraction]:
    """Binomial (exponential) convolution: (a * b)_n = sum_{i+j=n} C(n,i) a_i b_j."""
    out: List[Fraction] = []
    for n in range(n_terms):
        s = Fraction(0)
        for i in range(n + 1):
            s += comb(n, i) * Fraction(a[i]) * Fraction(b[n - i])
        out.append(s)
    return out


def cauchy_product(p: Sequence[Fraction], q: Sequence[Fraction], n_terms: int) -> List[Fraction]:
    """Ordinary Cauchy product of two power series (coefficient lists)."""
    out: List[Fraction] = []
    for n in range(n_terms):
        s = Fraction(0)
        for i in range(n + 1):
            s += Fraction(p[i]) * Fraction(q[n - i])
        out.append(s)
    return out


def add_series(p: Sequence[Fraction], q: Sequence[Fraction]) -> List[Fraction]:
    return [Fraction(p[i]) + Fraction(q[i]) for i in range(min(len(p), len(q)))]


# --------------------------------------------------------------------------------------
# Structural product cardinality, computed by brute force over subsets (card_prodSpecies)
# --------------------------------------------------------------------------------------

def card_prod_species(card_A: Callable[[int], int],
                      card_B: Callable[[int], int],
                      n: int) -> int:
    """
    |(A . B)[n]| = sum over subsets S of {0..n-1} of |A[|S|]| * |B[n-|S|]|.
    Computed by literally enumerating subsets, matching the Day-convolution definition.
    """
    total = 0
    labels = range(n)
    for k in range(n + 1):
        for S in combinations(labels, k):
            total += card_A(len(S)) * card_B(n - len(S))
    return total


def binconv_int(card_A: Callable[[int], int],
                card_B: Callable[[int], int],
                n: int) -> int:
    """sum_{i+j=n} C(n,i) |A[i]| |B[j]| — the closed-form right-hand side."""
    return sum(comb(n, i) * card_A(i) * card_B(n - i) for i in range(n + 1))


# --------------------------------------------------------------------------------------
# Pretty printing
# --------------------------------------------------------------------------------------

def fmt(c: Fraction) -> str:
    return str(c.numerator) if c.denominator == 1 else f"{c.numerator}/{c.denominator}"


def show_series(name: str, coeffs: Sequence[Fraction]) -> None:
    terms = "  ".join(f"{fmt(c)}·X^{i}" for i, c in enumerate(coeffs))
    print(f"  {name} = {terms}")


def assert_eq(lhs: Sequence, rhs: Sequence, label: str) -> None:
    ok = list(lhs) == list(rhs)
    status = "OK " if ok else "FAIL"
    print(f"  [{status}] {label}")
    if not ok:
        raise AssertionError(f"{label}: {lhs} != {rhs}")


# --------------------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------------------

def demo_sum_law(n_terms: int = 7) -> None:
    print("=" * 78)
    print("1. SUM LAW (egf_add):  EGF(a + b) = EGF(a) + EGF(b)")
    print("=" * 78)
    a = [Fraction(x) for x in [1, 1, 1, 1, 1, 1, 1]]          # species of sets
    b = [Fraction(factorial(n)) for n in range(n_terms)]       # linear orders
    lhs = egf_coeffs([a[i] + b[i] for i in range(n_terms)], n_terms)
    rhs = add_series(egf_coeffs(a, n_terms), egf_coeffs(b, n_terms))
    show_series("EGF(a+b)    ", lhs)
    show_series("EGF a + EGF b", rhs)
    assert_eq(lhs, rhs, "EGF(a+b) = EGF a + EGF b")
    print()


def demo_product_law(n_terms: int = 7) -> None:
    print("=" * 78)
    print("2. PRODUCT LAW (egf_mul):  EGF(a * b) = EGF(a) . EGF(b)")
    print("    where (a*b) is the binomial convolution, '.' the Cauchy product")
    print("=" * 78)
    a = [Fraction(x) for x in [1, 1, 1, 1, 1, 1, 1]]           # sets, EGF = exp
    b = [Fraction(factorial(n)) for n in range(n_terms)]        # linear orders, EGF = 1/(1-X)
    lhs = egf_coeffs(bin_conv(a, b, n_terms), n_terms)
    rhs = cauchy_product(egf_coeffs(a, n_terms), egf_coeffs(b, n_terms), n_terms)
    show_series("EGF(a*b)   ", lhs)
    show_series("EGF a . EGF b", rhs)
    assert_eq(lhs, rhs, "EGF(binConv a b) = EGF a * EGF b")
    print()


def demo_sets_is_exp(n_terms: int = 8) -> None:
    print("=" * 78)
    print("3. SPECIES OF SETS (egf_const_one / EGF_setSpecies):  EGF = exp")
    print("=" * 78)
    a = [Fraction(1) for _ in range(n_terms)]
    lhs = egf_coeffs(a, n_terms)
    exp_coeffs = [Fraction(1, factorial(n)) for n in range(n_terms)]
    show_series("EGF(1,1,1,...)", lhs)
    show_series("exp coeffs    ", exp_coeffs)
    assert_eq(lhs, exp_coeffs, "EGF of species of sets = exp")
    print()


def demo_linear_orders_geometric(n_terms: int = 8) -> None:
    print("=" * 78)
    print("4. SPECIES OF LINEAR ORDERS (egf_linearOrderSpecies):  (1-X).EGF = 1")
    print("=" * 78)
    a = [Fraction(factorial(n)) for n in range(n_terms)]
    egf = egf_coeffs(a, n_terms)                                # should be 1,1,1,...
    show_series("EGF(0!,1!,2!,...)", egf)
    # multiply by (1 - X):  (1 - X) * sum c_n X^n  has coeff_0 = c_0, coeff_n = c_n - c_{n-1}
    prod = [egf[0]] + [egf[n] - egf[n - 1] for n in range(1, n_terms)]
    show_series("(1-X) . EGF      ", prod)
    expected = [Fraction(1)] + [Fraction(0)] * (n_terms - 1)
    assert_eq(prod, expected, "(1 - X) * EGF(linear orders) = 1")
    print()


def demo_structural_product(n_max: int = 6) -> None:
    print("=" * 78)
    print("5. STRUCTURAL PRODUCT (card_prodSpecies):")
    print("    |(A.B)[n]| (brute-force over subsets)  ==  binomial convolution")
    print("=" * 78)
    # A = species of sets (|A[k]| = 1), B = species of linear orders (|B[k]| = k!)
    card_A = lambda k: 1
    card_B = lambda k: factorial(k)
    print("    A = sets (1 each),  B = linear orders (k! each)")
    print(f"    {'n':>2} | {'brute-force':>12} | {'binom-conv':>12}")
    print("    " + "-" * 34)
    for n in range(n_max + 1):
        lhs = card_prod_species(card_A, card_B, n)
        rhs = binconv_int(card_A, card_B, n)
        flag = "OK" if lhs == rhs else "FAIL"
        print(f"    {n:>2} | {lhs:>12} | {rhs:>12}  [{flag}]")
        assert lhs == rhs
    print()


def demo_bridge(n_terms: int = 7) -> None:
    print("=" * 78)
    print("6. THE FULL BRIDGE (egf_card_prodSpecies):")
    print("    EGF of the structural product A.B  =  EGF(A) . EGF(B)")
    print("=" * 78)
    card_A = lambda k: 1               # sets   -> exp
    card_B = lambda k: factorial(k)    # orders -> 1/(1-X)
    prod_counts = [Fraction(card_prod_species(card_A, card_B, n)) for n in range(n_terms)]
    lhs = egf_coeffs(prod_counts, n_terms)
    rhs = cauchy_product(
        egf_coeffs([Fraction(card_A(n)) for n in range(n_terms)], n_terms),
        egf_coeffs([Fraction(card_B(n)) for n in range(n_terms)], n_terms),
        n_terms,
    )
    show_series("EGF(A.B)   ", lhs)
    show_series("EGF A . EGF B", rhs)
    assert_eq(lhs, rhs, "EGF(structural product) = EGF A * EGF B")
    # Bonus: exp * 1/(1-X) has known coefficients  sum_{k<=n} 1/k!  (truncated e-partial sums)
    print("\n    Sanity: [X^n] (exp / (1-X)) = sum_{k=0}^{n} 1/k!  (partial sums of e):")
    for n in range(n_terms):
        partial = sum(Fraction(1, factorial(k)) for k in range(n + 1))
        assert lhs[n] == partial
        print(f"      n={n}:  {fmt(lhs[n]):>10}  ~  {float(lhs[n]):.6f}")
    print()


def main() -> None:
    print("\nCOMBINATORIAL SPECIES  <->  EXPONENTIAL GENERATING FUNCTIONS")
    print("Numerical verification of the formalized bridge theorems.\n")
    demo_sum_law()
    demo_product_law()
    demo_sets_is_exp()
    demo_linear_orders_geometric()
    demo_structural_product()
    demo_bridge()
    print("All demonstrations passed.\n")


if __name__ == "__main__":
    main()
